From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 2/3] bridge: only expire the mdb entry when
 query is received
Date: Fri, 03 May 2013 15:08:46 +0800
Message-ID: <1367564926.2415.56.camel@cr0>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
	 <1367305819-14013-2-git-send-email-amwang@redhat.com>
	 <20130502015938.GA2237@gondor.apana.org.au> <1367553022.2415.55.camel@cr0>
	 <20130503040102.GA10898@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761595Ab3ECHJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 03:09:03 -0400
In-Reply-To: <20130503040102.GA10898@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 12:01 +0800, Herbert Xu wrote:
> 
> I think I quoted the wrong hunk in the patch, I meant the code
> that arms the timer should no longer be in the leave_group function
> unless we just sent a query ourselves (and in that case the expiration
> should also be adjusted accordingly).

Is the following patch what you meant?

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d73276b..21fcc42 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1302,22 +1302,6 @@ static void br_multicast_leave_group(struct
net_bridge *br,
                goto out;
        }
 
-       for (p = mlock_dereference(mp->ports, br);
-            p != NULL;
-            p = mlock_dereference(p->next, br)) {
-               if (p->port != port)
-                       continue;
-
-               if (!hlist_unhashed(&p->mglist) &&
-                   (timer_pending(&p->timer) ?
-                    time_after(p->timer.expires, time) :
-                    try_to_del_timer_sync(&p->timer) >= 0)) {
-                       mod_timer(&p->timer, time);
-               }
-
-               break;
-       }
-
 out:
        spin_unlock(&br->multicast_lock);
 }
