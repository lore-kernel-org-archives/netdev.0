From: Pablo Neira <pablo@eurodev.net>
Subject: [PATCH 3/4] [NETLINK] make xfrm_user use netlink_check_skb
Date: Fri, 11 Feb 2005 01:14:11 +0100
Message-ID: <420BF8D3.1060000@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080805090606010004050501"
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080805090606010004050501
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The modification required to make xfrm_user.c use netlink_check_skb

--
Pablo

--------------080805090606010004050501
Content-Type: text/x-patch;
 name="02xfrm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02xfrm.patch"

===== net/xfrm/xfrm_user.c 1.52 vs edited =====
--- 1.52/net/xfrm/xfrm_user.c	2005-01-26 06:53:19 +01:00
+++ edited/net/xfrm/xfrm_user.c	2005-02-10 00:15:16 +01:00
@@ -980,33 +980,6 @@
 	return -1;
 }
 
-static int xfrm_user_rcv_skb(struct sk_buff *skb)
-{
-	int err;
-	struct nlmsghdr *nlh;
-
-	while (skb->len >= NLMSG_SPACE(0)) {
-		u32 rlen;
-
-		nlh = (struct nlmsghdr *) skb->data;
-		if (nlh->nlmsg_len < sizeof(*nlh) ||
-		    skb->len < nlh->nlmsg_len)
-			return 0;
-		rlen = NLMSG_ALIGN(nlh->nlmsg_len);
-		if (rlen > skb->len)
-			rlen = skb->len;
-		if (xfrm_user_rcv_msg(skb, nlh, &err) < 0) {
-			if (err == 0)
-				return -1;
-			netlink_ack(skb, nlh, err);
-		} else if (nlh->nlmsg_flags & NLM_F_ACK)
-			netlink_ack(skb, nlh, 0);
-		skb_pull(skb, rlen);
-	}
-
-	return 0;
-}
-
 static void xfrm_netlink_rcv(struct sock *sk, int len)
 {
 	do {
@@ -1015,7 +988,7 @@
 		down(&xfrm_cfg_sem);
 
 		while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
-			if (xfrm_user_rcv_skb(skb)) {
+			if (netlink_process_skb(skb, xfrm_user_rcv_msg)) {
 				if (skb->len)
 					skb_queue_head(&sk->sk_receive_queue,
 						       skb);

--------------080805090606010004050501--
