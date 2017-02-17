From: "Cui, Cheng" <Cheng.Cui@netapp.com>
Subject: [PATCHv2, 1/1] tcp: accommodate sequence number to a peer's shrunk
 receive window caused by precision loss in window scaling
Date: Fri, 17 Feb 2017 17:04:55 +0000
Message-ID: <BA334603-D37E-4C94-BB8B-19A830E0355C@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:10329 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934122AbdBQRE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 12:04:59 -0500
Content-Language: en-US
Content-ID: <2D1640E6C625D94989EF08C9A06F2066@namprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prevent sending out a left-shifted sequence number from a Linux sender in=20
response to a peer's shrunk receive-window caused by losing least significa=
nt
bits in window-scaling.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Cheng Cui <Cheng.Cui@netapp.com>
---
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1d5331a..634146c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -85,7 +85,8 @@ static void tcp_event_new_data_sent(struct sock *sk, cons=
t struct sk_buff *skb)
 		      tcp_skb_pcount(skb));
 }
=20
-/* SND.NXT, if window was not shrunk.
+/* SND.NXT, if window was not shrunk or the amount of shrunk was less than=
 one
+ * window scaling factor due to loss of precision.
  * If window has been shrunk, what should we make? It is not clear at all.
  * Using SND.UNA we will fail to open window, SND.NXT is out of window. :-=
(
  * Anything in between SND.UNA...SND.UNA+SND.WND also can be already
@@ -95,7 +96,9 @@ static inline __u32 tcp_acceptable_seq(const struct sock =
*sk)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
=20
-	if (!before(tcp_wnd_end(tp), tp->snd_nxt))
+	if (!before(tcp_wnd_end(tp), tp->snd_nxt) ||
+	    (tp->rx_opt.wscale_ok &&
+	     ((tp->snd_nxt - tcp_wnd_end(tp)) < (1 << tp->rx_opt.rcv_wscale))))
 		return tp->snd_nxt;
 	else
 		return tcp_wnd_end(tp);
