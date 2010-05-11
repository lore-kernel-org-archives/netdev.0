From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] virtif: initial interface extensions
Date: Tue, 11 May 2010 14:25:27 +0200
Message-ID: <201005111425.27366.arnd@arndb.de>
References: <C80DA4F7.2FBCF%scofeldm@cisco.com> <201005102346.38229.arnd@arndb.de> <OFFE8F5F70.5C07C656-ON8525771F.00787A71-8525771F.007FCDFC@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Scott Feldman <scofeldm@cisco.com>
To: Stefan Berger <stefanb@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:53975 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724Ab0EKMZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 08:25:31 -0400
In-Reply-To: <OFFE8F5F70.5C07C656-ON8525771F.00787A71-8525771F.007FCDFC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 May 2010, Stefan Berger wrote:
> Arnd Bergmann <arnd@arndb.de> wrote on 05/10/2010 05:46:37 PM:
> 
> > Stefan, can you just define the XML in a way that matches the netlink
> > definition? What you need is something like
> > 
> > 1. VF number (optional, signifies that 2/3 are done in firmware)
> 
> Shouldn't we be able to query that number via netlink starting with the
> macvtap device and the following the trail to the root and trying to find
> a VF number on the way?

No. If we have a macvtap device, there is no VF number. The VF number
should be known to libvirt in those cases where instead of creating a
macvtap device, it assigns a VF of an SR-IOV adapter to the guest.

> > 2. Lower-level protocol
> >   2.1. CDCP
> >      2.1.1 SVID
> >      2.1.2 SCID
> 
> Will the later on be qeueryable via netlink as well but not today???
> Vivek tells me svid is vlan, so that could be found out from the kernel.
> 
> So if we want to only support 1 and 2 for now, I'd rather skip them for 
> now.

svid is almost vlan (hence S-VLAN), but slightly different and is not
currently supported by the kernel. Again, if the implementation is done in
firmware, libvirt needs to set the same S-VLAN ID when setting up the
VF and when associating it to the switch.

When it's done in software, we need to create the device (or have
it created in advance), so you either know it or can query it as
you describe.

You don't need to support it yet in libvirt, but the definition should
be done in a way that leaves the option open to add it later.

> >      2.2.2 ...
> > 3. VDP
> >   3.1 VSI type/version/provider
> 
> as proposed on libvirt mailing list
> 
> >   3.2 UUID
> 
> we have a couple of UUIDs, which one?

This is a UUID that describes the VSI to the switch. It needs to be
unique in the migration domain. For a guest that has multiple
macvtap interfaces, you either need to have a single UUID and
put all MAC/VLAN pairs into the same netlink message with this
UUID, or have one UUID per device. 
 
> >   3.3 MAC/VLAN
> 
> MAC: available from libvirt
> VLAN: can be found out by querying for every interface for VLAN ID while 
> following the path towards the root device. 

Yes, in case of macvtap.

	Arnd
