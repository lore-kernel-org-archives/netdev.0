From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Patch V2] bonding: fix netpoll in active-backup mode
Date: Tue, 8 Mar 2011 16:24:05 -0500
Message-ID: <20110308212405.GX11864@gospo.rdu.redhat.com>
References: <1299578336-5888-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1299578336-5888-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 08, 2011 at 05:58:56PM +0800, Amerigo Wang wrote:
> V2: avoid calling slave_diable_netpoll() with write_lock_bh() held.
> 
> netconsole doesn't work in active-backup mode, because we don't do anything
> for nic failover in active-backup mode. We should disable netpoll on the
> failing slave when it is detected down and enable netpoll when it becomes
> the active slave.
> 
> Tested by ifdown the current active slave and ifup it again for several times,
> netconsole works well.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> 

It seems like you are going to a lot of trouble to fix a bug where
netpoll will not be setup on any interface that is down when enslaved.
That seems to be the only path that would not have slave->np setup
properly at enslavement.

Did you ever try just this?

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0592e6d..8d93044 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1352,8 +1352,6 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
 
 	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
-		if (!IS_UP(slave->dev))
-			continue;
 		err = slave_enable_netpoll(slave);
 		if (err) {
 			__bond_netpoll_cleanup(bond);
