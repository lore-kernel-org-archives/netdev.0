From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH iproute2] tc/netem: loss gemodel options fixes
Date: Tue, 05 Aug 2014 11:29:16 -0700
Message-ID: <5354.1407263356@localhost.localdomain>
References: <29682.1399754098@localhost.localdomain> <CAPh34mf4ahPyTDf-tEhsNKSFBL6GYjES9+TTvDjhMf2YLTr04Q@mail.gmail.com> <11467.1400183199@localhost.localdomain> <20140804123709.502bbe1d@haswell.linuxnetplumber.net> <CAPh34meHr_7z4nznKBeKV6Y4Dypni72yM7bSOdkQ6hopsnjzGg@mail.gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>, netem@lists.linux-foundation.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:46556 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451AbaHES3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 14:29:23 -0400
In-reply-to: <CAPh34meHr_7z4nznKBeKV6Y4Dypni72yM7bSOdkQ6hopsnjzGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer <hagen@jauu.net> wrote:

>On 4 August 2014 21:37, Stephen Hemminger <stephen@networkplumber.org> wrote:
>
>> I went ahead and applied these. They make sense and got no response.
>
>Wait Stephen,
>
>Jay do you compared your changes with the expected results? I mean did
>you run tests that the Markov chain model is _now_  working correctly
>(in all states)?
>
>The setup will be easy: send 10000 packets, capture the packets and
>'wc -l tcpdump -r trace.pcap' and compare to the expected number of
>packets for a given markov state setup. Enough bugs here where the
>should be no bugs at all. Some simple tests should be enough to get
>rid of them.

	I did test the changes when I originally submitted them, yes.
The kernel code is unmodified; what the patch changed is

	- the default for 1-k if not supplied as an option is documented
as 1-k=0, but was actually set to 1, i.e., drop everything in good state
if 1-k is not explicitly specified.

	- convert "1-h" to "h" as the kernel expects.  As I recall, I
originally noticed this when trying to specify small loss percentages in
the bad state, e.g., something like "netem loss gemodel 100 0 1" should
drop 1% in the bad state (1-h == 1%), but would instead drop 99%.

	I also posted some additional analysis:

From: Jay Vosburgh <jay.vosburgh@canonical.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
cc: netdev@vger.kernel.org, netem@lists.linux-foundation.org,
    Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc/netem: loss gemodel options fixes
Date: Thu, 15 May 2014 12:46:39 -0700

Hagen Paul Pfeifer <hagen@jauu.net> wrote:

>Stephen, tomorrow I will take a look at Jay's patches.

	Just to make it clear what I believe is incorrect with regards
to the h and 1-h part:

net/sched/sch_netem.c:
[...]
                /* 4-states and Gilbert-Elliot models */
                u32 a1; /* p13 for 4-states or p for GE */
                u32 a2; /* p31 for 4-states or r for GE */
                u32 a3; /* p32 for 4-states or h for GE */
                u32 a4; /* p14 for 4-states or 1-k for GE */
[...]

	Note that a3 is "h for GE" vs a4 is "1-k for GE". Also, in
the actual drop function:

static bool loss_gilb_ell(struct netem_sched_data *q)
[...]
        case GOOD_STATE:
[...]
                if (prandom_u32() < clg->a4)
                        return true;
                break;
        case BAD_STATE:
[...]
                if (prandom_u32() > clg->a3)
                        return true;
[...]

	The test for clg->a3 is inverted as compared to the test for
clg->a4.  Hence, the kernel is using "h," not "1-h," and therefore tc
should pass in the value for h instead of 1-h as it does currently.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
