From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/4] [RFC] virtio-net: Improve small packet performance
Date: Thu, 5 May 2011 13:33:14 +0530
Message-ID: <OF2E0182A1.3818A07E-ON65257887.00225EE8-65257887.002C000C@in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com> <20110504144622.GA15823@redhat.com> <OFAEA8C363.C13C507B-ON65257886.0051F71F-65257886.0052217F@in.ibm.com> <20110504212359.GA21446@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20110504212359.GA21446@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/05/2011 02:53:59 AM:

> > Not "hope" exactly. If the device is not ready, then
> > the packet is requeued. The main idea is to avoid
> > drops/stop/starts, etc.
>
> Yes, I see that, definitely. I guess it's a win if the
> interrupt takes at least a jiffy to arrive anyway,
> and a loss if not. Is there some reason interrupts
> might be delayed until the next jiffy?

I can explain this a bit as I have three debug counters
in start_xmit() just for this:

1. Whether the current xmit call was good, i.e. we had
   returned BUSY last time and this xmit was successful.
2. Whether the current xmit call was bad, i.e. we had
   returned BUSY last time and this xmit still failed.
3. The free capacity when we *resumed* xmits. This is
   after calling free_old_xmit_skbs where this function
   is not throttled, in effect it processes *all* the
   completed skbs. This counter is a sum:

   if (If_I_had_returned_EBUSY_last_iteration)
       free_slots += virtqueue_get_capacity();

The counters after a 30 min run of 1K,2K,16K netperf
sessions are:

Good:          1059172
Bad:           31226
Sum of slots:  47551557

(Total of Good+Bad tallies with the total number of requeues
as shown by tc:

qdisc pfifo_fast 0: root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1
1 1 1 1
 Sent 1560854473453 bytes 1075873684 pkt (dropped 718379, overlimits 0
requeues 1090398)
 backlog 0b 0p requeues 1090398
)

It shows that 2.9% of the time, the 1 jiffy was not enough
to free up space in the txq. That could also mean that we
had set xmit_restart just before jiffies changed. But the
average free capacity when we *resumed* xmits is:
Sum of slots / (Good + Bad) = 43.

So the delay of 1 jiffy helped the host clean up, on average,
just 43 entries, which is 16% of total entries. This is
intended to show that the guest is not sitting idle waiting
for the jiffy to expire.

> > > I can post it, mind testing this?
> >
> > Sure.
>
> Just posted. Would appreciate feedback.

Do I need to apply all the patches and simply test?

Thanks,

- KK

