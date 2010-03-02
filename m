From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked mode
 (v2)
Date: Tue, 2 Mar 2010 13:33:12 -0500
Message-ID: <20100302183312.GB22294@hmsreliant.think-freely.org>
References: <20100219194033.GA28743@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jon.maloy@ericsson.com, allan.stephens@windriver.com,
	tipc-discussion@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59817 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327Ab0CBSdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 13:33:17 -0500
Content-Disposition: inline
In-Reply-To: <20100219194033.GA28743@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, after some debate, heres version 2 of this patch.  Its a complete rewrite.
I started with the patches we'd proposed previously, then realized theres a much
easier and elegant way to handle this, which I've implemented below.

Fix TIPC to disallow sending to remote addresses prior to entering NET_MODE

user programs can oops the kernel by sending datagrams via AF_TIPC prior to
entering networked mode.  The following backtrace has been observed:

ID: 13459  TASK: ffff810014640040  CPU: 0   COMMAND: "tipc-client"
[exception RIP: tipc_node_select_next_hop+90]
RIP: ffffffff8869d3c3  RSP: ffff81002d9a5ab8  RFLAGS: 00010202
RAX: 0000000000000001  RBX: 0000000000000001  RCX: 0000000000000001
RDX: 0000000000000000  RSI: 0000000000000001  RDI: 0000000001001001
RBP: 0000000001001001   R8: 0074736575716552   R9: 0000000000000000
R10: ffff81003fbd0680  R11: 00000000000000c8  R12: 0000000000000008
R13: 0000000000000001  R14: 0000000000000001  R15: ffff810015c6ca00
ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
#4 [ffff81002d9a5ab0] tipc_node_select_next_hop at ffffffff8869d3b1
#5 [ffff81002d9a5ae0] tipc_link_send_sections_fast at ffffffff88698558
#6 [ffff81002d9a5be0] tipc_forward2port at ffffffff8869eb1d
#7 [ffff81002d9a5c10] tipc_send2port at ffffffff8869eb79
#8 [ffff81002d9a5c30] send_msg at ffffffff886a1d0b
#9 [ffff81002d9a5cb0] sock_sendmsg at ffffffff80055261
RIP: 0000003cbd8d49a3  RSP: 00007fffc84e0be8  RFLAGS: 00010206
RAX: 000000000000002c  RBX: ffffffff8005d116  RCX: 0000000000000000
RDX: 0000000000000008  RSI: 00007fffc84e0c00  RDI: 0000000000000003
RBP: 0000000000000000   R8: 00007fffc84e0c10   R9: 0000000000000010
R10: 0000000000000000  R11: 0000000000000246  R12: 0000000000000000
R13: 00007fffc84e0d10  R14: 0000000000000000  R15: 00007fffc84e0c30
ORIG_RAX: 000000000000002c  CS: 0033  SS: 002b

What happens is that, when the tipc module in inserted it enters a standalone
node mode in which communication to its own address is allowed <0.0.0> but not
to other addresses, since the appropriate data structures have not been
allocated yet (specifically the tipc_net pointer).  There is nothing stopping a
client from trying to send such a message however, and if that happens, we
attempt to dereference tipc_net.zones while the pointer is still NULL, and
explode.  The fix is pretty straightforward.  Since these oopses all arise from
the dereference of global pointers prior to their assignment to allocated
values, and since these allocations are small (about 2k total), lets convert
these pointers to static arrays of the appropriate size.  All the accesses to
these bits consider 0/NULL to be a non match when searching, so all the lookups
still work properly, and there is no longer a chance of a bad dererence
anywhere.  As a bonus, this lets us eliminate the setup/teardown routines for
those pointers, and elimnates the need to preform any locking around them to
prevent access while their being allocated/freed.

I've updated the tipc_net structure to behave this way to fix the exact reported
problem, and also fixed up the tipc_bearers and media_list arrays to fix an
obvious simmilar problem that arises from issuing tipc-config commands to
manipulate bearers/links prior to entering networked mode

I've tested this for a few hours by running the sanity tests and stress test
with the tipcutils suite, and nothing has fallen over.  There have been a few
lockdep warnings, but those were there before, and can be addressed later, as
they didn't actually result in any deadlock.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Allan Stephens <allan.stephens@windriver.com>
CC: David S. Miller <davem@davemloft.net>
CC: tipc-discussion@lists.sourceforge.net


 bearer.c |   28 ++--------------------------
 bearer.h |    2 +-
 net.c    |   25 ++++---------------------
 3 files changed, 7 insertions(+), 48 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 327011f..d1b9226 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -45,10 +45,10 @@
 
 #define MAX_ADDR_STR 32
 
-static struct media *media_list = NULL;
+static struct media media_list[MAX_MEDIA];
 static u32 media_count = 0;
 
-struct bearer *tipc_bearers = NULL;
+struct bearer tipc_bearers[MAX_BEARERS];
 
 /**
  * media_name_valid - validate media name
@@ -660,26 +660,6 @@ int tipc_disable_bearer(const char *name)
 
 
 
-int tipc_bearer_init(void)
-{
-	int res;
-
-	write_lock_bh(&tipc_net_lock);
-	tipc_bearers = kcalloc(MAX_BEARERS, sizeof(struct bearer), GFP_ATOMIC);
-	media_list = kcalloc(MAX_MEDIA, sizeof(struct media), GFP_ATOMIC);
-	if (tipc_bearers && media_list) {
-		res = 0;
-	} else {
-		kfree(tipc_bearers);
-		kfree(media_list);
-		tipc_bearers = NULL;
-		media_list = NULL;
-		res = -ENOMEM;
-	}
-	write_unlock_bh(&tipc_net_lock);
-	return res;
-}
-
 void tipc_bearer_stop(void)
 {
 	u32 i;
@@ -695,10 +675,6 @@ void tipc_bearer_stop(void)
 		if (tipc_bearers[i].active)
 			bearer_disable(tipc_bearers[i].publ.name);
 	}
-	kfree(tipc_bearers);
-	kfree(media_list);
-	tipc_bearers = NULL;
-	media_list = NULL;
 	media_count = 0;
 }
 
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index ca57348..000228e 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -114,7 +114,7 @@ struct bearer_name {
 
 struct link;
 
-extern struct bearer *tipc_bearers;
+extern struct bearer tipc_bearers[];
 
 void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a);
 struct sk_buff *tipc_media_get_names(void);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 7906608..f25b1cd 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -116,7 +116,8 @@
 */
 
 DEFINE_RWLOCK(tipc_net_lock);
-struct network tipc_net = { NULL };
+struct _zone *tipc_zones[256] = { NULL, };
+struct network tipc_net = { tipc_zones };
 
 struct tipc_node *tipc_net_select_remote_node(u32 addr, u32 ref)
 {
@@ -158,28 +159,12 @@ void tipc_net_send_external_routes(u32 dest)
 	}
 }
 
-static int net_init(void)
-{
-	memset(&tipc_net, 0, sizeof(tipc_net));
-	tipc_net.zones = kcalloc(tipc_max_zones + 1, sizeof(struct _zone *), GFP_ATOMIC);
-	if (!tipc_net.zones) {
-		return -ENOMEM;
-	}
-	return 0;
-}
-
 static void net_stop(void)
 {
 	u32 z_num;
 
-	if (!tipc_net.zones)
-		return;
-
-	for (z_num = 1; z_num <= tipc_max_zones; z_num++) {
+	for (z_num = 1; z_num <= tipc_max_zones; z_num++)
 		tipc_zone_delete(tipc_net.zones[z_num]);
-	}
-	kfree(tipc_net.zones);
-	tipc_net.zones = NULL;
 }
 
 static void net_route_named_msg(struct sk_buff *buf)
@@ -282,9 +267,7 @@ int tipc_net_start(u32 addr)
 	tipc_named_reinit();
 	tipc_port_reinit();
 
-	if ((res = tipc_bearer_init()) ||
-	    (res = net_init()) ||
-	    (res = tipc_cltr_init()) ||
+	if ((res = tipc_cltr_init()) ||
 	    (res = tipc_bclink_init())) {
 		return res;
 	}
