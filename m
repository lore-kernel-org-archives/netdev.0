From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 0/7] net_sched: act: lockless operation
Date: Mon, 6 Jul 2015 14:17:36 +0200
Message-ID: <CANn89iLaZ5uECv0susGeX4XFF_LN4TzVTegqoqgf36m0eTZJzA@mail.gmail.com>
References: <1436164896-8243-1-git-send-email-edumazet@google.com>
	<559A7099.9000506@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:33835 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286AbbGFMRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 08:17:38 -0400
Received: by wgqq4 with SMTP id q4so138732549wgq.1
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 05:17:37 -0700 (PDT)
In-Reply-To: <559A7099.9000506@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 6, 2015 at 2:12 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> on mirred:
> The main thing that is read-write is the stats. lastuse timestamp
> as well, but that one doesnt have to be accurate (used mainly
> to help decide when to flush out policies). so the lock around
> all that code is not necessary.
>
> BTW: I was wondering based on what you said earlier on false sharing
> if tcf_common can be re-arranged to avoid that?

Not really : You would still have a stall on lastuse ultimately, even
if it sits in a cache line of its own.

I mentioned that it shared a cache line to explain with "perf" was
showing the stall on reading another field.


>
> For mirred, you may have to add for overlimit stat in the common
> structure (we should really increment drop stats when we return
> TC_ACT_SHOT).
>
> Having said that: we want to maintain the fact that an action
> instance (based on index) can be used across different policies.
> i dont see any issue with the way you are proceeding for that
> to continue to work. i.e i can say something like:
> - create an action to redirect or mirror to port blah index 10
> - create filter one on eth1 with 1 of the actions being mirred index 10
> - create filter two on eth0 with 1 of the actions being mirred index 10

I do not see any issues either.

>
> On IFB:
> we use tasklets originally to avoid re-ordering. I think tasklets would
> still be useful to keep, with each tied to a queue?

Sure. We do not care about reorders if packets were delivered to
different RX queues.
