From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.19-rc4-git10][PKT_SCHED] sch_htb: INIT_HLIST_NODE
 after hlist_del()
Date: Tue, 7 Nov 2006 09:50:07 -0800
Message-ID: <20061107095007.71c11b47@freekitty>
References: <20061106113353.GA4829@ff.dom.local>
	<20061106094449.3b8253b9@freekitty>
	<20061107064943.GA998@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S\. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55504 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932722AbWKGRuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 12:50:18 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061107064943.GA998@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Nov 2006 07:49:43 +0100
Jarek Poplawski <jarkao2@o2.pl> wrote:

> On Mon, Nov 06, 2006 at 09:44:49AM -0800, Stephen Hemminger wrote:
> > On Mon, 6 Nov 2006 12:33:53 +0100
> > Jarek Poplawski <jarkao2@o2.pl> wrote:
> > 
> > > After hlist_del() next and pprev pointers are not NULL
> > > so hlist_unhashed() doesn't work properly.
> > > 
> > > 
> > > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> > > ---
> > > 
> > > 
> > > diff -Nurp linux-2.6.19-rc4-git10-/net/sched/sch_htb.c linux-2.6.19-rc4-git10/net/sched/sch_htb.c
> > > --- linux-2.6.19-rc4-git10-/net/sched/sch_htb.c	2006-11-06 11:42:41.000000000 +0100
> > > +++ linux-2.6.19-rc4-git10/net/sched/sch_htb.c	2006-11-06 11:53:15.000000000 +0100
> > > @@ -1284,8 +1284,10 @@ static void htb_destroy_class(struct Qdi
> > >  						  struct htb_class, sibling));
> > >  
> > >  	/* note: this delete may happen twice (see htb_delete) */
> > > -	if (!hlist_unhashed(&cl->hlist))
> > > +	if (!hlist_unhashed(&cl->hlist)) {
> > >  		hlist_del(&cl->hlist);
> > > +		INIT_HLIST_NODE(&cl->hlist);
> > > +	}
> > 
> > why not use hlist_del_init?

Your patch duplicated the code in hlist_del_init().  Why not do:

--- a/net/sched/sch_htb.c	2006-11-07 09:48:22.000000000 -0800
+++ b/net/sched/sch_htb.c	2006-11-07 09:49:01.000000000 -0800
@@ -1284,8 +1284,7 @@
 						  struct htb_class, sibling));
 
 	/* note: this delete may happen twice (see htb_delete) */
-	if (!hlist_unhashed(&cl->hlist))
-		hlist_del(&cl->hlist);
+	hlist_del_init(&cl->hlist);
 	list_del(&cl->sibling);
 
 	if (cl->prio_activity)
@@ -1333,8 +1332,7 @@
 	sch_tree_lock(sch);
 
 	/* delete from hash and active; remainder in destroy_class */
-	if (!hlist_unhashed(&cl->hlist))
-		hlist_del(&cl->hlist);
+	hlist_del_init(&cl->hlist);
 
 	if (cl->prio_activity)
 		htb_deactivate(q, cl);
