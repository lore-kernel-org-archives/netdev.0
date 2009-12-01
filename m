From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Tue, 1 Dec 2009 08:43:32 +0000
Message-ID: <20091201084332.GB6408@ff.dom.local>
References: <4B0F8A5D.1040806@gmail.com> <20091128000401.GA3713@ami.dom.local> <412e6f7f0911292026w704a70b8yc3af2c2473e05d34@mail.gmail.com> <20091130111020.GA7114@ff.dom.local> <412e6f7f0911301832o53e479f0x42345065b0b1616f@mail.gmail.com> <20091201080151.GA6408@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Martin Devera <martin.devera@cdi.cz>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:33081 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbZLAInc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 03:43:32 -0500
Received: by bwz27 with SMTP id 27so3221683bwz.21
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2009 00:43:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091201080151.GA6408@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 01, 2009 at 08:01:51AM +0000, Jarek Poplawski wrote:
> On Tue, Dec 01, 2009 at 10:32:26AM +0800, Changli Gao wrote:
> > On Mon, Nov 30, 2009 at 7:10 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
...
> > > And this patch is very similar, except ->peek()/dequeue(). Additional
> > > lookups are done instead of dequeuing the first found class, which
> > > might be quite long in some cases.
> > 
> > If the quantum is set correctly, there isn't difference except of a
> > comparison. In the other case, I think some additional CPU cycles are
> > better than overflow.
> 
> No, my main point is there _is_ a difference when the quantum is set
> correctly. Just these additional lookups.

And, again, there are less invasive ways to fix such overflow, like

htb_dequeue_tree()
{
...
        if (likely(skb != NULL)) {
                cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
                if (cl->un.leaf.deficit[level] < 0) {
                        cl->un.leaf.deficit[level] += cl->quantum;

+                	if (cl->un.leaf.deficit[level] < 0)
+                        	cl->un.leaf.deficit[level] = -cl->quantum;
+				/* or other limit */

                        htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
                                          ptr[0]) + prio);
                }
                /* this used to be after charge_class but this constelation
                   gives us slightly better performance */
                if (!cl->un.leaf.q->q.qlen)
                        htb_deactivate(q, cl);
                htb_charge_class(q, cl, level, skb);
        }
        return skb;
}

or even always zeroing cl->un.leaf.deficit[level] on activation or
deactivation (it's seems unlikely one activity period is enough for
such an overflow).

Jarek P.
