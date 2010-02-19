From: jamal <hadi@cyberus.ca>
Subject: [PATCH 1/3] pfkey: fix SA and SP flush sequence
Date: Fri, 19 Feb 2010 07:00:40 -0500
Message-ID: <1266580842-10608-2-git-send-email-hadi@cyberus.ca>
References: <flush-fix-xfrm>
 <1266580842-10608-1-git-send-email-hadi@cyberus.ca>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <hadi@cyberus.ca>
To: davem@davemloft.net, adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:23182 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645Ab0BSMA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:00:57 -0500
Received: by qw-out-2122.google.com with SMTP id 8so171666qwh.37
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 04:00:57 -0800 (PST)
In-Reply-To: <1266580842-10608-1-git-send-email-hadi@cyberus.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@cyberus.ca>

RFC 2367 says flushing behavior should be:
1) user space -> kernel: flush
2) kernel: flush
3) kernel -> user space: flush event to ALL listeners

This is not realistic today in the presence of selinux policies
which may reject the flush etc. So we make the sequence become:
1) user space -> kernel: flush
2) kernel: flush
3) kernel -> user space: flush response to originater from #1
4) if there were no errors then:
kernel -> user space: flush event to ALL listeners

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 net/key/af_key.c |   33 +++++++++++++++++++++++++++------
 1 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 79d2c0f..b3faede 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1712,6 +1712,23 @@ static int pfkey_register(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 	return 0;
 }
 
+static int unicast_flush_resp(struct sock *sk, struct sadb_msg *ihdr)
+{
+	struct sk_buff *skb;
+	struct sadb_msg *hdr;
+
+	skb = alloc_skb(sizeof(struct sadb_msg) + 16, GFP_ATOMIC);
+	if (!skb)
+		return -ENOBUFS;
+
+	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
+	memcpy(hdr, ihdr, sizeof(struct sadb_msg));
+	hdr->sadb_msg_errno = (uint8_t) 0;
+	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
+
+	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ONE, sk, sock_net(sk));
+}
+
 static int key_notify_sa_flush(struct km_event *c)
 {
 	struct sk_buff *skb;
@@ -1740,7 +1757,7 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 	unsigned proto;
 	struct km_event c;
 	struct xfrm_audit audit_info;
-	int err;
+	int err, err2;
 
 	proto = pfkey_satype2proto(hdr->sadb_msg_satype);
 	if (proto == 0)
@@ -1750,8 +1767,10 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 	audit_info.sessionid = audit_get_sessionid(current);
 	audit_info.secid = 0;
 	err = xfrm_state_flush(net, proto, &audit_info);
-	if (err)
-		return err;
+	err2 = unicast_flush_resp(sk, hdr);
+	if (err || err2)
+		return err ? err : err2;
+
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
@@ -2706,14 +2725,16 @@ static int pfkey_spdflush(struct sock *sk, struct sk_buff *skb, struct sadb_msg
 	struct net *net = sock_net(sk);
 	struct km_event c;
 	struct xfrm_audit audit_info;
-	int err;
+	int err, err2;
 
 	audit_info.loginuid = audit_get_loginuid(current);
 	audit_info.sessionid = audit_get_sessionid(current);
 	audit_info.secid = 0;
 	err = xfrm_policy_flush(net, XFRM_POLICY_TYPE_MAIN, &audit_info);
-	if (err)
-		return err;
+	err2 = unicast_flush_resp(sk, hdr);
+	if (err || err2)
+		return err ? err : err2;
+
 	c.data.type = XFRM_POLICY_TYPE_MAIN;
 	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;
-- 
1.6.0.4

