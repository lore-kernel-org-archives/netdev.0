From: Franchoze Eric <franchoze@yandex.ru>
Subject: why do we need printk on sending syn flood cookie?
Date: Mon, 02 Aug 2010 11:58:14 +0400
Message-ID: <480391280735894@web102.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward8.mail.yandex.net ([77.88.61.38]:42268 "EHLO
	forward8.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab0HBH6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 03:58:16 -0400
Received: from web102.yandex.ru (web102.yandex.ru [77.88.61.3])
	by forward8.mail.yandex.net (Yandex) with ESMTP id 0991616F0641
	for <netdev@vger.kernel.org>; Mon,  2 Aug 2010 11:58:15 +0400 (MSD)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by web102.yandex.ru (Yandex) with ESMTP id 06FA81A80A8
	for <netdev@vger.kernel.org>; Mon,  2 Aug 2010 11:58:15 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Just sirious why do we need printk each 1 second (60*HZ) about possible syn-flood? It really floods dmesg. Is there something dengerous? I have suggestion to turn off printk about sending tcp cookie each 1 second.

Something like this:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fe193e5..5574adc 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1230,8 +1230,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	__u32 isn = TCP_SKB_CB(skb)->when;
 #ifdef CONFIG_SYN_COOKIES
 	int want_cookie = 0;
+	int want_cookie_no_warn = 0;
 #else
 #define want_cookie 0 /* Argh, why doesn't gcc optimize this :( */
+#define want_cookie_no_warn 0 
 #endif
 
 	/* Never answer to SYNs send to broadcast or multicast */
@@ -1246,7 +1248,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 #ifdef CONFIG_SYN_COOKIES
 		if (sysctl_tcp_syncookies) {
 			want_cookie = 1;
-		} else
+			if (sysctl_tcp_syncookies == 2)
+				want_cookie_no_warn = 1;
+		}
+		else
 #endif
 		goto drop;
 	}
@@ -1296,6 +1301,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 #ifdef CONFIG_SYN_COOKIES
 		want_cookie = 0;	/* not our kind of cookie */
+		want_cookie_no_warn = 0;	/* no printk on syn flood */
 #endif
 		tmp_ext.cookie_out_never = 0; /* false */
 		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
@@ -1328,7 +1334,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	if (want_cookie) {
 #ifdef CONFIG_SYN_COOKIES
-		syn_flood_warning(skb);
+		if (!want_cookie_no_warn)
+			syn_flood_warning(skb);
 		req->cookie_ts = tmp_opt.tstamp_ok;
 #endif
 		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
