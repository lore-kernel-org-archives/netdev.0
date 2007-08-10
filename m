From: "Scott Thompson" <postfail@hushmail.com>
Subject: [PATCH 3/4]  /drivers/net ioremap balancing/returncode check (myri_sbus.c)
Date: Fri, 10 Aug 2007 14:40:26 -0400
Message-ID: <20070810184026.B3276DA82B@mailserver7.hushmail.com>
Reply-To: postfail@hushmail.com
Content-Type: text/plain; charset="UTF-8"
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

patchset against 2.6.23-rc2 for /drivers/net ioremap balancing / 
return check:

  corrects:
  --sbus_ioremap return unchecked.
  --ioremap function unchecked
  --function failure cases did not clean up ioremap'd values.
  lne390.c
   -- believe had incorrect/not ideal variable check on if for 
iounmap

this audit was only for files directly in drivers/net directory, 
not the full tree.

I split patches up by file changed as each file had different 
'owner' to ease accept/reject/revision process.

Signed-off-by: Scott Thompson <postfail <at> hushmail.com>
----------------------------------------------------------
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 13444da..fa624b3 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -1007,6 +1007,13 @@ static int __devinit myri_ether_init(struct 
sbus_dev *sdev)
 		mp->lanai =
 			sbus_ioremap(&sdev->resource[0], (512 * 1024),
 				     mp->eeprom.ramsz, "MyriCOM SRAM");
+
+
+		if (!mp->cregs || !mp->lregs || !mp->lanai ) {
+			printk("MyriCOM: Cannot map MyriCOM registers for cpuvers >= 
CPUVERS_4_0.\n");
+			goto err;
+		}
+		
 	}
 	DET(("Registers mapped: cregs[%p] lregs[%p] lanai[%p]\n",
 	     mp->cregs, mp->lregs, mp->lanai));
@@ -1108,6 +1115,16 @@ err_free_irq:
 err:
 	/* This will also free the co-allocated 'dev->priv' */
 	free_netdev(dev);
+
+	if (mp->regs)
+		sbus_iounmap(mp->regs, mp->reg_size);
+	if (mp->cregs)
+		sbus_iounmap(mp->cregs, PAGE_SIZE);
+	if (mp->lregs)
+		sbus_iounmap(mp->lregs, (256 * 1024));
+	if (mp->lanai)
+		sbus_iounmap(mp->lanai, (512 * 1024));
+
 	return -ENODEV;
 }
 




