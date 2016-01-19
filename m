From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: net: hang in ip_finish_output
Date: Tue, 19 Jan 2016 11:13:06 -0500
Message-ID: <CAEfhGizQXqMCbSbi-CCp=Ct7-Mb+0ROtPMYVTAb_GusgQOY6VQ@mail.gmail.com>
References: <CAEfhGiwsgd7-10ggn1EP4zTg3_mpqphWUnCo_7dSkRf=-jtmXQ@mail.gmail.com>
	<1453170024.1223.251.camel@edumazet-glaptop2.roam.corp.google.com>
	<1453171769.1223.255.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453171769.1223.255.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 18, 2016 at 9:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-01-18 at 18:20 -0800, Eric Dumazet wrote:
>
>> Same reason really.
>>
>> Right after sk2=socket(), setsockopt(sk2,...,SO_REUSEPORT, on) and
>> bind(sk2, ...), but _before_ the connect(sk2) is done, sk2 is added into
>> the soreuseport array, with a score which is smaller than the score of
>> first socket sk1 found in hash table (I am speaking of the regular UDP
>> hash table), if sk1 had the connect() done, giving a +8 to its score.
>>
>> So the bug has nothing to do with rcu or rcu_bh, it is just an infinite
>> loop caused by different scores.
>>
>>
>> hash bucket [X] -> sk1 -> sk2 -> NULL
>>
>> sk1 score = 14  (because it did a connect())
>> sk2 score = 6
>>
>> I guess we should relax the test done after atomic_inc_not_zero_hint()
>> to only test the base keys :
>> (net, ipv6_only_sock, inet->inet_rcv_saddr & inet->inet_num)
>
> One way to fix the issue it to not call reuseport_select_sock() if loop
> was restarted, and fallback to the old mechanism : If the optimized
> version might have a problem, just fallback to the safe thing.

Ah, yes, this makes complete sense.  Thanks for the clarification.
It's obviously wrong to re-use this fast method in the case where the
loop in the lookup functions begins again.  I verified your patch
against Dmitry's test and it seems to work.  I think it makes sense to
move the 'select_ok = false' lines next to the 'goto begin' line
though.  It makes it more obvious that the fast lookup is incompatible
with the condition the goto handles.

I'll prepare this and the v6 version for review.  Do you think the
change to the scoring function for SO_INCOMING_CPU is still necessary
as well?  Thanks again!
