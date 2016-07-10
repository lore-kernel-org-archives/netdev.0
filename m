From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Sun, 10 Jul 2016 16:48:26 -0300
Message-ID: <CAB9dFdv_ShA2cSez7Ut31XnW7OWufV59bfG-zN4Z0K3CgPvwuA@mail.gmail.com>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
 <20160627142238.GA10613@breakpoint.cc> <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
 <20160627153820.GB10613@breakpoint.cc> <CAB9dFdvQ4UyKNMmOSx+FePyR0_Q425XLJRb_k5h+4JOSkQkf3w@mail.gmail.com>
 <CAB9dFds7KQxihReHhW9CXJeY9+=4BPema3ZawVA89U45QL5uBw@mail.gmail.com> <20160705122803.GA26862@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Thorsten Leemhuis <regressions@leemhuis.info>,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160705122803.GA26862@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 5, 2016 at 9:28 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> Hi,
>
> On Mon, Jul 04, 2016 at 09:35:28AM -0300, Marc Dionne wrote:
>> If there is no quick fix, seems like a revert should be considered:
>> - Looks to me like the commit attempts to fix a long standing bug
>> (exists at least as far back as 3.5,
>> https://bugzilla.kernel.org/show_bug.cgi?id=52991)
>> - The above bug has a simple workaround (at least for us) that we
>> implemented more than 3 years ago
>
> I guess the workaround consists of using a rule to NOTRACK this
> traffic. Or there is any custom patch that you've used on your side to
> resolve this?
>
>> - The commit reverts cleanly, restoring the original behaviour
>> - From that bug report, bind was one of the affected applications; I
>> would suspect that this regression is likely to affect bind as well
>>
>> I'd be more than happy to test suggested fixes or give feedback with
>> debugging patches, etc.
>
> Could you monitor
>
> # conntrack -S
>
> or alternatively (if conntrack utility not available in your system):
>
> # cat /proc/net/stat/nf_conntrack
>
> ?
>
> Please, watch for insert_failed and drop statistics.
>
> Are you observing any splat or just large packet drops? Could you
> compile your kernel with lockdep on and retest?
>
> Is there any chance I can get your test file that generates the UDP
> client threads to reproduce this here?
>
> I'm also attaching a patch to drop old ct that lost race path out from
> hashtable locks to avoid releasing the ct object while holding the
> locks, although I couldn't come up with any interaction so far
> triggering the condition that you're observing.
>
> Thanks.

An update here since I've had some interactions with Pablo off list.

Further testing shows that the underlying cause of the different test
results is a udp packet that has a bogus source port number.  In the
test the server process tries to send an ack to the bogus port and the
flow is disrupted.

Notes:
- The packet with the bad source port is from a sendmsg() call that
has hit the connection tracker clash code introduced by 71d8c47fc653
- Packets are successfully sent after the bad one, from the same
socket, with the correct source port number
- The problem does not reproduce with 71d8c47fc653 reverted, or
without nf_conntrack loaded
- The bogus port numbers start at 1024, bumping up by 1 every few
times the problem occurs (1025, 1026, etc.)
- The patch above does not change the behaviour
- Enabling lockdep does not show anything

Our workaround for the original race was to retry sendmsg() once on
EPERM errors, and that had been effective.
I can trigger the insertion clash easily with some simple test code,
but I have not been able so far to reproduce the packets with bad
source port numbers with some simpler code that I could share.

Thanks,
Marc
