From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] tcp: Use absolute system clock for TCP timestamps
Date: Thu, 24 Sep 2015 07:49:08 -0700
Message-ID: <CANn89iJ+SrGJHJGYVpi7SnTkefCB6iq9KzvcU_iYTcz+WvYZPw@mail.gmail.com>
References: <CABPcSq+jxgKkuafpt5ubDLj9CBfHE1WFwmY-cGzRxuRsfM0KGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sasha.levin@oracle.com,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Tom Herbert <therbert@google.com>,
	makita.toshiaki@lab.ntt.co.jp, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Marek Majkowski <marek@cloudflare.com>
To: Jovi Zhangwei <jovi@cloudflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CABPcSq+jxgKkuafpt5ubDLj9CBfHE1WFwmY-cGzRxuRsfM0KGw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 7:14 AM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
> From f455dc3958593250909627474100f6cc5c158a5c Mon Sep 17 00:00:00 2001
> From: Marek Majkowski <marek@cloudflare.com>
> Date: Fri, 11 Sep 2015 06:05:07 -0700
> Subject: [PATCH] tcp: Use absolute system clock for TCP timestamps
>
> Using TCP timestamps is beneficial due for to its purpose in PAWS and when
> its role when SYN cookies are enabled. In practice though TCP timestamps are
> often disabled due to being a perceived security issue - they leak Linux
> system uptime.
>
> This patch introduces a kernel option that makes TCP timestamp always return
> an absolute value derived from a system clock as opposed to jiffies from
> boot.
>
> This patch is based on the approach taken by grsecurity:
>     https://grsecurity.net/~spender/random_timestamp.diff
>

Please do not send html messages, they wont reach lists.

May I ask how this patch was really tested ?

It cannot possibly work on current kernels, as TCP Timestamps are
generated from clock samples taken from skb_mstamp_get(),
and you did not change it.

static inline void skb_mstamp_get(struct skb_mstamp *cl)
{
        u64 val = local_clock();

        do_div(val, NSEC_PER_USEC);
        cl->stamp_us = (u32)val;
        cl->stamp_jiffies = (u32)jiffies;
}

TCP stack uses tcp_time_stamp internally, we do not want to add
overhead adding an offset on all places.

tp->lsndtime is an example, but we have others.

Therefore, I suggest you add a new function and use it only where needed.

static inline u32 secure_tcp_time_stamp(void)
{
   returns (u32)(tcp_time_stamp + rtc_timestamp_base);
}
