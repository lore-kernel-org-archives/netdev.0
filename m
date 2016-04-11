From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mark DECnet as broken
Date: Sun, 10 Apr 2016 23:02:01 -0400 (EDT)
Message-ID: <20160410.230201.2150110742043110823.davem@davemloft.net>
References: <1460013763-22985-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	eric.dumazet@gmail.com, sasha.levin@oracle.com
To: vegard.nossum@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460013763-22985-1-git-send-email-vegard.nossum@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Thu,  7 Apr 2016 09:22:43 +0200

> There are NULL pointer dereference bugs in DECnet which can be triggered
> by unprivileged users and have been reported multiple times to LKML,
> however nobody seems confident enough in the proposed fixes to merge them
> and the consensus seems to be that nobody cares enough about DECnet to
> see it fixed anyway.
> 
> To shield unsuspecting users from the possible DOS, we should mark this
> BROKEN until somebody who actually uses this code can fix it.
> 
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
> Link: https://lkml.org/lkml/2015/12/17/666

As stated, I'm not applying this, and rather I am fixing this as
below:

====================
[PATCH] decnet: Do not build routes to devices without decnet private data.

In particular, make sure we check for decnet private presence
for loopback devices.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/dn_route.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 607a14f..b1dc096 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1034,10 +1034,13 @@ source_ok:
 	if (!fld.daddr) {
 		fld.daddr = fld.saddr;
 
-		err = -EADDRNOTAVAIL;
 		if (dev_out)
 			dev_put(dev_out);
+		err = -EINVAL;
 		dev_out = init_net.loopback_dev;
+		if (!dev_out->dn_ptr)
+			goto out;
+		err = -EADDRNOTAVAIL;
 		dev_hold(dev_out);
 		if (!fld.daddr) {
 			fld.daddr =
@@ -1110,6 +1113,8 @@ source_ok:
 		if (dev_out == NULL)
 			goto out;
 		dn_db = rcu_dereference_raw(dev_out->dn_ptr);
+		if (!dn_db)
+			goto e_inval;
 		/* Possible improvement - check all devices for local addr */
 		if (dn_dev_islocal(dev_out, fld.daddr)) {
 			dev_put(dev_out);
@@ -1151,6 +1156,8 @@ select_source:
 			dev_put(dev_out);
 		dev_out = init_net.loopback_dev;
 		dev_hold(dev_out);
+		if (!dev_out->dn_ptr)
+			goto e_inval;
 		fld.flowidn_oif = dev_out->ifindex;
 		if (res.fi)
 			dn_fib_info_put(res.fi);
-- 
2.1.0
