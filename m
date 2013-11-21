From: Tom Herbert <therbert@google.com>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Wed, 20 Nov 2013 18:42:48 -0800
Message-ID: <CA+mtBx8g9uYOc0euQiEDi8qfx_ZggsE_Wn8N5R+peE1_N4WKEg@mail.gmail.com>
References: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
	<20131120.190252.940036939480739452.davem@davemloft.net>
	<CA+mtBx91hSmYKrbUsPrtnXRjYR8QDGZ+GAAnMixauUqw9LFkiQ@mail.gmail.com>
	<20131120.212321.700376819925646003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:44085 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583Ab3KUCmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 21:42:49 -0500
Received: by mail-ie0-f173.google.com with SMTP id to1so4608781ieb.4
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 18:42:49 -0800 (PST)
In-Reply-To: <20131120.212321.700376819925646003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 20, 2013 at 6:23 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 20 Nov 2013 17:09:01 -0800
>
>> I think the sw_rxhash holds more useful information.  In
>> skb_get_rxhash() either we have an L4 hash or we try to get one by
>> doing the SW computation, this means we don't ever return a HW hash
>> which is not L4 so basically that case is treated as an invalid hash.
>> So after a call to skb_get_rxhash, at least one of l4_rxhash or
>> sw_rxhash is and we won't redo flow dissection on subsequent calls
>> unless the rxhash is cleared.
>
> Ok.... one interesting issue remains, which is that the SW flow
> dissector considers decapsulating protocols like AH and ESP as
> "L4".
>
Thinking about a little more, maybe the valid bit is better.  Using
rxhash for both populating the flow hash table for consumption at a
low level and using it for flow lookup at a higher level might be at
odds.  In the original patches Eric mentioned that tun should always
compute its own hash anyway.

> I think we'll need to do something about that at some point.

We need the rxhash to be the value seen at the point of RPS (to do RFS
correctly), which I think probably means we don't ever want to change
it after the first calculation! (clearing at tunnel decap wouldn't be
correct either)  For ESP or AH, I believe it's appropriate to use SPI
as a substitute for ports.

Thanks for the comments,
Tom
