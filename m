From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ipv6: move dereference after check in fl_free()
Date: Thu, 16 Aug 2012 16:15:02 +0300
Message-ID: <20120816131502.GB23188@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:35561 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932288Ab2HPNP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 09:15:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a dereference before checking for NULL bug here.  Generally
free() functions should accept NULL pointers.  For example, fl_create()
can pass a NULL pointer to fl_free() on the error path.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Only needed on linux-next.

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index c836a6a..90bbefb 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -91,12 +91,9 @@ static struct ip6_flowlabel *fl_lookup(struct net *net, __be32 label)
 
 static void fl_free(struct ip6_flowlabel *fl)
 {
-	switch (fl->share) {
-	case IPV6_FL_S_PROCESS:
-		put_pid(fl->owner.pid);
-		break;
-	}
 	if (fl) {
+		if (fl->share == IPV6_FL_S_PROCESS)
+			put_pid(fl->owner.pid);
 		release_net(fl->fl_net);
 		kfree(fl->opt);
 	}
