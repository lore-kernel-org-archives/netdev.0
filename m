From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [BK-PATCH 2.6] IPV6: Fix checksum for rawv6 sockets
Date: Thu, 20 May 2004 19:32:40 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520.193240.67952249.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Following changesets fixes checksum for rawv6 sockets.
 - send appropriate checksum
 - don't receive packets with incorrect checksum
 - ensure to notify return code to the caller.

Please pull following csets from <bk://bk.skbuff.net:20606>.

Thanks in advance.

CHANGESET
---------
ChangeSet@1.1793, 2004-05-20 18:20:15+09:00, yoshfuji@linux-ipv6.org
  [IPV6] handle return value from ip6_push_pending_frames().

diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Thu May 20 19:09:12 2004
+++ b/net/ipv6/raw.c	Thu May 20 19:09:12 2004
@@ -485,7 +485,7 @@
 	}
 	if (*csum == 0)
 		*csum = -1;
-	ip6_push_pending_frames(sk);
+	err = ip6_push_pending_frames(sk);
 out:
 	return err;
 }


ChangeSet@1.1794, 2004-05-20 18:23:35+09:00, yoshfuji@linux-ipv6.org
  [IPV6] unify XXX_push_pending_frames() code path for rawv6 sockets.

diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Thu May 20 19:09:15 2004
+++ b/net/ipv6/raw.c	Thu May 20 19:09:15 2004
@@ -453,6 +453,9 @@
 	int err = 0;
 	u16 *csum;
 
+	if (!opt->checksum)
+		goto send;
+
 	if ((skb = skb_peek(&sk->sk_write_queue)) == NULL)
 		goto out;
 
@@ -485,6 +488,7 @@
 	}
 	if (*csum == 0)
 		*csum = -1;
+send:
 	err = ip6_push_pending_frames(sk);
 out:
 	return err;
@@ -702,13 +706,8 @@
 
 		if (err)
 			ip6_flush_pending_frames(sk);
-		else if (!(msg->msg_flags & MSG_MORE)) {
-			if (raw_opt->checksum) {
-				err = rawv6_push_pending_frames(sk, &fl, raw_opt, len);
-			} else {
-				err = ip6_push_pending_frames(sk);
-			}
-		}
+		else if (!(msg->msg_flags & MSG_MORE))
+			err = rawv6_push_pending_frames(sk, &fl, raw_opt, len);
 	}
 done:
 	ip6_dst_store(sk, dst,


ChangeSet@1.1795, 2004-05-20 18:30:34+09:00, yoshfuji@linux-ipv6.org
  [IPV6] unify csum_ipv6_magic() code path for rawv6 sockets.

diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Thu May 20 19:09:18 2004
+++ b/net/ipv6/raw.c	Thu May 20 19:09:18 2004
@@ -452,6 +452,7 @@
 	struct sk_buff *skb;
 	int err = 0;
 	u16 *csum;
+	u32 tmp_csum;
 
 	if (!opt->checksum)
 		goto send;
@@ -466,26 +467,24 @@
 		goto out;
 	}
 
+	/* should be check HW csum miyazawa */
 	if (skb_queue_len(&sk->sk_write_queue) == 1) {
 		/*
 		 * Only one fragment on the socket.
 		 */
-		/* should be check HW csum miyazawa */
-		*csum = csum_ipv6_magic(&fl->fl6_src,
-					&fl->fl6_dst,
-					len, fl->proto, skb->csum);
+		tmp_csum = skb->csum;
 	} else {
-		u32 tmp_csum = 0;
+		tmp_csum = 0;
 
 		skb_queue_walk(&sk->sk_write_queue, skb) {
 			tmp_csum = csum_add(tmp_csum, skb->csum);
 		}
-
-		tmp_csum = csum_ipv6_magic(&fl->fl6_src,
-					   &fl->fl6_dst,
-					   len, fl->proto, tmp_csum);
-		*csum = tmp_csum;
 	}
+
+	*csum = csum_ipv6_magic(&fl->fl6_src,
+				&fl->fl6_dst,
+				len, fl->proto, tmp_csum);
+
 	if (*csum == 0)
 		*csum = -1;
 send:


ChangeSet@1.1796, 2004-05-20 18:33:44+09:00, yoshfuji@linux-ipv6.org
  [IPV6] put appropriate checksum for rawv6 sockets even if it was not initialized.

diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Thu May 20 19:09:20 2004
+++ b/net/ipv6/raw.c	Thu May 20 19:09:20 2004
@@ -481,6 +481,10 @@
 		}
 	}
 
+	/* in case cksum was not initialized */
+	if (unlikely(*csum))
+		tmp_csum = csum_sub(tmp_csum, *csum);
+
 	*csum = csum_ipv6_magic(&fl->fl6_src,
 				&fl->fl6_dst,
 				len, fl->proto, tmp_csum);


ChangeSet@1.1797, 2004-05-20 18:41:07+09:00, yoshfuji@linux-ipv6.org
  [IPV6] ensure to evaluate the checksum for sockets with the IPV6_CHECKSUM option.

diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Thu May 20 19:09:23 2004
+++ b/net/ipv6/raw.c	Thu May 20 19:09:23 2004
@@ -283,7 +283,8 @@
 
 static inline int rawv6_rcv_skb(struct sock * sk, struct sk_buff * skb)
 {
-	if (sk->sk_filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
+	if ((raw6_sk(sk)->checksum || sk->sk_filter) && 
+	    skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
 			/* FIXME: increment a raw6 drops counter here */
 			kfree_skb(skb);

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
