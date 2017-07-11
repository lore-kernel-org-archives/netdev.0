From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Tue, 11 Jul 2017 13:33:15 -0700
Message-ID: <CAKgT0UfZ59Tx6D2+8xOqy=NYewJimXqpEamWm9jdDmKEREUXnw@mail.gmail.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
 <MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <MWHPR12MB160006024D920ED58126048AC8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Uc5KSJTj4A=9pSudiJ28AW0krc7FZpdW4upwY+FgpeArA@mail.gmail.com>
 <MWHPR12MB1600AECAE619EAA97E6B15D5C8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0UdqoRR8XLG1o3ygUZTqEBQ4dgNaneZ-n1OSNC1AiswO_g@mail.gmail.com> <MWHPR12MB16008EFFC5F2792880F7E80BC8A90@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ding Tianhong <dingtianhong@huawei.com>,
        "ashok.raj@intel.com" <ashok.raj@intel.com>,
        "helgaas@kernel.org" <helgaas@kernel.org>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "will.deacon@arm.com" <will.deacon@a
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <MWHPR12MB16008EFFC5F2792880F7E80BC8A90@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 10, 2017 at 5:01 PM, Casey Leedom <leedom@chelsio.com> wrote:
>
> Hey Alexander,
>
>   Okay, I understand your point regarding the "most likely scenario" being
> TLPs directed upstream to the Root Complex.  But I'd still like to make sure
> that we have an agreed upon API/methodology for doing Peer-to-Peer with
> Relaxed Ordering and no Relaxed Ordering to the Root Complex.  I don't see
> how the proposed APIs can be used in that fashion.
>
>   Right now the proposed change for cxgb4 is for it to test its own PCIe
> Capability Device Control[Relaxed Ordering Enable] in order to use that
> information to program the Chelsio Hardware to emit/not emit upstream TLPs
> with the Relaxed Ordering Attribute set.  But if we're going to have the
> mixed mode situation I describe, the PCIe Capability Device Control[Relaxed
> Ordering Enable] will have to be set which means that we'll be programming
> the Chelsio Hardware to send upstream TLPs with Relaxed Ordering Enable to
> the Root Complex which is what we were trying to avoid in the first place ...
>
>   [[ And, as I noted on Friday evening, the currect cxgb4 Driver hardwires
>      the Relaxed Ordering Enable on early dureing device probe, so that
>      would minimally need to be addressed even if we decide that we don't
>      ever want to support mixed mode Relaxed Ordering. ]]

So when you say "hardwires the Relaxed Ordering Enable" do you mean it
cannot be changed by software, or are you saying the firmware is just
setting the bit? I just want to make sure the change even works.

Really what I was trying to get at is the Relaxed Ordering Enable bit
doesn't have to stay as 0 if it is cleared due to the root complex not
supporting it. If you have a device that is smart enough to be able to
distinguish between different destinations and can change the TLPs
depending on where they are routed then the driver should feel free to
re-enable the relaxed ordering bit itself and do whatever it wants.
The idea though is that in most cases it will probably be enabled by
default since most firmwares default to that if I am not mistaken. If
we disable it, then it is up to the drivers to figure out if they need
to come up with a workaround.

>   We need some method of telling the Chelsio Driver that it should/shouldn't
> use Relaxed Ordering with TLPs directed at the Root Complex.  And the same
> is true for a Peer PCIe Device.

Well my thought for now is to take this in baby steps. Looking over
the code I might suggest that Ding just drops patch 3 and just focuses
on the first two patches for now. Patch 3 doesn't do anything from the
sounds of it since the Relaxed Ordering Enable being cleared will
cause the TLPs to already not set the relaxed ordering bit, do I have
that right?

The main thing Ding cared about is making the ixgbe driver behave more
like the cxgb4 driver in that he wanted to have us enable relaxed
ordering by default which right now we were only doing for the SPARC
platforms. As such we may want to look at changing patch 3 to instead
strip the code in ixgbe so that it is enabled to use Relaxed Ordering
by default and then let the configuration space determine if we use it
or not.

>   It may be that we should approach this from the completely opposite
> direction and instead of having quirks which identify problematic devices,
> have quirks which identify devices which would benefit from the use of
> Relaxed Ordering (if the sending device supports that).  That is, assume the
> using Relaxed Ordering shouldn't be done unless the target device says "I
> love Relaxed Ordering TLPs" ...  In such a world, an NVMe or a Graphics
> device might declare love of Relaxed Ordering and the same for a SPARC Root
> Complex (I think that was your example).

Really I think we are probably better off enabling it by default and
leaving it up to the configuration space of the end points to sort it
out. The advantage is that it will let us catch issues with platforms
that need these kind of quirks sooner since up until now we have been
avoiding enabling relaxed ordering for most devices on x86 and as we
get faster and faster buses we are going to need to start fully
supporting this sooner or later anyway.

>   By the way, the sole example of Data Corruption with Relaxed Ordering is
> the AMD A1100 ARM SoC and AMD appears to have given up on that almost as
> soon as it was released.  So what we're left with currently is a performance
> problem on modern Intel CPUs ...  (And hopefully we'll get a Technical
> Publication on that issue fairly soon.)
>
> Casey

That's also assuming there aren't any other platforms with issues
lurking out there. If something like this had been in place before
some of the modern Intel CPUs were developed perhaps they would have
caught the relaxed ordering issue soon enough to have resolved it in
the silicon.

Odds are this sets things up for how we will deal with future issues
more than current ones. I'm more a fan of just letting the drivers
configure themselves for relaxed ordering to the root complex by
default, and then if something comes up where relaxed ordering can't
be supported on the platform then we do workarounds for things like
the peer-to-peer performance you mentioned before for the NVMe
solution.

- Alex
