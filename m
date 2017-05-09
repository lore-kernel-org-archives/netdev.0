From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Tue, 9 May 2017 00:48:05 +0000
Message-ID: <MWHPR12MB1600AC957C7E3B0DB4F06D6CC8EE0@MWHPR12MB1600.namprd12.prod.outlook.com>
References: <cover.1493678834.git.leedom@chelsio.com>
 <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
 <20170502165329.GB26406@linux.intel.com>
 <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
 <MWHPR12MB160095DF53CE981C923FE65DC8160@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UdJ17DGAphuP5Y9co6ky-GBFdq2s-1nqctY_Tz_iz5__g@mail.gmail.com>
 <MWHPR12MB1600E78DD7F530AA9DC2433DC8EA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Ucwkp+fi-9HhMbze6t_i15dj4e2WQBp13Coi6MegrDh=w@mail.gmail.com>
 <22c46382-5778-022f-d0bd-74abec9e9c7c@huawei.com>,<CAKgT0Ufg6uebqj79e1FOHoPpF-GxPYMkp353r3Ok_=nM8wF6qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "Raj, Ashok" <ashok.raj@intel.com>,
        Bjorn Helgaas <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "Arjun V." <arjun@chelsio.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        "Patrick J Cramer" <patrick.j.cramer@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Mark Rutland <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        "Catalin Marinas" <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        "Robin Murphy" <robin.mu
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0126.outbound.protection.outlook.com ([104.47.36.126]:30189
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751243AbdEIAsI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 20:48:08 -0400
In-Reply-To: <CAKgT0Ufg6uebqj79e1FOHoPpF-GxPYMkp353r3Ok_=nM8wF6qA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


| From: Alexander Duyck <alexander.duyck@gmail.com>
| Date: Saturday, May 6, 2017 11:07 AM
|=20
| | From: Ding Tianhong <dingtianhong@huawei.com>
| | Date: Fri, May 5, 2017 at 8:08 PM
| |=20
| | According the suggestion, I could only think of this code:
| | ..
|=20
| This is a bit simplistic but it is a start.

  Yes, something tells me that this is going to be more complicated than an=
y
of us like ...

| The other bit I was getting at is that we need to update the core PCIe
| code so that when we configure devices and the root complex reports no
| support for relaxed ordering it should be clearing the relaxed
| ordering bits in the PCIe configuration registers on the upstream
| facing devices.

  Of course, this can be written to by the Driver at any time ... and is in
the case of the cxgb4 Driver ...

  After a lot of rummaging around, it does look like KVM prohibits writes t=
o
the PCIe Capability Device Control register in drivers/xen/xen-pciback/
conf_space_capability.c and conf_space.c simply because writes aren't
allowed unless "permissive" is set.  So it ~looks~ like a driver running in
a Virtual Machine can't turn Enable Relaxed Ordering back on ...

| The last bit we need in all this is a way to allow for setups where
| peer-to-peer wants to perform relaxed ordering but for writes to the
| host we have to not use relaxed ordering. For that we need to enable a
| special case and that isn't handled right now in any of the solutions
| we have coded up so far.

  Yes, we do need this.


| From: Alexander Duyck <alexander.duyck@gmail.com>
| Date: Saturday, May 8, 2017 08:22 AM
|
| The problem is we need to have something that can be communicated
| through a VM. Your change doesn't work in that regard. That was why I
| suggested just updating the code so that we when we initialized PCIe
| devices what we do is either set or clear the relaxed ordering bit in
| the PCIe device control register. That way when we direct assign an
| interface it could know just based on the bits int the PCIe
| configuration if it could use relaxed ordering or not.
|=20
| At that point the driver code itself becomes very simple since you
| could just enable the relaxed ordering by default in the igb/ixgbe
| driver and if the bit is set or cleared in the PCIe configuration then
| we are either sending with relaxed ordering requests or not and don't
| have to try and locate the root complex.
|=20
| So from the sound of it Casey has a special use case where he doesn't
| want to send relaxed ordering frames to the root complex, but instead
| would like to send them to another PCIe device. To do that he needs to
| have a way to enable the relaxed ordering bit in the PCIe
| configuration but then not send any to the root complex. Odds are that
| is something he might be able to just implement in the driver, but is
| something that may become a more general case in the future. I don't
| see our change here impacting it as long as we keep the solution
| generic and mostly confined to when we instantiate the devices as the
| driver could likely make the decision to change the behavior later.

  It's not just me.  Intel has said that while RO directed at the Root
Complex Host Coherent Memory has a performance bug (not Data Corruption),
it's a performance win for Peer-to-Peer writes to MMIO Space.  (I'll be ver=
y
interested in hearing what the bug is if we get that much detail.  The very
same TLPs directed to the Root Complex Port without Relaxed Ordering set ge=
t
good performance.  So this is essentially a bug in the hardware that was
~trying~ to implement a performance win.)

  Meanwhile, I currently only know of a single PCIe End Point which causes
catastrophic results: the AMD A1100 ARM SoC ("SEATTLE").  And it's not even
clear that product is even alive anymore since I haven't been able to get
any responses from them for several months.

  What I'm saying is: let's try to architect a solution which doesn't throw
the baby out with the bath water ...

  I think that if a Device's Root Complex Port has problems with Relaxed
Ordering, it ~probably~ makes sense to turn off the PCIe Capability Device
Control[Enable Relaxed Ordering] when we assign a device to a Virtual
Machine since the Device Driver can no longer query the Relaxed Ordering
Support of the Root Complex Port.  The only down side of this would be if w=
e
assigned two Peers to a VM in an application which wanted to do Peer-to-Pee=
r
transfers.  But that seems like a hard application to support in any case
since the PCI Bus:Slot.Function IDs for assigned Devices within a VM don't
match the actual values.

  For Devices running in the base OS/Hypervisor, their Drivers can query th=
e
Relaxed Ordering Support for the Root Complex Port or a Peer Device.  So a
simple flag within the (struct pci_dev *)->dev_flags would serve for that
along with a per-Architecture/Platform mechanism for setting it ...

Casey
