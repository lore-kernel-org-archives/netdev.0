From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 3/8 (V2)] stmmac: add the initial tx coalesce schema
Date: Fri, 14 Sep 2012 09:36:30 +0200
Message-ID: <5052DE7E.8070704@st.com>
References: <1347346514-23411-1-git-send-email-peppe.cavallaro@st.com> <1347346514-23411-4-git-send-email-peppe.cavallaro@st.com> <20120913.162333.1518469374321928795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:57525 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756578Ab2INHgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 03:36:50 -0400
In-Reply-To: <20120913.162333.1518469374321928795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/13/2012 10:23 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Tue, 11 Sep 2012 08:55:09 +0200
>
>> +	unsigned long flags;
>> +
>> +	spin_lock_irqsave(&priv->tx_lock, flags);
>>
>> -	spin_lock(&priv->tx_lock);
>> +	priv->xstats.tx_clean++;
>
> You are changing the locking here for the sake of the new timer.
>
> But timers run in software interrupt context, so this change is
> completely unnecessary since NAPI runs in software interrupt context
> as well, and neither timers nor NAPI run in hardware interrupts
> context.

Indeed It can be called by the ISR too in this new implementation.
I have added the spin_lock_irqsave/restore otherwise, testing with 
CONFIG_PROVE_LOOKING, I get the following warning on ARM SMP.

[    8.030000]
[    8.030000] =================================
[    8.030000] [ INFO: inconsistent lock state ]
[    8.030000] 3.4.7_stm24_0302-b2000+ #103 Not tainted
[    8.030000] ---------------------------------
[    8.030000] inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
[    8.030000] swapper/0/1 [HC1[1]:SC0[0]:HE0:SE1] takes:
[    8.030000]  (&(&priv->tx_lock)->rlock){?.-...}, at: [<802651d8>] 
stmmac_tx+0x1c/0x388
[    8.030000] {HARDIRQ-ON-W} state was registered at:
[    8.030000]   [<800562b4>] __lock_acquire+0x638/0x179c
[    8.030000]   [<80057884>] lock_acquire+0x60/0x74
[    8.030000]   [<80428a08>] _raw_spin_lock+0x40/0x50
[    8.030000]   [<802651d8>] stmmac_tx+0x1c/0x388
[    8.030000]   [<80026be0>] run_timer_softirq+0x180/0x23c
[    8.030000]   [<80020ccc>] __do_softirq+0xa0/0x114
[    8.030000]   [<80021204>] irq_exit+0x58/0x7c
[    8.030000]   [<8000dc80>] handle_IRQ+0x7c/0xb8
[    8.030000]   [<80008464>] gic_handle_irq+0x34/0x58
[    8.030000]   [<80429684>] __irq_svc+0x44/0x78
[    8.030000]   [<8001c3f4>] vprintk+0x41c/0x480
[    8.030000]   [<8042097c>] printk+0x18/0x24
[    8.030000]   [<805aef6c>] prepare_namespace+0x1c/0x1a4
[    8.030000]   [<805ae980>] kernel_init+0x1c8/0x20c
[    8.030000]   [<8000deb8>] kernel_thread_exit+0x0/0x8
[    8.030000] irq event stamp: 254745
[    8.030000] hardirqs last  enabled at (254744): [<80429240>] 
_raw_spin_unlock_irqrestore+0x3c/0x6c
[    8.030000] hardirqs last disabled at (254745): [<80429674>] 
__irq_svc+0x34/0x78
[    8.030000] softirqs last  enabled at (254741): [<8035d964>] 
dev_queue_xmit+0x6a4/0x724
[    8.030000] softirqs last disabled at (254737): [<8035d2d4>] 
dev_queue_xmit+0x14/0x724
[    8.030000]
[    8.030000] other info that might help us debug this:
[    8.030000]  Possible unsafe locking scenario:
[    8.030000]
[    8.030000]        CPU0
[    8.030000]        ----
[    8.030000]   lock(&(&priv->tx_lock)->rlock);
[    8.030000]   <Interrupt>
[    8.030000]     lock(&(&priv->tx_lock)->rlock);
[    8.030000]
[    8.030000]  *** DEADLOCK ***

> Therefore, disabling hardware interrupts for this lock is unnecessary
> and will decrease performance.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
