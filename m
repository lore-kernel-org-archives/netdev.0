From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in __skb_try_recv_datagram
Date: Wed, 30 Dec 2015 08:26:55 -0500
Message-ID: <CANn89iLpuz4nP+hPoGUHY8KSv=GwSE1x13D3qDeAQDJjV-S7pw@mail.gmail.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	<87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
	<20151229.150843.2021692616139434395.davem@davemloft.net>
	<CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: Jacob Siverskog <jacob@teenage.engineering>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 30, 2015 at 6:14 AM, Jacob Siverskog
<jacob@teenage.engineering> wrote:

> Ok. Thanks for your feedback. How do you believe the issue could be
> solved? Investigating it gives:
>
> static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
> {
> struct sk_buff *next, *prev;
>
> list->qlen--;
>      51c: e2433001 sub r3, r3, #1
>      520: e58b3074 str r3, [fp, #116] ; 0x74
> next   = skb->next;
> prev   = skb->prev;
>      524: e894000c ldm r4, {r2, r3}
> skb->next  = skb->prev = NULL;
>      528: e5841000 str r1, [r4]
>      52c: e5841004 str r1, [r4, #4]
> next->prev = prev;
>      530: e5823004 str r3, [r2, #4]                          <--
> trapping instruction (r2 NULL)
>
> Register contents:
> r7 : c58cfe1c  r6 : c06351d0  r5 : c77810ac  r4 : c583eac0
> r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : 20000013
>
> If I understand this correctly, then r4 = skb, r2 = next, r3 = prev.
>
> Should there be a check for this in __skb_try_recv_datagram?

At this point corruption already happened.
We can not possibly detect every possible corruption caused by bugs
elsewhere in the kernel and just 'recover' at this point.
We must indeed find the root cause and fix it, instead of trying to hide it.

How often can you trigger this bug ?
