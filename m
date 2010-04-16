From: Paul Turner <pjt@google.com>
Subject: Re: [PATCH v4] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 10:59:37 -0700
Message-ID: <i2oed628a921004161059z65a3cf1aq5f3cd2194f40a811@mail.gmail.com>
References: <alpine.DEB.1.00.1004121651460.31468@pokey.mtv.corp.google.com>
	 <20100412171205.561a1aec@nehalam>
	 <o2k65634d661004160851wc00c609p7136a22fd07503c1@mail.gmail.com>
	 <4BC89F6D.2080604@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	Ingo Molnar <mingo@elte.hu>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:37574 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757592Ab0DPR7l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 13:59:41 -0400
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [10.3.21.1])
	by smtp-out.google.com with ESMTP id o3GHxclp016242
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 19:59:39 +0200
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by hpaq1.eem.corp.google.com with ESMTP id o3GHx8ZI019683
	for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 19:59:37 +0200
Received: by pwj1 with SMTP id 1so2227046pwj.23
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 10:59:37 -0700 (PDT)
In-Reply-To: <4BC89F6D.2080604@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 10:33 AM, Rick Jones <rick.jones2@hp.com> wrote=
:
>>
>> This is true. =A0There is a fundamental question of whether schedule=
r
>> should lead networking or vice versa. =A0The advantages of networkin=
g
>> following scheduler seem to become more apparent on heavily loaded
>> systems or with threads that handle more than one flow.
>
> I will confess to being in the networking should follow the scheduler=
 camp
> :)
>
>> I'm not sure these two models have to be mutually exclusive, we are
>> looking at some ways to make a hybrid model.
>
> It is perhaps too speculative on my part, but if the host has no cont=
rol
> over the remote addressing of the connections to/from it, doesn't tha=
t
> suggest that allowing networking to lead the scheduler gives "externa=
l
> forces" more say in intra-system resource consumption than we might w=
ant
> them to have?
>
> rick jones
>

Even under a hybrid model I think phrasing it as networking leading
the scheduler here is a little strong.  The scheduler is in both cases
the most 'informed' place to make these decisions, but I think it
could benefit from more knowledge.  In the 'virgin' single flow case
without any steering the network stack is currently able to implicitly
hint to the scheduler where flows could be most efficiently served due
to wake-affine balancing behaviors.  This is a natural side-effect of
wake-ups being sourced by the networking cpus.

I think the win here would be allowing this (naturally existing)
hinting to be a little more explicit so that the scheduler and
load-balancer are able to gracefully 'collapse' back down onto the
network cpu socket under low stress conditions, even if previous
processing was balanced away from it due to load.

This would actually then look very much like today's model under loads
where you don't need scaling via parallelism.  One way to think about
making it an explicit hint could be: should the rx cpu sourcing the
wake-up in this case be the target for wake-affine as opposed to the
current bottom-half delegate?

- Paul
