From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 net 10/20] net/ena: remove redundant logic in napi
 callback for busy poll mode
Date: Sun, 04 Dec 2016 21:45:39 -0800
Message-ID: <1480916739.18162.516.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
         <1480857578-5065-11-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org, dwmw@amazon.com, zorik@annapurnalabs.com,
        alex@annapurnalabs.com, saeed@annapurnalabs.com, msw@amazon.com,
        aliguori@amazon.com, nafea@annapurnalabs.com
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480857578-5065-11-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-12-04 at 15:19 +0200, Netanel Belgazal wrote:
> sk_busy_loop can call the napi callback few million times a sec.
> For each call there is unmask interrupt.
> We want to reduce the number of unmasks.
> 
> Add an atomic variable that will tell the napi handler if
> it was called from irq context or not.
> Unmask the interrupt only from irq context.
> 
> A schenario where the driver left with missed unmask isn't feasible.
> when ena_intr_msix_io is called the driver have 2 options:
> 1)Before napi completes and call napi_complete_done
> 2)After calling napi_complete_done
> 
> In the former case the napi will unmask the interrupt as needed.
> In the latter case napi_complete_done will remove napi from the schedule
> list so napi will be rescheduled (by ena_intr_msix_io) and interrupt
> will be unmasked as desire in the 2nd napi call.
> 
> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> ---


This looks very complicated to me.

I guess you missed the recent patches that happened on net-next ?

2e713283751f494596655d9125c168aeb913f71d net/mlx4_en: use napi_complete_done() return value
364b6055738b4c752c30ccaaf25c624e69d76195 net: busy-poll: return busypolling status to drivers
21cb84c48ca0619181106f0f44f3802a989de024 net: busy-poll: remove need_resched() from sk_can_busy_loop()
217f6974368188fd8bd7804bf5a036aa5762c5e4 net: busy-poll: allow preemption in sk_busy_loop()

napi_complete_done() return code can be used by a driver,
no need to add yet another atomic operation in fast path.

Anyway, this looks wrong :

@@ -1186,6 +1201,7 @@ static irqreturn_t ena_intr_msix_io(int irq, void *data)
 {
        struct ena_napi *ena_napi = data;
 
+       atomic_set(&ena_napi->unmask_interrupt, 1);
        napi_schedule(&ena_napi->napi);
 
You probably wanted :

if (napi_schedule_prep(n)) {
	atomic_set(&ena_napi->unmask_interrupt, 1);
	__napi_schedule(n);
}



Please rework this napi poll using core infrastructure.

busypoll logic should be centralized, not reimplemented in different ways in a driver.

Thanks.
