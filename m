From: Song Liu <songliubraving@fb.com>
Subject: Re: [PATCH net-next] tcp: add tracepoint
 trace_tcp_retransmit_synack()
Date: Wed, 25 Oct 2017 16:17:34 +0000
Message-ID: <9122439C-FD4C-4404-BD22-3EE3E6D2032D@fb.com>
References: <20171024235709.2186047-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "liu.song.a23@gmail.com" <liu.song.a23@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        "brendan.d.gregg@gmail.com" <brendan.d.gregg@gmail.com>,
        "ncardwell@google.com" <ncardwell@google.com>,
        David Ahern <dsahern@gmail.com>,
        Kernel Team <Kernel-team@fb.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>
To: "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        Martin Lau <kafai@fb.com>, Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55576 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751682AbdJYQSU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 12:18:20 -0400
In-Reply-To: <20171024235709.2186047-1-songliubraving@fb.com>
Content-Language: en-US
Content-ID: <A82EDFAC053B554596A0D0F14A9EF7F6@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CCing key audience of the patch.=20

Thanks,
Song

> On Oct 24, 2017, at 4:57 PM, Song Liu <songliubraving@fb.com> wrote:
>=20
> This tracepoint can be used to trace synack retransmits. It maintains
> pointer to struct request_sock.
>=20
> We cannot simply reuse trace_tcp_retransmit_skb() here, because the
> sk here is the LISTEN socket. The IP addresses and ports should be
> extracted from struct request_sock.
>=20
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
> include/trace/events/tcp.h | 56 +++++++++++++++++++++++++++++++++++++++++=
+++++
> net/ipv4/tcp_output.c      |  1 +
> 2 files changed, 57 insertions(+)
>=20
> diff --git a/include/trace/events/tcp.h b/include/trace/events/tcp.h
> index 03699ba..07cccca 100644
> --- a/include/trace/events/tcp.h
> +++ b/include/trace/events/tcp.h
> @@ -237,6 +237,62 @@ TRACE_EVENT(tcp_set_state,
> 		  show_tcp_state_name(__entry->newstate))
> );
>=20
> +TRACE_EVENT(tcp_retransmit_synack,
> +
> +	TP_PROTO(const struct sock *sk, const struct request_sock *req),
> +
> +	TP_ARGS(sk, req),
> +
> +	TP_STRUCT__entry(
> +		__field(const void *, skaddr)
> +		__field(const void *, req)
> +		__field(__u16, sport)
> +		__field(__u16, dport)
> +		__array(__u8, saddr, 4)
> +		__array(__u8, daddr, 4)
> +		__array(__u8, saddr_v6, 16)
> +		__array(__u8, daddr_v6, 16)
> +	),
> +
> +	TP_fast_assign(
> +		struct inet_request_sock *ireq =3D inet_rsk(req);
> +		struct in6_addr *pin6;
> +		__be32 *p32;
> +
> +		__entry->skaddr =3D sk;
> +		__entry->req =3D req;
> +
> +		__entry->sport =3D ireq->ir_num;
> +		__entry->dport =3D ntohs(ireq->ir_rmt_port);
> +
> +		p32 =3D (__be32 *) __entry->saddr;
> +		*p32 =3D ireq->ir_loc_addr;
> +
> +		p32 =3D (__be32 *) __entry->daddr;
> +		*p32 =3D ireq->ir_rmt_addr;
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +		if (sk->sk_family =3D=3D AF_INET6) {
> +			pin6 =3D (struct in6_addr *)__entry->saddr_v6;
> +			*pin6 =3D ireq->ir_v6_loc_addr;
> +			pin6 =3D (struct in6_addr *)__entry->daddr_v6;
> +			*pin6 =3D ireq->ir_v6_rmt_addr;
> +		} else
> +#endif
> +		{
> +			pin6 =3D (struct in6_addr *)__entry->saddr_v6;
> +			ipv6_addr_set_v4mapped(ireq->ir_loc_addr, pin6);
> +			pin6 =3D (struct in6_addr *)__entry->daddr_v6;
> +			ipv6_addr_set_v4mapped(ireq->ir_rmt_addr, pin6);
> +		}
> +	),
> +
> +	TP_printk("sport=3D%hu dport=3D%hu saddr=3D%pI4 daddr=3D%pI4 saddrv6=3D=
%pI6c daddrv6=3D%pI6c",
> +		  __entry->sport, __entry->dport,
> +		  __entry->saddr, __entry->daddr,
> +		  __entry->saddr_v6, __entry->daddr_v6)
> +);
> +
> #endif /* _TRACE_TCP_H */
>=20
> /* This part must be outside protection */
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 1f01f4c..6a728a5 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -3735,6 +3735,7 @@ int tcp_rtx_synack(const struct sock *sk, struct re=
quest_sock *req)
> 		__NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
> 		if (unlikely(tcp_passive_fastopen(sk)))
> 			tcp_sk(sk)->total_retrans++;
> +		trace_tcp_retransmit_synack(sk, req);
> 	}
> 	return res;
> }
> --=20
> 2.9.5
>=20
