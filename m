From: Fabricio Archanjo <farchanjo@gmail.com>
Subject: Re: [PATCH v3] netfilter: xtables target SYNPROXY
Date: Fri, 3 Sep 2010 17:29:11 -0300
Message-ID: <AANLkTim_sgZhrcgvuH0=hFTfE-beMezvcvw6PspXRvHx@mail.gmail.com>
References: <1278044350-3136-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Changli Gao <xiaosuo@gmail.com>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1278044350-3136-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hey all,
is this patch gonna be on kernel tree?
It works fines. Yesterday I was over attack, after applied this patch
my problem was solved. It hasn't dropped real connections. Sometimes i
changed to freebsd due synproxy state on pf.


Thanks,

On Fri, Jul 2, 2010 at 1:19 AM, Changli Gao <xiaosuo@gmail.com> wrote:
>
> v3:
> fix the bug it can't work with bridge.
>
> netfilter: xtables target SYNPROXY.
>
> This patch implements an xtables target SYNPROXY. As the connection t=
o the
> TCP server won't be established until the ACK from the client is rece=
ived, it
> can protect the TCP server from the SYN-flood attacks.
>
> It works in the raw table of the PREROUTING chain, before conntrackin=
g system.
> Syncookies is used, so no new state is introduced into the conntracki=
ng system.
> In fact, until the first connection is established, conntracking syst=
em doesn't
> see any packets. So when there is a SYN-flood attack, conntracking sy=
stem won't
> be busy on finding and deleting the un-assured ct.
>
> As the SYN-packet of the second connection request is sent locally, t=
he DNAT
> rules which are in the PREROUTING chain should be moved to the OUTPUT=
 chain.
>
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> =A0include/net/netfilter/nf_conntrack.h =A0 =A0 =A0 =A0| =A0 10
> =A0include/net/netfilter/nf_conntrack_core.h =A0 | =A0 21
> =A0include/net/netfilter/nf_conntrack_extend.h | =A0 =A02
> =A0include/net/tcp.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 | =A0 =A07
> =A0net/ipv4/syncookies.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
| =A0 22
> =A0net/ipv4/tcp_ipv4.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 | =A0 =A09
> =A0net/netfilter/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
| =A0 17
> =A0net/netfilter/Makefile =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
| =A0 =A01
> =A0net/netfilter/nf_conntrack_core.c =A0 =A0 =A0 =A0 =A0 | =A0 45 +
> =A0net/netfilter/xt_SYNPROXY.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A06=
79 ++++++++++++++++++++++++++++
> =A010 files changed, 794 insertions(+), 19 deletions(-)
> diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfi=
lter/nf_conntrack.h
> index e624dae..5e6d8e4 100644
> --- a/include/net/netfilter/nf_conntrack.h
> +++ b/include/net/netfilter/nf_conntrack.h
> @@ -311,5 +311,15 @@ do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0#define MODULE_ALIAS_NFCT_HELPER(helper) \
> =A0 =A0 =A0 =A0 MODULE_ALIAS("nfct-helper-" helper)
>
> +#if defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY) || \
> + =A0 =A0defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY_MODULE)
> +extern unsigned int (*syn_proxy_pre_hook)(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 struct nf_conn *ct,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 enum ip_conntrack_info ctinfo);
> +
> +extern unsigned int (*syn_proxy_post_hook)(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0struct nf_conn *ct,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0enum ip_conntrack_info ctinfo);
> +#endif
> =A0#endif /* __KERNEL__ */
> =A0#endif /* _NF_CONNTRACK_H */
> diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/=
netfilter/nf_conntrack_core.h
> index aced085..637b404 100644
> --- a/include/net/netfilter/nf_conntrack_core.h
> +++ b/include/net/netfilter/nf_conntrack_core.h
> @@ -54,6 +54,23 @@ nf_conntrack_find_get(struct net *net, u16 zone,
>
> =A0extern int __nf_conntrack_confirm(struct sk_buff *skb);
>
> +static inline unsigned int syn_proxy_post_call(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0struct nf_conn *ct,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0enum ip_conntrack_info ctinfo)
> +{
> + =A0 =A0 =A0 unsigned int ret =3D NF_ACCEPT;
> +#if defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY) || \
> + =A0 =A0defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY_MODULE)
> + =A0 =A0 =A0 unsigned int (*syn_proxy)(struct sk_buff *, struct nf_c=
onn *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enu=
m ip_conntrack_info);
> + =A0 =A0 =A0 syn_proxy =3D rcu_dereference(syn_proxy_post_hook);
> + =A0 =A0 =A0 if (syn_proxy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D syn_proxy(skb, ct, ctinfo);
> +#endif
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> =A0/* Confirm a connection: returns NF_DROP if packet must be dropped=
=2E */
> =A0static inline int nf_conntrack_confirm(struct sk_buff *skb)
> =A0{
> @@ -63,8 +80,10 @@ static inline int nf_conntrack_confirm(struct sk_b=
uff *skb)
> =A0 =A0 =A0 =A0if (ct && !nf_ct_is_untracked(ct)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!nf_ct_is_confirmed(ct))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D __nf_conntrack=
_confirm(skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(ret =3D=3D NF_ACCEPT))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(ret =3D=3D NF_ACCEPT)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nf_ct_deliver_cached_e=
vents(ct);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D syn_proxy_post_=
call(skb, ct, skb->nfctinfo);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return ret;
> =A0}
> diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/ne=
t/netfilter/nf_conntrack_extend.h
> index 32d15bd..b2ae7e9 100644
> --- a/include/net/netfilter/nf_conntrack_extend.h
> +++ b/include/net/netfilter/nf_conntrack_extend.h
> @@ -11,6 +11,7 @@ enum nf_ct_ext_id {
> =A0 =A0 =A0 =A0NF_CT_EXT_ACCT,
> =A0 =A0 =A0 =A0NF_CT_EXT_ECACHE,
> =A0 =A0 =A0 =A0NF_CT_EXT_ZONE,
> + =A0 =A0 =A0 NF_CT_EXT_SYNPROXY,
> =A0 =A0 =A0 =A0NF_CT_EXT_NUM,
> =A0};
>
> @@ -19,6 +20,7 @@ enum nf_ct_ext_id {
> =A0#define NF_CT_EXT_ACCT_TYPE struct nf_conn_counter
> =A0#define NF_CT_EXT_ECACHE_TYPE struct nf_conntrack_ecache
> =A0#define NF_CT_EXT_ZONE_TYPE struct nf_conntrack_zone
> +#define NF_CT_EXT_SYNPROXY_TYPE struct syn_proxy_state
>
> =A0/* Extensions: optional stuff which isn't permanently in struct. *=
/
> =A0struct nf_ct_ext {
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index c2f96c2..06f28d3 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -460,8 +460,11 @@ extern int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_d=
isconnect(struct sock *sk, int flags);
> =A0extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
> =A0extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buf=
f *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
struct ip_options *opt);
> -extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff=
 *skb,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0__u16 *mss);
> +extern __u32 __cookie_v4_init_sequence(__be32 saddr, __be32 daddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0__be16 sport, __be16 dport, __u32 seq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0__u16 *mssp);
> +extern int cookie_v4_check_sequence(const struct iphdr *iph,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 const struct tcphdr *th, __u32 cookie);
>
> =A0extern __u32 cookie_init_timestamp(struct request_sock *req);
> =A0extern bool cookie_check_timestamp(struct tcp_options_received *op=
t, bool *);
> diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
> index 650cace..3adcba3 100644
> --- a/net/ipv4/syncookies.c
> +++ b/net/ipv4/syncookies.c
> @@ -159,26 +159,21 @@ static __u16 const msstab[] =3D {
> =A0* Generate a syncookie. =A0mssp points to the mss, which is return=
ed
> =A0* rounded down to the value encoded in the cookie.
> =A0*/
> -__u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, =
__u16 *mssp)
> +__u32 __cookie_v4_init_sequence(__be32 saddr, __be32 daddr, __be16 s=
port,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __be16 =
dport, __u32 seq, __u16 *mssp)
> =A0{
> - =A0 =A0 =A0 const struct iphdr *iph =3D ip_hdr(skb);
> - =A0 =A0 =A0 const struct tcphdr *th =3D tcp_hdr(skb);
> =A0 =A0 =A0 =A0int mssind;
> =A0 =A0 =A0 =A0const __u16 mss =3D *mssp;
>
> - =A0 =A0 =A0 tcp_synq_overflow(sk);
> -
> =A0 =A0 =A0 =A0for (mssind =3D ARRAY_SIZE(msstab) - 1; mssind ; mssin=
d--)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (mss >=3D msstab[mssind])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0*mssp =3D msstab[mssind];
>
> - =A0 =A0 =A0 NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT=
);
> -
> - =A0 =A0 =A0 return secure_tcp_syn_cookie(iph->saddr, iph->daddr,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0th->source, th->dest, ntohl(th->seq),
> + =A0 =A0 =A0 return secure_tcp_syn_cookie(saddr, daddr, sport, dport=
, seq,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 jiffies / (HZ * 60), mssind);
> =A0}
> +EXPORT_SYMBOL(__cookie_v4_init_sequence);
>
> =A0/*
> =A0* This (misnamed) value is the age of syncookie which is permitted=
=2E
> @@ -191,10 +186,9 @@ __u32 cookie_v4_init_sequence(struct sock *sk, s=
truct sk_buff *skb, __u16 *mssp)
> =A0* Check if a ack sequence number is a valid syncookie.
> =A0* Return the decoded mss if it is, or 0 if not.
> =A0*/
> -static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
> +int cookie_v4_check_sequence(const struct iphdr *iph, const struct t=
cphdr *th,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__u32 cookie=
)
> =A0{
> - =A0 =A0 =A0 const struct iphdr *iph =3D ip_hdr(skb);
> - =A0 =A0 =A0 const struct tcphdr *th =3D tcp_hdr(skb);
> =A0 =A0 =A0 =A0__u32 seq =3D ntohl(th->seq) - 1;
> =A0 =A0 =A0 =A0__u32 mssind =3D check_tcp_syn_cookie(cookie, iph->sad=
dr, iph->daddr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0th->source, th->dest, seq,
> @@ -203,6 +197,7 @@ static inline int cookie_check(struct sk_buff *sk=
b, __u32 cookie)
>
> =A0 =A0 =A0 =A0return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : =
0;
> =A0}
> +EXPORT_SYMBOL(cookie_v4_check_sequence);
>
> =A0static inline struct sock *get_cookie_sock(struct sock *sk, struct=
 sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 struct request_sock *req,
> @@ -282,7 +277,8 @@ struct sock *cookie_v4_check(struct sock *sk, str=
uct sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> =A0 =A0 =A0 =A0if (tcp_synq_no_recent_overflow(sk) ||
> - =A0 =A0 =A0 =A0 =A0 (mss =3D cookie_check(skb, cookie)) =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 (mss =3D cookie_v4_check_sequence(ip_hdr(skb), =
tcp_hdr(skb),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 cookie)) =3D=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NET_INC_STATS_BH(sock_net(sk), LINUX_M=
IB_SYNCOOKIESFAILED);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 8fa32f5..3b094c7 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1332,7 +1332,14 @@ int tcp_v4_conn_request(struct sock *sk, struc=
t sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0TCP_ECN_create_request(req, tcp_hdr(sk=
b));
>
> =A0 =A0 =A0 =A0if (want_cookie) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 isn =3D cookie_v4_init_sequence(sk, skb=
, &req->mss);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct tcphdr *th;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_synq_overflow(sk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 NET_INC_STATS_BH(sock_net(sk), LINUX_MI=
B_SYNCOOKIESSENT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 th =3D tcp_hdr(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 isn =3D __cookie_v4_init_sequence(saddr=
, daddr, th->source,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 th->dest, ntohl(th->seq),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 &req->mss);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0req->cookie_ts =3D tmp_opt.tstamp_ok;
> =A0 =A0 =A0 =A0} else if (!isn) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct inet_peer *peer =3D NULL;
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index 413ed24..fd8ad8c 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -560,6 +560,23 @@ config NETFILTER_XT_TARGET_SECMARK
>
> =A0 =A0 =A0 =A0 =A0To compile it as a module, choose M here. =A0If un=
sure, say N.
>
> +config NETFILTER_XT_TARGET_SYNPROXY
> + =A0 =A0 =A0 tristate '"SYNPROXY" target support (EXPERIMENTAL)'
> + =A0 =A0 =A0 depends on EXPERIMENTAL
> + =A0 =A0 =A0 depends on SYN_COOKIES
> + =A0 =A0 =A0 depends on IP_NF_RAW
> + =A0 =A0 =A0 depends on NF_CONNTRACK
> + =A0 =A0 =A0 depends on NETFILTER_ADVANCED
> + =A0 =A0 =A0 help
> + =A0 =A0 =A0 =A0 The SYNPROXY target allows a raw rule to specify th=
at some TCP
> + =A0 =A0 =A0 =A0 connections are relayed to protect the TCP servers =
from the SYN-flood
> + =A0 =A0 =A0 =A0 DoS attacks. Syn cookies is used to save the initia=
l state, so no
> + =A0 =A0 =A0 =A0 conntrack is needed until the client side connectio=
n is established.
> + =A0 =A0 =A0 =A0 It frees the connection tracking system from creati=
ng/deleting
> + =A0 =A0 =A0 =A0 conntracks when SYN-flood DoS attack acts.
> +
> + =A0 =A0 =A0 =A0 To compile it as a module, choose M here. =A0If uns=
ure, say N.
> +
> =A0config NETFILTER_XT_TARGET_TCPMSS
> =A0 =A0 =A0 =A0tristate '"TCPMSS" target support'
> =A0 =A0 =A0 =A0depends on (IPV6 || IPV6=3Dn)
> diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
> index e28420a..4e32834 100644
> --- a/net/netfilter/Makefile
> +++ b/net/netfilter/Makefile
> @@ -62,6 +62,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) +=3D =
xt_TCPOPTSTRIP.o
> =A0obj-$(CONFIG_NETFILTER_XT_TARGET_TEE) +=3D xt_TEE.o
> =A0obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) +=3D xt_TRACE.o
> =A0obj-$(CONFIG_NETFILTER_XT_TARGET_IDLETIMER) +=3D xt_IDLETIMER.o
> +obj-$(CONFIG_NETFILTER_XT_TARGET_SYNPROXY) +=3D xt_SYNPROXY.o
>
> =A0# matches
> =A0obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) +=3D xt_cluster.o
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_con=
ntrack_core.c
> index 16b41b4..dd85d6f 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -800,6 +800,26 @@ resolve_normal_ct(struct net *net, struct nf_con=
n *tmpl,
> =A0 =A0 =A0 =A0return ct;
> =A0}
>
> +static inline unsigned int syn_proxy_pre_call(int protonum, struct s=
k_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct nf_conn *ct,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 enum ip_conntrack_info ctinfo)
> +{
> + =A0 =A0 =A0 unsigned int ret =3D NF_ACCEPT;
> +#if defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY) || \
> + =A0 =A0defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY_MODULE)
> + =A0 =A0 =A0 unsigned int (*syn_proxy)(struct sk_buff *, struct nf_c=
onn *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enu=
m ip_conntrack_info);
> +
> + =A0 =A0 =A0 if (protonum =3D=3D IPPROTO_TCP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 syn_proxy =3D rcu_dereference(syn_proxy=
_pre_hook);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (syn_proxy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D syn_proxy(skb, =
ct, ctinfo);
> + =A0 =A0 =A0 }
> +#endif
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> =A0unsigned int
> =A0nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *skb)
> @@ -855,8 +875,9 @@ nf_conntrack_in(struct net *net, u_int8_t pf, uns=
igned int hooknum,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l3proto, =
l4proto, &set_reply, &ctinfo);
> =A0 =A0 =A0 =A0if (!ct) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Not valid part of a connection */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 NF_CT_STAT_INC_ATOMIC(net, invalid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D NF_ACCEPT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D syn_proxy_pre_call(protonum, sk=
b, NULL, ctinfo);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret =3D=3D NF_ACCEPT)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NF_CT_STAT_INC_ATOMIC(n=
et, invalid);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
>
> @@ -869,6 +890,9 @@ nf_conntrack_in(struct net *net, u_int8_t pf, uns=
igned int hooknum,
>
> =A0 =A0 =A0 =A0NF_CT_ASSERT(skb->nfct);
>
> + =A0 =A0 =A0 ret =3D syn_proxy_pre_call(protonum, skb, ct, ctinfo);
> + =A0 =A0 =A0 if (ret !=3D NF_ACCEPT)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> =A0 =A0 =A0 =A0ret =3D l4proto->packet(ct, skb, dataoff, ctinfo, pf, =
hooknum);
> =A0 =A0 =A0 =A0if (ret <=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Invalid: inverse of the return code=
 tells
> @@ -1476,6 +1500,17 @@ s16 (*nf_ct_nat_offset)(const struct nf_conn *=
ct,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 seq);
> =A0EXPORT_SYMBOL_GPL(nf_ct_nat_offset);
>
> +#if defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY) || \
> + =A0 =A0defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY_MODULE)
> +unsigned int (*syn_proxy_pre_hook)(struct sk_buff *skb, struct nf_co=
nn *ct,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
enum ip_conntrack_info ctinfo);
> +EXPORT_SYMBOL(syn_proxy_pre_hook);
> +
> +unsigned int (*syn_proxy_post_hook)(struct sk_buff *skb, struct nf_c=
onn *ct,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 enum ip_conntrack_info ctinfo);
> +EXPORT_SYMBOL(syn_proxy_post_hook);
> +#endif
> +
> =A0int nf_conntrack_init(struct net *net)
> =A0{
> =A0 =A0 =A0 =A0int ret;
> @@ -1496,6 +1531,12 @@ int nf_conntrack_init(struct net *net)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Howto get NAT offsets */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_assign_pointer(nf_ct_nat_offset, N=
ULL);
> +
> +#if defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY) || \
> + =A0 =A0defined(CONFIG_NETFILTER_XT_TARGET_SYNPROXY_MODULE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(syn_proxy_pre_hook, =
NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(syn_proxy_post_hook,=
 NULL);
> +#endif
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return 0;
>
> diff --git a/net/netfilter/xt_SYNPROXY.c b/net/netfilter/xt_SYNPROXY.=
c
> new file mode 100644
> index 0000000..1a55f33
> --- /dev/null
> +++ b/net/netfilter/xt_SYNPROXY.c
> @@ -0,0 +1,679 @@
> +/* (C) 2010- Changli Gao <xiaosuo@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + *
> + * It bases on ipt_REJECT.c
> + */
> +#define pr_fmt(fmt) "SYNPROXY: " fmt
> +#include <linux/module.h>
> +#include <linux/skbuff.h>
> +#include <linux/slab.h>
> +#include <linux/ip.h>
> +#include <linux/udp.h>
> +#include <linux/icmp.h>
> +#include <linux/unaligned/access_ok.h>
> +#include <net/icmp.h>
> +#include <net/ip.h>
> +#include <net/tcp.h>
> +#include <net/route.h>
> +#include <net/dst.h>
> +#include <net/netfilter/nf_conntrack.h>
> +#include <net/netfilter/nf_conntrack_extend.h>
> +#include <linux/netfilter/x_tables.h>
> +#include <linux/netfilter_ipv4/ip_tables.h>
> +
> +MODULE_LICENSE("GPL");
> +MODULE_AUTHOR("Changli Gao <xiaosuo@gmail.com>");
> +MODULE_DESCRIPTION("Xtables: \"SYNPROXY\" target for IPv4");
> +MODULE_ALIAS("ipt_SYNPROXY");
> +
> +enum {
> + =A0 =A0 =A0 TCP_SEND_FLAG_NOTRACE =A0 =3D 0x1,
> + =A0 =A0 =A0 TCP_SEND_FLAG_SYNCOOKIE =3D 0x2,
> + =A0 =A0 =A0 TCP_SEND_FLAG_ACK2SYN =A0 =3D 0x4,
> +};
> +
> +struct syn_proxy_state {
> + =A0 =A0 =A0 u16 =A0 =A0 seq_inited;
> + =A0 =A0 =A0 __be16 =A0window;
> + =A0 =A0 =A0 u32 =A0 =A0 seq_diff;
> +};
> +
> +static int get_mtu(const struct dst_entry *dst)
> +{
> + =A0 =A0 =A0 int mtu;
> +
> + =A0 =A0 =A0 mtu =3D dst_mtu(dst);
> + =A0 =A0 =A0 if (mtu)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return mtu;
> +
> + =A0 =A0 =A0 return dst->dev ? dst->dev->mtu : 0;
> +}
> +
> +static int get_advmss(const struct dst_entry *dst)
> +{
> + =A0 =A0 =A0 int advmss;
> +
> + =A0 =A0 =A0 advmss =3D dst_metric(dst, RTAX_ADVMSS);
> + =A0 =A0 =A0 if (advmss)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return advmss;
> + =A0 =A0 =A0 advmss =3D get_mtu(dst);
> + =A0 =A0 =A0 if (advmss)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return advmss - (sizeof(struct iphdr) +=
 sizeof(struct tcphdr));
> +
> + =A0 =A0 =A0 return TCP_MSS_DEFAULT;
> +}
> +
> +static int syn_proxy_route(struct sk_buff *skb, struct net *net, u16=
 *pmss)
> +{
> + =A0 =A0 =A0 const struct iphdr *iph =3D ip_hdr(skb);
> + =A0 =A0 =A0 struct rtable *rt;
> + =A0 =A0 =A0 struct flowi fl =3D {};
> + =A0 =A0 =A0 unsigned int type;
> + =A0 =A0 =A0 int flags =3D 0;
> + =A0 =A0 =A0 int err;
> + =A0 =A0 =A0 u16 mss;
> +
> + =A0 =A0 =A0 type =3D inet_addr_type(net, iph->saddr);
> + =A0 =A0 =A0 if (type !=3D RTN_LOCAL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 type =3D inet_addr_type(net, iph->daddr=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (type =3D=3D RTN_LOCAL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags |=3D FLOWI_FLAG_A=
NYSRC;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (type =3D=3D RTN_LOCAL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fl.nl_u.ip4_u.daddr =3D iph->daddr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fl.nl_u.ip4_u.saddr =3D iph->saddr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fl.nl_u.ip4_u.tos =3D RT_TOS(iph->tos);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fl.flags =3D flags;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ip_route_output_key(net, &rt, &=
fl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_dst_set(skb, &rt->dst);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* non-local src, find valid iif to sat=
isfy
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* rp-filter when calling ip_route_in=
put. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fl.nl_u.ip4_u.daddr =3D iph->saddr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ip_route_output_key(net, &rt, &=
fl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D ip_route_input(skb, iph->daddr,=
 iph->saddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0RT_TOS(iph->tos), rt->dst.dev);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dst_release(&rt->dst);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pmss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mss =3D get_advmss(&rt-=
>dst);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (*pmss > mss)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *pmss =3D=
 mss;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dst_release(&rt->dst);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 err =3D skb_dst(skb)->error;
> + =A0 =A0 =A0 if (!err && pmss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mss =3D get_advmss(skb_dst(skb));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (*pmss > mss)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *pmss =3D mss;
> + =A0 =A0 =A0 }
> +
> +out:
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int tcp_send(__be32 src, __be32 dst, __be16 sport, __be16 dpo=
rt,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 seq, u32 ack_seq, __be16 wi=
ndow, u16 mss, u8 tcp_flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 tos, struct net_device *dev,=
 int flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *oskb)
> +{
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 struct iphdr *iph;
> + =A0 =A0 =A0 struct tcphdr *th;
> + =A0 =A0 =A0 int err, len;
> +
> + =A0 =A0 =A0 len =3D sizeof(*th);
> + =A0 =A0 =A0 if (mss)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D TCPOLEN_MSS;
> +
> + =A0 =A0 =A0 skb =3D NULL;
> + =A0 =A0 =A0 /* caller must give me a large enough oskb */
> + =A0 =A0 =A0 if (oskb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned char *odata =3D oskb->data;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_recycle_check(oskb, 0)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 oskb->data =3D odata;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reset_tail_pointer(=
oskb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D oskb;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("recycle skb\n=
");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D alloc_skb(LL_MAX_HEADER + sizeo=
f(*iph) + len, GFP_ATOMIC);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reserve(skb, LL_MAX_HEADER);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 skb_reset_network_header(skb);
> + =A0 =A0 =A0 if (!(flags & TCP_SEND_FLAG_ACK2SYN) || skb !=3D oskb) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph =3D (struct iphdr *)skb_put(skb, si=
zeof(*iph));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->version =A0 =A0=3D 4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->ihl =A0 =A0 =A0 =A0=3D sizeof(*iph=
) / 4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->tos =A0 =A0 =A0 =A0=3D tos;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* tot_len is set in ip_local_out() */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->id =A0 =A0 =A0 =A0 =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->frag_off =A0 =3D htons(IP_DF);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->protocol =A0 =3D IPPROTO_TCP;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->saddr =A0 =A0 =A0=3D src;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->daddr =A0 =A0 =A0=3D dst;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 th =3D (struct tcphdr *)skb_put(skb, le=
n);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 th->source =A0 =A0 =A0=3D sport;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 th->dest =A0 =A0 =A0 =A0=3D dport;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph =3D (struct iphdr *)skb->data;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->id =A0 =A0 =A0 =A0 =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->frag_off =A0 =3D htons(IP_DF);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_put(skb, iph->ihl * 4 + len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 th =3D (struct tcphdr *)(skb->data + ip=
h->ihl * 4);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 th->seq =A0 =A0 =A0 =A0 =3D htonl(seq);
> + =A0 =A0 =A0 th->ack_seq =A0 =A0 =3D htonl(ack_seq);
> + =A0 =A0 =A0 tcp_flag_byte(th) =3D tcp_flags;
> + =A0 =A0 =A0 th->doff =A0 =A0 =A0 =A0=3D len / 4;
> + =A0 =A0 =A0 th->window =A0 =A0 =A0=3D window;
> + =A0 =A0 =A0 th->urg_ptr =A0 =A0 =3D 0;
> +
> + =A0 =A0 =A0 skb->protocol =3D htons(ETH_P_IP);
> + =A0 =A0 =A0 if ((flags & TCP_SEND_FLAG_SYNCOOKIE) && mss)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D syn_proxy_route(skb, dev_net(de=
v), &mss);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D syn_proxy_route(skb, dev_net(de=
v), NULL);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;
> +
> + =A0 =A0 =A0 if ((flags & TCP_SEND_FLAG_SYNCOOKIE)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 th->seq =3D htonl(__coo=
kie_v4_init_sequence(dst, src,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dport, spo=
rt,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ack_seq - =
1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &mss));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mss =3D TCP_MSS_DEFAULT=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 th->seq =3D htonl(__coo=
kie_v4_init_sequence(dst, src,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dport, spo=
rt,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ack_seq - =
1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &mss));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mss =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (mss)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 * (__force __be32 *)(th + 1) =3D htonl(=
(TCPOPT_MSS << 24) |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(TCPOLEN_MSS << 16) |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mss);
> + =A0 =A0 =A0 skb->ip_summed =3D CHECKSUM_PARTIAL;
> + =A0 =A0 =A0 th->check =3D ~tcp_v4_check(len, src, dst, 0);
> + =A0 =A0 =A0 skb->csum_start =3D (unsigned char *)th - skb->head;
> + =A0 =A0 =A0 skb->csum_offset =3D offsetof(struct tcphdr, check);
> +
> + =A0 =A0 =A0 if (!(flags & TCP_SEND_FLAG_ACK2SYN) || skb !=3D oskb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iph->ttl =A0 =A0 =A0 =A0=3D dst_metric(=
skb_dst(skb), RTAX_HOPLIMIT);
> +
> + =A0 =A0 =A0 if (skb->len > get_mtu(skb_dst(skb))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (printk_ratelimit())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_warning("%s has smal=
ler mtu: %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
skb_dst(skb)->dev->name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
get_mtu(skb_dst(skb)));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if ((flags & TCP_SEND_FLAG_NOTRACE)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->nfct =3D &nf_ct_untracked_get()->c=
t_general;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->nfctinfo =3D IP_CT_NEW;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nf_conntrack_get(skb->nfct);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 pr_debug("ip_local_out: %pI4n:%hu -> %pI4n:%hu (seq=3D%=
u, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"ack_seq=3D%u mss=3D%hu flags=3D%hhx=
)\n", &src, ntohs(th->source),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&dst, ntohs(th->dest), ntohl(th->seq=
), ack_seq, mss,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcp_flags);
> +
> + =A0 =A0 =A0 err =3D ip_local_out(skb);
> + =A0 =A0 =A0 if (err > 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D net_xmit_errno(err);
> +
> + =A0 =A0 =A0 pr_debug("ip_local_out: return with %d\n", err);
> +out:
> + =A0 =A0 =A0 if (oskb && oskb !=3D skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_skb(oskb);
> +
> + =A0 =A0 =A0 return err;
> +
> +err_out:
> + =A0 =A0 =A0 kfree_skb(skb);
> + =A0 =A0 =A0 goto out;
> +}
> +
> +static int get_mss(u8 *data, int len)
> +{
> + =A0 =A0 =A0 u8 olen;
> +
> + =A0 =A0 =A0 while (len >=3D TCPOLEN_MSS) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (data[0]) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TCPOPT_EOL:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TCPOPT_NOP:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 data++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len--;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case TCPOPT_MSS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (data[1] !=3D TCPOLE=
N_MSS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return get_unaligned_be=
16(data + 2);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 olen =3D data[1];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (olen < 2 || olen > =
len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 data +=3D olen;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 len -=3D olen;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static DEFINE_PER_CPU(struct syn_proxy_state, syn_proxy_state);
> +
> +/* syn_proxy_pre isn't under the protection of nf_conntrack_proto_tc=
p.c */
> +static unsigned int syn_proxy_pre(struct sk_buff *skb, struct nf_con=
n *ct,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enu=
m ip_conntrack_info ctinfo)
> +{
> + =A0 =A0 =A0 struct syn_proxy_state *state;
> + =A0 =A0 =A0 struct iphdr *iph;
> + =A0 =A0 =A0 struct tcphdr *th, _th;
> +
> + =A0 =A0 =A0 /* only support IPv4 now */
> + =A0 =A0 =A0 iph =3D ip_hdr(skb);
> + =A0 =A0 =A0 if (iph->version !=3D 4)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
> +
> + =A0 =A0 =A0 th =3D skb_header_pointer(skb, iph->ihl * 4, sizeof(_th=
), &_th);
> + =A0 =A0 =A0 if (th =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_DROP;
> +
> + =A0 =A0 =A0 if (!ct || !nf_ct_is_confirmed(ct)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!th->syn && th->ack) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 mss;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *rec_skb=
;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mss =3D cookie_v4_check=
_sequence(iph, th,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntohl(th->ack_seq) - 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mss)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
NF_ACCEPT;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("%pI4n:%hu -> =
%pI4n:%hu(mss=3D%hu)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&iph=
->saddr, ntohs(th->source),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&iph=
->daddr, ntohs(th->dest), mss);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_tailroom(skb) <=
 TCPOLEN_MSS &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->len < iph-=
>ihl * 4 + sizeof(*th) + TCPOLEN_MSS)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec_skb=
 =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rec_skb=
 =3D skb;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_bh_disable();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state =3D &__get_cpu_va=
r(syn_proxy_state);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->seq_inited =3D 1=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->window =3D th->w=
indow;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->seq_diff =3D nto=
hl(th->ack_seq) - 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rec_skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_sen=
d(iph->saddr, iph->daddr, 0, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0ntohl(th->seq) - 1, 0, th->window,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0mss, TCPHDR_SYN, 0, skb->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0TCP_SEND_FLAG_ACK2SYN, rec_skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_sen=
d(iph->saddr, iph->daddr, th->source,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0th->dest, ntohl(th->seq) - 1, 0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0th->window, mss, TCPHDR_SYN,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0iph->tos, skb->dev, 0, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->seq_inited =3D 0=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_bh_enable();
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!rec_skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree_s=
kb(skb);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_STOLEN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ct || !th->syn || th->ack)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D NF_ACCEPT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_bh_disable();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 state =3D &__get_cpu_var(syn_proxy_stat=
e);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (state->seq_inited) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct syn_proxy_state =
*nstate;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nstate =3D nf_ct_ext_ad=
d(ct, NF_CT_EXT_SYNPROXY,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0GFP_ATOMIC);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nstate !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nstate-=
>seq_inited =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nstate-=
>window =3D state->window;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nstate-=
>seq_diff =3D state->seq_diff;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debu=
g("seq_diff: %u\n", nstate->seq_diff);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D=
 NF_DROP;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_bh_enable();
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 state =3D nf_ct_ext_find(ct, NF_CT_EXT_SYNPROXY);
> + =A0 =A0 =A0 if (!state)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
> +
> + =A0 =A0 =A0 if (CTINFO2DIR(ctinfo) =3D=3D IP_CT_DIR_ORIGINAL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __be32 newack;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* don't need to mangle duplicate SYN p=
ackets */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (th->syn && !th->ack)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb_make_writable(skb, ip_hdrlen(s=
kb) + sizeof(*th)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_DROP;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 th =3D (struct tcphdr *)(skb->data + ip=
_hdrlen(skb));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 newack =3D htonl(ntohl(th->ack_seq) - s=
tate->seq_diff);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_proto_csum_replace4(&th->check, sk=
b, th->ack_seq, newack,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A00);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("alter ack seq: %u -> %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntohl(th->ack_seq), =
ntohl(newack));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 th->ack_seq =3D newack;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Simultaneous open ? Oh, no. The conn=
ection between
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* client and us is established. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (th->syn && !th->ack)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_DROP;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NF_ACCEPT;
> +}
> +
> +static unsigned int syn_proxy_mangle_pkt(struct sk_buff *skb, struct=
 iphdr *iph,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0struct tcphdr *th, u32 seq_diff)
> +{
> + =A0 =A0 =A0 __be32 new;
> + =A0 =A0 =A0 int olen;
> +
> + =A0 =A0 =A0 if (skb->len < (iph->ihl + th->doff) * 4)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_DROP;
> + =A0 =A0 =A0 if (!skb_make_writable(skb, (iph->ihl + th->doff) * 4))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_DROP;
> + =A0 =A0 =A0 iph =3D (struct iphdr *)(skb->data);
> + =A0 =A0 =A0 th =3D (struct tcphdr *)(skb->data + iph->ihl * 4);
> +
> + =A0 =A0 =A0 new =3D tcp_flag_word(th) & (~TCP_FLAG_SYN);
> + =A0 =A0 =A0 inet_proto_csum_replace4(&th->check, skb, tcp_flag_word=
(th), new, 0);
> + =A0 =A0 =A0 tcp_flag_word(th) =3D new;
> +
> + =A0 =A0 =A0 new =3D htonl(ntohl(th->seq) + seq_diff);
> + =A0 =A0 =A0 inet_proto_csum_replace4(&th->check, skb, th->seq, new,=
 0);
> + =A0 =A0 =A0 pr_debug("alter seq: %u -> %u\n", ntohl(th->seq), ntohl=
(new));
> + =A0 =A0 =A0 th->seq =3D new;
> +
> + =A0 =A0 =A0 olen =3D th->doff - sizeof(*th) / 4;
> + =A0 =A0 =A0 if (olen) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __be32 *opt;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 opt =3D (__force __be32 *)(th + 1);
> +#define TCPOPT_EOL_WORD ((TCPOPT_EOL << 24) + (TCPOPT_EOL << 16) + \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(TCPOPT_EOL << 8) + =
TCPOPT_EOL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_proto_csum_replace4(&th->check, sk=
b, *opt, TCPOPT_EOL_WORD,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A00);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *opt =3D TCPOPT_EOL_WORD;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NF_ACCEPT;
> +}
> +
> +static unsigned int syn_proxy_post(struct sk_buff *skb, struct nf_co=
nn *ct,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
enum ip_conntrack_info ctinfo)
> +{
> + =A0 =A0 =A0 struct syn_proxy_state *state;
> + =A0 =A0 =A0 struct iphdr *iph;
> + =A0 =A0 =A0 struct tcphdr *th;
> +
> + =A0 =A0 =A0 /* untraced packets don't have NF_CT_EXT_SYNPROXY ext, =
as they don't
> + =A0 =A0 =A0 =A0* enter syn_proxy_pre() */
> + =A0 =A0 =A0 state =3D nf_ct_ext_find(ct, NF_CT_EXT_SYNPROXY);
> + =A0 =A0 =A0 if (state =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
> +
> + =A0 =A0 =A0 iph =3D ip_hdr(skb);
> + =A0 =A0 =A0 if (!skb_make_writable(skb, iph->ihl * 4 + sizeof(*th))=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_DROP;
> + =A0 =A0 =A0 th =3D (struct tcphdr *)(skb->data + iph->ihl * 4);
> + =A0 =A0 =A0 if (!state->seq_inited) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (th->syn) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* It must be from orig=
inal direction, as the ones
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* from the other sid=
e are dropped in function
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* syn_proxy_pre() */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!th->ack)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
NF_ACCEPT;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("SYN-ACK %pI4n=
:%hu -> %pI4n:%hu "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"(se=
q=3D%u ack_seq=3D%u)\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&iph=
->saddr, ntohs(th->source), &iph->daddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntoh=
s(th->dest), ntohl(th->seq),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntoh=
l(th->ack_seq));
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* SYN-ACK from reply d=
irection with the protection
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* of conntrack */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_bh(&ct->lock)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!state->seq_inited)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->=
seq_inited =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debu=
g("update seq_diff %u -> %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0state->seq_diff,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0state->seq_diff - ntohl(th->seq));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->=
seq_diff -=3D ntohl(th->seq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_bh(&ct->loc=
k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_send(iph->daddr, ip=
h->saddr, th->dest, th->source,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntoh=
l(th->ack_seq),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntoh=
l(th->seq) + 1 + state->seq_diff,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat=
e->window, 0, TCPHDR_ACK, iph->tos,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb-=
>dev, 0, NULL);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return syn_proxy_mangle=
_pkt(skb, iph, th,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 state->seq_diff + 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __be32 newseq;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!th->rst)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
NF_ACCEPT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 newseq =3D htonl(state-=
>seq_diff + 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_proto_csum_replace=
4(&th->check, skb, th->seq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0newseq, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("alter RST seq=
: %u -> %u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntoh=
l(th->seq), ntohl(newseq));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 th->seq =3D newseq;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* ct should be in ESTABLISHED state, but if the ack pa=
ckets from
> + =A0 =A0 =A0 =A0* us are lost. */
> + =A0 =A0 =A0 if (th->syn) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!th->ack)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_ACCEPT;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_send(iph->daddr, iph->saddr, th->de=
st, th->source,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntohl(th->ack_seq),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntohl(th->seq) + 1 +=
 state->seq_diff,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0state->window, 0, TC=
PHDR_ACK, iph->tos,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->dev, 0, NULL);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return syn_proxy_mangle_pkt(skb, iph, t=
h, state->seq_diff + 1);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (CTINFO2DIR(ctinfo) =3D=3D IP_CT_DIR_REPLY) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __be32 newseq;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 newseq =3D htonl(ntohl(th->seq) + state=
->seq_diff);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 inet_proto_csum_replace4(&th->check, sk=
b, th->seq, newseq, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("alter seq: %u -> %u\n", ntohl=
(th->seq),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntohl(newseq));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 th->seq =3D newseq;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return NF_ACCEPT;
> +}
> +
> +static unsigned int tcp_process(struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 const struct iphdr *iph;
> + =A0 =A0 =A0 const struct tcphdr *th;
> + =A0 =A0 =A0 int err;
> + =A0 =A0 =A0 u16 mss;
> +
> + =A0 =A0 =A0 iph =3D ip_hdr(skb);
> + =A0 =A0 =A0 if (iph->frag_off & htons(IP_OFFSET))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 if (!pskb_may_pull(skb, iph->ihl * 4 + sizeof(*th)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 th =3D (const struct tcphdr *)(skb->data + iph->ihl * 4=
);
> + =A0 =A0 =A0 if ((tcp_flag_byte(th) &
> + =A0 =A0 =A0 =A0 =A0 =A0(TCPHDR_FIN | TCPHDR_RST | TCPHDR_ACK | TCPH=
DR_SYN)) !=3D TCPHDR_SYN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 if (nf_ip_checksum(skb, NF_INET_PRE_ROUTING, iph->ihl *=
 4, IPPROTO_TCP))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 mss =3D 0;
> + =A0 =A0 =A0 if (th->doff > sizeof(*th) / 4) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pskb_may_pull(skb, (iph->ihl + th-=
>doff) * 4))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D get_mss((u8 *)(th + 1), th->dof=
f * 4 - sizeof(*th));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err !=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mss =3D err;
> + =A0 =A0 =A0 } else if (th->doff !=3D sizeof(*th) / 4)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 tcp_send(iph->daddr, iph->saddr, th->dest, th->source, =
0,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ntohl(th->seq) + 1, 0, mss, TCPHDR_S=
YN | TCPHDR_ACK,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iph->tos, skb->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0TCP_SEND_FLAG_NOTRACE | TCP_SEND_FLA=
G_SYNCOOKIE, skb);
> +
> + =A0 =A0 =A0 return NF_STOLEN;
> +
> +out:
> + =A0 =A0 =A0 return NF_DROP;
> +}
> +
> +static unsigned int synproxy_tg(struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const s=
truct xt_action_param *par)
> +{
> + =A0 =A0 =A0 struct nf_conn *ct;
> + =A0 =A0 =A0 enum ip_conntrack_info ctinfo;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 /* received from lo */
> + =A0 =A0 =A0 ct =3D nf_ct_get(skb, &ctinfo);
> + =A0 =A0 =A0 if (ct)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return IPT_CONTINUE;
> +
> + =A0 =A0 =A0 local_bh_disable();
> + =A0 =A0 =A0 if (!__get_cpu_var(syn_proxy_state).seq_inited)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D tcp_process(skb);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D IPT_CONTINUE;
> + =A0 =A0 =A0 local_bh_enable();
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static int synproxy_tg_check(const struct xt_tgchk_param *par)
> +{
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 ret =3D nf_ct_l3proto_try_module_get(par->family);
> + =A0 =A0 =A0 if (ret < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("cannot load conntrack support =
for proto=3D%u\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 par->family);
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +static void synproxy_tg_destroy(const struct xt_tgdtor_param *par)
> +{
> + =A0 =A0 =A0 nf_ct_l3proto_module_put(par->family);
> +}
> +
> +static struct xt_target synproxy_tg_reg __read_mostly =3D {
> + =A0 =A0 =A0 .name =A0 =A0 =A0 =A0 =A0 =3D "SYNPROXY",
> + =A0 =A0 =A0 .family =A0 =A0 =A0 =A0 =3D NFPROTO_IPV4,
> + =A0 =A0 =A0 .target =A0 =A0 =A0 =A0 =3D synproxy_tg,
> + =A0 =A0 =A0 .table =A0 =A0 =A0 =A0 =A0=3D "raw",
> + =A0 =A0 =A0 .hooks =A0 =A0 =A0 =A0 =A0=3D 1 << NF_INET_PRE_ROUTING,
> + =A0 =A0 =A0 .proto =A0 =A0 =A0 =A0 =A0=3D IPPROTO_TCP,
> + =A0 =A0 =A0 .checkentry =A0 =A0 =3D synproxy_tg_check,
> + =A0 =A0 =A0 .destroy =A0 =A0 =A0 =A0=3D synproxy_tg_destroy,
> + =A0 =A0 =A0 .me =A0 =A0 =A0 =A0 =A0 =A0 =3D THIS_MODULE,
> +};
> +
> +static struct nf_ct_ext_type syn_proxy_state_ext __read_mostly =3D {
> + =A0 =A0 =A0 .len =A0 =A0=3D sizeof(struct syn_proxy_state),
> + =A0 =A0 =A0 .align =A0=3D __alignof__(struct syn_proxy_state),
> + =A0 =A0 =A0 .id =A0 =A0 =3D NF_CT_EXT_SYNPROXY,
> +};
> +
> +static int __init synproxy_tg_init(void)
> +{
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 rcu_assign_pointer(syn_proxy_pre_hook, syn_proxy_pre);
> + =A0 =A0 =A0 rcu_assign_pointer(syn_proxy_post_hook, syn_proxy_post)=
;
> + =A0 =A0 =A0 err =3D nf_ct_extend_register(&syn_proxy_state_ext);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_out;
> + =A0 =A0 =A0 err =3D xt_register_target(&synproxy_tg_reg);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_out2;
> +
> + =A0 =A0 =A0 return err;
> +
> +err_out2:
> + =A0 =A0 =A0 nf_ct_extend_unregister(&syn_proxy_state_ext);
> +err_out:
> + =A0 =A0 =A0 rcu_assign_pointer(syn_proxy_post_hook, NULL);
> + =A0 =A0 =A0 rcu_assign_pointer(syn_proxy_pre_hook, NULL);
> + =A0 =A0 =A0 rcu_barrier();
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +static void __exit synproxy_tg_exit(void)
> +{
> + =A0 =A0 =A0 xt_unregister_target(&synproxy_tg_reg);
> + =A0 =A0 =A0 nf_ct_extend_unregister(&syn_proxy_state_ext);
> + =A0 =A0 =A0 rcu_assign_pointer(syn_proxy_post_hook, NULL);
> + =A0 =A0 =A0 rcu_assign_pointer(syn_proxy_pre_hook, NULL);
> + =A0 =A0 =A0 rcu_barrier();
> +}
> +
> +module_init(synproxy_tg_init);
> +module_exit(synproxy_tg_exit);
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
