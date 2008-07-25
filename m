From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Fri, 25 Jul 2008 11:53:55 +0000
Message-ID: <20080725115355.GD10399@ff.dom.local>
References: <20080719233506.12596.59935.stgit@fate.lan> <20080725105748.GB10399@ff.dom.local> <20080725.035712.33516738.davem@davemloft.net> <20080725113757.GC10399@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:59968 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbYGYLst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 07:48:49 -0400
Received: by ug-out-1314.google.com with SMTP id h2so675144ugf.16
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 04:48:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080725113757.GC10399@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 11:37:57AM +0000, Jarek Poplawski wrote:
> On Fri, Jul 25, 2008 at 03:57:12AM -0700, David Miller wrote:
...
> > It should be OK here, we have the root qdisc locked, so nobody
> > can remove it from the queue and if we got NET_XMIT_SUCCESS that
> > thing must not have been freed.
> > 
> > And anyways, we can't know the qdisc_pkt_len() until the enqueue
> > fucntion has been called.
> 
> OK, I see htb did this earlier with ".packets", so it looks like I'm
> wrong with this - sorry! (Anyway, it seems to unnecessarily restrict
> the way qdisc are working.)
> 
> > Even TCP depends upon that NET_XMIT_* return value having some real
> > meaning, remember the HTB bug we tracked down last week? :-)

As a matter of fact it's a good example: in your patch we have this:

+		ret = cl->un.leaf.q->enqueue(skb, cl->un.leaf.q);
+		if (ret == NET_XMIT_DROP) {
+			sch->qstats.drops++;
+			cl->qstats.drops++;
+		} else {
+			cl->bstats.packets +=
+				skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
+			cl->bstats.bytes += skb->len;

So, if something works like noop_enqueue() and returns NET_XMIT_CN
here, we're just using skb after kfree...

Jarek P.
