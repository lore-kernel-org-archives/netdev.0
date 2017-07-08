From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v6 0/3] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Fri, 7 Jul 2017 20:37:52 -0700
Message-ID: <CAKgT0UdqoRR8XLG1o3ygUZTqEBQ4dgNaneZ-n1OSNC1AiswO_g@mail.gmail.com>
References: <1498133721-21152-1-git-send-email-dingtianhong@huawei.com>
 <MWHPR12MB160087E9E0B17F7A17609714C8AA0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <MWHPR12MB160006024D920ED58126048AC8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
 <CAKgT0Uc5KSJTj4A=9pSudiJ28AW0krc7FZpdW4upwY+FgpeArA@mail.gmail.com> <MWHPR12MB1600AECAE619EAA97E6B15D5C8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
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
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <MWHPR12MB1600AECAE619EAA97E6B15D5C8AB0@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 7, 2017 at 7:04 PM, Casey Leedom <leedom@chelsio.com> wrote:
>   Okay, thanks for the note Alexander.  I'll have to look more closely at
> the patch on Monday and try it out on one of the targeted systems to verify
> the semantics you describe.
>
>   However, that said, there is no way to tell a priori where a device will
> send TLPs.  To simply assume that all TLPs will be directed towards the Root
> Complex is a big assumption.  Only the device and the code controlling it
> know where the TLPs will be directed.  That's why there are changes required
> in the cxgb4 driver.  For instance, the code in
> drivers/net/ethernet/chelsio./cxgb4/sge.c: t4_sge_alloc_rxq() knows that
> it's allocating Free List Buffers in Host Memory and that the RX Queues that
> it's allocating in the Hardware will eventually send Ingress Data to those
> Free List Buffers.  (And similarly for the Free List Buffer Pointer Queue
> with respect to DMA Reads from the host.)  In that routine we explicitly
> configure the Hardware to use/not-use the Relaxed Ordering Attribute via the
> FW_IQ_CMD_FL0FETCHRO and FW_IQ_CMD_FL0DATARO flags.  Basically we're
> conditionally setting them based on the desirability of sending Relaxed
> Ordering TLPs to the Root Complex.  (And we would perform the same kind of
> check for an nVME application ... which brings us to ...)

The general idea with this is to keep this simple. In the vast
majority of cases the assumption is that a device will be sending data
back and forth from system memory. As such the mostly likely thing
that any given device will be interacting with is the root complex. By
making it so that we disable relaxed ordering if the root complex says
we can't support it seems like the simplest and most direct solution
to avoid the issue of us sending any requests with relaxed ordering
enabled TLPs to the root complex.

With that said what we are getting into are subtleties that end up
impacting devices that perform peer-to-peer operations and I don't
suspect that peer-to-peer is really all that common. Ideally my
thought on this is that if there is something in the setup that cannot
support relaxed ordering we should be disabling relaxed ordering and
then re-enabling it in the drivers that have special peer-to-peer
routes that they are aware of. This should help to simplify things for
cases such as a function being direct assigned as the configuration
space should be passed through to the guest with the relaxed ordering
attribute disabled, and that status will be visible to the guest. If
we just use the quirk we lose that and it becomes problematic if a
function is direct assigned on a system that doesn't support relaxed
ordering as the guest has no visibility into the host's quirks.

>   And what would be the code using these patch APIs to set up a Peer-to-Peer
> nVME-style application?  In that case we'd need the Chelsio adapter's PCIe
> Capability Device Control[Relaxed Ordering Enable] set for the nVME
> application ... and we would avoid programming the Chelsio Hardware to use
> Relaxed Ordering for TLPs directed at the Root Complex.  Thus we would be in
> a position where some TLPs being emitted by the device to Peer devices would
> have Relaxed Ordering set and some directed at the Root Complex would not.
> And the only way for that to work is if the source device's Device
> Control[Relaxed Ordering Enable] is set ...

Right. I admit this is pushing extra complexity into the driver, but
what else would you have us do?

The idea here is more of a lock-out tag-out type setup. We go in and
disable relaxed ordering on the devices if it isn't safe to send a
relaxed ordering TLP to the root complex. We then leave it up to the
driver to go through and re-enable it if the driver knows enough about
how it works and what kind of transactions it might issue. I'm not
saying we have to leave the relaxed ordering bit disabled in the
control register. I'm saying we disable it at first, and then leave it
up to the device driver to re-enable it if it needs the functionality
for something that is other than root-complex based and it knows it
can avoid sending the frames to the root complex. Ideally such a
driver would also clean up after itself if removed so that it leaves
the device in the same state it found it in.

Maybe we don't even really need patch 3/3 in this series. If disabling
the relaxed ordering bit in the configuration space already disabled
relaxed ordering for the entire device then this patch doesn't even
really do anything then right? The device takes care of it already for
us so we could probably just drop this patch as it currently stands.

If that is the case maybe we need to refocus patch 3/3 on re-enabling
relaxed ordering for that nVME specific case. That might be beyond the
scope of what Ding can handle though, and I am not familiar with the
Chelsio hardware either. So that might be something that is best left
to you as a follow-up patch.

>   Finally, setting aside my disagreements with the patch, we still have the
> code in the cxgb4 driver which explicitly turns on its own Device
> Control[Relaxed Ordering Enable] in cxgb4_main.c:
> enable_pcie_relaxed_ordering().  So the patch is something of a loop if all
> we're doing is testing our own Relaxed Ordering Enable state ...

I assume you are talking about what I am suggesting and not what is in
the actual patch.

Basically what it comes down to is sort of a loop. You would need to
add some code on your probe and remove routines to check the status of
the bits and configure them the way you want, and on remove you would
need to clean things up so that the next time a driver loads it
doesn't get confused. However you should only need this in the case
where the root complex cannot support relaxed ordering. In all other
cases you should be just running with relaxed ordering enabled for
everything.
