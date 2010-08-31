From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: Re: [PATCH 3/4] drivers/net/can/mscan/mpc5xxx_can.c: Add of_node_put
	to avoid memory leak
Date: Tue, 31 Aug 2010 19:44:00 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008311943280.2668@ask.diku.dk>
References: <1283269738-14612-1-git-send-email-julia@diku.dk>
	<1283269738-14612-4-git-send-email-julia@diku.dk>
	<20100831165153.GB28015@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfram Sang <w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20100831165153.GB28015-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a call to of_node_put in the error handling code following a call to
of_find_matching_node.

This patch also moves the existing call to of_node_put after the call to
iounmap in the error handling code, to make it possible to jump to
of_node_put without doing iounmap.  These appear to be disjoint operations,
so the ordering doesn't matter.

This patch furthermore changes the -ENODEV result in the error handling
code for of_find_matching_node to a return of 0, as found in the error
handling code for of_iomap, because the return type of the function is
unsigned.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r exists@
local idexpression x;
expression E,E1,E2;
statement S;
@@

*x = 
(of_find_node_by_path
|of_find_node_by_name
|of_find_node_by_phandle
|of_get_parent
|of_get_next_parent
|of_get_next_child
|of_find_compatible_node
|of_match_node
|of_find_node_by_type
|of_find_node_with_property
|of_find_matching_node
|of_parse_phandle
)(...);
...
if (x == NULL) S
<... when != x = E
*if (...) {
  ... when != of_node_put(x)
      when != if (...) { ... of_node_put(x); ... }
(
  return <+...x...+>;
|
*  return ...;
)
}
...>
(
E2 = x;
|
of_node_put(x);
)
// </smpl>

Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>

---
 drivers/net/can/mscan/mpc5xxx_can.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -143,12 +143,12 @@ static u32 __devinit mpc512x_can_get_clock(struct platform_device *ofdev,
 	np_clock = of_find_matching_node(NULL, mpc512x_clock_ids);
 	if (!np_clock) {
 		dev_err(&ofdev->dev, "couldn't find clock node\n");
-		return -ENODEV;
+		return 0;
 	}
 	clockctl = of_iomap(np_clock, 0);
 	if (!clockctl) {
 		dev_err(&ofdev->dev, "couldn't map clock registers\n");
-		return 0;
+		goto exit_put;
 	}
 
 	/* Determine the MSCAN device index from the physical address */
@@ -233,9 +233,9 @@ static u32 __devinit mpc512x_can_get_clock(struct platform_device *ofdev,
 		clocksrc == 1 ? "ref_clk" : "sys_clk", clockdiv);
 
 exit_unmap:
-	of_node_put(np_clock);
 	iounmap(clockctl);
-
+exit_put:
+	of_node_put(np_clock);
 	return freq;
 }
 #else /* !CONFIG_PPC_MPC512x */
