From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: [PATCH 3/4] drivers/net/can/mscan/mpc5xxx_can.c: Add of_node_put to
	avoid memory leak
Date: Tue, 31 Aug 2010 17:48:57 +0200
Message-ID: <1283269738-14612-4-git-send-email-julia@diku.dk>
References: <1283269738-14612-1-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1283269738-14612-1-git-send-email-julia-dAYI7NvHqcQ@public.gmane.org>
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
 drivers/net/can/mscan/mpc5xxx_can.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/mscan/mpc5xxx_can.c
index b1bdc90..883959c 100644
--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -148,7 +148,7 @@ static u32 __devinit mpc512x_can_get_clock(struct platform_device *ofdev,
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
