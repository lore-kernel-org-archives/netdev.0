From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 02/36] scsi,rcu: convert call_rcu(fc_rport_free_rcu) to kfree_rcu()
Date: Fri, 18 Mar 2011 11:41:14 +0800
Message-ID: <4D82D45A.30102@cn.fujitsu.com>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Jens Axboe <axboe@kernel.dk>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Tejun Heo <tj@kernel.org>, Jarek Poplawski <jarkao2@gmail.com>,
	linux-kernel@vger.kernel.org, devel@open-fcoe.org,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64337 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab1CRDj3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:39:29 -0400
In-Reply-To: <4D82D3FF.2080303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback fc_rport_free_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(fc_rport_free_rcu).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 drivers/scsi/libfc/fc_rport.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/drivers/scsi/libfc/fc_rport.c b/drivers/scsi/libfc/fc_rport.c
index a7175ad..29abab0 100644
--- a/drivers/scsi/libfc/fc_rport.c
+++ b/drivers/scsi/libfc/fc_rport.c
@@ -151,18 +151,6 @@ static struct fc_rport_priv *fc_rport_create(struct fc_lport *lport,
 }
 
 /**
- * fc_rport_free_rcu() - Free a remote port
- * @rcu: The rcu_head structure inside the remote port
- */
-static void fc_rport_free_rcu(struct rcu_head *rcu)
-{
-	struct fc_rport_priv *rdata;
-
-	rdata = container_of(rcu, struct fc_rport_priv, rcu);
-	kfree(rdata);
-}
-
-/**
  * fc_rport_destroy() - Free a remote port after last reference is released
  * @kref: The remote port's kref
  */
@@ -171,7 +159,7 @@ static void fc_rport_destroy(struct kref *kref)
 	struct fc_rport_priv *rdata;
 
 	rdata = container_of(kref, struct fc_rport_priv, kref);
-	call_rcu(&rdata->rcu, fc_rport_free_rcu);
+	kfree_rcu(rdata, rcu);
 }
 
 /**
-- 
1.7.4
