From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Fri, 10 Apr 2015 08:48:46 -0400
Message-ID: <5527C6AE.6010301@mojatatu.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net> <5525EC69.1080606@plumgrid.com> <5526593E.4040608@mojatatu.com> <5526B0E0.7060000@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33972 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932446AbbDJMsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 08:48:53 -0400
Received: by iedfl3 with SMTP id fl3so18350908ied.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 05:48:53 -0700 (PDT)
In-Reply-To: <5526B0E0.7060000@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/09/15 13:03, Alexei Starovoitov wrote:
> On 4/9/15 3:49 AM, Jamal Hadi Salim wrote:
>> those devices and only speacial case with them. Your assumptions of
>> blindly pushing/pulling will break  in some cases (take a look at
>> mirred).
>
> you underestimated how much time I've spent studying mirred ;)
> In particular my v2 patch fixes two bugs in it:
> - it was forwarding packets with L2 present to tunnel devices if used
>    with egress qdisc
> - it wasn't updating skb->csum with ingress qdisc
>
> In v3 since 'needs_l2' is an optional flag, I didn't touch mirred
> and left its bugs for the future patches.
>

Alexei,  when you do stuff like based on some policy as you suggest:
+	skb_push(skb, hard_header_len);
+	skb_postpush_rcsum(skb, skb->data, hard_header_len);

That doesnt give you L2 at offset 0 for _some devices_ which is what you
say you need. In some devices it adds a second L2 header.
This is why i keep pointing you to mirred. That is just how
the system works today.

To your "bugs" comments:
- It is reasonable but borderline grey area intepretation of policy
intent to refer additional L2 header a "bug". It is clearly
undesirable to send additional L2 headers (depending on the tunnel
device) and up  to now i havent thought of it as a "bug". But I would
concede that point. In my testing I thought that was a feature. This
is different from the ingress  side where it simply wont work if
you have a missing L2 header.
- updating csum; earlier i said i was conflicted it being a
useful "feature".
You are repeating again that it is a bug. It is not.
This action is intended to  mirror or redirect packets, period.
Unix philosophy do small things and do them well.
Adding checksum recomputation maybe useful if some preceding action
required it. But calling lack of checksum recomputation a bug is a
big stretch.


>
> hmm. penalize everyone? it's an optional flag.

You added at minimal two if conditions that execute on a per-packet
level. Eric D. has been hounding me for just having one.

> If ingress_l2 is used with cls_bpf plus some other classifier,
> sure, the other classifier is paying potential cost skb_share_check
> if taps are active. The chances of having more than a couple classifiers
> on a single device are very slim, since they're called sequentially
> and killing performance regardless.

In my world it is not uncommon.

> In most of the use cases I'm after, cls_bpf will be the only classifier
> attached.

And i am pointing there are other use cases.

>In some cases there may be few others, but cls_bpf will be
> the first and the heaviest one. So it makes sense to optimize for it.
>

I am sorry - but i remain unconvinced.

>> code path and you are adding a bunch more unconditionally.
>
> not true at all. Looks like you misread the v3 patch completely.
> It's an optional flag.

+		needs_l2 = q->flags & TCQ_F_INGRESS_L2;
+		if (needs_l2) {
..
....
+		if (needs_l2)

That is executed for _every_ packet going after ingress qdisc.

cheers,
jamal
