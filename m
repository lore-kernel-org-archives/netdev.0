From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH 4/4] [NETLINK] make rtnetlink use netlink_check_skb
Date: Fri, 11 Feb 2005 01:19:30 +0100
Message-ID: <420BFA12.1050504@eurodev.net>
References: <420BF8DF.4080407@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040009010804030004010404"
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com
In-Reply-To: <420BF8DF.4080407@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040009010804030004010404
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

oops, forgot to attach the patch

Pablo Neira wrote:

> The modification required to make rtnetlink.c use netlink_check_skb
>
> -- 
> Pablo
>


--------------040009010804030004010404
Content-Type: text/x-patch;
 name="03rtnetlink.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03rtnetlink.patch"

===== net/core/rtnetlink.c 1.33 vs edited =====
--- 1.33/net/core/rtnetlink.c	2005-01-10 22:42:22 +01:00
+++ edited/net/core/rtnetlink.c	2005-02-10 00:14:59 +01:00
@@ -570,41 +570,6 @@
 	return -1;
 }
 
-/* 
- * Process one packet of messages.
- * Malformed skbs with wrong lengths of messages are discarded silently.
- */
-
-static inline int rtnetlink_rcv_skb(struct sk_buff *skb)
-{
-	int err;
-	struct nlmsghdr * nlh;
-
-	while (skb->len >= NLMSG_SPACE(0)) {
-		u32 rlen;
-
-		nlh = (struct nlmsghdr *)skb->data;
-		if (nlh->nlmsg_len < sizeof(*nlh) || skb->len < nlh->nlmsg_len)
-			return 0;
-		rlen = NLMSG_ALIGN(nlh->nlmsg_len);
-		if (rlen > skb->len)
-			rlen = skb->len;
-		if (rtnetlink_rcv_msg(skb, nlh, &err)) {
-			/* Not error, but we must interrupt processing here:
-			 *   Note, that in this case we do not pull message
-			 *   from skb, it will be processed later.
-			 */
-			if (err == 0)
-				return -1;
-			netlink_ack(skb, nlh, err);
-		} else if (nlh->nlmsg_flags&NLM_F_ACK)
-			netlink_ack(skb, nlh, 0);
-		skb_pull(skb, rlen);
-	}
-
-	return 0;
-}
-
 /*
  *  rtnetlink input queue processing routine:
  *	- try to acquire shared lock. If it is failed, defer processing.
@@ -622,7 +587,7 @@
 			return;
 
 		while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
-			if (rtnetlink_rcv_skb(skb)) {
+			if (netlink_process_skb(skb, rtnetlink_rcv_msg)) {
 				if (skb->len)
 					skb_queue_head(&sk->sk_receive_queue,
 						       skb);

--------------040009010804030004010404--
