From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/1] ATM: solos-pci, remove use after free
Date: Mon, 11 Oct 2010 09:50:44 +0200
Message-ID: <1286783444-7719-1-git-send-email-jslaby@suse.cz>
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com,
	Chas Williams <chas@cmf.nrl.navy.mil>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanse found we do in console_show:
  kfree_skb(skb);
  return skb->len;
which is not good. Fix that by remembering the len and use it in the
function instead.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
---
 drivers/atm/solos-pci.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index f916ddf..f46138a 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -444,6 +444,7 @@ static ssize_t console_show(struct device *dev, struct device_attribute *attr,
 	struct atm_dev *atmdev = container_of(dev, struct atm_dev, class_dev);
 	struct solos_card *card = atmdev->dev_data;
 	struct sk_buff *skb;
+	unsigned int len;
 
 	spin_lock(&card->cli_queue_lock);
 	skb = skb_dequeue(&card->cli_queue[SOLOS_CHAN(atmdev)]);
@@ -451,11 +452,12 @@ static ssize_t console_show(struct device *dev, struct device_attribute *attr,
 	if(skb == NULL)
 		return sprintf(buf, "No data.\n");
 
-	memcpy(buf, skb->data, skb->len);
-	dev_dbg(&card->dev->dev, "len: %d\n", skb->len);
+	len = skb->len;
+	memcpy(buf, skb->data, len);
+	dev_dbg(&card->dev->dev, "len: %d\n", len);
 
 	kfree_skb(skb);
-	return skb->len;
+	return len;
 }
 
 static int send_command(struct solos_card *card, int dev, const char *buf, size_t size)
-- 
1.7.3.1
