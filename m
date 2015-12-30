From: Jacob Siverskog <jacob@teenage.engineering>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in __skb_try_recv_datagram
Date: Wed, 30 Dec 2015 12:14:42 +0100
Message-ID: <CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
 <87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com> <20151229.150843.2021692616139434395.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <edumazet@google.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151229.150843.2021692616139434395.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 29, 2015 at 9:08 PM, David Miller <davem@davemloft.net> wrote:
> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Date: Tue, 29 Dec 2015 19:42:36 +0000
>
>> Jacob Siverskog <jacob@teenage.engineering> writes:
>>> This should fix a NULL pointer dereference I encountered (dump
>>> below). Since __skb_unlink is called while walking,
>>> skb_queue_walk_safe should be used.
>>
>> The code in question is:
>  ...
>> __skb_unlink is only called prior to returning from the function.
>> Consequently, it won't affect the skb_queue_walk code.
>
> Agreed, this patch doesn't fix anything.

Ok. Thanks for your feedback. How do you believe the issue could be
solved? Investigating it gives:

static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
{
struct sk_buff *next, *prev;

list->qlen--;
     51c: e2433001 sub r3, r3, #1
     520: e58b3074 str r3, [fp, #116] ; 0x74
next   = skb->next;
prev   = skb->prev;
     524: e894000c ldm r4, {r2, r3}
skb->next  = skb->prev = NULL;
     528: e5841000 str r1, [r4]
     52c: e5841004 str r1, [r4, #4]
next->prev = prev;
     530: e5823004 str r3, [r2, #4]                          <--
trapping instruction (r2 NULL)

Register contents:
r7 : c58cfe1c  r6 : c06351d0  r5 : c77810ac  r4 : c583eac0
r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : 20000013

If I understand this correctly, then r4 = skb, r2 = next, r3 = prev.

Should there be a check for this in __skb_try_recv_datagram?
