From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/7] net-sysfs: Use rtnl_trylock in sysfs methods.
Date: Wed, 13 May 2009 19:57:25 -0700
Message-ID: <m1skj8qtm2.fsf@fess.ebiederm.org>
References: <m13ab8s8cr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54760 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224AbZENC51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 22:57:27 -0400
In-Reply-To: <m13ab8s8cr.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Wed\, 13 May 2009 19\:53\:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The earlier patch to fix the deadlock between a network device going
away and writing to sysfs attributes was incomplete.
- It did not set signal_pending so we would leak ERSTARTSYS to user space.
- It used ERESTARTSYS which only restarts if sigaction configures it to.
- It did not cover store and show for ifalias.

So fix all of these up and use the new helper restart_syscall so we get
the details correct on what it takes.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/core/net-sysfs.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 2da59a0..b9641e8 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -78,7 +78,7 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,
 		goto err;
 
 	if (!rtnl_trylock())
-		return -ERESTARTSYS;
+		return restart_syscall();
 
 	if (dev_isalive(net)) {
 		if ((ret = (*set)(net, new)) == 0)
@@ -225,7 +225,8 @@ static ssize_t store_ifalias(struct device *dev, struct device_attribute *attr,
 	if (len >  0 && buf[len - 1] == '\n')
 		--count;
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
 	ret = dev_set_alias(netdev, buf, count);
 	rtnl_unlock();
 
@@ -238,7 +239,8 @@ static ssize_t show_ifalias(struct device *dev,
 	const struct net_device *netdev = to_net_dev(dev);
 	ssize_t ret = 0;
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
 	if (netdev->ifalias)
 		ret = sprintf(buf, "%s\n", netdev->ifalias);
 	rtnl_unlock();
-- 
1.6.0.6

