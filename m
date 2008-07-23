From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] xt_hashlimit: fix race between htable_destroy and htable_gc
Date: Thu, 24 Jul 2008 01:51:23 +0400
Message-ID: <4887A7DB.4030305@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Deleting a timer with del_timer doesn't guarantee, that the
timer function is not running at the moment of deletion. Thus
in the xt_hashlimit case we can get into a ticklish situation
when the htable_gc rearms the timer back and we'll actually
delete an entry with a pending timer.

Fix it with using del_timer_sync().

AFAIK del_timer_sync checks for the timer to be pending by
itself, so I remove the check.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 6809af5..d9418a2 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -367,9 +367,7 @@ static void htable_gc(unsigned long htlong)
 
 static void htable_destroy(struct xt_hashlimit_htable *hinfo)
 {
-	/* remove timer, if it is pending */
-	if (timer_pending(&hinfo->timer))
-		del_timer(&hinfo->timer);
+	del_timer_sync(&hinfo->timer);
 
 	/* remove proc entry */
 	remove_proc_entry(hinfo->pde->name,
