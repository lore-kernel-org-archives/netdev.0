From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v3] bfin_mac: convert bfin Ethernet driver to NAPI framework
Date: Mon, 14 Jul 2014 11:40:37 +0800
Message-ID: <CAJxxZ0PLapq1jodHN5u+1qNm4dxLkCC9kvbB+D=R3gNfWjk-3w@mail.gmail.com>
References: <1405074434-13947-1-git-send-email-sonic.adi@gmail.com>
	<20140711.150136.1090869144440145481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:46523 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaGNDki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 23:40:38 -0400
Received: by mail-ob0-f179.google.com with SMTP id wn1so1616826obc.38
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 20:40:37 -0700 (PDT)
In-Reply-To: <20140711.150136.1090869144440145481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sat, Jul 12, 2014 at 6:01 AM, David Miller <davem@davemloft.net> wrote:
> From: Sonic Zhang <sonic.adi@gmail.com>
> Date: Fri, 11 Jul 2014 18:27:14 +0800
>
>> +     if (i < budget) {
>> +             napi_complete(napi);
>> +             if (!(bfin_read_IPEND() & IRQ_EVX))
>> +                     enable_irq(IRQ_MAC_RX);
>> +     }
>
> This doesn't make any sense, why are you only re-enabling the
> interrupt if the status bit is clear?
>
> You should do this unconditionally.

In the case of netpoll_poll_dev() is invoked repeatedly from an
exception handler and no packet is available in the Ethernet device
buffer, the MAC_RX IRQ is not disabled in bfin_mac_interrupt handler
when ndo_poll_controller() callback is invoked. But, the NAPI poll()
callback is always called with bit NAPI_STATE_NPSVC set in
poll_one_napi(). If the MAC_RX IRQ is enabled unconditionally, kernel
warning "Unbalanced enable for IRQ %d\n" is always printed out in
function __enable_irq().

This exception status checking is to avoid the unbalanced IRQ warning
from enable_irq(). There is no similar warning in
disable_irq_nosync(). Do you have any better solution for this
problem?

Thanks,

Sonic


>
> If your logic triggers, polling is disabled and the interrupt handler
> isn't going to run, so your driver will stop taking packets.
>
> Please please, stop being so clever with the conditions here, simply
> if you didn't use the whole budget turn off NAPI and reenable
> interrupts.
