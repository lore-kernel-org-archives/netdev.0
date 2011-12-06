From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 6/11] inet_diag: Introduce new inet_diag_req header
Date: Tue, 06 Dec 2011 21:58:21 +0400
Message-ID: <4EDE57BD.1020207@parallels.com>
References: <4EDE573A.6040607@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:35171 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343Ab1LFR61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 12:58:27 -0500
In-Reply-To: <4EDE573A.6040607@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one coinsides with the sock_diag_req in the beginning and 
contains only used fields from its previous analogue.

The existing code is patched to use the _compat version of it
for now.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |   11 ++++++++++-
 net/ipv4/inet_diag.c      |   14 +++++++-------
 2 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index f7baaf6..defe8ff 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -23,7 +23,7 @@ struct inet_diag_sockid {
 
 /* Request structure */
 
-struct inet_diag_req {
+struct inet_diag_req_compat {
 	__u8	idiag_family;		/* Family of addresses. */
 	__u8	idiag_src_len;
 	__u8	idiag_dst_len;
@@ -35,6 +35,15 @@ struct inet_diag_req {
 	__u32	idiag_dbs;		/* Tables to dump (NI) */
 };
 
+struct inet_diag_req {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+	__u8	idiag_ext;
+	__u8	pad;
+	__u32	idiag_states;
+	struct inet_diag_sockid id;
+};
+
 enum {
 	INET_DIAG_REQ_NONE,
 	INET_DIAG_REQ_BYTECODE,
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index ccbe8ea..9a6a6de 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -265,7 +265,7 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 {
 	int err;
 	struct sock *sk;
-	struct inet_diag_req *req = NLMSG_DATA(nlh);
+	struct inet_diag_req_compat *req = NLMSG_DATA(nlh);
 	struct sk_buff *rep;
 	struct inet_hashinfo *hashinfo;
 	const struct inet_diag_handler *handler;
@@ -504,7 +504,7 @@ static int inet_csk_diag_dump(struct sock *sk,
 			      struct netlink_callback *cb,
 			      const struct nlattr *bc)
 {
-	struct inet_diag_req *r = NLMSG_DATA(cb->nlh);
+	struct inet_diag_req_compat *r = NLMSG_DATA(cb->nlh);
 
 	if (bc != NULL) {
 		struct inet_diag_entry entry;
@@ -541,7 +541,7 @@ static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 			       struct netlink_callback *cb,
 			       const struct nlattr *bc)
 {
-	struct inet_diag_req *r = NLMSG_DATA(cb->nlh);
+	struct inet_diag_req_compat *r = NLMSG_DATA(cb->nlh);
 
 	if (bc != NULL) {
 		struct inet_diag_entry entry;
@@ -629,7 +629,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 			       const struct nlattr *bc)
 {
 	struct inet_diag_entry entry;
-	struct inet_diag_req *r = NLMSG_DATA(cb->nlh);
+	struct inet_diag_req_compat *r = NLMSG_DATA(cb->nlh);
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct listen_sock *lopt;
 	struct inet_sock *inet = inet_sk(sk);
@@ -712,12 +712,12 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int i, num;
 	int s_i, s_num;
-	struct inet_diag_req *r = NLMSG_DATA(cb->nlh);
+	struct inet_diag_req_compat *r = NLMSG_DATA(cb->nlh);
 	const struct inet_diag_handler *handler;
 	struct inet_hashinfo *hashinfo;
 	const struct nlattr *bc = NULL;
 
-	if (nlmsg_attrlen(cb->nlh, sizeof(struct inet_diag_req)))
+	if (nlmsg_attrlen(cb->nlh, sizeof(struct inet_diag_req_compat)))
 		bc = nlmsg_find_attr(cb->nlh, sizeof(*r), INET_DIAG_REQ_BYTECODE);
 
 	handler = inet_diag_lock_handler(inet_diag_type2proto(cb->nlh->nlmsg_type));
@@ -863,7 +863,7 @@ unlock:
 
 static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	int hdrlen = sizeof(struct inet_diag_req);
+	int hdrlen = sizeof(struct inet_diag_req_compat);
 
 	if (nlh->nlmsg_type >= INET_DIAG_GETSOCK_MAX ||
 	    nlmsg_len(nlh) < hdrlen)
-- 
1.5.5.6
