From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v3 4/5] skb: add tracepoints to freeing skb
Date: Tue, 20 Jul 2010 06:54:03 +0200
Message-ID: <1279601643.2458.64.camel@edumazet-laptop>
References: <4C44F12F.5090908@jp.fujitsu.com>
	 <4C44F286.1050907@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	nhorman@tuxdriver.com, laijs@cn.fujitsu.com,
	scott.a.mcmillan@intel.com, rostedt@goodmis.org,
	fweisbec@gmail.com, mathieu.desnoyers@polymtl.ca
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C44F286.1050907@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 20 juillet 2010 =C3=A0 09:49 +0900, Koki Sanagi a =C3=A9crit :
> [RFC PATCH v3 4/5] skb: add tracepoints to freeing skb
> This patch adds tracepoint to consume_skb, dev_kfree_skb_irq and
> skb_free_datagram_locked. Combinating with tracepoint on dev_hard_sta=
rt_xmit,
> we can check how long it takes to free transmited packets. And using =
it, we can
> calculate how many packets driver had at that time. It is useful when=
 a drop of
> transmited packet is a problem.
>=20
>           <idle>-0     [001] 241409.218333: consume_skb: skbaddr=3Ddd=
6b2fb8
>           <idle>-0     [001] 241409.490555: dev_kfree_skb_irq: skbadd=
r=3Df5e29840
>=20
>         udp-recv-302   [001] 515031.206008: skb_free_datagram_locked:=
 skbaddr=3Df5b1d900
>=20
>=20
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>  include/trace/events/skb.h |   42 ++++++++++++++++++++++++++++++++++=
++++++++
>  net/core/datagram.c        |    1 +
>  net/core/dev.c             |    2 ++
>  net/core/skbuff.c          |    1 +
>  4 files changed, 46 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/trace/events/skb.h b/include/trace/events/skb.h
> index 4b2be6d..84c9041 100644
> --- a/include/trace/events/skb.h
> +++ b/include/trace/events/skb.h
> @@ -35,6 +35,48 @@ TRACE_EVENT(kfree_skb,
>  		__entry->skbaddr, __entry->protocol, __entry->location)
>  );
> =20
> +DECLARE_EVENT_CLASS(free_skb,
> +
> +	TP_PROTO(struct sk_buff *skb),
> +
> +	TP_ARGS(skb),
> +
> +	TP_STRUCT__entry(
> +		__field(	void *,	skbaddr	)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->skbaddr =3D skb;
> +	),
> +
> +	TP_printk("skbaddr=3D%p", __entry->skbaddr)
> +
> +);
> +
> +DEFINE_EVENT(free_skb, consume_skb,
> +
> +	TP_PROTO(struct sk_buff *skb),
> +
> +	TP_ARGS(skb)
> +
> +);
> +
> +DEFINE_EVENT(free_skb, dev_kfree_skb_irq,
> +
> +	TP_PROTO(struct sk_buff *skb),
> +
> +	TP_ARGS(skb)
> +
> +);
> +
> +DEFINE_EVENT(free_skb, skb_free_datagram_locked,
> +
> +	TP_PROTO(struct sk_buff *skb),
> +
> +	TP_ARGS(skb)
> +
> +);
> +
>  TRACE_EVENT(skb_copy_datagram_iovec,
> =20
>  	TP_PROTO(const struct sk_buff *skb, int len),
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index f5b6f43..1ea32a0 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -231,6 +231,7 @@ void skb_free_datagram_locked(struct sock *sk, st=
ruct sk_buff *skb)
>  {
>  	bool slow;
> =20
> +	trace_skb_free_datagram_locked(skb);

Here you unconditionally trace before the test on skb->users

>  	if (likely(atomic_read(&skb->users) =3D=3D 1))
>  		smp_rmb();
>  	else if (likely(!atomic_dec_and_test(&skb->users)))
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 4acfec6..d979847 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -131,6 +131,7 @@
>  #include <linux/random.h>
>  #include <trace/events/napi.h>
>  #include <trace/events/net.h>
> +#include <trace/events/skb.h>
>  #include <linux/pci.h>
> =20
>  #include "net-sysfs.h"
> @@ -1581,6 +1582,7 @@ void dev_kfree_skb_irq(struct sk_buff *skb)
>  		struct softnet_data *sd;
>  		unsigned long flags;
> =20
> +		trace_dev_kfree_skb_irq(skb);
>  		local_irq_save(flags);
>  		sd =3D &__get_cpu_var(softnet_data);
>  		skb->next =3D sd->completion_queue;
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 34432b4..a7b4036 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -466,6 +466,7 @@ void consume_skb(struct sk_buff *skb)
>  		smp_rmb();
>  	else if (likely(!atomic_dec_and_test(&skb->users)))
>  		return;

While here you trace _after_ the test on skb->users - and a "return;" ,
so you miss some consume_skb() calls


> +	trace_consume_skb(skb);
>  	__kfree_skb(skb);
>  }
>  EXPORT_SYMBOL(consume_skb);
>=20
