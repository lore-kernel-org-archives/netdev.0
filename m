From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [v2 RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 6 Oct 2010 23:13:31 +0530
Message-ID: <OF806283F6.38268772-ON652577B4.005E805A-652577B4.00611B1C@in.ibm.com>
References: <20100917100307.21276.79185.sendpatchset@krkumar2.in.ibm.com> <20100919124443.GJ7350@redhat.com> <OF13594229.1A55A20C-ON652577B3.00393C8D-652577B3.003A54C9@in.ibm.com> <20101005182323.GA25852@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20101005182323.GA25852@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 10/05/2010 11:53:23 PM:

> > > Any idea where does this come from?
> > > Do you see more TX interrupts? RX interrupts? Exits?
> > > Do interrupts bounce more between guest CPUs?
> > > 4. Identify reasons for single netperf BW regression.
> >
> > After testing various combinations of #txqs, #vhosts, #netperf
> > sessions, I think the drop for 1 stream is due to TX and RX for
> > a flow being processed on different cpus.
>
> Right. Can we fix it?

I am not sure how to. My initial patch had one thread but gave
small gains and ran into limitations once number of sessions
became large.

> >  I did two more tests:
> >     1. Pin vhosts to same CPU:
> >         - BW drop is much lower for 1 stream case (- 5 to -8% range)
> >         - But performance is not so high for more sessions.
> >     2. Changed vhost to be single threaded:
> >           - No degradation for 1 session, and improvement for upto
> >          8, sometimes 16 streams (5-12%).
> >           - BW degrades after that, all the way till 128 netperf
sessions.
> >           - But overall CPU utilization improves.
> >             Summary of the entire run (for 1-128 sessions):
> >                 txq=4:  BW: (-2.3)      CPU: (-16.5)    RCPU: (-5.3)
> >                 txq=16: BW: (-1.9)      CPU: (-24.9)    RCPU: (-9.6)
> >
> > I don't see any reasons mentioned above.  However, for higher
> > number of netperf sessions, I see a big increase in retransmissions:
>
> Hmm, ok, and do you see any errors?

I haven't seen any in any statistics, messages, etc. Also no
retranmissions for txq=1.

> > Single netperf case didn't have any retransmissions so that is not
> > the cause for drop.  I tested ixgbe (MQ):
> > ___________________________________________________________
> > #netperf      ixgbe             ixgbe (pin intrs to cpu#0 on
> >                                        both server/client)
> >             BW (#retr)          BW (#retr)
> > ___________________________________________________________
> > 1           3567 (117)          6000 (251)
> > 2           4406 (477)          6298 (725)
> > 4           6119 (1085)         7208 (3387)
> > 8           6595 (4276)         7381 (15296)
> > 16          6651 (11651)        6856 (30394)
>
> Interesting.
> You are saying we get much more retransmissions with physical nic as
> well?

Yes, with ixgbe. I re-ran with 16 netperfs running for 15 secs on
both ixgbe and cxgb3 just now to reconfirm:

ixgbe: BW: 6186.85  SD/Remote: 135.711, 339.376  CPU/Remote: 79.99, 200.00,
Retrans: 545
cxgb3: BW: 8051.07  SD/Remote: 144.416, 260.487  CPU/Remote: 110.88,
200.00, Retrans: 0

However 64 netperfs for 30 secs gave:

ixgbe: BW: 6691.12  SD/Remote: 8046.617, 5259.992  CPU/Remote: 1223.86,
799.97, Retrans: 1424
cxgb3: BW: 7799.16  SD/Remote: 2589.875, 4317.013  CPU/Remote: 480.39
800.64, Retrans: 649

# ethtool -i eth4
driver: ixgbe
version: 2.0.84-k2
firmware-version: 0.9-3
bus-info: 0000:1f:00.1

# ifconfig output:
       RX packets:783241 errors:0 dropped:0 overruns:0 frame:0
       TX packets:689533 errors:0 dropped:0 overruns:0 carrier:0
       collisions:0 txqueuelen:1000

# lspci output:
1f:00.0 Ethernet controller: Intel Corporation 82599EB 10-Gigabit Network
Connec
tion (rev 01)
        Subsystem: Intel Corporation Ethernet Server Adapter X520-2
        Flags: bus master, fast devsel, latency 0, IRQ 30
        Memory at 98900000 (64-bit, prefetchable) [size=512K]
        I/O ports at 2020 [size=32]
        Memory at 98a00000 (64-bit, prefetchable) [size=16K]
        Capabilities: [40] Power Management version 3
        Capabilities: [50] MSI: Enable- Count=1/1 Maskable+ 64bit+
        Capabilities: [70] MSI-X: Enable+ Count=64 Masked-
        Capabilities: [a0] Express Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Device Serial Number 00-1b-21-ff-ff-40-4a-b4
        Capabilities: [150] Alternative Routing-ID Interpretation (ARI)
        Capabilities: [160] Single Root I/O Virtualization (SR-IOV)
        Kernel driver in use: ixgbe
        Kernel modules: ixgbe

> > I haven't done this right now since I don't have a setup.  I guess
> > it would be limited by wire speed and gains may not be there.  I
> > will try to do this later when I get the setup.
>
> OK but at least need to check that it does not hurt things.

Yes, sure.

> > Summary:
> >
> > 1. Average BW increase for regular I/O is best for #txq=16 with the
> >    least CPU utilization increase.
> > 2. The average BW for 512 byte I/O is best for lower #txq=2. For higher
> >    #txqs, BW increased only after a particular #netperf sessions - in
> >    my testing that limit was 32 netperf sessions.
> > 3. Multiple txq for guest by itself doesn't seem to have any issues.
> >    Guest CPU% increase is slightly higher than BW improvement.  I
> >    think it is true for all mq drivers since more paths run in parallel
> >    upto the device instead of sleeping and allowing one thread to send
> >    all packets via qdisc_restart.
> > 4. Having high number of txqs gives better gains and reduces cpu util
> >    on the guest and the host.
> > 5. MQ is intended for server loads.  MQ should probably not be
explicitly
> >    specified for client systems.
> > 6. No regression with numtxqs=1 (or if mq option is not used) in any
> >    testing scenario.
>
> Of course txq=1 can be considered a kind of fix, but if we know the
> issue is TX/RX flows getting bounced between CPUs, can we fix this?
> Workload-specific optimizations can only get us this far.

I will test with your patch tomorrow night once I am back.

Thanks,

- KK

