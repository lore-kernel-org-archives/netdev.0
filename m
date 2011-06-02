From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: Re: [PATCH 4/10] drivers/net/can/flexcan.c: add missing clk_put
Date: Thu, 2 Jun 2011 07:48:50 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1106020748020.22932@ask.diku.dk>
References: <1306948213-20767-4-git-send-email-julia@diku.dk>
	<1306949175.32125.20.camel@Joe-Laptop>
	<Pine.LNX.4.64.1106012207260.5871@ask.diku.dk>
	<20110601.131136.391831410750786951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, wharms-fPG8STNUNVg@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20110601.131136.391831410750786951.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

The failed_get label is used after the call to clk_get has succeeded, so it
should be moved up above the call to clk_put.

The failed_req labels doesn't do anything different than failed_get, so
delete it.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r exists@
expression e1,e2;
statement S;
@@

e1 = clk_get@p1(...);
... when != e1 = e2
    when != clk_put(e1)
    when any
if (...) { ... when != clk_put(e1)
               when != if (...) { ... clk_put(e1) ... }
* return@p3 ...;
 } else S
// </smpl>

Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

---
 drivers/net/can/flexcan.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index d499056..1767811 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -923,7 +923,7 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 	mem_size = resource_size(mem);
 	if (!request_mem_region(mem->start, mem_size, pdev->name)) {
 		err = -EBUSY;
-		goto failed_req;
+		goto failed_get;
 	}
 
 	base = ioremap(mem->start, mem_size);
@@ -977,9 +977,8 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
 	iounmap(base);
  failed_map:
 	release_mem_region(mem->start, mem_size);
- failed_req:
-	clk_put(clk);
  failed_get:
+	clk_put(clk);
  failed_clock:
 	return err;
 }
