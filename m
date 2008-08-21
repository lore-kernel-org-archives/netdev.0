From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 10:01:55 +0000
Message-ID: <20080821100155.GA3621@ff.dom.local>
References: <20080819072316.GA4878@gondor.apana.org.au> <20080819073558.GD4376@ff.dom.local> <20080819074606.GA5261@gondor.apana.org.au> <20080819075623.GE4376@ff.dom.local> <20080819080557.GA17977@gondor.apana.org.au> <20080819081713.GF4376@ff.dom.local> <20080819082355.GA28869@gondor.apana.org.au> <20080819083909.GG4376@ff.dom.local> <20080819085504.GB29038@gondor.apana.org.au> <20080819091642.GI4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:37941 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbYHUKCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 06:02:02 -0400
Received: by nf-out-0910.google.com with SMTP id d3so431840nfc.21
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 03:02:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819091642.GI4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 09:16:42AM +0000, Jarek Poplawski wrote:
> On Tue, Aug 19, 2008 at 06:55:04PM +1000, Herbert Xu wrote:
...
> > In fact we're not really adding anything new here, the qdiscs were
> > not accessed under RCU uniformly.  If you go back in the tree prior
> > to the multi-qdisc stuff, you'll find that only dev_queue_xmit works
> > under RCU.  qdisc_restart does not and therefore deferring the
> > destruction to RCU is pointless anyway.
> > 
> > So in fact we've already been relying on the fact that by the time
> > qdisc_destroy comes about nobody on the read side (i.e., the packet
> > transmission path) should have a reference to it.
> 
> Let's not discuss using such a qdisc by others but a possibility
> that some common lists could be broken for readers from upper qdiscs.
> (They were not deactivated.) Of course, if it's done properly with
> some references before qdisc_destroy then it's all right. I'd prefer
> to check this later yet.

So, what I was most suspicious of, cls_u32, looks like safe wrt. this.
Congratulations for good estimation of this.

But how about this part in qdisc_destroy(): 
        if (qdisc->parent)
                list_del(&qdisc->list);

If we do this with child qdisc from qdisc_graft() it's without
deactivation. The rest of the tree can be dequeued in the meantime
and call qdisc_tree_decrease_qlen() (like hfsc, tbf, netem), which
uses qdisc_lookup() to access this list. We list_del() under rtnl
lock only, they lookup under sch_tree_lock(). Is it a bit unsafe
or I miss something?

Thanks,
Jarek P.
