From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: Fix potential NULL pointer dereference in __skb_try_recv_datagram
Date: Wed, 30 Dec 2015 15:32:31 +0000
Message-ID: <87fuykuf3k.fsf@doppelsaurus.mobileactivedefense.com>
References: <1451416224-15871-1-git-send-email-jacob@teenage.engineering>
	<87y4cdyrbn.fsf@doppelsaurus.mobileactivedefense.com>
	<20151229.150843.2021692616139434395.davem@davemloft.net>
	<CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <edumazet@google.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Al Viro <viro@zeniv.linux.org.uk>,
	LKML <linux-kernel@vger.kernel.org>
To: Jacob Siverskog <jacob@teenage.engineering>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnXRPtJBoOn+JgXDEUdL07WkbYVViAT_+LBiV4X=NVQ3SiDaQ@mail.gmail.com>
	(Jacob Siverskog's message of "Wed, 30 Dec 2015 12:14:42 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jacob Siverskog <jacob@teenage.engineering> writes:
> On Tue, Dec 29, 2015 at 9:08 PM, David Miller <davem@davemloft.net> wrote:
>> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>> Date: Tue, 29 Dec 2015 19:42:36 +0000
>>
>>> Jacob Siverskog <jacob@teenage.engineering> writes:
>>>> This should fix a NULL pointer dereference I encountered (dump
>>>> below). Since __skb_unlink is called while walking,
>>>> skb_queue_walk_safe should be used.
>>>
>>> The code in question is:
>>  ...
>>> __skb_unlink is only called prior to returning from the function.
>>> Consequently, it won't affect the skb_queue_walk code.
>>
>> Agreed, this patch doesn't fix anything.
>
> Ok. Thanks for your feedback. How do you believe the issue could be
> solved? Investigating it gives:
>
> static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head *list)
> {

[...]

> next->prev = prev;
>      530: e5823004 str r3, [r2, #4]                          <--
> trapping instruction (r2 NULL)
>
> Register contents:
> r7 : c58cfe1c  r6 : c06351d0  r5 : c77810ac  r4 : c583eac0
> r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : 20000013
>
> If I understand this correctly, then r4 = skb, r2 = next, r3 = prev.

Some additional information which may be helpful: The next->prev = prev
was pretty obvious from the original error message alone: The invalid
access happened at 4 but no register contained 4. Considering that this
is for ARM, this must have been caused by an instruction using an
address of the form

[Rx, #4]

ie, value of register x + 4. And the next->prev = prev is the only
access to something located 4 bytes beyond something else.

> Should there be a check for this in __skb_try_recv_datagram?

These lists are supposed to be circular, ie, the next pointer of the
last element should point to the first and the prev pointer of the first
to the last. If there's an element with ->next == NULL on the list,
something either didn't do inserts correctly or corrupted an originally
intact list.

General advice: The original error occurred with 4.3.0. Had this
happened to me, I'd either tried to locate the error in the same kernel
version or to reproduce the bug with the one I was planning to
modify. Trying to fix a 'strange memory access' error which was observed
with version x.y by modifying version x.z is IMHO needlessly moving on
shaky ground.
