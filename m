From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v3 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Thu, 09 Apr 2015 10:03:28 -0700
Message-ID: <5526B0E0.7060000@plumgrid.com>
References: <1428535575-7736-1-git-send-email-ast@plumgrid.com>	<1428535575-7736-2-git-send-email-ast@plumgrid.com> <20150408.224404.1913719826015357860.davem@davemloft.net> <5525EC69.1080606@plumgrid.com> <5526593E.4040608@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, tgraf@suug.ch, jiri@resnulli.us,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:34872 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbbDIRDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 13:03:31 -0400
Received: by iggg4 with SMTP id g4so72191931igg.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 10:03:30 -0700 (PDT)
In-Reply-To: <5526593E.4040608@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/9/15 3:49 AM, Jamal Hadi Salim wrote:
> those devices and only speacial case with them. Your assumptions of
> blindly pushing/pulling will break  in some cases (take a look at
> mirred).

you underestimated how much time I've spent studying mirred ;)
In particular my v2 patch fixes two bugs in it:
- it was forwarding packets with L2 present to tunnel devices if used
   with egress qdisc
- it wasn't updating skb->csum with ingress qdisc

In v3 since 'needs_l2' is an optional flag, I didn't touch mirred
and left its bugs for the future patches.

> Your changes penalize everyone else because of this assumption
> bpf makes. We have always tried to be sensitive to perfomance.

hmm. penalize everyone? it's an optional flag.
If ingress_l2 is used with cls_bpf plus some other classifier,
sure, the other classifier is paying potential cost skb_share_check
if taps are active. The chances of having more than a couple classifiers
on a single device are very slim, since they're called sequentially
and killing performance regardless.
In most of the use cases I'm after, cls_bpf will be the only classifier
attached. In some cases there may be few others, but cls_bpf will be
the first and the heaviest one. So it makes sense to optimize for it.

> code path and you are adding a bunch more unconditionally.

not true at all. Looks like you misread the v3 patch completely.
It's an optional flag.
