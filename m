From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 1/1] tipc: allocate user memory
	with GFP_KERNEL flag
Date: Fri, 13 Jan 2017 15:46:25 +0100
Message-ID: <1484318785-20749-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>, <ying.xue@windriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Until now, we allocate memory always with GFP_ATOMIC flag.
When the system is under memory pressure and a user tries to send,
the send fails due to low memory. However, the user application
can wait for free memory if we allocate it using GFP_KERNEL flag.

In this commit, we use allocate memory with GFP_KERNEL for all user
allocation.

Reported-by: Rune Torgersen <runet@innovsys.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/discover.c   |  4 ++--
 net/tipc/link.c       |  2 +-
 net/tipc/msg.c        | 16 ++++++++--------
 net/tipc/msg.h        |  2 +-
 net/tipc/name_distr.c |  2 +-
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 6b109a808d4c..02462d67d191 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -169,7 +169,7 @@ void tipc_disc_rcv(struct net *net, struct sk_buff *skb,
 
 	/* Send response, if necessary */
 	if (respond && (mtyp == DSC_REQ_MSG)) {
-		rskb = tipc_buf_acquire(MAX_H_SIZE);
+		rskb = tipc_buf_acquire(MAX_H_SIZE, GFP_ATOMIC);
 		if (!rskb)
 			return;
 		tipc_disc_init_msg(net, rskb, DSC_RESP_MSG, bearer);
@@ -278,7 +278,7 @@ int tipc_disc_create(struct net *net, struct tipc_bearer *b,
 	req = kmalloc(sizeof(*req), GFP_ATOMIC);
 	if (!req)
 		return -ENOMEM;
-	req->buf = tipc_buf_acquire(MAX_H_SIZE);
+	req->buf = tipc_buf_acquire(MAX_H_SIZE, GFP_ATOMIC);
 	if (!req->buf) {
 		kfree(req);
 		return -ENOMEM;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index b758ca8b2f79..b0f8646e0631 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1384,7 +1384,7 @@ void tipc_link_tnl_prepare(struct tipc_link *l, struct tipc_link *tnl,
 			msg_set_seqno(hdr, seqno++);
 		pktlen = msg_size(hdr);
 		msg_set_size(&tnlhdr, pktlen + INT_H_SIZE);
-		tnlskb = tipc_buf_acquire(pktlen + INT_H_SIZE);
+		tnlskb = tipc_buf_acquire(pktlen + INT_H_SIZE, GFP_ATOMIC);
 		if (!tnlskb) {
 			pr_warn("%sunable to send packet\n", link_co_err);
 			return;
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index a22be502f1bd..ab02d0742476 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -58,12 +58,12 @@ static unsigned int align(unsigned int i)
  * NOTE: Headroom is reserved to allow prepending of a data link header.
  *       There may also be unrequested tailroom present at the buffer's end.
  */
-struct sk_buff *tipc_buf_acquire(u32 size)
+struct sk_buff *tipc_buf_acquire(u32 size, gfp_t gfp)
 {
 	struct sk_buff *skb;
 	unsigned int buf_size = (BUF_HEADROOM + size + 3) & ~3u;
 
-	skb = alloc_skb_fclone(buf_size, GFP_ATOMIC);
+	skb = alloc_skb_fclone(buf_size, gfp);
 	if (skb) {
 		skb_reserve(skb, BUF_HEADROOM);
 		skb_put(skb, size);
@@ -95,7 +95,7 @@ struct sk_buff *tipc_msg_create(uint user, uint type,
 	struct tipc_msg *msg;
 	struct sk_buff *buf;
 
-	buf = tipc_buf_acquire(hdr_sz + data_sz);
+	buf = tipc_buf_acquire(hdr_sz + data_sz, GFP_ATOMIC);
 	if (unlikely(!buf))
 		return NULL;
 
@@ -261,7 +261,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 
 	/* No fragmentation needed? */
 	if (likely(msz <= pktmax)) {
-		skb = tipc_buf_acquire(msz);
+		skb = tipc_buf_acquire(msz, GFP_KERNEL);
 		if (unlikely(!skb))
 			return -ENOMEM;
 		skb_orphan(skb);
@@ -282,7 +282,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 	msg_set_importance(&pkthdr, msg_importance(mhdr));
 
 	/* Prepare first fragment */
-	skb = tipc_buf_acquire(pktmax);
+	skb = tipc_buf_acquire(pktmax, GFP_KERNEL);
 	if (!skb)
 		return -ENOMEM;
 	skb_orphan(skb);
@@ -313,7 +313,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 			pktsz = drem + INT_H_SIZE;
 		else
 			pktsz = pktmax;
-		skb = tipc_buf_acquire(pktsz);
+		skb = tipc_buf_acquire(pktsz, GFP_KERNEL);
 		if (!skb) {
 			rc = -ENOMEM;
 			goto error;
@@ -448,7 +448,7 @@ bool tipc_msg_make_bundle(struct sk_buff **skb,  struct tipc_msg *msg,
 	if (msz > (max / 2))
 		return false;
 
-	_skb = tipc_buf_acquire(max);
+	_skb = tipc_buf_acquire(max, GFP_ATOMIC);
 	if (!_skb)
 		return false;
 
@@ -496,7 +496,7 @@ bool tipc_msg_reverse(u32 own_node,  struct sk_buff **skb, int err)
 
 	/* Never return SHORT header; expand by replacing buffer if necessary */
 	if (msg_short(hdr)) {
-		*skb = tipc_buf_acquire(BASIC_H_SIZE + dlen);
+		*skb = tipc_buf_acquire(BASIC_H_SIZE + dlen, GFP_ATOMIC);
 		if (!*skb)
 			goto exit;
 		memcpy((*skb)->data + BASIC_H_SIZE, msg_data(hdr), dlen);
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 850ae0e469f5..f07b51e3f6f1 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -818,7 +818,7 @@ static inline bool msg_is_reset(struct tipc_msg *hdr)
 	return (msg_user(hdr) == LINK_PROTOCOL) && (msg_type(hdr) == RESET_MSG);
 }
 
-struct sk_buff *tipc_buf_acquire(u32 size);
+struct sk_buff *tipc_buf_acquire(u32 size, gfp_t gfp);
 bool tipc_msg_validate(struct sk_buff *skb);
 bool tipc_msg_reverse(u32 own_addr, struct sk_buff **skb, int err);
 void tipc_msg_init(u32 own_addr, struct tipc_msg *m, u32 user, u32 type,
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index c1cfd92de17a..23f8899e0f8c 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -69,7 +69,7 @@ static struct sk_buff *named_prepare_buf(struct net *net, u32 type, u32 size,
 					 u32 dest)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct sk_buff *buf = tipc_buf_acquire(INT_H_SIZE + size);
+	struct sk_buff *buf = tipc_buf_acquire(INT_H_SIZE + size, GFP_ATOMIC);
 	struct tipc_msg *msg;
 
 	if (buf != NULL) {
-- 
2.1.4


------------------------------------------------------------------------------
Developer Access Program for Intel Xeon Phi Processors
Access to Intel Xeon Phi processor-based developer platforms.
With one year of Intel Parallel Studio XE.
Training and support from Colfax.
Order your platform today. http://sdm.link/xeonphi
