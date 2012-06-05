From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: fix a race in inetpeer_gc_worker()
Date: Tue, 05 Jun 2012 14:19:12 +0200
Message-ID: <1338898752.2760.2482.camel@edumazet-glaptop>
References: <1338888507.2760.2146.camel@edumazet-glaptop>
	 <20120605115640.GC27795@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57995 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623Ab2FEMTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 08:19:17 -0400
Received: by bkcji2 with SMTP id ji2so4527529bkc.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 05:19:16 -0700 (PDT)
In-Reply-To: <20120605115640.GC27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 13:56 +0200, Steffen Klassert wrote:
> On Tue, Jun 05, 2012 at 11:28:27AM +0200, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > commit 5faa5df1fa2024 (inetpeer: Invalidate the inetpeer tree along with
> > the routing cache) added a race :
> > 
> > Before freeing an inetpeer, we must respect a RCU grace period, and make
> > sure no user will attempt to increase refcnt.
> > 
> 
> As already mentioned in the other mail. In this case, I think
> we can just delete the inetpeer once the refcount got zero.
> 

Nope, a concurrent lookup can find an entry about to be freed.

We must prevent it to increase the refcount from 0 to 1.

And we must wait a RCU grace period before freeing inetpeer.

Alternative would be the following patch :


diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index d4d61b6..6df9951 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -560,6 +560,17 @@ bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout)
 }
 EXPORT_SYMBOL(inet_peer_xrlim_allow);
 
+static void inetpeer_inval_rcu(struct rcu_head *head)
+{
+	struct inet_peer *p = container_of(head, struct inet_peer, rcu);
+
+	spin_lock(&gc_lock);
+	list_add_tail(&p->gc_list, &gc_list);
+	spin_unlock(&gc_lock);
+
+	schedule_delayed_work(&gc_work, gc_delay);
+}
+
 void inetpeer_invalidate_tree(int family)
 {
 	struct inet_peer *old, *new, *prev;
@@ -576,10 +587,7 @@ void inetpeer_invalidate_tree(int family)
 	prev = cmpxchg(&base->root, old, new);
 	if (prev == old) {
 		base->total = 0;
-		spin_lock(&gc_lock);
-		list_add_tail(&prev->gc_list, &gc_list);
-		spin_unlock(&gc_lock);
-		schedule_delayed_work(&gc_work, gc_delay);
+		call_rcu(&prev->rcu, inetpeer_inval_rcu);
 	}
 
 out:
