From: =?utf-8?Q?Toke_H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>
Subject: Re: [RFC/RFT] mac80211: implement fq_codel for software queuing
Date: Tue, 08 Mar 2016 11:19:59 +0100
Message-ID: <87d1r5tgog.fsf@toke.dk>
References: <1456492163-11437-1-git-send-email-michal.kazior@tieto.com>
	<CAA93jw4XsEnp3jTgPL7OKWTJP-83VwRaCdb+foc8nCuqxk3WZA@mail.gmail.com>
	<CA+BoTQk+3jhwK57_fDw0scNCGzu_Edqp9-Beeppz8xj9kSQcoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dave Taht <dave.taht@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Tim Shepard <shep@alum.mit.edu>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tohojo.dk ([77.235.48.147]:49698 "EHLO mail2.tohojo.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932491AbcCHK1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 05:27:07 -0500
In-Reply-To: <CA+BoTQk+3jhwK57_fDw0scNCGzu_Edqp9-Beeppz8xj9kSQcoQ@mail.gmail.com>
	(Michal Kazior's message of "Tue, 8 Mar 2016 08:12:21 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Kazior <michal.kazior@tieto.com> writes:

>> With large values for flows_cnt, fq, dominates, for small values, aqm
>> does. We did quite a lot of testing at 16 and 32 queues in the early
>> days, with pretty good results, except when we didn't. Cake went whole
>> hog with an 8 way set associative hash leading to "near perfect" fq,
>> which, at the cost of more cpu overhead, could cut the number of
>> queues down by a lot, also. Eric did "perfect" fq with sch_fq...
>
> Out of curiosity - do you have any numbers to compare against
> fq_codel? Like hash collision probability vs number of active flows?

Basically, the analytical expression for hash collisions is fairly
straight forward (though I can't take credit for coming up with it
myself):

Given N bins with M items being hashed into them by a hypothetical
perfectly uniform hash, you get:

  Expected number of bins with x items = N * (1/N)^x * (1 - 1/N) ^ (M - x) * C(M, x)

where C(M, x) is the combinatorial function = M! / (x! * (M-x)!).

By expanding this expression for x=1 and dividing by M, you get the
probability that one of your M items is in its own bin. Subtract this
from 1 and you get the collision probability.

I have a neat spreadsheet to compute this for arbitrary numbers; but for
a 1024-bin FQ-Codel this gives a collision probability of just under 1%
for 10 flows, and just over 9% for 100 flows. This is not too far off
from actual values in a real-world hashing function.

Now, to add to the confusion, you also have to take into account that an
active flow (from an end-to-end perspective) does not necessarily
translate into an active flow from the queue perspective. And that in
fact the number of active flows in a router can be significantly less
than the number of active end-to-end flows, and scales sub-linearly...
There has been at least one paper demonstrating this, but right now I
can't recall who wrote it.

-Toke
