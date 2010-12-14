From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC][net-next-2.6 PATCH 0/2] rtnetlink: New IFLA_PORT_PROTO_* attr
Date: Tue, 14 Dec 2010 16:47:38 +0100
Message-ID: <201012141647.38303.arnd@arndb.de>
References: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Christian Benvenuti <benve@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:62995 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757271Ab0LNPrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 10:47:42 -0500
In-Reply-To: <20101208042925.16856.89232.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 08 December 2010, Christian Benvenuti wrote:
> 
> In order to be able to scope a port profile, as part of the 802.1Qbh
> implementation we would like to add a new attribute: IFLA_PORT_CLUSTER_UUID.
> This parameter (perhaps known under a different name) is already in use
> (or going to be added) by most Virtual Machine Managers to define migration
> domains. In the case of 802.1Qbh a port profile would most likely be scoped
> using the same ID used by VM manager to represent the migration domain.
> 
> Adding another attribute (IFLA_PORT_CLUSTER_UUID in this case) to the list of
> IFLA_PORT_* attributes is an option.

Sounds reasonable.

> However, we thought that it would be better to 1st re-arrange the current
> Netlink attribute scheme in order to better group the IFLA_PORT_* attributes
> (for example by protocol).

We don't normally rearrange protocols once they are in an upstream
release. Having to maintain compatibility to two different versions
of the API is a huge burden for maintainance, so IMHO the only
reason why we should deprecate the current API and introduce
a new one is if it is absolutely impossible to implement necessary
features without breaking compatibility. Your explanations are
very detailed and well explained, but I have not found anything
in there that describes why it cannot be done without changing the
existing interface.

> --------------------------------------------------
> 2) REASON FOR THIS CHANGE
> --------------------------------------------------
> We would like to add one more attribute (IFLA_PORT_CLUSTER_UUID), and the list 
> of IFLA_PORT_* attributes may need to grow again due to the changes that may
> be required by the two still evolving standard protocols 802.1Qbh/802.1Qbg.
> Because of that, if you see a value in the re-organization of the
> IFLA_PORT_* attributes that we are proposing, it would be better to address
> such changes sooner than later, in order to reduce the impact of backward
> compatibility issues later.

The changes you propose now seem reasonable and we could probably have
done it that way initially, but as far as I'm concerned they are too late.
The burden imposed by the change is larger than the risk of breaking
backwards compatibility later by not fixing it now, as far as I'm concerned.

To give another example, the split between IFLA_VFINFO_LIST and
IFLA_VF_PORTS is totally arbitrary, we should have merged them at the
time, but because of timing concerns of the two going in during the
merge window, we are stuck with two separate lists of VFs now, and
I don't think we should change them any more.

> --------------------------------------------------
> 4) IFLA_* versus IFLA_PORT_*
> --------------------------------------------------
> 
> Here is an alternative way to introduce the new Netlink attribute scheme.
> We personally like better the previous scheme, but I'll include this one too
> should someone find it interesting.

The impact of doing this would be even bigger.
 
> OPTION_3: According to the new Netlink attribute scheme that we are
>           proposing, each protocol has its own set of attributes and
>           therefore it would not be considered superfluous to have the
>           same (or a similar) attribute defined for both protocols.
>           (in this case it would be manager_ID for 802.1qbg and
>           cluster_uuid for 802.1qbh).
> 
> To us OPTION_3 looks like the option that offers most flexibility.

I don't see this depending on the change to split attributes per
protocol. Just introducing a new IFLA_PORT_CLUSTER_UUID should be
all you need. Since a cluster UUID is not exactly the same concept
as a vsi manager id, there is no need to share the same netlink
attribute.

> --------------------------------------------------
> 8) OPT1: MORE CONFIGURATION FLEXIBILITY
> --------------------------------------------------
> The change described in this section is orthogonal to the ones Discussed above.
> We believe it would add value to the new scheme.
> We would like to include it as part of the new Netlink scheme (but the current
> patch does not include it).
> 
> In order to allow device drivers (or a generic consumer of the Netlink messages)
> to provide extra features or simple optimizations I would suggest the
> introduction of a new nested attribute that I will call IFLA_PORT_DATA for now.
> 
> This attribute would allow the use of extra attributes that are not part of
> the official protocol specs (802.1Qbg/bh for now) or simply allow device
> drivers to start supporting pre-standard parameters that would not be included
> in the Netlink scheme before they reach some stability.

I really don't think that you should add per-driver attributes. If we
believe that we need an extension for a specific feature in the netlink
interface, it should be defined in a way that is generic enough to work
for other hardware implementing the same feature.

> Here are a couple of examples of use.
> Let's suppose that driver ABC needed to receive a couple of parameters
> more (that are not part of the official 802.1Qbh/bg protocols).
> In this case driver ABC can use the new attribute IFLA_PORT_DATA to
> receive its two additional parameters without any need to touch/modify
> the IFLA_PORT_* list of attributes.

We can in theory add features that are not part of the official
standard. IMHO it is more important that the features are of
general interest and are being actively used. They should of
course not conflict with other features or the standard.

> If in the future driver ABC needed to change any of its private
> parameters (those it receives through the IFLA_PORT_DATA attribute), it
> can do it by updating its parsing routine (of course it would need
> to implement a basic versioning scheme for its private attributes), but
> no change would be required in the core Netlink code.

A data structure being private to a driver would not save you from
maintaining backwards compatibility, you still cannot just go and
change it as you like.

> If we do not want to add IFLA_PORT_DATA, an alternative solution would
> be that of using a separate control channel to provide that extra
> info, for example based on something like the NETLINK_GENERIC Netlink
> protocol.
> This alternative approach would offer the same flexibility, but I
> can see One drawback: this solution would require some extra code
> to synchronize the two control channels
> (generic NETLINK_ROUTE/IFLA_PORT_XXX and NETLINK_GENERIC/Driver).

Right, using generic netlink for this does not help, it has all the
problems of your IFLA_PORT_DATA suggestions and is more complex.

Just don't add driver-private interfaces, make them official!

If we give driver writers a way to add their own interfaces, there
is a very realistic risk of these interface being defined in a
broken way, with people relying on them before the code gets
submitted for mainline inclusion.

	Arnd
