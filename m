From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in sch_sfq
Date: Tue, 3 Mar 2015 13:00:53 -0800
Message-ID: <CA+mtBx-CmSPRP4TAOA1rO7UZUFJBtppirbMV-=OOa14LsJq0Yw@mail.gmail.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	<1425247789-21211-7-git-send-email-therbert@google.com>
	<1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
	<1425324278.5130.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:43888 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755711AbbCCVAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 16:00:54 -0500
Received: by igbhn18 with SMTP id hn18so31695785igb.2
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 13:00:53 -0800 (PST)
In-Reply-To: <1425324278.5130.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 11:24 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-03-02 at 07:31 -0800, Tom Herbert wrote:
>
>> As I already mentioned, the probability of skb_get_hash returning the
>> same value for two flows is 1/2^32. I suspect it's greater probability
>> to get a hash collision between two IPv6 flows with subtlety different
>> addresses or simply match 4-tuples in different address spaces (like
>> VLAN or with VNID). If hash collision is really a problem, we can
>> periodically rekey skb->hash (either SW or HW) or maybe move to 64 bit
>> hashes somehow. Anyway, we potentially have the same problem in RSS
>> and other uses of the hash, if hashes collide then two flows share the
>> same bucket forever unless there is an action to break that.
>
> Main historical use of SFQ is for routers.
>
> We do not control skb->hash for forwarding workload, unless you
> reprogram RSS keys on the NIC.
>
> If you remember, we used to have a problem on some NIC using a well
> known RSS key. It is fortunate SFQ/fq_codel did not rely on skb->hash
> too much.
>
Okay, I'll audit the drivers returning skb->hash fro HW to make sure
they are properly randomizing the initial hash key.

Unless, there's other material objections, I'll formally post these
patches. Consolidating the packet hash for different use cases should
be more efficient and we'll be able focus efforts on strengthening it
over time in one place. As for SW vs. HW hash, it still seems like
getting a Toeplitz hash from the hardware is going to be stronger at
least for TCP/IPv6 than what we can currently do with jhash as the
input is the full 40 bytes of 4-tuple. I must admit I wish Microsoft
would have continued to make advancements with Toeplitz hash, it would
be nice if there was a real definition for use with UDP and maybe we
had instructions for this in x86!

Tom

> If to target one flow, attackers need to attack your big boxes to flood
> one particular RX queue at NIC level, this has a huge cost for them.
>
> While targeting one hash bucket on a qdisc might be much easier, if they
> know even a hash perturbation has no effect against their attack.
>
>
>
