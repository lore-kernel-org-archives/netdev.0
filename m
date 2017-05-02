From: "Raj, Ashok" <ashok.raj@intel.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Tue, 2 May 2017 12:34:25 -0700
Message-ID: <20170502193425.GA28805@araj-mobl1.jf.intel.com>
References: <cover.1493678834.git.leedom@chelsio.com>
 <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
 <20170502165329.GB26406@linux.intel.com>
 <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Casey Leedom <leedom@chelsio.com>,
        Bjorn Helgaas <helgaas@kernel.org>, leedom@gmail.com,
        Michael Werner <werner@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Arjun V <arjun@chelsio.com>,
        David Miller <davem@davemloft.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        Patrick J Cramer <patrick.j.cramer@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Ding Tianhong <dingtianhong@huawei.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        Jeff Kirsher
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:16686 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751243AbdEBTe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 15:34:26 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 02, 2017 at 11:10:22AM -0700, Alexander Duyck wrote:
> On Tue, May 2, 2017 at 9:53 AM, Raj, Ashok <ashok.raj@intel.com> wrote:
> > On Tue, May 02, 2017 at 09:39:34AM -0700, Alexander Duyck wrote:
> >> On Mon, May 1, 2017 at 4:13 PM, Casey Leedom <leedom@chelsio.com> wrote:
> >> > The new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING indicates that the Relaxed
> >> > Ordering Attribute should not be used on Transaction Layer Packets destined
> >> > for the PCIe End Node so flagged.  Initially flagged this way are Intel
> >> > E5-26xx Root Complex Ports which suffer from a Flow Control Credit
> >> > Performance Problem and AMD A1100 ARM ("SEATTLE") Root Complex Ports which
> >> > don't obey PCIe 3.0 ordering rules which can lead to Data Corruption.
> >>
> >> So this is a good first step though might I suggest one other change.
> >>
> >> We may want to add logic to the core PCIe code that clears the "Enable
> >> Relaxed Ordering" bit in the device control register for all devices
> >> hanging off of this root complex. Assuming the devices conform to the
> >> PCIe spec doing that should disable relaxed ordering in a device
> >> agnostic way that then enables us at a driver level to just enable the
> >> feature always without having to perform any checks for your flag. We
> >> could probably do that as a part of probing the PCIe interfaces
> >> hanging off of these devices.
> >
> > I suppose you don't want to turn off RO completely on the device. When
> > traffic is targetted to mmio for peer to peer reasons RO has performance
> > upside. The specific issue with these root ports indicate limitation using
> > RO for traffic targetting coherent memory.
> 
> Actually my main concern here is virtualization. If I take the PCIe
> function and direct assign it I have no way of seeing the root complex
> flag as it is now virtualized away. In the meantime the guest now has
> the ability to enable the function and sees nothing that says you
> can't enable relaxed ordering which in turn ends up potentially
> causing data corruption on the system. I want relaxed ordering
> disabled before I even consider assigning it to the guest on the
> systems where this would be an issue.
> 
> I prefer to err on the side of caution with this. Enabling Relaxed
> Ordering is technically a performance enhancement, so we function but
> not as well as we would like, while having it enabled when there are
> issues can lead to data corruption. I would weigh the risk of data
> corruption the thing to be avoided and of much higher priority than
> enabling improved performance. As such I say we should default the
> relaxed ordering attribute to off in general and look at
> "white-listing" it in for various architectures and/or chipsets that
> support/need it rather than having it enabled by default and trying to
> switch it off after the fact when we find some new issue.

I agree, after thinking about it a bit more.. even for transactions going to
p2p, i'm just reading the pcie spec and some sections aren't super clear
about completion redirect and ACS rules for p2p.

Also it appears the device control default value is 1 for enabling
Relaxed Ordering. This means we should probably save these states across
resets/FLR for e.g. To ensure perf isn't affected after a FLR.
> 
> So for example, in the case of x86 it seems like there are multiple
> root complexes that have issues, and the gains for enabling it with
> standard DMA to host memory are small. As such we may want to default
> it to off via the architecture specific PCIe code and then look at
> having "white-list" cases where we enable it for things like
> peer-to-peer accesses. In the case of SPARC we could look at
> defaulting it to on, and only "black-list" any cases where there might
> be issues since SPARC relies on this in a significant way for
> performance. In the case of ARM and other architectures it is a bit of
> a toss-up. I would say we could just default it to on for now and
> "black-list" anything that doesn't work, or we could go the other way
> like I suggested for x86. It all depends on what the ARM community
> would want to agree on for this. I would say unless it makes a
> significant difference like it does in the case of SPARC we are
> probably better off just defaulting it to off.
> 
> - Alex
