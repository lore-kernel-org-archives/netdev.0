From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v7] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Tue, 22 Jul 2014 16:53:30 +0800
Message-ID: <CAJxxZ0Niah8QXGoa4CT4Y5i7qnSjL2xq_GYq7rUHmdJpaNzBHg@mail.gmail.com>
References: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
	<1406015984.10255.121.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140722.010105.2036198226851589509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:54344 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbaGVIxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 04:53:31 -0400
Received: by mail-oa0-f52.google.com with SMTP id o6so9231077oag.11
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 01:53:30 -0700 (PDT)
In-Reply-To: <20140722.010105.2036198226851589509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Jul 22, 2014 at 4:01 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 22 Jul 2014 09:59:44 +0200
>
>> On Tue, 2014-07-22 at 15:38 +0800, Sonic Zhang wrote:
>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>>> +    if (i < budget) {
>>> +            napi_complete(napi);
>>> +            if (lp->rx_irq_disabled--)
>>> +                    if (!lp->rx_irq_disabled)
>>> +                            enable_irq(IRQ_MAC_RX);
>>
>>
>> You wrote :
>>
>>       if (A--)
>>               if (!A)
>>                       something();
>>
>> Isnt a bit strange ???
>
> Indeed, it's very strange, how about:
>
>         if (!--lp->rx_irq_disabled)
>
> which is the canonical way to express this.

if (!--A)

doesn't equal to

if (A--)
        if (!A)

In net poll loop, because of NAPI state bit NAPI_STATE_NPSVC, the napi
poll callback may be called with A = 0 (MAC RX IRQ is enabled) if
napi_complete() other than __napi_complete() is used. See the
explanation in my last email.

In this case, the up condition decreases A to a negative number and
the interrupt handler condition "if (!A++)" can never increase A back
to 0 (disable the RX IRQ). While, the down condition only decreases A
if it is not 0.


Regards,

Sonic
