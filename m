From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the suspend tree with the net tree
Date: Wed, 4 Aug 2010 13:14:11 +1000
Message-ID: <20100804131411.85975b86.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	James Bottomley <James.Bottomley@suse.de>,
	mark gross <markgross@thegnar.org>,
	Florian Mickler <florian@mickler.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rafael,

Today's linux-next merge of the suspend tree got a conflict in
drivers/net/e1000e/netdev.c between commit
c128ec29208d410568469bd8bb373b4cdc10912a ("e1000e: register pm_qos
request on hardware activation") from the net tree and commit
82f682514a5df89ffb3890627eebf0897b7a84ec ("pm_qos: Get rid of the
allocation in pm_qos_add_request()") from the suspend tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/e1000e/netdev.c
index 35c7dbd,9f13b66..0000000
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@@ -3525,12 -3495,6 +3525,13 @@@ static int e1000_open(struct net_devic
  	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN))
  		e1000_update_mng_vlan(adapter);
  
 +	/* DMA latency requirement to workaround early-receive/jumbo issue */
 +	if (adapter->flags & FLAG_HAS_ERT)
- 		adapter->netdev->pm_qos_req =
- 		                    pm_qos_add_request(PM_QOS_CPU_DMA_LATENCY,
- 		                                       PM_QOS_DEFAULT_VALUE);
++		pm_qos_add_request(&adapter->netdev->pm_qos_req,
++				   PM_QOS_CPU_DMA_LATENCY,
++				   PM_QOS_DEFAULT_VALUE);
++
 +
  	/*
  	 * before we allocate an interrupt, we must be ready to handle it.
  	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
@@@ -3635,11 -3599,6 +3636,10 @@@ static int e1000_close(struct net_devic
  	if (adapter->flags & FLAG_HAS_AMT)
  		e1000_release_hw_control(adapter);
  
- 	if (adapter->flags & FLAG_HAS_ERT) {
- 		pm_qos_remove_request(adapter->netdev->pm_qos_req);
- 		adapter->netdev->pm_qos_req = NULL;
- 	}
++	if (adapter->flags & FLAG_HAS_ERT)
++		pm_qos_remove_request(&adapter->netdev->pm_qos_req);
++
 +
  	pm_runtime_put_sync(&pdev->dev);
  
  	return 0;
