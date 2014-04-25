From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v4 1/3] net: ipv6: Unduplicate
 {raw,udp}v6_sendmsg code
Date: Fri, 25 Apr 2014 20:09:49 +0900
Message-ID: <CAKD1Yr0MoyjBwUVG+Bjf5D-k0-JkvzOL3mDaNtjF4rUeWJ21Ew@mail.gmail.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
 <1398235078-27088-1-git-send-email-lorenzo@google.com> <20140424150019.GE1960@order.stressinduktion.org>
 <20140424150206.GF1960@order.stressinduktion.org> <CAKD1Yr2DSkF59hdGyD=RiDNSseHT8u7Cf-0oYcJU=2uDgV_+Dw@mail.gmail.com>
 <20140424154305.GI1960@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Lorenzo Colitti <lorenzo@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:36566 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529AbaDYLKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 07:10:10 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so3649623ieb.34
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 04:10:09 -0700 (PDT)
In-Reply-To: <20140424154305.GI1960@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 12:43 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>> I wonder, is it better to just initialize dontfrag to np->dontfrag
>> instead of -1 in the caller? ip6_datagram_send_ctl seems to just
>> overwrite dontfrag with whatever comes from userspace, so nobody ever
>> checks that it's < 0.
>
> Yes, that is what I had in mind. So we must not reset dontfrag to -1 in
> datagram_common_send and leave the check just after do_append_data as is.

Thinking about it some more, it seems that that might be confusing as
well. Someone might trip up over it again - it's already happened
twice.

Instead, I've moved the initialization back into
ip6_datagram_send_common, so the variables are now obviously
uninitialized in the callers, and in udpv6_sendmsg I explicitly set
hlimit and tclass to -1, and dontfrag to np->dontfrag, before the goto
do_append data. That way, if the goto is taken, it's immediately
obvious that the variables are being set, and if it's not, it's clear
that they are uninitialized and being set in ip6_datagram_send_common.
