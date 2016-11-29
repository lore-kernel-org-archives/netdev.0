From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net] openvswitch: Fix skb leak in IPv6 reassembly.
Date: Mon, 28 Nov 2016 17:16:15 -0800
Message-ID: <CAPWQB7GR3V5Q8FNMDG27TLyjGhAc=yTcKk5EiNSsfmaDkQjyJg@mail.gmail.com>
References: <20161128234353.4262-1-diproiettod@ovn.org> <1480378950.18162.107.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161129004505.GB11456@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Daniele Di Proietto <diproiettod@ovn.org>,
        netdev <netdev@vger.kernel.org>,
        Pravin B Shelar <pshelar@ovn.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:40924 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755447AbcK2BQk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 20:16:40 -0500
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id E5639C5A44
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 02:16:38 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 7KHJ1DrytbCo for <netdev@vger.kernel.org>;
        Tue, 29 Nov 2016 02:16:37 +0100 (CET)
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 652E1C5A4F
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 02:16:37 +0100 (CET)
Received: by mail-oi0-f52.google.com with SMTP id w63so173278737oiw.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 17:16:37 -0800 (PST)
In-Reply-To: <20161129004505.GB11456@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 November 2016 at 16:45, Florian Westphal <fw@strlen.de> wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Mon, 2016-11-28 at 15:43 -0800, Daniele Di Proietto wrote:
>> > If nf_ct_frag6_gather() returns an error other than -EINPROGRESS, it
>> > means that we still have a reference to the skb.  We should free it
>> > before returning from handle_fragments, as stated in the comment above.
>> >
>> > Fixes: daaa7d647f81 ("netfilter: ipv6: avoid nf_iterate recursion")
>> > CC: Florian Westphal <fw@strlen.de>
>> > CC: Pravin B Shelar <pshelar@ovn.org>
>> > CC: Joe Stringer <joe@ovn.org>
>> > Signed-off-by: Daniele Di Proietto <diproiettod@ovn.org>
>> > ---
>> >  net/openvswitch/conntrack.c | 5 ++++-
>> >  1 file changed, 4 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> > index 31045ef..fecefa2 100644
>> > --- a/net/openvswitch/conntrack.c
>> > +++ b/net/openvswitch/conntrack.c
>> > @@ -370,8 +370,11 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
>> >             skb_orphan(skb);
>> >             memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
>> >             err = nf_ct_frag6_gather(net, skb, user);
>> > -           if (err)
>> > +           if (err) {
>> > +                   if (err != -EINPROGRESS)
>> > +                           kfree_skb(skb);
>> >                     return err;
>> > +           }
>> >
>> >             key->ip.proto = ipv6_hdr(skb)->nexthdr;
>> >             ovs_cb.mru = IP6CB(skb)->frag_max_size;
>>
>> Interesting, have you followed the "GPF in eth_header" thread today ?
>>
>> In a nutshell, we want a complete patch, not something that would solve
>> part of the problem.
>
> I think this patch is fine, intent seems to be to only take fully reassembled
> skb, rather than a stray fragment (ovs does NOT seem to call handle_fragments
> in case skb is already known to not contain a fragment header, afaics).

Correct, this is used in OVS only for fragmented packets and this
function either morphs the skb into the full skb fragment chain, or
steals/frees the skb.

> I'll send a patch for the GPF in eth_header thing soon.
