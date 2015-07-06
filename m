From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v2 net-next 0/7] net_sched: act: lockless operation
Date: Mon, 06 Jul 2015 08:12:09 -0400
Message-ID: <559A7099.9000506@mojatatu.com>
References: <1436164896-8243-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33559 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754911AbbGFMMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 08:12:15 -0400
Received: by ieqy10 with SMTP id y10so112003739ieq.0
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 05:12:14 -0700 (PDT)
In-Reply-To: <1436164896-8243-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/15 02:41, Eric Dumazet wrote:
> As mentioned by Alexei last week in Budapest, it is a bit weird
> to take a spinlock in order to drop a packet in a tc filter...
>
> Lets add percpu infra for tc actions and use it for gact & mirred.
>
> Before changes, my host with 8 RX queues was handling 5 Mpps with gact,
> and more than 11 Mpps after.
>
> Mirred change is not yet visible if ifb+qdisc is used, as ifb is
> not yet multi queue enabled, but is a step forward.
>

on mirred:
The main thing that is read-write is the stats. lastuse timestamp
as well, but that one doesnt have to be accurate (used mainly
to help decide when to flush out policies). so the lock around
all that code is not necessary.

BTW: I was wondering based on what you said earlier on false sharing
if tcf_common can be re-arranged to avoid that?

For mirred, you may have to add for overlimit stat in the common
structure (we should really increment drop stats when we return
TC_ACT_SHOT).

Having said that: we want to maintain the fact that an action
instance (based on index) can be used across different policies.
i dont see any issue with the way you are proceeding for that
to continue to work. i.e i can say something like:
- create an action to redirect or mirror to port blah index 10
- create filter one on eth1 with 1 of the actions being mirred index 10
- create filter two on eth0 with 1 of the actions being mirred index 10

On IFB:
we use tasklets originally to avoid re-ordering. I think tasklets would
still be useful to keep, with each tied to a queue?

cheers,
jamal
