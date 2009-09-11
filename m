From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 4/8] drivers/net/wan: introduce missing kfree
Date: Fri, 11 Sep 2009 18:21:51 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0909111821360.10552@pc-004.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:42709 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754553AbZIKQVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 12:21:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Error handling code following a kmalloc should free the allocated data.

The semantic match that finds the problem is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@r exists@
local idexpression x;
statement S;
expression E;
identifier f,f1,l;
position p1,p2;
expression *ptr != NULL;
@@

x@p1 = \(kmalloc\|kzalloc\|kcalloc\)(...);
...
if (x == NULL) S
<... when != x
     when != if (...) { <+...x...+> }
(
x->f1 = E
|
 (x->f1 == NULL || ...)
|
 f(...,x->f1,...)
)
...>
(
 return \(0\|<+...x...+>\|ptr\);
|
 return@p2 ...;
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

print "* file: %s kmalloc %s return %s" % (p1[0].file,p1[0].line,p2[0].line)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
---
 drivers/net/wan/hdlc_ppp.c          |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 72a7cda..b9b9d6b 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -389,6 +389,7 @@ static void ppp_cp_parse_cr(struct net_device *dev, u16 pid, u8 id,
 	for (opt = data; len; len -= opt[1], opt += opt[1]) {
 		if (len < 2 || len < opt[1]) {
 			dev->stats.rx_errors++;
+			kfree(out);
 			return; /* bad packet, drop silently */
 		}
 
