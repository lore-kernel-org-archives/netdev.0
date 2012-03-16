From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net: sh_eth: use NAPI
Date: Fri, 16 Mar 2012 02:15:38 -0700 (PDT)
Message-ID: <20120316.021538.2022095011493944779.davem@davemloft.net>
References: <4F62FDDA.9070708@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4F62FDDA.9070708@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Date: Fri, 16 Mar 2012 17:46:18 +0900

sh_eth_interrupt takes mdp->lock, and:

> +static int sh_eth_poll(struct napi_struct *napi, int budget)
> +{
> +	struct sh_eth_private *mdp = container_of(napi, struct sh_eth_private,
> +						  napi);
> +	struct net_device *ndev = mdp->ndev;
> +	struct sh_eth_cpu_data *cd = mdp->cd;
> +	int work_done = 0, txfree_num;
> +	u32 intr_status = sh_eth_read(ndev, EESR);
> +
> +	spin_lock(&mdp->lock);

sh_eth_poll() runs from software interrupt context, therefore
this can deadlock.

Even though you turned off interrupts in sh_eth_interrupt to
enable NAPI mode, this can still happen, interrupts can be
stuck in the interrupt controller, another device can be on
the same interrupt line, etc.  Therefore you must handle
this properly.

I would suggest _NOT_ fixing this by taking the lock with interrupts
disabled in sh_eth_poll(), that defeats the whole prupose of
converting to NAPI and this would also require you to change back
the dev_kfree_skb() to dev_kfree_skb_irq().

Instead, do what other drivers do, make your interrupt handler run
completely lockless and have a sophisticated quiescence sequence
when you want to sync interrupts off and make sure no async contexts
are still running in the interrupt handler.  See tg3.c for one
example of this.

I'm toss this entire patch series, it needs a lot more work.
