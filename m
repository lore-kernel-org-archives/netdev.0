From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] virtif: initial interface extensions
Date: Tue, 11 May 2010 16:22:40 +0200
Message-ID: <201005111622.40770.arnd@arndb.de>
References: <C80DA4F7.2FBCF%scofeldm@cisco.com> <201005111425.27366.arnd@arndb.de> <OF2E2B37D4.51A81D74-ON85257720.0045FA96-85257720.004C5403@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Scott Feldman <scofeldm@cisco.com>
To: Stefan Berger <stefanb@us.ibm.com>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:56004 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab0EKOWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 10:22:54 -0400
In-Reply-To: <OF2E2B37D4.51A81D74-ON85257720.0045FA96-85257720.004C5403@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 May 2010, Stefan Berger wrote:
> Arnd Bergmann <arnd@arndb.de> wrote on 05/11/2010 08:25:27 AM:
> > netdev, Scott Feldman
> > On Tuesday 11 May 2010, Stefan Berger wrote:
> > > Arnd Bergmann <arnd@arndb.de> wrote on 05/10/2010 05:46:37 PM:
> > No. If we have a macvtap device, there is no VF number. The VF number
> > should be known to libvirt in those cases where instead of creating a
> > macvtap device, it assigns a VF of an SR-IOV adapter to the guest.
> 
> The only interface type that currently supports the vsi parameters is the
> 'direct' type of interface which directly maps into macvtap. That's the 
> only one that would currently let you run the setup protocol with the
> switch. Regular tap devices created through other interface types 
> (bridge, network) do not support these parameters and hence you cannot
> run the protocol with the switch. I never tried passthrough but I 
> believe libvirt is not aware of what it is passing through nor do we
> currently support the parameters for passthrough devices.

Ok. I believe we will at least have to add the same kind of setup
to bridged devices as well, not just macvtap.

For SR-IOV with device assignment, I'm not sure. This will be more
important when adapters show up that actually support VEPA in hardware
and don't have their own switch, but even for those with an integrated
switch, it would be nice if we could use VDP correctly.

> > svid is almost vlan (hence S-VLAN), but slightly different and is not
> > currently supported by the kernel. Again, if the implementation is done  in
> > firmware, libvirt needs to set the same S-VLAN ID when setting up the
> > VF and when associating it to the switch.
> 
> The netlink messages go into the kernel and I suppose the driver should be
> able to find out what the S-VLAN ID is that it needs to use, no?

Possibly yes, but that will depend on how the firmware does this. It
may also be possible that adapters implement this similar to what enic
does, which does not expose the S-VLAN ID at all and uses the VF
number as the identifier.

Maybe we should leave out the CDCP stuff for now, until we start seeing
hardware for it.

> > This is a UUID that describes the VSI to the switch. It needs to be
> > unique in the migration domain. For a guest that has multiple
> > macvtap interfaces, you either need to have a single UUID and
> > put all MAC/VLAN pairs into the same netlink message with this
> > UUID, or have one UUID per device. 
> 
> In that case it's the instanceID as proposed in this XML here:
> 
>    <interface type='direct'>
>       <source dev='static' mode='vepa'/>
>       <model type='virtio'/>
>       <vsi managerid='12' typeid='0x123456' typeidversion='1'
>            instanceid='fa9b7fff-b0a0-4893-8e0e-beef4ff18f8f' />
>       <filterref filter='clean-traffic'/>
>    </interface>

Yes.

	Arnd
