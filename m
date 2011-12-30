From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Fri, 30 Dec 2011 22:50:24 +0100
Message-ID: <20111230215024.GA5513@electric-eye.fr.zoreil.com>
References: <20111229183902.GC21946@electric-eye.fr.zoreil.com> <20111229.170514.1766899380937848638.davem@davemloft.net> <CACPM=kV8NwYLAdODQHxYmJ21X0RmZ8KJT9szKdY2xa-DsesvQg@mail.gmail.com> <CACPM=kVfsXgFhKheevTS1pm7kCoezKO3M+102O=PRbXzxebxxg@mail.gmail.com> <20111229235312.GA27092@electric-eye.fr.zoreil.com> <CACPM=kXTqY1kVWrEMB-Z0Lqy6t+rXvMzixcSUy7fAz6g_ajV9g@mail.gmail.com> <20111230125655.GA32031@electric-eye.fr.zoreil.com> <CACPM=kVBxcL1_Z9zVvnEEdEgAc0rbAAbzkcocz4OYWQ2xn6VmQ@mail.gmail.com> <20111230180347.GA3647@electric-eye.fr.zoreil.com> <CACPM=kXWXUE+JcVhkz-6tGZ2YyteN9sGA80+Pnw6+LaJ-eNWBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACPM=kXWXUE+JcVhkz-6tGZ2YyteN9sGA80+Pnw6+LaJ-eNWBA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
[...]
> Just applied it to HEAD of net-next, and got the following compiler warning:
> drivers/net/ethernet/via/via-rhine.c:2182:13: warning:
> 'rhine_task_enable' defined but not used

You are running with CONFIG_PM disabled and a down / up loop will not
work. The patch below should hide the latter, at least as long as the
relevant workqueue does not stall for too long... Extra cancel_work in
task_enable could work too but it will look strange.

> Just so you know that too :)

Thanks for testing.

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index c57e1da..89ced1b 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1536,6 +1536,7 @@ static int rhine_open(struct net_device *dev)
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
+	rhine_task_enable(rp);
 	init_registers(dev);
 	if (debug > 2)
 		netdev_dbg(dev, "%s() Done - status %04x MII status: %04x\n",
-- 
Ueimor
