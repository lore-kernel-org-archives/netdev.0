From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] virtif: initial interface extensions
Date: Tue, 11 May 2010 14:59:01 +0200
Message-ID: <201005111459.01539.arnd@arndb.de>
References: <C80DF1EC.2FFE0%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stefan Berger <stefanb@us.ibm.com>, netdev@vger.kernel.org,
	chrisw@redhat.com, davem@davemloft.net
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:54000 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756660Ab0EKM7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 08:59:37 -0400
In-Reply-To: <C80DF1EC.2FFE0%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 May 2010, Scott Feldman wrote:
> On 5/10/10 2:46 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:
>
> > Stefan, can you just define the XML in a way that matches the netlink
> > definition? What you need is something like
> > 
> > 1. VF number (optional, signifies that 2/3 are done in firmware)
> > 2. Lower-level protocol
> >   2.1. CDCP
> >      2.1.1 SVID
> >      2.1.2 SCID
> >   2.2. enic
> >      2.2.1 port profile name
> >      2.2.2 ...
> > 3. VDP
> >   3.1 VSI type/version/provider
> >   3.2 UUID
> >   3.3 MAC/VLAN
> > 
> > You need to have 2. or 3. or both, and 2.1/2.2 are mutually exclusive.
> 
> I'm don't think this is going in the right direction.  We're talking a
> pretty simple concept of a port-profile used to configure the virtual port
> backing a VM i/f to something that's trying to munge disjoint protocols
> based on pre-standard work into a single API.  It's forcing all those
> pre-standard protocol details into the API, into the XML, and into the mgmt
> software (libvirt), and into the admin's lap.

No. I agree that the port-profile concept is simple and that the complexity
comes from trying to merge the Linux interface with what we do for VDP.
It would be much more sensible IMHO to just unify port-profiles and CDCP
in the kernel interface, because they are conceptually more similar and
both rather simple (note that there is no S-VLAN implementation in Linux,
so CDCP is not there yet either).

If we layer VDP on top of the two and do it always in user space (LLDPAD
with lldptool), things are much simpler on the interface side.

The focus of VDP is to manage migration, which is something that
enic doesn't do (or doesn't need to do) and most of the complexity
in there comes from this.

> I want the API to pass a port-profile name plus other information associated
> with the VM i/f to some mgmt object which can setup the virtual port backing
> the VM i/f.  (And unset it).  Using netlink for API let's that object be in
> user- or kernel-space software, hardware or firmware.  How the object sets
> up the virtual port based on the passed port-profile is beyond the scope of
> the API.
> 
> My last port-profile patch is this API.  It gives us this:
> 
>     1) single netlink msg for kernel- and user-space

Except for the VF argument, which is kernel- only, and it doesn't work
if user space needs additional information that only the firmware has
in your case (something like a virtual channel ID).

>     2) single parameter set from sender's perspective (libvirt)
>     3) single XML representation of parameters
>     4) single code path in kernel and libvirt

>     5) (potential) cross-vendor-switch VM migration

You cannot do live migration between Cisco switches and those implementing
802.1Qbg, because of the differences between port profiles and VSI types,
e.g. how they handle VLANs or handover during migration.
Migration between 802.1Qbg capable switches is covered by the standard.

>     6) admin-friendly port-profile names

>     7) allows pre-standard (802.1Qbg/bh) details to change
>        without bogging down the API

We're basically nailing down the API right here. As soon as this is
supported in Linux, it will be the standard, so the details won't
be able to change any more.

> What I proposed on the libvirt list is to maintain a mapping database from
> port-profile to vendor-specific or protocol-specific parameters.  Using VDP
> as an example, a port-profile would resolve the VDP tuple:
> 
>      port-profile: "joes-garage"   --->  VSI Manager ID: 15
>                                          VSI Type ID: 12345
>                                          VSI Type ID Ver: 1
>                                          other VSI settings (preassociate)

I agree that the port profile name matches the VSI manager/type/version ID
to a large degree and that it would be nice to unify these, but I don't think
there is a point given all the other differences.

There is no way around the preassociate/associate/disassociate messages
being part of the API, because otherwise you cannot do seamless migration
across multiple switches. 

Also, the primary key on VDP is the VSI UUID, which needs to be the same
on the target host after migration, while in your case the switch never
identifies the guest itself, only the port profile.

If I have understood you correctly, the primary key identifying a port
on enic is something that is only visible to the switch and nic firmware,
but never to software, so you identify the guest by its VF number on the
user API.

	Arnd
