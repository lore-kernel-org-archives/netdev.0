From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/4] [RFC] virtio-net: Improve small packet performance
Date: Wed, 4 May 2011 20:29:44 +0530
Message-ID: <OFAEA8C363.C13C507B-ON65257886.0051F71F-65257886.0052217F@in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com> <20110504144622.GA15823@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110504144622.GA15823@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/04/2011 08:16:22 PM:

> > A. virtio:
> >    - Provide a API to get available number of slots.
> >
> > B. virtio-net:
> >    - Remove stop/start txq's and associated callback.
> >    - Pre-calculate the number of slots needed to transmit
> >      the skb in xmit_skb and bail out early if enough space
> >      is not available. My testing shows that 2.5-3% of
> >      packets are benefited by using this API.
> >    - Do not drop skbs but instead return TX_BUSY like other
> >      drivers.
> >    - When returning EBUSY, set a per-txq variable to indicate
> >      to dev_queue_xmit() whether to restart xmits on this txq.
> >
> > C. net/sched/sch_generic.c:
> >    Since virtio-net now returns EBUSY, the skb is requeued to
> >    gso_skb. This allows adding the addional check for restart
> >    xmits in just the slow-path (the first re-queued packet
> >    case of dequeue_skb, where it checks for gso_skb) before
> >    deciding whether to call the driver or not.
> >
> > Patch was also tested between two servers with Emulex OneConnect
> > 10G cards to confirm there is no regression. Though the patch is
> > an attempt to improve only small packet performance, there was
> > improvement for 1K, 2K and also 16K both in BW and SD. Results
> > from Guest -> Remote Host (BW in Mbps) for 1K and 16K I/O sizes:
> >
> > ________________________________________________________
> >          I/O Size: 1K
> > #   BW1   BW2 (%)      SD1   SD2 (%)
> > ________________________________________________________
> > 1   1226   3313 (170.2)   6.6   1.9 (-71.2)
> > 2   3223   7705 (139.0)   18.0   7.1 (-60.5)
> > 4   7223   8716 (20.6)   36.5   29.7 (-18.6)
> > 8   8689   8693 (0)   131.5   123.0 (-6.4)
> > 16   8059   8285 (2.8)   578.3   506.2 (-12.4)
> > 32   7758   7955 (2.5)   2281.4   2244.2 (-1.6)
> > 64   7503   7895 (5.2)   9734.0   9424.4 (-3.1)
> > 96   7496   7751 (3.4)   21980.9   20169.3 (-8.2)
> > 128   7389   7741 (4.7)   40467.5   34995.5 (-13.5)
> > ________________________________________________________
> > Summary:   BW: 16.2%   SD: -10.2%
> >
> > ________________________________________________________
> >          I/O Size: 16K
> > #   BW1   BW2 (%)      SD1   SD2 (%)
> > ________________________________________________________
> > 1   6684   7019 (5.0)   1.1   1.1 (0)
> > 2   7674   7196 (-6.2)   5.0   4.8 (-4.0)
> > 4   7358   8032 (9.1)   21.3   20.4 (-4.2)
> > 8   7393   8015 (8.4)   82.7   82.0 (-.8)
> > 16   7958   8366 (5.1)   283.2   310.7 (9.7)
> > 32   7792   8113 (4.1)   1257.5   1363.0 (8.3)
> > 64   7673   8040 (4.7)   5723.1   5812.4 (1.5)
> > 96   7462   7883 (5.6)   12731.8   12119.8 (-4.8)
> > 128   7338   7800 (6.2)   21331.7   21094.7 (-1.1)
> > ________________________________________________________
> > Summary:   BW: 4.6%   SD: -1.5%
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> > ---
>
> So IIUC, we delay transmit by an arbitrary value and hope
> that the host is done with the packets by then?

Not "hope" exactly. If the device is not ready, then
the packet is requeued. The main idea is to avoid
drops/stop/starts, etc.

> Interesting.
>
> I am currently testing an approach where
> we tell the host explicitly to interrupt us only after
> a large part of the queue is empty.
> With 256 entries in a queue, we should get 1 interrupt per
> on the order of 100 packets which does not seem like a lot.
>
> I can post it, mind testing this?

Sure.

- KK

