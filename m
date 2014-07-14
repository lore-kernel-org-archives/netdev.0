From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Sun, 13 Jul 2014 22:11:22 -0700 (PDT)
Message-ID: <20140713.221122.1949618261732322493.davem@davemloft.net>
References: <1405074434-13947-1-git-send-email-sonic.adi@gmail.com>
	<20140711.150136.1090869144440145481.davem@davemloft.net>
	<CAJxxZ0PLapq1jodHN5u+1qNm4dxLkCC9kvbB+D=R3gNfWjk-3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net,
	sonic.zhang@analog.com
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbaGNFLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 01:11:25 -0400
In-Reply-To: <CAJxxZ0PLapq1jodHN5u+1qNm4dxLkCC9kvbB+D=R3gNfWjk-3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.adi@gmail.com>
Date: Mon, 14 Jul 2014 11:40:37 +0800

> Hi David,
> 
> On Sat, Jul 12, 2014 at 6:01 AM, David Miller <davem@davemloft.net> wrote:
>> From: Sonic Zhang <sonic.adi@gmail.com>
>> Date: Fri, 11 Jul 2014 18:27:14 +0800
>>
>>> +     if (i < budget) {
>>> +             napi_complete(napi);
>>> +             if (!(bfin_read_IPEND() & IRQ_EVX))
>>> +                     enable_irq(IRQ_MAC_RX);
>>> +     }
>>
>> This doesn't make any sense, why are you only re-enabling the
>> interrupt if the status bit is clear?
>>
>> You should do this unconditionally.
> 
> In the case of netpoll_poll_dev() is invoked repeatedly from an
> exception handler and no packet is available in the Ethernet device
> buffer, the MAC_RX IRQ is not disabled in bfin_mac_interrupt handler
> when ndo_poll_controller() callback is invoked. But, the NAPI poll()
> callback is always called with bit NAPI_STATE_NPSVC set in
> poll_one_napi(). If the MAC_RX IRQ is enabled unconditionally, kernel
> warning "Unbalanced enable for IRQ %d\n" is always printed out in
> function __enable_irq().
> 
> This exception status checking is to avoid the unbalanced IRQ warning
> from enable_irq(). There is no similar warning in
> disable_irq_nosync(). Do you have any better solution for this
> problem?

Regardless of what your issue is, such a scheme is racey and you're
going to lose events.

You really should unconditionally disable all interrupt sources when a
NAPI poll that covers those events is scheduled, and then
unconditionally re-enable all of them when the NAPI poll is completed.
