From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] caif: fix cfcnfg_add_phy_layer() leaks
Date: Tue, 25 Oct 2011 00:01:00 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1110242359160.19795@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two locations where we 'goto out' after having allocated
memory for 'phyinfo' but have not yet assigned it to anything. At the
'out:' label we'll exit from the function and 'phyinfo' will go out of
scope and thus we leak the memory we allocated.

This patch frees the memory before jumping to 'out:', thus fixing the
leaks.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 net/caif/cfcnfg.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

 compile tested only.

diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 52fe33b..b25dc02 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -499,6 +499,7 @@ got_phyid:
 		    cfserl_create(CFPHYTYPE_FRAG, phyid, stx);
 		if (!phy_driver) {
 			pr_warn("Out of memory\n");
+			kfree(phyinfo);
 			goto out;
 		}
 		break;
@@ -506,6 +507,7 @@ got_phyid:
 		phy_driver = NULL;
 		break;
 	default:
+		kfree(phyinfo);
 		goto out;
 	}
 	phy_layer->id = phyid;
-- 
1.7.7


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
