From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next-2.6] net: Consistent skb timestamping
Date: Thu, 6 May 2010 08:12:57 -0700
Message-ID: <AANLkTikLgHvtpCtBTKmJZBwixmZDHjRjGb1c59oAemli@mail.gmail.com>
References: <1273147309.2357.59.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:40134 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758601Ab0EFPNB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 11:13:01 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o46FCx2Z027920
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 08:12:59 -0700
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by hpaq13.eem.corp.google.com with ESMTP id o46FCIoe013028
	for <netdev@vger.kernel.org>; Thu, 6 May 2010 08:12:58 -0700
Received: by pwi10 with SMTP id 10so35280pwi.0
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 08:12:57 -0700 (PDT)
In-Reply-To: <1273147309.2357.59.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 6, 2010 at 5:01 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> With RPS inclusion, skb timestamping is not consistent in RX path.
>
> If netif_receive_skb() is used, its deferred after RPS dispatch.
>
> If netif_rx() is used, its done before RPS dispatch.
>
> This can give strange tcpdump timestamps results.
>
> I think timestamping should be done as soon as possible in the receiv=
e
> path, to get meaningful values (ie timestamps taken at the time packe=
t
> was delivered by NIC driver to our stack), even if NAPI already can
> defer timestamping a bit (RPS can help to reduce the gap)
>
The counter argument to this is that it moves another thing into the
serialized path for networking which slows everyone down.  I'm not
concerned about when tcpdump is running since performance will suck
anyway, but what is bad is if any single socket in the system turns on
SO_TIMESTAMP, overhead is incurred on *every* packet.  This happens
regardless of whether the application ever actually gets a timestamp,
or even whether timestamps are supported by the protocol (try setting
SO_TIMESTAMP on a TCP socket ;-) ).  I'm contemplating changing
SO_TIMESTAMP to not enable global timestamps, but only take the
timestamp for a packet once the socket is identified and the timestamp
flag is set (this is the technique done in FreeBSD and Solaris, so I
believe the external semantics would still be valid).

> Remove timestamping from __netif_receive_skb, and add it to
> netif_receive_skb(), before RPS.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> =A0net/core/dev.c | =A0 46 ++++++++++++++++++++++++++----------------=
----
> =A01 file changed, 26 insertions(+), 20 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 36d53be..3278003 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1454,7 +1454,7 @@ void net_disable_timestamp(void)
> =A0}
> =A0EXPORT_SYMBOL(net_disable_timestamp);
>
> -static inline void net_timestamp(struct sk_buff *skb)
> +static inline void net_timestamp_set(struct sk_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0if (atomic_read(&netstamp_needed))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__net_timestamp(skb);
> @@ -1462,6 +1462,12 @@ static inline void net_timestamp(struct sk_buf=
f *skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->tstamp.tv64 =3D 0;
> =A0}
>
> +static inline void net_timestamp_check(struct sk_buff *skb)
> +{
> + =A0 =A0 =A0 if (!skb->tstamp.tv64 && atomic_read(&netstamp_needed))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __net_timestamp(skb);
> +}
> +
> =A0/**
> =A0* dev_forward_skb - loopback an skb to another netif
> =A0*
> @@ -1509,9 +1515,9 @@ static void dev_queue_xmit_nit(struct sk_buff *=
skb, struct net_device *dev)
>
> =A0#ifdef CONFIG_NET_CLS_ACT
> =A0 =A0 =A0 =A0if (!(skb->tstamp.tv64 && (G_TC_FROM(skb->tc_verd) & A=
T_INGRESS)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 net_timestamp(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 net_timestamp_set(skb);
> =A0#else
> - =A0 =A0 =A0 net_timestamp(skb);
> + =A0 =A0 =A0 net_timestamp_set(skb);
> =A0#endif
>
> =A0 =A0 =A0 =A0rcu_read_lock();
> @@ -2458,8 +2464,7 @@ int netif_rx(struct sk_buff *skb)
> =A0 =A0 =A0 =A0if (netpoll_rx(skb))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NET_RX_DROP;
>
> - =A0 =A0 =A0 if (!skb->tstamp.tv64)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 net_timestamp(skb);
> + =A0 =A0 =A0 net_timestamp_check(skb);
>
> =A0#ifdef CONFIG_RPS
> =A0 =A0 =A0 =A0{
> @@ -2780,9 +2785,6 @@ static int __netif_receive_skb(struct sk_buff *=
skb)
> =A0 =A0 =A0 =A0int ret =3D NET_RX_DROP;
> =A0 =A0 =A0 =A0__be16 type;
>
> - =A0 =A0 =A0 if (!skb->tstamp.tv64)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 net_timestamp(skb);
> -
> =A0 =A0 =A0 =A0if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receiv=
e(skb))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NET_RX_SUCCESS;
>
> @@ -2899,23 +2901,27 @@ out:
> =A0*/
> =A0int netif_receive_skb(struct sk_buff *skb)
> =A0{
> + =A0 =A0 =A0 net_timestamp_check(skb);
> +
> =A0#ifdef CONFIG_RPS
> - =A0 =A0 =A0 struct rps_dev_flow voidflow, *rflow =3D &voidflow;
> - =A0 =A0 =A0 int cpu, ret;
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct rps_dev_flow voidflow, *rflow =3D=
 &voidflow;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int cpu, ret;
>
> - =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>
> - =A0 =A0 =A0 cpu =3D get_rps_cpu(skb->dev, skb, &rflow);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu =3D get_rps_cpu(skb->dev, skb, &rfl=
ow);
>
> - =A0 =A0 =A0 if (cpu >=3D 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D enqueue_to_backlog(skb, cpu, &r=
flow->last_qtail);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __netif_receive_skb(skb);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cpu >=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D enqueue_to_back=
log(skb, cpu, &rflow->last_qtail);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __netif_receive=
_skb(skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> =A0#else
> =A0 =A0 =A0 =A0return __netif_receive_skb(skb);
> =A0#endif
>
>
>
