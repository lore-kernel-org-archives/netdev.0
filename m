From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/4] ila: Use NF_INET_PRE_ROUTING nfhook
Date: Tue, 29 Sep 2015 10:17:17 -0700
Message-ID: <CALx6S36n68LjzyfYbBNR+aLEJxK9cp1HefhP22mNCPNrcSGJQQ@mail.gmail.com>
References: <1443112224-574543-1-git-send-email-tom@herbertland.com>
	<20150926.231554.1860934088223264189.davem@davemloft.net>
	<20150927081055.GA17055@breakpoint.cc>
	<CALx6S35gFbcFjCWEQsDY_DzBOrr0i7+3fdBWiF4rLmcz9HJRBg@mail.gmail.com>
	<20150928230010.GB19923@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37454 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934655AbbI2RRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 13:17:18 -0400
Received: by igbni9 with SMTP id ni9so12055993igb.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 10:17:17 -0700 (PDT)
In-Reply-To: <20150928230010.GB19923@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 28, 2015 at 4:00 PM, Florian Westphal <fw@strlen.de> wrote:
> Tom Herbert <tom@herbertland.com> wrote:
>> RFC6296 doesn't work because it allows an invalid checksum to be sent
>> on wire relative to the addresses used on the wire. That means we
>> would lose CHECKSUM_UNNECESSARY for ILA which is way too big of a
>> performance hit.
>
> Not following.  I did not say you should use NPT instead of ILA.
>
> [..]
>> In any case, I did at one point create some netfilter targets for ILA
>> to do the translation correctly updating the checksum. While this
>> provided the required functionality, I couldn't get sufficient
>> performance. A specialized fixed length lookup table gets most of the
>> performance needed for ILA.
>
> I'm not following at all.
>
> Could you explain why you can't just 'relocate' your proposed
> implementation to netfilter/ipv6?
>
Florian

I modified DNPT to perform ILA. Performance results are below. What I
see is that DNPT offers only a slight improvement over just doing
translation at LWT and not getting a hit in early demux. Top function
in perf is:

2.49%  [kernel]                   [k] ip6t_do_table

so I think this performance result is mostly the overhead of netfilter
and not ILA translation. But in any case, doing a direct specialized
lookup like what we do in this patch gets us close to same performance
without ILA enabled-- low performance overhead is critical for our ILA
use cases.

Tom

No ILA, baseline
   85.72% CPU utilization
   1861945 tps
   93/163/330 50/90/99% latencies

ILA before fix (LWT on both input and output)
   83.47 CPU utilization
   16583186 tps (-11% from baseline)
   107/183/338 50/90/99% latencies

ILA after fix (hook for input)
   84.97% CPU utilization
   1833948 tps (-1.5% from baseline)
   95/164/331 50/90/99% latencies

Modify DNPT to do ILA (ip6tables -t mangle -I PREROUTING -d
2001:0:0:3::/64 -j DNPT --src-pfx 2001:0:0:3::/64 --dst-pfx
3333:0:0:1::/64)
   80.94% CPU utilization
   1683315 tps (-10% from baseline)
   104/179/350 50/90/99% latencies

> F.e. I see no reason why you could not use a lookup table in a netfilter
> target (or nft expression, for that matter) ... ?
>
> Thanks,
> Florian
