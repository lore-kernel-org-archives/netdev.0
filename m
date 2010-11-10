From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Fix hung tasks.
Date: Wed, 10 Nov 2010 17:57:54 +0100
Message-ID: <OFB11D8F46.84F3CAC0-ONC12577D7.005C8EE4-C12577D7.005D3148@transmode.se>
References: <1289211819-21746-1-git-send-email-Joakim.Tjernlund@transmode.se> <OFEBFE0319.7D12AA7E-ONC12577D7.00423B59-C12577D7.00426B71@LocalDomain> <OF7C87528F.1727C94B-ONC12577D7.004DB53C-C12577D7.004DF235@LocalDomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:40055 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756972Ab0KJQ55 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 11:57:57 -0500
In-Reply-To: <OF7C87528F.1727C94B-ONC12577D7.004DB53C-C12577D7.004DF235@LocalDomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund/Transmode wrote on 2010/11/10 15:11:22:
>
> Actually, there is something wrong anyway with TX timeout
> so don't use this patch. I must investigate more but
> it seems like cancel_work_sync hangs whenever an TX timeout
> occurs.

OK, found the problem. Currently ucc_geth bring the IF down and up
each time a TX timeout occurs which means you cannot do cancel_work_sync()
in ucc_geth_close as it will dead lock.

Looking at gianfar, it just reinits the controller and PHY and
I guess ucc_geth really should do the same.
This patch tries to do that but I am not sure it recovers
after a TX timeout.

Anton, what do think? If OK with you I will write up
a proper patch.

 diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 6647ed7..133aaba 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2065,9 +2065,6 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	/* Disable Rx and Tx */
 	clrbits32(&ug_regs->maccfg1, MACCFG1_ENABLE_RX | MACCFG1_ENABLE_TX);

-	phy_disconnect(ugeth->phydev);
-	ugeth->phydev = NULL;
-
 	ucc_geth_memclean(ugeth);
 }

@@ -3558,6 +3555,8 @@ static int ucc_geth_close(struct net_device *dev)

 	cancel_work_sync(&ugeth->timeout_work);
 	ucc_geth_stop(ugeth);
+	phy_disconnect(ugeth->phydev);
+	ugeth->phydev = NULL;

 	free_irq(ugeth->ug_info->uf_info.irq, ugeth->ndev);

@@ -3586,8 +3585,12 @@ static void ucc_geth_timeout_work(struct work_struct *work)
 		 * Must reset MAC *and* PHY. This is done by reopening
 		 * the device.
 		 */
-		ucc_geth_close(dev);
-		ucc_geth_open(dev);
+		netif_tx_stop_all_queues(dev);
+		ucc_geth_stop(ugeth);
+		ucc_geth_init_mac(ugeth);
+		/* Must start PHY here */
+		phy_start(ugeth->phydev);
+		netif_tx_start_all_queues(dev);
 	}

 	netif_tx_schedule_all(dev);

>
> Joakim Tjernlund/Transmode wrote on 2010/11/10 13:05:28:
> >
> > Ping?
> >
> > Even though this patch didn't solve my hang it is still a bug.
> >
> >      Jocke
> >
> > Joakim Tjernlund <Joakim.Tjernlund@transmode.se> wrote on 2010/11/08 11:23:39:
> >
> > > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > > To: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, Anton Vorontsov <avorontsov@ru.mvista.com>
> > > Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > > Date: 2010/11/08 11:23
> > > Subject: [PATCH] ucc_geth: Fix hung tasks.
> > >
> > > We noticed a few hangs like this:
> > >
> > > INFO: task ifconfig:572 blocked for more than 120 seconds.
> > > "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > > ifconfig      D 0ff65760     0   572    369 0x00000000
> > > Call Trace:
> > > [c6157be0] [c6008460] 0xc6008460 (unreliable)
> > > [c6157ca0] [c0008608] __switch_to+0x4c/0x6c
> > > [c6157cb0] [c028fecc] schedule+0x184/0x310
> > > [c6157ce0] [c0290e54] __mutex_lock_slowpath+0xa4/0x150
> > > [c6157d20] [c0290c48] mutex_lock+0x44/0x48
> > > [c6157d30] [c01aba74] phy_stop+0x20/0x70
> > > [c6157d40] [c01aef40] ucc_geth_stop+0x30/0x98
> > > [c6157d60] [c01b18fc] ucc_geth_close+0x9c/0xdc
> > > [c6157d80] [c01db0cc] __dev_close+0xa0/0xd0
> > > [c6157d90] [c01deddc] __dev_change_flags+0x8c/0x148
> > > [c6157db0] [c01def54] dev_change_flags+0x1c/0x64
> > > [c6157dd0] [c0237ac8] devinet_ioctl+0x678/0x784
> > > [c6157e50] [c0239a58] inet_ioctl+0xb0/0xbc
> > > [c6157e60] [c01cafa8] sock_ioctl+0x174/0x2a0
> > > [c6157e80] [c009a16c] vfs_ioctl+0xcc/0xe0
> > > [c6157ea0] [c009a998] do_vfs_ioctl+0xc4/0x79c
> > > [c6157f10] [c009b0b0] sys_ioctl+0x40/0x74
> > > [c6157f40] [c00117c4] ret_from_syscall+0x0/0x38
> > >
> > > I THINK this is due to a missing cancel_work_sync in the driver
> > > although we cannot be sure. I found this by comparing
> > > ucc_geth with gianfar.
> > >
> > > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > > ---
> > >  drivers/net/ucc_geth.c |    1 +
> > >  1 files changed, 1 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> > > index 97f9f7d..6647ed7 100644
> > > --- a/drivers/net/ucc_geth.c
> > > +++ b/drivers/net/ucc_geth.c
> > > @@ -3556,6 +3556,7 @@ static int ucc_geth_close(struct net_device *dev)
> > >
> > >     napi_disable(&ugeth->napi);
> > >
> > > +   cancel_work_sync(&ugeth->timeout_work);
> > >     ucc_geth_stop(ugeth);
> > >
> > >     free_irq(ugeth->ug_info->uf_info.irq, ugeth->ndev);
> > > --
> > > 1.7.2.2
> > >

