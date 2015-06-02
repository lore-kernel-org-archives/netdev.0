From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH 07/10] net: thunderx: fix nicvf_set_rxfh()
Date: Tue, 2 Jun 2015 11:00:24 -0700
Message-ID: <1433268028-23992-8-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a copypaste bug that was discovered by a static analysis
tool:

The patch 4863dea3fab0: "net: Adding support for Cavium ThunderX
network controller" from May 26, 2015, leads to the following static
checker warning:

        drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c:517
nicvf_set_rxfh()
        warn: we tested 'hkey' before and it was 'false'

drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
   506          /* We do not allow change in unsupported parameters */
   507          if (hkey ||
                    ^^^^
We return here.

   508              (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc !=
ETH_RSS_HASH_TOP))
   509                  return -EOPNOTSUPP;
   510
   511          rss->enable = true;
   512          if (indir) {
   513                  for (idx = 0; idx < rss->rss_size; idx++)
   514                          rss->ind_tbl[idx] = indir[idx];
   515          }
   516
   517          if (hkey) {
                    ^^^^
So this is dead code.

   518                  memcpy(rss->key, hkey, RSS_HASH_KEY_SIZE *
sizeof(u64));
   519                  nicvf_set_rss_key(nic);
   520          }
   521
   522          nicvf_config_rss(nic);
   523          return 0;
   524  }

regards,
dan carpenter

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index 0fc4a53..16bd2d7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -504,8 +504,7 @@ static int nicvf_set_rxfh(struct net_device *dev, const u32 *indir,
 	}
 
 	/* We do not allow change in unsupported parameters */
-	if (hkey ||
-	    (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP))
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
 
 	rss->enable = true;
-- 
2.4.1
