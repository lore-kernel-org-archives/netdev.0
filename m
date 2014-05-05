From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] netdev: pktgen xmit packet through vlan interface
Date: Mon, 5 May 2014 17:12:52 +0200
Message-ID: <20140505171252.49773a5a@redhat.com>
References: <1399015092-28643-1-git-send-email-zhouzhouyi@gmail.com>
	<20140502151921.014fbeec@redhat.com>
	<5363A4E0.2000403@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Zhouyi Zhou <zhouzhouyi@gmail.com>, davem@davemloft.net,
	steffen.klassert@secunet.com, fan.du@windriver.com,
	dborkman@redhat.com, minipli@googlemail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>, brouer@redhat.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57365 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbaEEPNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 11:13:43 -0400
In-Reply-To: <5363A4E0.2000403@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 02 May 2014 07:00:00 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> On 5/2/2014 6:19 AM, Jesper Dangaard Brouer wrote:
> > On Fri,  2 May 2014 15:18:12 +0800
> > Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> >
> >> As http://www.spinics.net/lists/netdev/msg165015.html
> >> pktgen generates shared packet through vlan interface will cause
> >> oops because of duplicate entering tc queue.
> >>
> >> Try to solve this problem by means of packet clone instead of sharing.
> >
> > I really don't like adding this stuff to the fast path of pktgen.
> >
> > Why would you use pktgen on a VLAN?
> 
> Its a good way to test qdiscs. When you run pktgen over the VLAN
> you exercise the lower devices qdisc.

I do (personally) need a faster way/tool to exercise the qdisc path.
I'm currently using trafgen, but it is not fast enough for my 10G
testing.

Perhaps we could add a pktgen option, that explicitly enable
transmitting on qdisc path.  And when adding a VLAN device, auto enable
that mode?


> Although I never submitted a patch like this because I figured it
> was a corner case and we would want to keep the hotpath clean.

I'm worried about the overhead of skb_clone() on for every pktgen
pkt_dev->clone_skb counter... does it "invalidate" using the pktgen
CLONE_SKB counter (kind-of confusing pktgen uses "clone_skb" for its
counter).


> > Why don't you use the "vlan_id" feature available in pktgen, and send
> > in the lower real device?

Guess, we can use it for testing/stressing the qdisc code path.


> >> Signed-off-by: Zhouyi Zhou <yizhouzhou@ict.ac.cn>
> >> ---
> >>   net/core/pktgen.c |   20 +++++++++++++++++---
> >>   1 files changed, 17 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
[...]
> >> @@ -3347,8 +3348,18 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
> >>   		pkt_dev->last_ok = 0;
> >>   		goto unlock;
> >>   	}
> >> -	atomic_inc(&(pkt_dev->skb->users));
> >> -	ret = (*xmit)(pkt_dev->skb, odev);
> >> +
> >> +	if (pkt_dev->clone_skb && is_vlan_dev(odev)) {
> >> +		nskb = skb_clone(pkt_dev->skb, GFP_ATOMIC);
> >> +		ret = -ENOMEM;
> >> +		if (nskb)
> >> +			ret = (*xmit)(nskb, odev);
> >> +		else
> >> +			nskb = ERR_PTR(ret);
> >> +	} else {
> >> +		atomic_inc(&(pkt_dev->skb->users));
> >> +		ret = (*xmit)(pkt_dev->skb, odev);
> >> +	}


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
