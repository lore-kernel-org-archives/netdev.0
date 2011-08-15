From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] tcp: Use LIMIT_NETDEBUG in syn_flood_warning()
Date: Sun, 14 Aug 2011 20:20:34 -0700
Message-ID: <CA+mtBx8zm=VQBFiacuzU6GK8DH65fTRUGYEJZrvk4c8kzLrJCg@mail.gmail.com>
References: <alpine.DEB.2.00.1108102229130.5341@pokey.mtv.corp.google.com>
	<20110810.231318.959972077845910551.davem@davemloft.net>
	<1313044387.3066.8.camel@edumazet-laptop>
	<1313129310.2669.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:26073 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302Ab1HODUn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2011 23:20:43 -0400
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p7F3KbNb018829
	for <netdev@vger.kernel.org>; Sun, 14 Aug 2011 20:20:37 -0700
Received: from iyf13 (iyf13.prod.google.com [10.241.50.77])
	by hpaq11.eem.corp.google.com with ESMTP id p7F3Jajh015057
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 14 Aug 2011 20:20:35 -0700
Received: by iyf13 with SMTP id 13so6724088iyf.16
        for <netdev@vger.kernel.org>; Sun, 14 Aug 2011 20:20:35 -0700 (PDT)
In-Reply-To: <1313129310.2669.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [PATCH] tcp: Use LIMIT_NETDEBUG in syn_flood_warning()
>
> LIMIT_NETDEBUG allows the admin to disable some warning messages :
> echo 0 > /proc/sys/net/core/warnings
>
> Use it to avoid filling syslog on busy servers.
>
> Based on a previous patch from Tom Herbert
>
> Factorize syn_flood_warning() IPv4/IPv6 implementations
>

Acked-by: Tom Herbert <therbert@google.coml>

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Tom Herbert <therbert@google.com>
> ---
> =A0include/net/tcp.h =A0 | =A0 =A01 +
> =A0net/ipv4/tcp_ipv4.c | =A0 14 ++++++--------
> =A0net/ipv6/tcp_ipv6.c | =A0 17 +----------------
> =A03 files changed, 8 insertions(+), 24 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 149a415..964341c 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -460,6 +460,7 @@ extern int tcp_write_wakeup(struct sock *);
> =A0extern void tcp_send_fin(struct sock *sk);
> =A0extern void tcp_send_active_reset(struct sock *sk, gfp_t priority)=
;
> =A0extern int tcp_send_synack(struct sock *);
> +extern void tcp_syn_flood_warning(const struct sk_buff *skb, const c=
har *proto);
> =A0extern void tcp_push_one(struct sock *, unsigned int mss_now);
> =A0extern void tcp_send_ack(struct sock *sk);
> =A0extern void tcp_send_delayed_ack(struct sock *sk);
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 1c12b8e..9e622da 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -808,20 +808,19 @@ static void tcp_v4_reqsk_destructor(struct requ=
est_sock *req)
> =A0 =A0 =A0 =A0kfree(inet_rsk(req)->opt);
> =A0}
>
> -static void syn_flood_warning(const struct sk_buff *skb)
> +void tcp_syn_flood_warning(const struct sk_buff *skb, const char *pr=
oto)
> =A0{
> - =A0 =A0 =A0 const char *msg;
> + =A0 =A0 =A0 const char *msg =3D "Dropping request";
>
> =A0#ifdef CONFIG_SYN_COOKIES
> =A0 =A0 =A0 =A0if (sysctl_tcp_syncookies)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0msg =3D "Sending cookies";
> - =A0 =A0 =A0 else
> =A0#endif
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 msg =3D "Dropping request";
>
> - =A0 =A0 =A0 pr_info("TCP: Possible SYN flooding on port %d. %s.\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ntohs(t=
cp_hdr(skb)->dest), msg);
> + =A0 =A0 =A0 LIMIT_NETDEBUG(KERN_INFO "%s: Possible SYN flooding on =
port %d. %s.\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0proto, ntohs(tcp_hdr(skb=
)->dest), msg);
> =A0}
> +EXPORT_SYMBOL(tcp_syn_flood_warning);
>
> =A0/*
> =A0* Save and compile IPv4 options into the request_sock if needed.
> @@ -1250,8 +1249,7 @@ int tcp_v4_conn_request(struct sock *sk, struct=
 sk_buff *skb)
> =A0 =A0 =A0 =A0 * evidently real one.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (net_ratelimit())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 syn_flood_warning(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_syn_flood_warning(skb, "TCP");
> =A0#ifdef CONFIG_SYN_COOKIES
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sysctl_tcp_syncookies) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0want_cookie =3D 1;
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index d1fb63f..a043386 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -531,20 +531,6 @@ static int tcp_v6_rtx_synack(struct sock *sk, st=
ruct request_sock *req,
> =A0 =A0 =A0 =A0return tcp_v6_send_synack(sk, req, rvp);
> =A0}
>
> -static inline void syn_flood_warning(struct sk_buff *skb)
> -{
> -#ifdef CONFIG_SYN_COOKIES
> - =A0 =A0 =A0 if (sysctl_tcp_syncookies)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"TCPv6: Possible SYN flo=
oding on port %d. "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Sending cookies.\n", nt=
ohs(tcp_hdr(skb)->dest));
> - =A0 =A0 =A0 else
> -#endif
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_INFO
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"TCPv6: Possible SYN flo=
oding on port %d. "
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Dropping request.\n", n=
tohs(tcp_hdr(skb)->dest));
> -}
> -
> =A0static void tcp_v6_reqsk_destructor(struct request_sock *req)
> =A0{
> =A0 =A0 =A0 =A0kfree_skb(inet6_rsk(req)->pktopts);
> @@ -1192,8 +1178,7 @@ static int tcp_v6_conn_request(struct sock *sk,=
 struct sk_buff *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>
> =A0 =A0 =A0 =A0if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (net_ratelimit())
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 syn_flood_warning(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tcp_syn_flood_warning(skb, "TCPv6");
> =A0#ifdef CONFIG_SYN_COOKIES
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sysctl_tcp_syncookies)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0want_cookie =3D 1;
>
>
>
