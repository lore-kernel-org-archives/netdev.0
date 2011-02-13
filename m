From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] ATM, Solos PCI ADSL2+: Don't deref NULL pointer if
 net_ratelimit() and alloc_skb() interact badly.
Date: Sun, 13 Feb 2011 21:49:32 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1102132142460.18930@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	Nathan Williams <nathan@traverse.com.au>,
	David Woodhouse <dwmw2@infradead.org>,
	Treker Chen <treker@xrio.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If alloc_skb() fails to allocate memory and returns NULL then we want to 
return -ENOMEM from drivers/atm/solos-pci.c::popen() regardless of the 
value of net_ratelimit(). The way the code is today, we may not return if 
net_ratelimit() returns 0, then we'll proceed to pass a NULL pointer to 
skb_put() which will blow up in our face.
This patch ensures that we always return -ENOMEM on alloc_skb() failure 
and only let the dev_warn() be controlled by the value of net_ratelimit().

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 solos-pci.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 73fb1c4..25ef1a4 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -866,8 +866,9 @@ static int popen(struct atm_vcc *vcc)
 	}
 
 	skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
-	if (!skb && net_ratelimit()) {
-		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in popen()\n");
+	if (!skb) {
+		if (net_ratelimit())
+			dev_warn(&card->dev->dev, "Failed to allocate sk_buff in popen()\n");
 		return -ENOMEM;
 	}
 	header = (void *)skb_put(skb, sizeof(*header));


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Plain text mails only, please.
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
