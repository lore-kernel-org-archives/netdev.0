From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: fix refcount leak in fib_check_nh()
Date: Sat, 15 Aug 2015 10:54:07 -0700
Message-ID: <1439661247.7258.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1439586894.7507.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1439594063.7507.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55CE7776.5000706@cumulusnetworks.com>
	 <1439595092.7507.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33443 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753173AbbHORyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2015 13:54:09 -0400
Received: by pabyb7 with SMTP id yb7so79194240pab.0
        for <netdev@vger.kernel.org>; Sat, 15 Aug 2015 10:54:09 -0700 (PDT)
In-Reply-To: <1439595092.7507.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

fib_lookup() forces FIB_LOOKUP_NOREF flag, while fib_table_lookup()
does not.

This patch solves the typical message at reboot time or device
dismantle :

unregister_netdevice: waiting for eth0 to become free. Usage count = 4

Fixes: 3bfd847203c6 ("net: Use passed in table for nexthop lookups")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_semantics.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index b7f1d20a9615..c8025851dac7 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -708,7 +708,8 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 
 			if (tbl)
 				err = fib_table_lookup(tbl, &fl4, &res,
-						   FIB_LOOKUP_IGNORE_LINKSTATE);
+						       FIB_LOOKUP_IGNORE_LINKSTATE |
+						       FIB_LOOKUP_NOREF);
 			else
 				err = fib_lookup(net, &fl4, &res,
 						 FIB_LOOKUP_IGNORE_LINKSTATE);
