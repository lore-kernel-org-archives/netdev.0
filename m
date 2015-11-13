From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: kernel panic in 4.2.3, rb_erase in sch_fq
Date: Fri, 13 Nov 2015 23:41:17 +0200
Message-ID: <0e90d63df7c019906682e9b10290231c@visp.net.lb>
References: <d66d455afe6dd28bed32ed3e17f797b7@visp.net.lb>
 <CAHA+R7MNxEkMfyQa56d0HRk2HxeqsduUfM3BkBh=Oxm2yNBVaA@mail.gmail.com>
 <0705e2b76150c28341d7e1915433450d@visp.net.lb>
 <1446612381.4184.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446612381.4184.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I can confirm, after patch this issue never appeared again. So maybe 
good to push it to stable and etc :) Thanks a lot Eric, you saved me 
again.


Still i have some weird panic issues, maybe related to conntrack, but 
they are rare even on high load, so i am slowly gathering data, and i 
found at least one more person with similar conntrack crashes on latest 
kernels.


On 2015-11-04 06:46, Eric Dumazet wrote:
> On Wed, 2015-11-04 at 06:25 +0200, Denys Fedoryshchenko wrote:
>> On 2015-11-04 00:06, Cong Wang wrote:
>> > On Mon, Nov 2, 2015 at 6:11 AM, Denys Fedoryshchenko
>> > <nuclearcat@nuclearcat.com> wrote:
>> >> Hi!
>> >>
>> >> Actually seems i was getting this panic for a while (once per week) on
>> >> loaded pppoe server, but just now was able to get full panic message.
>> >> After checking commit logs on sch_fq.c i didnt seen any fixes, so
>> >> probably
>> >> upgrading to newer kernel wont help?
>> >
>> >
>> > Can you share your `tc qdisc show dev xxxx` with us? And how to
>> > reproduce
>> > it? I tried to setup htb+fq and then flip the interface back and forth
>> > but I don't
>> > see any crash.
>> My guess it wont be easy to reproduce, it is happening on box with 
>> 4.5k
>> interfaces, that constantly create/delete interfaces,
>> and even with that this problem may happen once per day, or may not
>> happen for 1 week.
>> 
>> Here is script that is being fired after new ppp interface detected. 
>> But
>> pppoe process are independent from
>> process that are "establishing" shapers.
> 
> 
> It is probably a generic bug. sch_fq seems OK to me.
> 
> Somehow nobody tries to change qdisc hundred times per second ;)
> 
> Could you try following patch ?
> 
> It seems to 'fix' the issue for me.
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8ce3f74cd6b9..bf136103bc7b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2880,6 +2880,12 @@ static inline int __dev_xmit_skb(struct sk_buff
> *skb, struct Qdisc *q,
>  		spin_lock(&q->busylock);
> 
>  	spin_lock(root_lock);
> +	if (unlikely(q != rcu_dereference_bh(txq->qdisc))) {
> +		pr_err_ratelimited("Arg, qdisc changed ! state %lx\n", q->state);
> +		kfree_skb(skb);
> +		rc = NET_XMIT_DROP;
> +		goto end;
> +	}
>  	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
>  		kfree_skb(skb);
>  		rc = NET_XMIT_DROP;
> @@ -2913,6 +2919,7 @@ static inline int __dev_xmit_skb(struct sk_buff
> *skb, struct Qdisc *q,
>  			__qdisc_run(q);
>  		}
>  	}
> +end:
>  	spin_unlock(root_lock);
>  	if (unlikely(contended))
>  		spin_unlock(&q->busylock);
