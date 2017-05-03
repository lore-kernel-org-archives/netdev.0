From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/2] PCI: Add new PCIe Fabric End Node flag, PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Wed, 3 May 2017 09:02:12 -0700
Message-ID: <CAKgT0UdJ17DGAphuP5Y9co6ky-GBFdq2s-1nqctY_Tz_iz5__g@mail.gmail.com>
References: <cover.1493678834.git.leedom@chelsio.com> <758d0e431c732fe133e7b0e660bde5fc1beccdba.1493678834.git.leedom@chelsio.com>
 <CAKgT0UeuW88AHBX14H8xHteeG7vR0AH3apbjOeEDx_6p46x7tA@mail.gmail.com>
 <20170502165329.GB26406@linux.intel.com> <CAKgT0UcxjGCZu_QV-eF7_yWkDBbQpLpdaPqBf1gji8XXM5Cc=w@mail.gmail.com>
 <MWHPR12MB160095DF53CE981C923FE65DC8160@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Raj, Ashok" <ashok.raj@intel.com>,
        Bjorn Helgaas <helgaas@kernel.org>,
        "leedom@gmail.com" <leedom@gmail.com>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "Arjun V." <arjun@chelsio.com>,
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
        Jeff Kirsher <jeffrey.t.kir
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34984 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdECQCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 12:02:18 -0400
Received: by mail-io0-f173.google.com with SMTP id r16so188810322ioi.2
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 09:02:18 -0700 (PDT)
In-Reply-To: <MWHPR12MB160095DF53CE981C923FE65DC8160@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 2, 2017 at 9:30 PM, Casey Leedom <leedom@chelsio.com> wrote:
> | From: Alexander Duyck <alexander.duyck@gmail.com>
> | Date: Tuesday, May 2, 2017 11:10 AM
> | ...
> | So for example, in the case of x86 it seems like there are multiple
> | root complexes that have issues, and the gains for enabling it with
> | standard DMA to host memory are small. As such we may want to default
> | it to off via the architecture specific PCIe code and then look at
> | having "white-list" cases where we enable it for things like
> | peer-to-peer accesses. In the case of SPARC we could look at
> | defaulting it to on, and only "black-list" any cases where there might
> | be issues since SPARC relies on this in a significant way for
> | performance. In the case of ARM and other architectures it is a bit of
> | a toss-up. I would say we could just default it to on for now and
> | "black-list" anything that doesn't work, or we could go the other way
> | like I suggested for x86. It all depends on what the ARM community
> | would want to agree on for this. I would say unless it makes a
> | significant difference like it does in the case of SPARC we are
> | probably better off just defaulting it to off.
>
>   Sorry, I forgot to respond to this earlier when someone was rushing me out
> to a customer dinner.
>
>   I'm unaware of any other x86 Root Complex Port that has a problem with
> Relaxed Ordering other than the performance issue with the current Intel
> implementation.  Ashok tells me that Intel is in the final stages of putting
> together a technical notice on this issue but I don't know when that will
> come out.  Hopefully that will shed much more light on the cause and actual
> use of Relaxed Ordering when directed to Coherent Memory on current and past
> Intel platforms.  (Note that the performance bug seems to limit us to
> ~75-85Gb/s DMA Write speed to Coherent Host Memory.)

So my concern isn't so much about existing issues as it is about where
is the advantage in enabling it. We have had support in the Intel
hardware for enabling relaxed ordering for about 10 years. In all that
time I have yet to see an x86 platform that sees any real benefit from
enabling it for standard DMA. That is why my preference would be to
leave it disabled by default on x86 and we white list it in at some
point when hardware shows that there is a benefit to be had for
enabling it.

>   The only other Device that I currently know of which has issues with
> Relaxed Ordering TLPs directed at it, is also a Root Complex Port on the new
> AMD A1100 ARM SoC ("SEATTLE").  There we have an actual bug which could lead
> to Data Corruption.
>
>   But I don't know anything about other x86 Root Complex Ports having issues
> with this -- we've been using it ever since commit ef306b50b from December
> 2010.

So the question I would have for you then, is what benefits have you
seen from enabling it on x86? In our case we haven't seen any for
transactions that go through the root complex. If you are seeing
benefits would I be correct in assuming it is for your peer-to-peer
case or were there some x86 platforms that showed gains?

>   Also, I'm not aware of any performance data which has been gathered on the
> use of Relaxed Ordering when directed at Host Memory.  From your note, it
> sounds like it's important on SPARC architectures.  But it could conceivably
> be important on any architecture or Root Complex/Memory Controller
> implementation.  We use it to direct Ingress Packet Data to Free List
> Buffers, followed by a TLP without Relaxed Ordering directed at a Host
> Memory Message Queue.  The idea here is to give the Root Complex options on
> which DMA Memory Write TLPs to process in order to optimize data placement
> in memory.  And with the next Ethernet speed bump to 200Gb/s this may be
> even more important.

The operative term here is "may be". That is my concern. We are
leaving this enabled by default and there are known hardware that have
issues that can be pretty serious. I'm not saying we have to disable
it and keep it disabled, but I would like to see us intelligently
enable this feature so that it is enabled on the platforms that show
benefit and disabled on the ones that don't.

My biggest concern with all this is introducing regressions as drivers
like igb and ixgbe are used on a wide range of platforms beyond even
what is covered by x86 and I would prefer not to suddenly have a
deluge of bugs to sort out triggered by us enabling relaxed ordering
on platforms that historically have not had it enabled on them.

>   Basically, I'd hate to come up with a solution where we write off the use
> of Relaxed Ordering for DMA Writes to Host Memory.  I don't think you're
> suggesting that, but there are a number of x86 Root Complex implementations
> out there -- and some like the new AMD Ryzen have yet to be tested -- as
> well as other architectures.

I'm not saying that we have to write off the use of Relaxed Ordering,
what I am saying is that we should probably be more judicious about
how we go about enabling it. If a platform and/or architecture has no
benefit to enabling it what is the point in adding the possible risk?

Hopefully the AMD Ryzen platform has already been tested and doesn't
need a quirk to disable relaxed ordering. Really it shouldn't fall on
the likes of us to be testing for those kind of things.

>   And, as Ashok and I have both nothed, any solution we come up with needs
> to cope with a heterogeneous situation where, on the same PCIe Fabric, it
> may be necessesary/desireable to support Relaxed Ordering TLPs directed at
> some End Nodes but not others.
>
> Casey

It sounds like we are more or less in agreement. My only concern is
really what we default this to. On x86 I would say we could probably
default this to disabled for existing platforms since my understanding
is that relaxed ordering doesn't provide much benefit on what is out
there right now when performing DMA through the root complex. As far
as peer-to-peer I would say we should probably look at enabling the
ability to have Relaxed Ordering enabled for some channels but not
others. In those cases the hardware needs to be smart enough to allow
for you to indicate you want it disabled by default for most of your
DMA channels, and then enabled for the select channels that are
handling the peer-to-peer traffic.

- Alex
