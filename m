From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 5/7] net: Fix bridgeing sysfs handling of rtnl_lock
Date: Wed, 13 May 2009 20:00:41 -0700
Message-ID: <m1ab5gqtgm.fsf@fess.ebiederm.org>
References: <m13ab8s8cr.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ben Greear <greearb@candelatech.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53172 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260AbZENDAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 23:00:44 -0400
In-Reply-To: <m13ab8s8cr.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Wed\, 13 May 2009 19\:53\:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Holding rtnl_lock when we are unregistering the sysfs files can
deadlock if we unconditionally take rtnl_lock in a sysfs file.  So fix
it with the now familiar patter of: rtnl_trylock and syscall_restart()

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/bridge/br_sysfs_br.c |    3 ++-
 net/bridge/br_sysfs_if.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 603d892..ee4820a 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -172,7 +172,8 @@ static ssize_t store_stp_state(struct device *d,
 	if (endp == buf)
 		return -EINVAL;
 
-	rtnl_lock();
+	if (!rtnl_trylock())
+		return restart_syscall();
 	br_stp_set_enabled(br, val);
 	rtnl_unlock();
 
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 02b2d50..4a3cdf8 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -189,7 +189,8 @@ static ssize_t brport_store(struct kobject * kobj,
 
 	val = simple_strtoul(buf, &endp, 0);
 	if (endp != buf) {
-		rtnl_lock();
+		if (!rtnl_trylock())
+			return restart_syscall();
 		if (p->dev && p->br && brport_attr->store) {
 			spin_lock_bh(&p->br->lock);
 			ret = brport_attr->store(p, val);
-- 
1.6.0.6

