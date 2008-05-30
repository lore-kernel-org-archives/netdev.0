From: "Adam Langley" <agl@imperialviolet.org>
Subject: [PATCH] Fix corrupt TCP packets when options space overflows with MD5SIG enabled
Date: Fri, 30 May 2008 11:40:58 -0700
Message-ID: <396556a20805301140x586093e5o92d44e38f7c2869a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:28480 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbYE3SlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 14:41:01 -0400
Received: by rv-out-0506.google.com with SMTP id l9so4754206rvb.1
        for <netdev@vger.kernel.org>; Fri, 30 May 2008 11:40:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When MD5 signatures are turned on we can end up with syntactically invalid
packets with a header length < 20 bytes. This is because tcp_header_size
overflows with 12 bytes of timestamp, 20 bytes of signature and > 8 bytes of
SACK option.

Since we can't fit any SACK blocks in the final 8 bytes of options space, and
the MD5 signature is more important, we disable including SACK, or even
advertising it, when MD5 is enabled.

Signed-off-by: Adam Langley <agl@imperialviolet.org>

---

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e399bde..70392a6 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -504,6 +504,16 @@ static int tcp_transmit_skb(struct sock *sk,
struct sk_buff *skb, int clone_it,
        tcb = TCP_SKB_CB(skb);
        tcp_header_size = tp->tcp_header_len;

+#ifdef CONFIG_TCP_MD5SIG
+       /*
+        * Are we doing MD5 on this segment? If so - make
+        * room for it.
+        */
+       md5 = tp->af_specific->md5_lookup(sk, sk);
+       if (md5)
+               tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
+#endif
+
 #define SYSCTL_FLAG_TSTAMPS    0x1
 #define SYSCTL_FLAG_WSCALE     0x2
 #define SYSCTL_FLAG_SACK       0x4
@@ -519,12 +529,23 @@ static int tcp_transmit_skb(struct sock *sk,
struct sk_buff *skb, int clone_it,
                        tcp_header_size += TCPOLEN_WSCALE_ALIGNED;
                        sysctl_flags |= SYSCTL_FLAG_WSCALE;
                }
-               if (sysctl_tcp_sack) {
+               if (sysctl_tcp_sack
+#ifdef CONFIG_TCP_MD5SIG
+                   /* We don't include SACK options if we are going to
+                    * include an MD5 signature because they can't fit
+                    * in the options space */
+                   && !md5
+#endif
+                   ) {
                        sysctl_flags |= SYSCTL_FLAG_SACK;
                        if (!(sysctl_flags & SYSCTL_FLAG_TSTAMPS))
                                tcp_header_size += TCPOLEN_SACKPERM_ALIGNED;
                }
-       } else if (unlikely(tp->rx_opt.eff_sacks)) {
+       } else if (unlikely(tp->rx_opt.eff_sacks
+#ifdef CONFIG_TCP_MD5SIG
+                           && !md5
+#endif
+                           )) {
                /* A SACK is 2 pad bytes, a 2 byte header, plus
                 * 2 32-bit sequence numbers for each SACK block.
                 */
@@ -536,16 +557,6 @@ static int tcp_transmit_skb(struct sock *sk,
struct sk_buff *skb, int clone_it,
        if (tcp_packets_in_flight(tp) == 0)
                tcp_ca_event(sk, CA_EVENT_TX_START);

-#ifdef CONFIG_TCP_MD5SIG
-       /*
-        * Are we doing MD5 on this segment? If so - make
-        * room for it.
-        */
-       md5 = tp->af_specific->md5_lookup(sk, sk);
-       if (md5)
-               tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
-#endif
-
        skb_push(skb, tcp_header_size);
        skb_reset_transport_header(skb);
        skb_set_owner_w(skb, sk);
