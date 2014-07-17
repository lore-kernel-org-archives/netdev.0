From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v5] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Thu, 17 Jul 2014 13:28:36 +0800
Message-ID: <CAJxxZ0OybvReRHvRuL84N=25T6cRG8k1j_gXLcu7U6jHvSZ5Tw@mail.gmail.com>
References: <1405504302-21344-1-git-send-email-sonic.adi@gmail.com>
	<1405516649.10255.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140716.140301.896018835447121717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Varka Bhadram <varkabhadram@gmail.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:59842 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbaGQF2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 01:28:37 -0400
Received: by mail-ig0-f169.google.com with SMTP id r2so5122040igi.4
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 22:28:36 -0700 (PDT)
In-Reply-To: <20140716.140301.896018835447121717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, Jul 17, 2014 at 5:03 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 16 Jul 2014 15:17:29 +0200
>
>> On Wed, 2014-07-16 at 17:51 +0800, Sonic Zhang wrote:
>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>> +    if (i < budget) {
>>> +            napi_gro_flush(napi, false);
>>> +            local_irq_save(flags);
>>> +            __napi_complete(napi);
>>> +            local_irq_restore(flags);
>>> +            enable_irq(IRQ_MAC_RX);
>>
>> I have no idea why you open-code napi_complete();
>>
>> Why cant you just copy/paste what other drivers do here ?
>>
>>       if (i < budget) {
>>               napi_complete(napi);
>>               enable_irq(IRQ_MAC_RX);
>>       }
>
> Generally speaking, I am very frustrated at how this bfin_mac NAPI
> conversion tries to do things in special ways.
>
> Please mimick what other drivers do rather than trying to do things in
> a special way unique to your driver.

Driver realtek/8139cp.c does things in the same way as the bfin_mac
NAPI code. Bfin EMAC device has no capability to disable the MAC_RX
interrupt in its EMAC register directly. The bfin_mac driver has to do
it in its system interrupt controller via the kernel API
enable_irq()/disable_irq_nosync().

In net_poll loop, if napi_complete() is called, the EMAC IRQ is
enabled more times than the it is disabled. This is not a problem to
drivers which don't call enable_irq()/disable_irq_nosync(). But, the
IRQ enabling and disabling operations have to be balanced in the
bfin_mac driver via __napi_complete() to avoid the kernel warning.


Regards,

Sonic Zhang
