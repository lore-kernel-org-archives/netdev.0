From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 6/6] sched: Eliminate use of flow_keys in sch_sfq
Date: Mon, 2 Mar 2015 08:25:53 -0800
Message-ID: <CA+mtBx-Bhewd6Ez4OotWEhxvVO8rrOieWCGAnMa9vfhTbzj=yg@mail.gmail.com>
References: <1425247789-21211-1-git-send-email-therbert@google.com>
	<1425247789-21211-7-git-send-email-therbert@google.com>
	<1425257932.5130.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:41188 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbbCBQZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 11:25:54 -0500
Received: by igal13 with SMTP id l13so18660825iga.0
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 08:25:53 -0800 (PST)
In-Reply-To: <CA+mtBx-gAq=knRnf73qrOKuWy=WVaHvq2Vzb8RC39p81WBXZ8Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 2, 2015 at 7:31 AM, Tom Herbert <therbert@google.com> wrote:
>
> On Sun, Mar 1, 2015 at 4:58 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sun, 2015-03-01 at 14:09 -0800, Tom Herbert wrote:
> >> Call qdisc_skb_get_hash instead of doing skb_flow_dissect and then
> >> jhash by hand.
> >
> > This defeats one of the perturbation goal :
> >
> > If two flows hashes into same hash, then skb_get_hash_perturb(skb,
> > q->perturbation) will also give same hash forever and map to same hash
> > bucket.
> >
> As I already mentioned, the probability of skb_get_hash returning the
> same value for two flows is 1/2^32. I suspect it's greater probability
> to get a hash collision between two IPv6 flows with subtlety different
> addresses or simply match 4-tuples in different address spaces (like
> VLAN or with VNID). If hash collision is really a problem, we can
> periodically rekey skb->hash (either SW or HW) or maybe move to 64 bit
> hashes somehow. Anyway, we potentially have the same problem in RSS
> and other uses of the hash, if hashes collide then two flows share the
> same bucket forever unless there is an action to break that.
>
One other possibility is that with the txhash changes we can rehash
individual connections that are sourced from the host. I was planning
to do this on too many TCP retransmits to try to get a different ECMP
path (type of source routing), but we could also do this periodically
or based on request from qdisc. ooo_okay could be taken into account
to avoid OOO packets.

>
> > Ideally, we could add a 'u32 perturbation' salt to
> > __skb_get_hash()/__flow_hash_from_keys()/__flow_hash_3words instead of
> > using a net_get_random_once(&hashrnd, sizeof(hashrnd));
> >
> > but I guess all these functions are becoming very fat.
> >
> Same thing as rekeying.
>
> >
> >
