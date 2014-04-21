From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 06/11] tipc: use RCU to protect
	media_ptr pointer
Date: Mon, 21 Apr 2014 10:55:47 +0800
Message-ID: <1398048952-7825-7-git-send-email-ying.xue@windriver.com>
References: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Now the media_ptr pointer is protected with tipc_net_lock write lock
on write side; tipc_net_lock read lock is used to read side. As the
part of effort of eliminating tipc_net_lock, we decide to adjust the
locking policy of media_ptr pointer protection: on write side, RTNL
lock is use while on read side RCU read lock is applied.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bearer.c |   13 ++++++++++---
 net/tipc/bearer.h |    2 +-
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index e0625e9..c24a351 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -458,7 +458,7 @@ int tipc_enable_l2_media(struct tipc_bearer *b)
 		return -ENODEV;
 
 	/* Associate TIPC bearer with Ethernet bearer */
-	b->media_ptr = dev;
+	rcu_assign_pointer(b->media_ptr, dev);
 	memset(b->bcast_addr.value, 0, sizeof(b->bcast_addr.value));
 	memcpy(b->bcast_addr.value, dev->broadcast, b->media->hwaddr_len);
 	b->bcast_addr.media_id = b->media->type_id;
@@ -477,7 +477,10 @@ int tipc_enable_l2_media(struct tipc_bearer *b)
  */
 void tipc_disable_l2_media(struct tipc_bearer *b)
 {
-	struct net_device *dev = (struct net_device *)b->media_ptr;
+	struct net_device *dev;
+
+	dev = (struct net_device *)rtnl_dereference(b->media_ptr);
+	RCU_INIT_POINTER(b->media_ptr, NULL);
 	RCU_INIT_POINTER(dev->tipc_ptr, NULL);
 	dev_put(dev);
 }
@@ -492,8 +495,12 @@ int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
 		     struct tipc_media_addr *dest)
 {
 	struct sk_buff *clone;
+	struct net_device *dev;
 	int delta;
-	struct net_device *dev = (struct net_device *)b->media_ptr;
+
+	dev = (struct net_device *)rcu_dereference_rtnl(b->media_ptr);
+	if (!dev)
+		return 0;
 
 	clone = skb_clone(buf, GFP_ATOMIC);
 	if (!clone)
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 2fa86bd..a983b30 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -128,7 +128,7 @@ struct tipc_media {
  * care of initializing all other fields.
  */
 struct tipc_bearer {
-	void *media_ptr;			/* initalized by media */
+	void __rcu *media_ptr;			/* initalized by media */
 	u32 mtu;				/* initalized by media */
 	struct tipc_media_addr addr;		/* initalized by media */
 	char name[TIPC_MAX_BEARER_NAME];
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
