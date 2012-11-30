From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Fri, 30 Nov 2012 13:01:31 +0100
Message-ID: <1354276891.11754.424.camel@localhost>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au,
	David Laight <David.Laight@ACULAB.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab2K3MDV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 07:03:21 -0500
In-Reply-To: <1354227470.11754.348.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 23:17 +0100, Jesper Dangaard Brouer wrote:
> On Thu, 2012-11-29 at 12:44 -0500, David Miller wrote:
> > 
> > The only way I could see this making sense is if some "probability
> > of fulfillment" was taken into account.  
[...]

> This patch/system actually includes a "promise/probability of
> fulfillment". Let me explain.
> 
> We allow "warn" entries to complete, by allowing (new) fragments/packets
> for these entries (present in the frag queue).  While we don't allow the
> system to create new entries.  This creates the selection we interested
> in (as we must drop some packets given the arrival rate bigger than the
> processing rate).

To help reviewers understand; the implications of allowing existing frag
queue to complete/finish. 

Let me explain the memory implications:

Remember we only allow (default) 256K mem to be used, (now) per CPU for
fragments (raw memory usage skb->truesize).  

 Hint: I violate this!!! -- the embedded lynch mob is gathering support

As the existing entries in the frag queues, are still being allowed
packets through (even when the memory limit is exceeded).   In
worst-case, as DaveM explained, this can be as much as 100KBytes per
entry (for 64K fragments).

The highest number of frag queue hash entries, I have seen is 308, at
4x10G with two fragments size 2944. (This is of-cause unrealistic to get
this high with 64K frames, due to bw link limit, I would approximate is
max at 77 entries at 4x10G).

Now I'm teasing the embedded lynch mob.
Worst case memory usage:

 308 * 100KBytes = 30.8 MBytes (not per CPU, total)

Now the embedded lynch mob is banging at my door, yelling that I'm
opening a remote OOM DoS attack on their small memory boxes.
I'll calm them down, by explaining why we cannot reach this number.

The "warm" fragment code is making sure, this does not get out of hand.
An entry is considered "warn" for only one jiffie (1 HZ), which on
1000HZ systems is 1 ms (and 100HZ = 10 ms). (after-which the fragment
queue is freed)

How much data can we send in 1 ms at 10000 Mbit/s:
  10000 Mbit/s div 8bit-per-bytes * 0.001 sec = 1.25 MBytes

And having 4x10G can result in 5 MBytes (and the raw mem usage
skb->truesize is going to get it a bit higher).

Now, the embedded lynch mob is trying find a 4x 10Gbit/s embedded system
with less than 10MBytes of memory... they give up and go home.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
