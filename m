From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 08/27] e1000: fix return value not set on
	error
Date: Fri, 10 Dec 2010 01:50:48 -0800
Message-ID: <1291974667-30254-9-git-send-email-jeffrey.t.kirsher__7967.6178786487$1291976742$gmane$org@intel.com>
References: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dean Nelson <dnelson@redhat.com>,
        bphilips@novell.com, Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>, gospo@redhat.com,
        stable@kernel.org
Return-path: <stable-bounces@linux.kernel.org>
To: davem@davemloft.net
In-Reply-To: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemleft.org, dnelson@redhat.com
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org

From: Dean Nelson <dnelson@redhat.com>

Dean noticed that 'err' wasn't being set when the "goto err_dma"
statement is executed in the following hunk from the commit. It's value
will be zero as a result of a successful call to e1000_init_hw_struct().

This patch changes the error condition to be correctly propagated.

CC: stable@kernel.org
Signed-off-by:  Dean Nelson <dnelson@redhat.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000/e1000_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 06c7d1c..491bf2a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -971,11 +971,13 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		 */
 		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
 		pci_using_dac = 1;
-	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
-		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
 	} else {
-		pr_err("No usable DMA config, aborting\n");
-		goto err_dma;
+		err = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (err) {
+			pr_err("No usable DMA config, aborting\n");
+			goto err_dma;
+		}
+		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
 	}
 
 	netdev->netdev_ops = &e1000_netdev_ops;
-- 
1.7.3.2
