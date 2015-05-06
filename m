From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH] stmmac: call local_irq_save other than disable_irq in poll_controller
Date: Wed, 6 May 2015 11:53:53 +0800
Message-ID: <CAJxxZ0Oi_xLA3PY4Phb6q+J-2FeO6tvVyD0viTAdXVWVQm1V-g@mail.gmail.com>
References: <1430812553-7588-1-git-send-email-sonic.adi@gmail.com>
	<20150505.193633.2161230945632055751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	adi-buildroot-devel@lists.sourceforge.net,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:36494 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756766AbbEFDxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 23:53:53 -0400
Received: by oift201 with SMTP id t201so165116443oif.3
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 20:53:53 -0700 (PDT)
In-Reply-To: <20150505.193633.2161230945632055751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, May 6, 2015 at 7:36 AM, David Miller <davem@davemloft.net> wrote:
> From: Sonic Zhang <sonic.adi@gmail.com>
> Date: Tue, 5 May 2015 15:55:53 +0800
>
>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>> It is possible that poll_controller is called from netpoll.c with irq
>> already disabled. Unexpected interrupt may be triggered if always
>> enable irq before returning from poll_controller.
>>
>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>
> Nope, this is wrong.
>
> If you don't use disable_irq(), the interrupt handler can run in
> parallel on another cpu and you definitely do not want that.

How about change local_irq_save(flags) to
spin_lock_irqsave(&priv->lock, flags) ?

>
> There is nothing wrong with the interrupt triggering on the
> enable_irq() here.  If that causes some problem, there is a
> bug in this driver.

When I debug Linux kernel via KGDB over Ethernet, KGDB calls netpoll
API and stmmac_poll_controller to send UDP packets with all interrupts
disabled. KGDB assumes all interrupts keeps disabled when it is active
and doing UDP data transmission. Enabling interrupts in
stmmac_poll_controller causes KGDB re-enter exception and system halt.

Although KGDB over Ethernet is not part of the mainline tree, I feel
this patch is useful in case other kernel functions want to call
netpoll API with interrupts disabled.


Regards,

Sonic
