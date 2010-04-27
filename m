From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with Linus' tree
Date: Tue, 27 Apr 2010 11:28:27 +1000
Message-ID: <20100427112827.1f17be40.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>, Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/e100.c between commit
401da6aea31ef69c2fcd260382adabdcf7ce820a ("e100: Fix the TX workqueue
race") from Linus' tree and commit
fa05e1ad1b61b37fb64a66794c11ab478e975c56 ("drivers/net/e100.c: Use
pr_<level> and netif_<level>") from the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix
for a while.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/e100.c
index 7910803,3e8d000..0000000
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@@ -2264,15 -2278,10 +2279,15 @@@ static void e100_tx_timeout_task(struc
  	struct nic *nic = container_of(work, struct nic, tx_timeout_task);
  	struct net_device *netdev = nic->netdev;
  
- 	DPRINTK(TX_ERR, DEBUG, "scb.status=0x%02X\n",
- 		ioread8(&nic->csr->scb.status));
+ 	netif_printk(nic, tx_err, KERN_DEBUG, nic->netdev,
+ 		     "scb.status=0x%02X\n", ioread8(&nic->csr->scb.status));
 -	e100_down(netdev_priv(netdev));
 -	e100_up(netdev_priv(netdev));
 +
 +	rtnl_lock();
 +	if (netif_running(netdev)) {
 +		e100_down(netdev_priv(netdev));
 +		e100_up(netdev_priv(netdev));
 +	}
 +	rtnl_unlock();
  }
  
  static int e100_loopback_test(struct nic *nic, enum loopback loopback_mode)
