From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Tue, 10 Feb 2015 00:53:44 +0000
Message-ID: <20150210005344.GA6293@casper.infradead.org>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56280 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932287AbbBJAxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 19:53:46 -0500
Content-Disposition: inline
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/15 at 06:34pm, David Ahern wrote:
> Namespaces provide excellent separation of the networking stack from =
the
> netdevices and up. The intent of VRFs is to provide an additional,
> logical separation at the L3 layer within a namespace.

What you ask for seems to be L3 micro segmentation inside netns. I
would argue that we already support this through multiple routing
tables. I would prefer improving the existing architecture to cover
your use cases: Increase the number of supported tables, extend
routing rules as needed, ...

> The VRF id of tasks defaults to 1 and is inherited parent to child. I=
t can
> be read via the file '/proc/<pid>/vrf' and can be changed anytime by =
writing
> to this file (if preferred this can be made a prctl to change the VRF=
 id).
> This allows services to be launched in a VRF context using ip, simila=
r to
> what is done for network namespaces.
>     e.g., ip vrf exec 99 /usr/sbin/sshd

I think such as classification should occur through cgroups instead
of touching PIDs directly.

> Network devices belong to a single VRF context which defaults to VRF =
1.
> They can be assigned to another VRF using IFLA_VRF attribute in link
> messages. Similarly the VRF assignment is returned in the IFLA_VRF
> attribute. The ip command has been modified to display the VRF id of =
a
> device. L2 applications like lldp are not VRF aware and still work th=
rough
> through all network devices within the namespace.

I believe that binding net_devices to VRFs is misleading and the
concept by itself is non-scalable. You do not want to create 10k
net_devices for your overlay of choice just to tie them to a
particular VRF. You want to store the VRF identifier as metadata and
have a stateless classifier included it in the VRF decision. See the
recent VXLAN-GBP work.

You could either map whatever selects the VRF to the mark or support it
natively in the routing rules classifier.

An obvious alternative is OVS. What you describe can be implemented in
a scalable matter using OVS and mark. I understand that OVS is not for
everybody but it gets a fundamental principle right: Scalability
demands for programmability.

I don=E2=80=99t think we should be adding a new single purpose metadata=
 field
to arbitrary structures for every new use case that comes up. We
should work on programmability which increases flexibility and allows
decoupling application interest from networking details.

> On RX skbs get their VRF context from the netdevice the packet is rec=
eived
> on. For TX the VRF context for an skb is taken from the socket. The
> intention is for L3/raw sockets to be able to set the VRF context for=
 a
> packet TX using cmsg (not coded in this patch set).

Specyfing L3 context in cmsg seems very broken to me. We do not want
to bind applications any closer to underlying networking infrastructure=
=2E
In fact, we should do the opposite and decouple this completely.

> The 'any' context applies to listen sockets only; connected sockets a=
re in
> a VRF context. Child sockets accepted by the daemon acquire the VRF c=
ontext
> of the network device the connection originated on.

Linux considers an address local regardless of the interface the packet
was received on.  So you would accept the packet on any interface and
then bind it to the VRF of that interface even though the route for it
might be on a different interface.

This really belongs into routing rules from my perspective which takes
mark and the cgroup context into account.
