From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 2/3] bridge: only expire the mdb entry when
 query is received
Date: Mon, 06 May 2013 11:24:13 +0800
Message-ID: <1367810653.6246.5.camel@cr0>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
	 <1367305819-14013-2-git-send-email-amwang@redhat.com>
	 <20130502015938.GA2237@gondor.apana.org.au> <1367553022.2415.55.camel@cr0>
	 <20130503040102.GA10898@gondor.apana.org.au> <1367564926.2415.56.camel@cr0>
	 <20130503093017.GA12471@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244Ab3EFDYh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 May 2013 23:24:37 -0400
In-Reply-To: <20130503093017.GA12471@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 17:30 +0800, Herbert Xu wrote:
> On Fri, May 03, 2013 at 03:08:46PM +0800, Cong Wang wrote:
> > On Fri, 2013-05-03 at 12:01 +0800, Herbert Xu wrote:
> > > 
> > > I think I quoted the wrong hunk in the patch, I meant the code
> > > that arms the timer should no longer be in the leave_group function
> > > unless we just sent a query ourselves (and in that case the expiration
> > > should also be adjusted accordingly).
> > 
> > Is the following patch what you meant?
> 
> Right, but also add the corresponding timers in case we send a
> group-specific query since that won't loop back to ourselves.

Ok, then something like below , it is a delta patch, the first piece
should go to patch 3/3.

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d73276b..11946a4 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1263,6 +1263,24 @@ static void br_multicast_leave_group(struct
net_bridge *br,
 			br->multicast_query_interval;
 		mod_timer(port ? &port->multicast_query_timer :
 				 &br->multicast_query_timer, time);
+
+		time = jiffies + br->multicast_last_member_count *
+				 br->multicast_last_member_interval;
+		for (p = mlock_dereference(mp->ports, br);
+		     p != NULL;
+		     p = mlock_dereference(p->next, br)) {
+			if (p->port != port)
+				continue;
+
+			if (!hlist_unhashed(&p->mglist) &&
+			    (timer_pending(&p->timer) ?
+			     time_after(p->timer.expires, time) :
+			     try_to_del_timer_sync(&p->timer) >= 0)) {
+				mod_timer(&p->timer, time);
+			}
+
+			break;
+		}
 	}
 
 	if (port && (port->flags & BR_MULTICAST_FAST_LEAVE)) {
@@ -1298,24 +1316,6 @@ static void br_multicast_leave_group(struct
net_bridge *br,
 		     try_to_del_timer_sync(&mp->timer) >= 0)) {
 			mod_timer(&mp->timer, time);
 		}
-
-		goto out;
-	}
-
-	for (p = mlock_dereference(mp->ports, br);
-	     p != NULL;
-	     p = mlock_dereference(p->next, br)) {
-		if (p->port != port)
-			continue;
-
-		if (!hlist_unhashed(&p->mglist) &&
-		    (timer_pending(&p->timer) ?
-		     time_after(p->timer.expires, time) :
-		     try_to_del_timer_sync(&p->timer) >= 0)) {
-			mod_timer(&p->timer, time);
-		}
-
-		break;
 	}
 
 out:
