From: David Miller <davem@davemloft.net>
Subject: [PATCH] niu: Rename NIU parent platform device name to fix
 conflict.
Date: Sat, 19 Mar 2011 23:07:33 -0700 (PDT)
Message-ID: <20110319.230733.193709340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34550
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751069Ab1CTGG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 02:06:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When the OF device driver bits were converted over to the platform
device infrastructure in commit 74888760d40b3ac9054f9c5fa07b566c0676ba2d
("dt/net: Eliminate users of of_platform_{,un}register_driver") we
inadvertantly created probing problems in the OF case.

The NIU driver creates a dummy platform device to represent the
board that contains one or more child NIU devices.  Unfortunately
we use the same name, "niu", as the OF device driver itself uses.

The result is that we try to probe the dummy "niu" parent device we
create, and since it has a NULL ofdevice pointer etc. everything
explodes:

[783019.128243] niu: niu.c:v1.1 (Apr 22, 2010)
[783019.128810] Unable to handle kernel NULL pointer dereference
[783019.128949] tsk->{mm,active_mm}->context = 000000000000039e
[783019.129078] tsk->{mm,active_mm}->pgd = fffff803afc5a000
[783019.129206]               \|/ ____ \|/
[783019.129213]               "@'/ .. \`@"
[783019.129220]               /_| \__/ |_\
[783019.129226]                  \__U_/
[783019.129378] modprobe(2004): Oops [#1]
[783019.129423] TSTATE: 0000000011001602 TPC: 0000000010052ff8 TNPC: 000000000061bbb4 Y: 00000000    Not tainted
[783019.129542] TPC: <niu_of_probe+0x3c/0x2dc [niu]>
[783019.129624] g0: 8080000000000000 g1: 0000000000000000 g2: 0000000010056000 g3: 0000000000000002
[783019.129733] g4: fffff803fc1da0c0 g5: fffff800441e2000 g6: fffff803fba84000 g7: 0000000000000000
[783019.129842] o0: fffff803fe7df010 o1: 0000000010055700 o2: 0000000000000000 o3: fffff803fbacaca0
[783019.129951] o4: 0000000000000080 o5: 0000000000777908 sp: fffff803fba866e1 ret_pc: 0000000010052ff4
[783019.130083] RPC: <niu_of_probe+0x38/0x2dc [niu]>
[783019.130165] l0: fffff803fe7df010 l1: fffff803fbacafc0 l2: fffff803fbacaca0 l3: ffffffffffffffed
[783019.130273] l4: 0000000000000000 l5: 000000007fffffff l6: fffff803fba86f40 l7: 0000000000000001
[783019.130382] i0: fffff803fe7df000 i1: fffff803fc20aba0 i2: 0000000000000000 i3: 0000000000000001
[783019.130490] i4: 0000000000000000 i5: 0000000000000000 i6: fffff803fba867a1 i7: 000000000062038c
[783019.130614] I7: <platform_drv_probe+0xc/0x20>

Fix by simply renaming the parent device to "niu-board".

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Grant, I'll push this fix via the net-2.6 tree, you don't have
to worry about it.

 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 40fa59e..32678b6 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -9501,7 +9501,7 @@ static struct niu_parent * __devinit niu_new_parent(struct niu *np,
 	struct niu_parent *p;
 	int i;
 
-	plat_dev = platform_device_register_simple("niu", niu_parent_index,
+	plat_dev = platform_device_register_simple("niu-board", niu_parent_index,
 						   NULL, 0);
 	if (IS_ERR(plat_dev))
 		return NULL;
-- 
1.7.4.1

