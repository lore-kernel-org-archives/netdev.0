From: jamal <hadi@cyberus.ca>
Subject: [PATCH]xfrm: Flushing empty SAD generates false events
Date: Thu, 11 Feb 2010 04:51:27 -0500
Message-ID: <1265881887.3988.4.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-pm3YtRNEGEGftKycmwz5"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f190.google.com ([209.85.221.190]:47943 "EHLO
	mail-qy0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073Ab0BKJvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 04:51:31 -0500
Received: by qyk28 with SMTP id 28so645061qyk.25
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2010 01:51:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pm3YtRNEGEGftKycmwz5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


To see the effect make sure you have an empty SAD.
-On window1 "ip xfrm mon" 
-on window2 issue "ip xfrm state flush"
You get prompt back in window1 
and you see the flush event on window2.
With this fix, you still get prompt on window1 but no 
event on window2.

I was tempted to return -ESRCH on window1 (which would
show "RTNETLINK answers: No such process") but didnt want 
to change current behavior.

cheers,
jamal

--=-pm3YtRNEGEGftKycmwz5
Content-Disposition: attachment; filename="SAD-flush-ev"
Content-Type: text/plain; name="SAD-flush-ev"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 5f3dd4a772326166e1bcf54acc2391df00dc7ab5
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Thu Feb 11 04:41:36 2010 -0500

    xfrm: Flushing empty SAD generates false events
    
    To see the effect make sure you have an empty SAD.
    On window1 "ip xfrm mon" and on window2 issue "ip xfrm state flush"
    You get prompt back in window1 and you see the flush event on window2.
    With this fix, you still get prompt on window1 but no event on window2.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/net/key/af_key.c b/net/key/af_key.c
index 76fa6fe..0f53e60 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1751,7 +1751,7 @@ static int pfkey_flush(struct sock *sk, struct sk_buff *skb, struct sadb_msg *hd
 	audit_info.secid = 0;
 	err = xfrm_state_flush(net, proto, &audit_info);
 	if (err)
-		return err;
+		return 0;
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index b36cc34..f50ee9b 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -603,13 +603,14 @@ xfrm_state_flush_secctx_check(struct net *net, u8 proto, struct xfrm_audit *audi
 
 int xfrm_state_flush(struct net *net, u8 proto, struct xfrm_audit *audit_info)
 {
-	int i, err = 0;
+	int i, err = 0, cnt = 0;
 
 	spin_lock_bh(&xfrm_state_lock);
 	err = xfrm_state_flush_secctx_check(net, proto, audit_info);
 	if (err)
 		goto out;
 
+	err = -ESRCH;
 	for (i = 0; i <= net->xfrm.state_hmask; i++) {
 		struct hlist_node *entry;
 		struct xfrm_state *x;
@@ -626,13 +627,16 @@ restart:
 							audit_info->sessionid,
 							audit_info->secid);
 				xfrm_state_put(x);
+				if (!err)
+					cnt++;
 
 				spin_lock_bh(&xfrm_state_lock);
 				goto restart;
 			}
 		}
 	}
-	err = 0;
+	if (cnt)
+		err = 0;
 
 out:
 	spin_unlock_bh(&xfrm_state_lock);
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 943c871..7c87004 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1525,7 +1525,7 @@ static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	audit_info.secid = NETLINK_CB(skb).sid;
 	err = xfrm_state_flush(net, p->proto, &audit_info);
 	if (err)
-		return err;
+		return 0;
 	c.data.proto = p->proto;
 	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;

--=-pm3YtRNEGEGftKycmwz5--

