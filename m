From: "Cui, Cheng" <Cheng.Cui@netapp.com>
Subject: [PATCH 1/1] tcp: accommodate sequence number to a peer's shrunk
 receive window caused by precision loss in window scaling
Date: Tue, 14 Feb 2017 23:14:59 +0000
Message-ID: <41B57547-A148-49D5-8F03-18F976263CED@netapp.com>
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
Received: from mx141.netapp.com ([216.240.21.12]:61709 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750766AbdBNXPF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 18:15:05 -0500
Content-Language: en-US
Content-ID: <FE191F164C91364594D1052F5DDAE481@namprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updates tcp_acceptable_seq(), one of the oldest functions since 2.4.0,=
 by
preventing sending out a left-shifted sequence number from a Linux sender i=
n
response to a peer's shrunk receive-window caused by losing least significa=
nt
bits in window-scaling.

RFC7323 page 10 (Chapter 2.4. Addressing Window Retraction) specifies sende=
r
side responsibility to handle the sequence number out of window:
> On the sender side:
>=20
>    3)  The initial transmission MUST be within the window announced by
>        the most recent <ACK>.

Some related discussion can be found at the IETF [tcpm] mailing list:
https://mailarchive.ietf.org/arch/msg/tcpm/pPO7cYxtky27Qto9b30eaHB_RQI

The issue has been reproduced and the patch has been verified by scp a 20GB=
 file
from a Linux box using kernel version 4.4.48 to a FreeBSD 11.0 box.

[ I mainly want feedback to see if everyone is OK with the approach. ]

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Cheng Cui <Cheng.Cui@netapp.com>
---
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1d5331a..29d736d 100644
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
@@ -95,7 +96,8 @@ static inline __u32 tcp_acceptable_seq(const struct sock =
*sk)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
=20
-	if (!before(tcp_wnd_end(tp), tp->snd_nxt))
+	if ((!before(tcp_wnd_end(tp), tp->snd_nxt)) || (tp->rx_opt.wscale_ok &&
+	    ((tp->snd_nxt - tcp_wnd_end(tp)) < (1 << tp->rx_opt.rcv_wscale))))
 		return tp->snd_nxt;
 	else
 		return tcp_wnd_end(tp);
--=20
2.9.3 (Apple Git-75)
