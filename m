From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] bond_main.c: fix device deregistration in init
 exception path
Date: Sat, 17 Sep 2005 23:32:24 -0700
Message-ID: <20050917233224.2d4b3652.akpm@osdl.org>
References: <432D0612.7070408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ctindel@users.sourceforge.net,
	fubar@us.ibm.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751196AbVIRGdM@vger.kernel.org>
To: Florin Malita <fmalita@gmail.com>
In-Reply-To: <432D0612.7070408@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florin Malita <fmalita@gmail.com> wrote:
>
> User-Agent: Mozilla Thunderbird 1.0.6-1.1.fc4 (X11/20050720)

Your MUA is converting tabs to spaces.

>  bond_init() is not releasing rtnl_sem after register_netdevice() and
>  before calling unregister_netdevice() (from bond_free_all()) in the
>  exception path. As the device registration is not completed
>  (dev->reg_state == NETREG_REGISTERING), the call to
>  unregister_netdevice() triggers BUG_ON(dev->reg_state != NETREG_REGISTERED).
> 
>  Signed-off-by: Florin Malita <fmalita@gmail.com>
>  ----
>  diff --git a/drivers/net/bonding/bond_main.c
>  b/drivers/net/bonding/bond_main.c
>  --- a/drivers/net/bonding/bond_main.c
>  +++ b/drivers/net/bonding/bond_main.c
>  @@ -5039,6 +5039,10 @@ static int __init bonding_init(void)
>          return 0;
> 
>   out_err:
>  +       /* give register_netdevice() a chance to complete */
>  +       rtnl_unlock();
>  +       rtnl_lock();
>  +
>          /* free and unregister all bonds that were successfully added */
>          bond_free_all();

OK, so the bonding devices which were registered are now in state
NETREG_REGISTERING and we need to run netdev_run_todo() to flip them into
state NETREG_REGISTERED.  If we don't do that,
bond_free_all()->unregister_netdevice() will go BUG.

The fix is solid enough, although a better comment is needed.  Let's let
Dave decide whether that was a sane thing to go BUG over..



From: Florin Malita <fmalita@gmail.com>

bond_init() is not releasing rtnl_sem after register_netdevice() and before
calling unregister_netdevice() (from bond_free_all()) in the exception
path.  As the device registration is not completed (dev->reg_state ==
NETREG_REGISTERING), the call to unregister_netdevice() triggers
BUG_ON(dev->reg_state != NETREG_REGISTERED).

Signed-off-by: Florin Malita <fmalita@gmail.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/bonding/bond_main.c |    8 ++++++++
 1 files changed, 8 insertions(+)

diff -puN drivers/net/bonding/bond_main.c~bond_mainc-fix-device-deregistration-in-init-exception drivers/net/bonding/bond_main.c
--- devel/drivers/net/bonding/bond_main.c~bond_mainc-fix-device-deregistration-in-init-exception	2005-09-17 23:18:38.000000000 -0700
+++ devel-akpm/drivers/net/bonding/bond_main.c	2005-09-17 23:31:02.000000000 -0700
@@ -5039,6 +5039,14 @@ static int __init bonding_init(void)
 	return 0;
 
 out_err:
+	/*
+	 * rtnl_unlock() will run netdev_run_todo(), putting the
+	 * thus-far-registered bonding devices into a state which
+	 * unregigister_netdevice() will accept
+	 */
+	rtnl_unlock();
+	rtnl_lock();
+
 	/* free and unregister all bonds that were successfully added */
 	bond_free_all();
 
_
