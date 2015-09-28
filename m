From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/4] ila: Use NF_INET_PRE_ROUTING nfhook
Date: Mon, 28 Sep 2015 15:27:16 -0700
Message-ID: <CALx6S35gFbcFjCWEQsDY_DzBOrr0i7+3fdBWiF4rLmcz9HJRBg@mail.gmail.com>
References: <1443112224-574543-1-git-send-email-tom@herbertland.com>
	<20150926.231554.1860934088223264189.davem@davemloft.net>
	<20150927081055.GA17055@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36210 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbbI1W1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 18:27:17 -0400
Received: by ioii196 with SMTP id i196so192599885ioi.3
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 15:27:16 -0700 (PDT)
In-Reply-To: <20150927081055.GA17055@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 27, 2015 at 1:10 AM, Florian Westphal <fw@strlen.de> wrote:
> David Miller <davem@davemloft.net> wrote:
>> > This patch set addresses the issue for ILA by adding a fast locator
>> > lookup that occurs before early demux. This is done by using a hook
>> > at NF_INET_PRE_ROUTING. For the backend we implement an rhashtable
>> > that contains identifier to locator to mappings. The table also
>> > allows more specific matches that include original locator and
>> > interface.
>>
>> I really don't think we should use netfilter hooks to perform
>> operations setup outside of netfilter's normal configuration
>> mechanisms.
>
> Thanks, thats my thinking as well.
>
>> If ILA were instead configured inside of netfilter's normal mechanisms
>> then there would be full transparency about whether ILA
>> transformations are performed before or after the user's other
>> netfilter rules.  And the user would have full control over this.
>> As implemented here, they don't.
>>
>> So sorry, I'm not too keen on this and I bet if netfilter developers
>> reviewed this patch series they'd have similar objections.
>
> Seems this should/could be implemented similar to RFC6296 network
> prefix translations (see net/ipv6/netfilter/ip6t_NPT.c).

Hi Florian,

RFC6296 doesn't work because it allows an invalid checksum to be sent
on wire relative to the addresses used on the wire. That means we
would lose CHECKSUM_UNNECESSARY for ILA which is way too big of a
performance hit. This might actually be worse for some devices that
are doing NETIF_F_IP_CSUM if they are calculating the checksum based
on the addresses in packet instead of the ultimate destination address
which seems to be what RFC6296 wants (could result checksum errors).
Unfortunately we're going to be seeing this problem more and more as
there are more method that rewrite addresses without updating the
transport checksum before leaving the host (e.g. segment routing).

For devices doing CHECKSUM_COMPLETE I suspect there are also some
issues. In ip6t_npt_map_pfx it seems like if the addresses are being
rewritten in the receive path, the skb->csum should be updated
accordingly. GRO might consistently fail on bad checksums also...

In any case, I did at one point create some netfilter targets for ILA
to do the translation correctly updating the checksum. While this
provided the required functionality, I couldn't get sufficient
performance. A specialized fixed length lookup table gets most of the
performance needed for ILA.

Thanks,
Tom
