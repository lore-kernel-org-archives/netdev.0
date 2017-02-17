From: "Cui, Cheng" <Cheng.Cui@netapp.com>
Subject: Re: [PATCH 1/1] tcp: accommodate sequence number to a peer's shrunk
 receive window caused by precision loss in window scaling
Date: Fri, 17 Feb 2017 16:44:23 +0000
Message-ID: <1554418B-B544-4F08-84D2-0FFF5AEAAF84@netapp.com>
References: <41B57547-A148-49D5-8F03-18F976263CED@netapp.com>
 <20170217.110858.1023681409351044871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:15338 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934140AbdBQQo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 11:44:27 -0500
In-Reply-To: <20170217.110858.1023681409351044871.davem@davemloft.net>
Content-Language: en-US
Content-ID: <B66BB303D042AD46BD1675A0369656C0@namprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the comment. This is the patch update.

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
 --
2.9.3 (Apple Git-75)
