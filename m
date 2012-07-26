From: Cong Wang <amwang@redhat.com>
Subject: re: bonding: sync netpoll code with bridge
Date: Thu, 26 Jul 2012 15:15:05 +0800
Message-ID: <1343286905.12207.7.camel@cr0>
References: <20120725134710.GA25625@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868Ab2GZHPL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2012 03:15:11 -0400
In-Reply-To: <20120725134710.GA25625@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 16:47 +0300, Dan Carpenter wrote:
> Hello Amerigo Wang,
> 
> The patch 8a8efa22f51b: "bonding: sync netpoll code with bridge" from 
> Feb 17, 2011, leads to the following warning:
> drivers/net/bonding/bond_main.c:1849 bond_enslave()
> 	 error: scheduling with locks held: 'read_lock:&bond->lock'

Yeah, makes sense. Just wondering why I didn't catch it when I tested
that patch. Anyway, could you try the following patch?

----------->

diff --git a/drivers/net/bonding/bond_main.c
b/drivers/net/bonding/bond_main.c
index 6fae5f3..ab773d4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1235,7 +1235,7 @@ static inline int slave_enable_netpoll(struct
slave *slave)
 	struct netpoll *np;
 	int err = 0;
 
-	np = kzalloc(sizeof(*np), GFP_KERNEL);
+	np = kzalloc(sizeof(*np), GFP_ATOMIC);
 	err = -ENOMEM;
 	if (!np)
 		goto out;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index b4c90e4..c78a966 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -734,7 +734,7 @@ int __netpoll_setup(struct netpoll *np, struct
net_device *ndev)
 	}
 
 	if (!ndev->npinfo) {
-		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
+		npinfo = kmalloc(sizeof(*npinfo), GFP_ATOMIC);
 		if (!npinfo) {
 			err = -ENOMEM;
 			goto out;
