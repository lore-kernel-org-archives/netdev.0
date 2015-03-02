From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in sch_sfq
Date: Mon, 2 Mar 2015 07:31:45 -0800
Message-ID: <CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	<1425247789-21211-7-git-send-email-therbert@google.com>
	<1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:39698 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692AbbCBPbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 10:31:46 -0500
Received: by iecvy18 with SMTP id vy18so48630829iec.6
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 07:31:45 -0800 (PST)
In-Reply-To: <1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 1, 2015 at 4:58 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2015-03-01 at 14:09 -0800, Tom Herbert wrote:
>> Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
>> jhash by hand.
>
> This defeats one of the perturbation goal :
>
> If two flows hashes into same hash, then skb_get_hash_perturb(skb,
> q->perturbation) will also give same hash forever and map to same hash
> bucket.
>
As I already mentioned, the probability of skb_get_hash returning the
same value for two flows is 1/2^32. I suspect it's greater probability
to get a hash collision between two IPv6 flows with subtlety different
addresses or simply match 4-tuples in different address spaces (like
VLAN or with VNID). If hash collision is really a problem, we can
periodically rekey skb->hash (either SW or HW) or maybe move to 64 bit
hashes somehow. Anyway, we potentially have the same problem in RSS
and other uses of the hash, if hashes collide then two flows share the
same bucket forever unless there is an action to break that.

> Ideally, we could add a 'u32 perturbation' salt to
> __skb_get_hash()/__flow_hash_from_keys()/__flow_hash_3words instead of
> using a net_get_random_once(&hashrnd, sizeof(hashrnd));
>
> but I guess all these functions are becoming very fat.
>
Same thing as rekeying.

>
>
