From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-proc: expose the tos values in /proc/net/[tcp|udp]
Date: Wed, 05 Oct 2011 11:34:29 +0200
Message-ID: <1317807270.2473.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1317324162-21621-1-git-send-email-muralira@google.com>
	 <20110929.153259.169108824599752228.davem@davemloft.net>
	 <CAP3iWTTYk7tErsCVdeytdpiu0fo-7B8cNZZk0EpR_rj-VOGi-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: MuraliRaja Muniraju <muralira@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP3iWTTYk7tErsCVdeytdpiu0fo-7B8cNZZk0EpR_rj-VOGi-g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 04 octobre 2011 =C3=A0 10:38 -0700, MuraliRaja Muniraju a =C3=A9=
crit :
> I shall make the changes by exposing the tos values via the
> netlink as suggested. I had a doubt is I have to modify the
> inet_diag_sockid or export it via a new option. I am considering
> that adding into inet_diag_sockid is better because the latter is a
> bit of a over kill for a single value to be exposed and it also seems
> to be logical fit.
> Can you let me know your thoughts on this.

I believe you could add one "u32 tos" to struct tcp_info

[ It wont solve the UDP case, since "ss -u" still dumps /proc/net/udp
and /proc/net/udp6 ]

=46ollowing patch should handle tcp/dccp ipv4/ipv6

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7f59ee9..eec6f3b 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -167,6 +167,7 @@ struct tcp_info {
 	__u32	tcpi_rcv_space;
=20
 	__u32	tcpi_total_retrans;
+	__u32	tos;
 };
=20
 /* for TCP_MD5SIG socket option */
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index b21f261..70d9498 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -37,6 +37,7 @@ static void dccp_get_info(struct sock *sk, struct tcp=
_info *info)
=20
 	if (dp->dccps_hc_tx_ccid !=3D NULL)
 		ccid_hc_tx_get_info(dp->dccps_hc_tx_ccid, sk, info);
+	info->tos =3D inet_sk(sk)->tos;
 }
=20
 static void dccp_diag_get_info(struct sock *sk, struct inet_diag_msg *=
r,
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4c0da24..b24c3d8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2493,6 +2493,7 @@ void tcp_get_info(struct sock *sk, struct tcp_inf=
o *info)
 	info->tcpi_rcv_space =3D tp->rcvq_space.space;
=20
 	info->tcpi_total_retrans =3D tp->total_retrans;
+	info->tos =3D inet_sk(sk)->tos;
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
=20
