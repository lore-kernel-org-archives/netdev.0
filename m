From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: kernel panic removing devices from a teql queuing discipline
Date: Tue, 6 Nov 2007 13:48:55 +0300
Message-ID: <20071106104855.GA32033@2ka.mipt.ru>
References: <47261FA1.10300@redhat.com> <20071030.013341.205362893.davem@davemloft.net> <20071105200800.GA4075@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cebbert@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33727 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754779AbXKFKsj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 05:48:39 -0500
Content-Disposition: inline
In-Reply-To: <20071105200800.GA4075@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 05, 2007 at 11:08:00PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Tue, Oct 30, 2007 at 01:33:41AM -0700, David Miller (davem@davemloft.net) wrote:
> > > The panic is in __teql_resolve (which has been inlined into teql_master_xmit) in
> > > net/sched/sch_teql.c at this line:
> > > 
> > > 	if (n && n->tbl == mn->tbl &&
> > > 
> > > Specifically the dereference of n->tbl is faulting as n is not valid.
> 
> n is never valid (null), mn is garbage.

My fault, of course you are right, n is invalid because it is
dereferenced from qdisc, which was changed. That was too late in Moscow 
for conclusions...

> > > And the address looks like part of an ASCCI string...  "figt"
> > 
> > I studied sch_teql.c a bit and I suspect that the slave list
> > management in teql_destroy() and teql_qdisc_init() might be
> > suspect.
> 
> tecl_reset() is called from deactivate and qdisc is set to noop already,
> but subsequent teql_xmit does not know about it and dereference private
> data as teql qdisc and thus oopses. I will fix it tomorrow if you will
> not catch it first :)

It looks like I am.
Tested, works, fixed.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index f05ad9a..e0a44b9 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -263,6 +276,9 @@ __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *
 static __inline__ int
 teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res, struct net_device *dev)
 {
+	if (dev->qdisc == &noop_qdisc)
+		return -ENODEV;
+
 	if (dev->hard_header == NULL ||
 	    skb->dst == NULL ||
 	    skb->dst->neighbour == NULL)

-- 
	Evgeniy Polyakov
