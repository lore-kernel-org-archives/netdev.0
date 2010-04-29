From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support for enic dynamic vnics
Date: Thu, 29 Apr 2010 17:48:38 +0200
Message-ID: <201004291748.38702.arnd@arndb.de>
References: <C7FEE68A.2CBEF%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:62288 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab0D3Ugv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 16:36:51 -0400
In-Reply-To: <C7FEE68A.2CBEF%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 29 April 2010, Scott Feldman wrote:
> On 4/29/10 5:27 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> 
> I don't believe those links are available at this time.
> 
> > Is it possible or planned to implement the same protocol in Linux so you
> > can do it with Cisco switches and cheap non-IOV NICs?
> 
> That seems very possible from a technical standpoint.  I don't think the
> port-profile netlink API we're specing out excludes that option.

Ok, good.

> >>    ip port_profile set DEVICE [ base DEVICE ] [ { pre_associate |
> >>                                                   pre_associate_rr } ]
> >>                               { name PORT-PROFILE | vsi MGR:VTID:VER }
> 
> BTW, I was meaning to ask: is there a way to role the vsi tuple and the
> flags up into a single identifier, say a string like PORT-PROFILE?  I'm
> asking because it seems awkward from an admin's perspective to know how to
> construct a vsi tuple or to know what pre_associate_rr means. I have to
> admit I didn't fully grok what pre_associate_rr means myself.  Even if there
> was a simple local database to map named port-profiles to the underlying
> {vsi tuple, flags}, that would bring us closer to a more consistent user
> interface.  Is this possible?

I think that's technically possible but may not be helpful to make the
user interface easier. Some background on pre-associate:

The purpose of this is to assist guest migration. A single VSI (i.e. guest
network adapter) may only be connected to a single switch port at any
given time. The VSI is identified by its UUID and it has a unique
MAC address.

When migrating a guest to a new hypervisor, we need to ask the switch
to associate that VSI at the destination switch port (which may or may
not be on the same different switch as the source port). This operation
may fail for a number of reasons and can take some time. Since we want
migration to alway succeed and take as little time as possible, we
do a pre-associate-with-resource-reservation before the migration and
only start the actual guest migration if that completes successfully.

After a successful pre-associate-with-resource-reservation step, we
know that the actual associate step will be both fast and successful.
After it completes, the VSI is known to be on the destination
and all traffic goes there (replacing the gratuitous ARP method we do
today).

I don't think we'd ever do a pre-associate without the
resource-reservation, but the standard defines both. In theory,
we could do a pre-associate at every switch in the data center
in order to find out if it's possible to migrate there.

If you want to have more details, please look at the draft spec at
http://www.ieee802.org/1/files/public/docs2010/bg-joint-evb-0410v1.pdf

> >> 2. Future enic for pass-thru case where base != target.  We get:
> >> 
> >>     ip port_profile set eth1 base eth0 name joes-garage ...
> >> 
> >> And
> >> 
> >>     eth0:ndi_set_port_profile(eth1, ...)
> > 
> > Is eth1 the static device and eth0 the dynamic device in this scenario
> > or the other way round?
> 
> eth0 is the static and eth1 is the dynamic.  So eth0 is the base device.
> (The PF in SR-IOV parlance).

ok.

> > Wouldn't you still require access to both devices from the host root
> > network namespace here or do you just ignore the identifier for the
> > dynamic device here?
> 
> The dynamic device is the one to apply the port-profile to (we'll, I should
> say to apply to the dynamic's devices switch port).  So we need the dynamic
> device identified.

What I mean is: how do you identify it when it belongs to someone else?
Do we always have a proxy netdev for an SR-IOV VF that is assigned to
the guest?

For the separate network namespace case, I guess we could still require
doing it before assigning the device to the guest namespace, but it's
still not ideal.

> >> Does this work?  I want to get agreement before coding up patch attempt #4.
> > 
> > Seems ok for all I can see at this point, other than the complexity
> > that results from doing two network protocols through a single netlink
> > protocol. Maybe Jens and Chris can comment some more on this.
> 
> Ok, thanks Arnd.  I'll start coding this up now, hedging that the design is
> set before hearing back from Jens/Chris.

I believe Chris is the one that was pushing most for having a single interface
for both VDP/LLDPAD and enic.
While I now understand your reasons for doing it in firmware and requiring the
kernel interface in addition to the user interface, my doubts on whether VDP
and your protocol should be part of the same interface are increasing.

While I'm convinced that you can make it work for both now, the alternative
to split the two may turn out to be cleaner. We'd still be able to do
either of the two in kernel or user space. Using iproute2 syntax to describe
this again, it would mean an interface like

   ip iov set  port-profile DEVICE [ base BASE-DEVICE ] name PORT-PROFILE
	                              [ host_uuid HOST_UUID ]
        	                      [ client_name CLIENT_NAME ]
                                      [ client_uuid CLIENT_UUID ]
   ip iov set  vsi { associate | pre-associate | pre-associate-rr } BASE-DEVICE
                                      vsi MGR:VTID:VER
                                      mac LLADDR [ vlan VID ]
                                      client_uuid CLIENT_UUID

   ip iov del  port_profile DEVICE      [ base BASE-DEVICE ]
   ip iov del  vsi          BASE-DEVICE [ mac LLADDR [ vlan VID ] ]
				        [ client_uuid CLIENT_UUID ]

   ip iov show port_profile DEVICE      [ base BASE-DEVICE ]
   ip iov show vsi          BASE-DEVICE [ mac LLADDR [ vlan VID ] ]
					[ client_uuid CLIENT_UUID ]

You would obvioulsy only implement the kernel support for the port-profile
stuff as callbacks, because no driver yet does VDP in the kernel, but we should
have a common netlink header that defines both variants.

Chris, any opinion on this interface as opposed to the combined one?
Either one should work, but splitting it seems cleaner to me.

	Arnd
