From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 2/5] tipc: Simplify bearer shutdown logic
Date: Thu, 14 Oct 2010 19:58:26 -0400
Message-ID: <20101014235825.GA5048@windriver.com>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
 <1286929558-2954-2-git-send-email-paul.gortmaker@windriver.com>
 <20101013143922.GC31379@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60693 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004Ab0JNX6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 19:58:42 -0400
Content-Disposition: inline
In-Reply-To: <20101013143922.GC31379@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next 2/5] tipc: Simplify bearer shutdown logic] On 13/10/2010 (Wed 10:39) Neil Horman wrote:

> On Tue, Oct 12, 2010 at 08:25:55PM -0400, Paul Gortmaker wrote:
> > From: Allan Stephens <allan.stephens@windriver.com>
> > 
> > Disable all active bearers when TIPC is shut down without having to do
> > a name-based search to locate each bearer object.
> > 
> It seems like you're doing a good deal more in this patch than just disabling
> all active bearers without doing a name search.  The description is implemented
> in the for loop of tipc_bearer_stop.  Whats the rest of it for?

It seems the original needlessly bloated out the patch size by
swapping the order of tipc_bearer_find_interface & bearer_find
in the file (now fixed) - and you are right, the locking change
wasn't properly covered in the commit log.  The extra test you'd
suggested tossing out is also now gone.

This change doesn't explicitly depend on any other changes,
so if it is now OK, the option is there for it to be applied
independently of the others that haven't been reworked yet.

Thanks,
Paul.


>From 1771ad642cb076dbeb71e3533a25cb2f07df9cd8 Mon Sep 17 00:00:00 2001
From: Allan Stephens <allan.stephens@windriver.com>
Date: Sat, 4 Sep 2010 09:29:04 -0400
Subject: [PATCH] tipc: Simplify bearer shutdown logic

Optimize processing in TIPC's bearer shutdown code, including:

1. Remove an unnecessary check to see if TIPC bearer's can exist.
2. Don't release spinlocks before calling a media-specific disabling
routine, since the routine can't sleep.
3. Make bearer_disable() operate directly on a struct bearer, instead
of needlessly taking a name and then mapping that to the struct.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |   38 +++++++++++---------------------------
 1 files changed, 11 insertions(+), 27 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 9c10c6b..fd9c06c 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -288,9 +288,6 @@ static struct bearer *bearer_find(const char *name)
 	struct bearer *b_ptr;
 	u32 i;
 
-	if (tipc_mode != TIPC_NET_MODE)
-		return NULL;
-
 	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
 		if (b_ptr->active && (!strcmp(b_ptr->publ.name, name)))
 			return b_ptr;
@@ -630,30 +627,17 @@ int tipc_block_bearer(const char *name)
  * Note: This routine assumes caller holds tipc_net_lock.
  */
 
-static int bearer_disable(const char *name)
+static int bearer_disable(struct bearer *b_ptr)
 {
-	struct bearer *b_ptr;
 	struct link *l_ptr;
 	struct link *temp_l_ptr;
 
-	b_ptr = bearer_find(name);
-	if (!b_ptr) {
-		warn("Attempt to disable unknown bearer <%s>\n", name);
-		return -EINVAL;
-	}
-
-	info("Disabling bearer <%s>\n", name);
+	info("Disabling bearer <%s>\n", b_ptr->publ.name);
 	tipc_disc_stop_link_req(b_ptr->link_req);
 	spin_lock_bh(&b_ptr->publ.lock);
 	b_ptr->link_req = NULL;
 	b_ptr->publ.blocked = 1;
-	if (b_ptr->media->disable_bearer) {
-		spin_unlock_bh(&b_ptr->publ.lock);
-		write_unlock_bh(&tipc_net_lock);
-		b_ptr->media->disable_bearer(&b_ptr->publ);
-		write_lock_bh(&tipc_net_lock);
-		spin_lock_bh(&b_ptr->publ.lock);
-	}
+	b_ptr->media->disable_bearer(&b_ptr->publ);
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
 		tipc_link_delete(l_ptr);
 	}
@@ -664,10 +648,16 @@ static int bearer_disable(const char *name)
 
 int tipc_disable_bearer(const char *name)
 {
+	struct bearer *b_ptr;
 	int res;
 
 	write_lock_bh(&tipc_net_lock);
-	res = bearer_disable(name);
+	b_ptr = bearer_find(name);
+	if (b_ptr == NULL) {
+		warn("Attempt to disable unknown bearer <%s>\n", name);
+		res = -EINVAL;
+	} else
+		res = bearer_disable(b_ptr);
 	write_unlock_bh(&tipc_net_lock);
 	return res;
 }
@@ -680,13 +670,7 @@ void tipc_bearer_stop(void)
 
 	for (i = 0; i < MAX_BEARERS; i++) {
 		if (tipc_bearers[i].active)
-			tipc_bearers[i].publ.blocked = 1;
-	}
-	for (i = 0; i < MAX_BEARERS; i++) {
-		if (tipc_bearers[i].active)
-			bearer_disable(tipc_bearers[i].publ.name);
+			bearer_disable(&tipc_bearers[i]);
 	}
 	media_count = 0;
 }
-
-
-- 
1.7.2.1

