From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 8 Sep 2010 14:53:03 +0530
Message-ID: <OFB2808A12.59A863DC-ON65257798.002E987B-65257798.0033564B@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908081011.GC23051@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au, rick.jones2@hp.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20100908081011.GC23051@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 09/08/2010 01:40:11 PM:

>
_______________________________________________________________________________

> >                            TCP (#numtxqs=2)
> > N#      BW1     BW2    (%)      SD1     SD2    (%)      RSD1    RSD2
(%)
> >
>
_______________________________________________________________________________

> > 4       26387   40716 (54.30)   20      28   (40.00)    86i     85
(-1.16)
> > 8       24356   41843 (71.79)   88      129  (46.59)    372     362
(-2.68)
> > 16      23587   40546 (71.89)   375     564  (50.40)    1558    1519
(-2.50)
> > 32      22927   39490 (72.24)   1617    2171 (34.26)    6694    5722
(-14.52)
> > 48      23067   39238 (70.10)   3931    5170 (31.51)    15823   13552
(-14.35)
> > 64      22927   38750 (69.01)   7142    9914 (38.81)    28972   26173
(-9.66)
> > 96      22568   38520 (70.68)   16258   27844 (71.26)   65944   73031
(10.74)
>
> That's a significant hit in TCP SD. Is it caused by the imbalance between
> number of queues for TX and RX? Since you mention RX is complete,
> maybe measure with a balanced TX/RX?

Yes, I am not sure why it is so high. I found the same with #RX=#TX
too. As a hack, I tried ixgbe without MQ (set "indices=1" before
calling alloc_etherdev_mq, not sure if that is entirely correct) -
here too SD worsened by around 40%. I can't explain it, since the
virtio-net driver runs lock free once sch_direct_xmit gets
HARD_TX_LOCK for the specific txq. Maybe the SD calculation is not strictly
correct since
more threads are now running parallel and load is higher? Eg, if you
compare SD between
#netperfs = 8 vs 16 for original code (cut-n-paste relevant columns
only) ...

N#         BW        SD
8           24356   88
16         23587   375

... SD has increased more than 4 times for the same BW.

> What happens with a single netperf?
> host -> guest performance with TCP and small packet speed
> are also worth measuring.

OK, I will do this and send the results later today.

> At some level, host/guest communication is easy in that we don't really
> care which queue is used.  I would like to give some thought (and
> testing) to how is this going to work with a real NIC card and packet
> steering at the backend.
> Any idea?

I have done a little testing with guest -> remote server both
using a bridge and with macvtap (mq is required only for rx).
I didn't understand what you mean by packet steering though,
is it whether packets go out of the NIC on different queues?
If so, I verified that is the case by putting a counter and
displaying through /debug interface on the host. dev_queue_xmit
on the host handles it by calling dev_pick_tx().

> > Guest interrupts for a 4 TXQ device after a 5 min test:
> > # egrep "virtio0|CPU" /proc/interrupts
> >       CPU0     CPU1     CPU2    CPU3
> > 40:   0        0        0       0        PCI-MSI-edge  virtio0-config
> > 41:   126955   126912   126505  126940   PCI-MSI-edge  virtio0-input
> > 42:   108583   107787   107853  107716   PCI-MSI-edge  virtio0-output.0
> > 43:   300278   297653   299378  300554   PCI-MSI-edge  virtio0-output.1
> > 44:   372607   374884   371092  372011   PCI-MSI-edge  virtio0-output.2
> > 45:   162042   162261   163623  162923   PCI-MSI-edge  virtio0-output.3
>
> Does this mean each interrupt is constantly bouncing between CPUs?

Yes. I didn't do *any* tuning for the tests. The only "tuning"
was to use 64K IO size with netperf. When I ran default netperf
(16K), I got a little lesser improvement in BW and worse(!) SD
than with 64K.

Thanks,

- KK

