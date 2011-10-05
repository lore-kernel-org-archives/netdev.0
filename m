From: MuraliRaja Muniraju <muralira@google.com>
Subject: Re: [PATCH] net-proc: expose the tos values in /proc/net/[tcp|udp]
Date: Wed, 5 Oct 2011 07:09:24 -0700
Message-ID: <CAP3iWTSsY0a5p_NEq_xnpgT3y5Qg2PXsG1RdvcSxcXWiGwYM0Q@mail.gmail.com>
References: <1317324162-21621-1-git-send-email-muralira@google.com>
	<20110929.153259.169108824599752228.davem@davemloft.net>
	<CAP3iWTTYk7tErsCVdeytdpiu0fo-7B8cNZZk0EpR_rj-VOGi-g@mail.gmail.com>
	<1317807270.2473.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317807270.2473.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,
     I am trying one more approach of adding a new attribute to the
inet_diag extension to expose the tos values. Hence with this approach
tcp tos problem would be solved. When  udp would also be supported via
netlink and will be using inet_diag, it would be just be publishing
the tos values in the new extension added. Can you let me know your
thoughts on the following patch.

--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -97,9 +97,10 @@ enum {
        INET_DIAG_INFO,
        INET_DIAG_VEGASINFO,
        INET_DIAG_CONG,
+       INET_DIAG_TOS,
 };

-#define INET_DIAG_MAX INET_DIAG_CONG
+#define INET_DIAG_MAX INET_DIAG_TOS


 /* INET_DIAG_MEM */
@@ -120,6 +121,13 @@ struct tcpvegas_info {
        __u32   tcpv_minrtt;
 };

+/* INET_DIAG_TOS */
+
+struct inet_diag_tos {
+       __u8    idiag_tos;
+       __u8    idiag_reserved[3];
+};
+
 #ifdef __KERNEL__
 struct sock;
 struct inet_hashinfo;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index e5fa2dd..abdd606 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -82,6 +82,7 @@ static int inet_csk_diag_fill(struct sock *sk,
        struct nlmsghdr  *nlh;
        void *info =3D NULL;
        struct inet_diag_meminfo  *minfo =3D NULL;
+       struct inet_diag_tos *tos =3D NULL;
        unsigned char    *b =3D skb_tail_pointer(skb);
        const struct inet_diag_handler *handler;

@@ -108,6 +109,9 @@ static int inet_csk_diag_fill(struct sock *sk,
                       icsk->icsk_ca_ops->name);
        }

+       if (ext & (1 << (INET_DIAG_TOS - 1)))
+               tos =3D INET_DIAG_PUT(skb, INET_DIAG_TOS, sizeof(*tos))=
;
+
        r->idiag_family =3D sk->sk_family;
        r->idiag_state =3D sk->sk_state;
        r->idiag_timer =3D 0;
@@ -169,6 +173,9 @@ static int inet_csk_diag_fill(struct sock *sk,
            icsk->icsk_ca_ops && icsk->icsk_ca_ops->get_info)
                icsk->icsk_ca_ops->get_info(sk, ext, skb);

+       if (tos)
+               tos->idiag_tos =3D inet->tos;
+
        nlh->nlmsg_len =3D skb_tail_pointer(skb) - b;
        return skb->len;


Thanks,
Murali

On Wed, Oct 5, 2011 at 2:34 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le mardi 04 octobre 2011 =E0 10:38 -0700, MuraliRaja Muniraju a =E9cr=
it :
>> I shall make the changes by exposing the tos values via the
>> netlink as suggested. I had a doubt is I have to modify the
>> inet_diag_sockid or export it via a new option. I am considering
>> that adding into inet_diag_sockid is better because the latter is a
>> bit of a over kill for a single value to be exposed and it also seem=
s
>> to be logical fit.
>> Can you let me know your thoughts on this.
>
> I believe you could add one "u32 tos" to struct tcp_info
>
> [ It wont solve the UDP case, since "ss -u" still dumps /proc/net/udp
> and /proc/net/udp6 ]
>
> Following patch should handle tcp/dccp ipv4/ipv6
>
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 7f59ee9..eec6f3b 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -167,6 +167,7 @@ struct tcp_info {
> =A0 =A0 =A0 =A0__u32 =A0 tcpi_rcv_space;
>
> =A0 =A0 =A0 =A0__u32 =A0 tcpi_total_retrans;
> + =A0 =A0 =A0 __u32 =A0 tos;
> =A0};
>
> =A0/* for TCP_MD5SIG socket option */
> diff --git a/net/dccp/diag.c b/net/dccp/diag.c
> index b21f261..70d9498 100644
> --- a/net/dccp/diag.c
> +++ b/net/dccp/diag.c
> @@ -37,6 +37,7 @@ static void dccp_get_info(struct sock *sk, struct t=
cp_info *info)
>
> =A0 =A0 =A0 =A0if (dp->dccps_hc_tx_ccid !=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ccid_hc_tx_get_info(dp->dccps_hc_tx_cc=
id, sk, info);
> + =A0 =A0 =A0 info->tos =3D inet_sk(sk)->tos;
> =A0}
>
> =A0static void dccp_diag_get_info(struct sock *sk, struct inet_diag_m=
sg *r,
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 4c0da24..b24c3d8 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2493,6 +2493,7 @@ void tcp_get_info(struct sock *sk, struct tcp_i=
nfo *info)
> =A0 =A0 =A0 =A0info->tcpi_rcv_space =3D tp->rcvq_space.space;
>
> =A0 =A0 =A0 =A0info->tcpi_total_retrans =3D tp->total_retrans;
> + =A0 =A0 =A0 info->tos =3D inet_sk(sk)->tos;
> =A0}
> =A0EXPORT_SYMBOL_GPL(tcp_get_info);
>
>
>
>



--=20
Thanks,
Murali
