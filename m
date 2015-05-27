From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH RFC] 8139cp: make timeout HZ independent
Date: Wed, 27 May 2015 20:46:41 +0200
Message-ID: <1432752401-7235-1-git-send-email-hofrat@osadl.org>
Cc: Varka Bhadram <varkab@cdac.in>, Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

schedule_timeout_* takes a timeout in jiffies but the code currently is
passing in a constant which makes this timeout HZ dependent, so pass it
through msecs_to_jiffies() to fix this up.

patch was compile tested with x86_64_defconfig + CONFIG_8139CP=m

Patch is against 4.1-rc5 (localversion-next is -next-20150527)

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

As there is no documentation of the intended timeout it might be wrong
to convert it with msecs_to_jiffies as this can reduces the actual 
jiffies value by at least a factor of 10 - so someone that knows this
driver needs to check on the actual value - but in any case it needs 
to be passed in a HZ independent way.

Further there was a build warning during build test
  CC [M]  drivers/net/ethernet/realtek/8139cp.o
drivers/net/ethernet/realtek/8139cp.c: In function 'cp_tx_timeout':
drivers/net/ethernet/realtek/8139cp.c:1252:6: warning: variable 'rc' set but
not used [-Wunused-but-set-variable]

checking this (line numbers from 4.1-rc5)
1261         cp_clean_rings(cp);
1262         rc = cp_init_rings(cp);
1263         cp_start_hw(cp);

its an unchecked return even though cp_init_rings() is ultimately doing 
kmalloc(  GFP_ATOMIC) and thus could fail and cp_start_hw() will use 
that memory without any further checking.

 drivers/net/ethernet/realtek/8139cp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index d79e33b..02ce4b3 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -990,7 +990,7 @@ static void cp_reset_hw (struct cp_private *cp)
 		if (!(cpr8(Cmd) & CmdReset))
 			return;
 
-		schedule_timeout_uninterruptible(10);
+		schedule_timeout_uninterruptible(msecs_to_jiffies(10));
 	}
 
 	netdev_err(cp->dev, "hardware reset timeout\n");
-- 
1.7.10.4
