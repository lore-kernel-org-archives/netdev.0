From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 17:59:36 -0800
Message-ID: <CAMEtUuyoGjP3q3HZGXD5nGp5X9et2=RcN_aRszgQ_PGM7M+Baw@mail.gmail.com>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
	<1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com>
	<20131203.165034.1085515763685633822.davem@davemloft.net>
	<1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	<1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuzEM957fRjsb5aSG7xHWKp13fy59QxWpsU_=d+-6ydazg@mail.gmail.com>
	<1386117362.30495.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMEtUuy8HA1nOQJTnxy+p7vNFV25zxMAmz1fh2spj0k4hYgh4w@mail.gmail.com>
	<1386120216.30495.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:47628 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755651Ab3LDB7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 20:59:38 -0500
Received: by mail-we0-f181.google.com with SMTP id x55so14624605wes.12
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 17:59:36 -0800 (PST)
In-Reply-To: <1386120216.30495.59.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 5:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2013-12-03 at 16:55 -0800, Alexei Starovoitov wrote:
>> On Tue, Dec 3, 2013 at 4:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Tue, 2013-12-03 at 16:26 -0800, Alexei Starovoitov wrote:
>> >
>> >>
>> >> Could you use some other way to mark skb ?
>> >
>> > I could ;)
>> >
>> >> In tracing we might want to examine skb more carefully and not being
>> >> able to see the device
>> >> will limit the usability of this tracepoint.
>> >
>> > Unfortunately, using skb->dev as a pointer to device would be buggy or
>> > expensive (you would need to take a reference on device in order not
>> > letting it disappear, as we escape RCU protection)
>>
>> well, yes, you might have an skb around when device is already freed
>> when skb_dst_noref.
>> but I'm not suggesting anything expensive. Tracing definitely should
>> not add overhead by doing rcu_lock() or dev_hold(). Instead it can go
>> through skb, skb->dev, skb->dev->xxx via probe_kernel_read(). If dev
>> is gone, it's still safe.
>
> Its certainly not safe to 'probe'.
>
> Its not about faulting inexistent memory, that is the least of the
> problem.
>
> Any kind of information fetched from skb->dev might have been
> overwritten.
>
> You could for example fetch security sensitive data and expose it.

Of course.
Even without walking pointer chains with probe() you could infer all
sorts of info from tracepoints.
That's why tracing filters are for root only.

>> > Anyway, this magic is pretty easy to change, I am open to suggestions.
>>
>> you're the expert :) use skb->mark field, since it's unused during
>> freeing path... ?
>
> cache line miss ;)
>
> skb->dev is in the first cache line, where we access skb->next anyway.
>
> I could use skb->cb[] like the following patch :
>
> +struct __dev_kfree_skb_cb {
> +       unsigned int reason;
> +};
> +
> +static inline struct __dev_kfree_skb_cb *get_kfree_skb_cb(const struct sk_buff *skb)
> +{
> +       return (struct __dev_kfree_skb_cb *)skb->cb;
> +}
> +
> +enum {
> +       SKB_REASON_CONSUMED,
> +       SKB_REASON_DROPPED,
> +};
> +
>  /* Use this variant in places where it could be invoked
>   * from either hardware interrupt or other context, with hardware interrupts
>   * either disabled or enabled.
> + * Note that TX completion should use dev_consume_skb_any()
>   */
> -void dev_kfree_skb_any(struct sk_buff *skb);
> +static inline void dev_kfree_skb_any(struct sk_buff *skb)
> +{
> +       get_kfree_skb_cb(skb)->reason = SKB_REASON_DROPPED;
> +       __dev_kfree_skb_any(skb);
> +}
> +
> +static inline void dev_consume_skb_any(struct sk_buff *skb)
> +{
> +       get_kfree_skb_cb(skb)->reason = SKB_REASON_CONSUMED;
> +       __dev_kfree_skb_any(skb);
> +}

thanks. I think that is much cleaner. Ack.
