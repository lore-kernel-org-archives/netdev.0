From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: [PATCH] ibm_newemac: Fix new MAL feature handling
Date: Thu, 16 Oct 2008 10:38:40 -0400
Message-ID: <20081016143840.GA29805@yoda.jdub.homelinux.org>
References: <20081015213337.a99a9595.akpm@linux-foundation.org>
	<1224133010.8157.543.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <1224133010.8157.543.camel@pasglop>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 16, 2008 at 03:56:50PM +1100, Benjamin Herrenschmidt wrote:
>> drivers/net/ibm_newemac/mal.c: In function 'mal_txeob':
>> drivers/net/ibm_newemac/mal.c:284: error: implicit declaration of function 'mtdcri'
>> drivers/net/ibm_newemac/mal.c:284: error: 'SDR0' undeclared (first use in this function)
>> drivers/net/ibm_newemac/mal.c:284: error: (Each undeclared identifier is reported only once
>> drivers/net/ibm_newemac/mal.c:284: error: for each function it appears in.)
>> drivers/net/ibm_newemac/mal.c:285: error: implicit declaration of function 'mfdcri'
>> drivers/net/ibm_newemac/mal.c: In function 'mal_rxeob':
>> drivers/net/ibm_newemac/mal.c:302: error: 'SDR0' undeclared (first use in this function)
>
>That's annoying, I'll have a look.

Support for new features needed by the PPC 405EZ boards
introduced some errors in the MAL and EMAC feature handling.
This broke 'allmodconfig' builds as CONFIG_PPC_DCR_NATIVE is
not set for those.

This patch fixes these errors by wrapping the code in the
appropriate #ifdefs.

Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

---

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index efcf21c..2ee2622 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2604,8 +2604,16 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 		if (of_device_is_compatible(np, "ibm,emac-440ep") ||
 		    of_device_is_compatible(np, "ibm,emac-440gr"))
 			dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
-		if (of_device_is_compatible(np, "ibm,emac-405ez"))
+		if (of_device_is_compatible(np, "ibm,emac-405ez")) {
+#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CONTROL
 			dev->features |= EMAC_FTR_NO_FLOW_CONTROL_40x;
+#else
+			printk(KERN_ERR "%s: Flow control not disabled!\n",
+					np->full_name);
+			return -ENXIO;
+#endif
+		}
+
 	}
 
 	/* Fixup some feature bits based on the device tree */
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 1839d3f..ecf9798 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -280,9 +280,11 @@ static irqreturn_t mal_txeob(int irq, void *dev_instance)
 	mal_schedule_poll(mal);
 	set_mal_dcrn(mal, MAL_TXEOBISR, r);
 
+#ifdef CONFIG_PPC_DCR_NATIVE
 	if (mal_has_feature(mal, MAL_FTR_CLEAR_ICINTSTAT))
 		mtdcri(SDR0, DCRN_SDR_ICINTSTAT,
 				(mfdcri(SDR0, DCRN_SDR_ICINTSTAT) | ICINTSTAT_ICTX));
+#endif
 
 	return IRQ_HANDLED;
 }
@@ -298,9 +300,11 @@ static irqreturn_t mal_rxeob(int irq, void *dev_instance)
 	mal_schedule_poll(mal);
 	set_mal_dcrn(mal, MAL_RXEOBISR, r);
 
+#ifdef CONFIG_PPC_DCR_NATIVE
 	if (mal_has_feature(mal, MAL_FTR_CLEAR_ICINTSTAT))
 		mtdcri(SDR0, DCRN_SDR_ICINTSTAT,
 				(mfdcri(SDR0, DCRN_SDR_ICINTSTAT) | ICINTSTAT_ICRX));
+#endif
 
 	return IRQ_HANDLED;
 }
@@ -572,9 +576,18 @@ static int __devinit mal_probe(struct of_device *ofdev,
 		goto fail;
 	}
 
-	if (of_device_is_compatible(ofdev->node, "ibm,mcmal-405ez"))
+	if (of_device_is_compatible(ofdev->node, "ibm,mcmal-405ez")) {
+#if defined(CONFIG_IBM_NEW_EMAC_MAL_CLR_ICINTSTAT) && \
+		defined(CONFIG_IBM_NEW_EMAC_MAL_COMMON_ERR)
 		mal->features |= (MAL_FTR_CLEAR_ICINTSTAT |
 				MAL_FTR_COMMON_ERR_INT);
+#else
+		printk(KERN_ERR "%s: Support for 405EZ not enabled!\n",
+				ofdev->node->full_name);
+		err = -ENODEV;
+		goto fail;
+#endif
+	}
 
 	mal->txeob_irq = irq_of_parse_and_map(ofdev->node, 0);
 	mal->rxeob_irq = irq_of_parse_and_map(ofdev->node, 1);
