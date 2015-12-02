From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 1/1] atm: solos-pci: Replace simple_strtol by kstrtoint
Date: Wed,  2 Dec 2015 13:54:49 +0100
Message-ID: <1449060889-20447-2-git-send-email-clabbe.montjoie@gmail.com>
References: <1449060889-20447-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449060889-20447-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The simple_strtol function is obsolete.
This patch replace it by kstrtoint.
This will simplify code, since some error case not handled by
simple_strtol are handled by kstrtoint.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/atm/solos-pci.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 3d7fb65..f944d75 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -347,8 +347,8 @@ static char *next_string(struct sk_buff *skb)
  */       
 static int process_status(struct solos_card *card, int port, struct sk_buff *skb)
 {
-	char *str, *end, *state_str, *snr, *attn;
-	int ver, rate_up, rate_down;
+	char *str, *state_str, *snr, *attn;
+	int ver, rate_up, rate_down, err;
 
 	if (!card->atmdev[port])
 		return -ENODEV;
@@ -357,11 +357,11 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 	if (!str)
 		return -EIO;
 
-	ver = simple_strtol(str, NULL, 10);
-	if (ver < 1) {
+	err = kstrtoint(str, 10, &ver);
+	if (ver < 1 || err) {
 		dev_warn(&card->dev->dev, "Unexpected status interrupt version %d\n",
 			 ver);
-		return -EIO;
+		return err;
 	}
 
 	str = next_string(skb);
@@ -373,16 +373,16 @@ static int process_status(struct solos_card *card, int port, struct sk_buff *skb
 		return 0;
 	}
 
-	rate_down = simple_strtol(str, &end, 10);
-	if (*end)
-		return -EIO;
+	err = kstrtoint(str, 10, &rate_down);
+	if (err)
+		return err;
 
 	str = next_string(skb);
 	if (!str)
 		return -EIO;
-	rate_up = simple_strtol(str, &end, 10);
-	if (*end)
-		return -EIO;
+	err = kstrtoint(str, 10, &rate_up);
+	if (err)
+		return err;
 
 	state_str = next_string(skb);
 	if (!state_str)
@@ -417,7 +417,7 @@ static int process_command(struct solos_card *card, int port, struct sk_buff *sk
 	struct solos_param *prm;
 	unsigned long flags;
 	int cmdpid;
-	int found = 0;
+	int found = 0, err;
 
 	if (skb->len < 7)
 		return 0;
@@ -428,7 +428,9 @@ static int process_command(struct solos_card *card, int port, struct sk_buff *sk
 	    skb->data[6] != '\n')
 		return 0;
 
-	cmdpid = simple_strtol(&skb->data[1], NULL, 10);
+	err = kstrtoint(&skb->data[1], 10, &cmdpid);
+	if (err)
+		return err;
 
 	spin_lock_irqsave(&card->param_queue_lock, flags);
 	list_for_each_entry(prm, &card->param_queue, list) {
-- 
2.4.10
