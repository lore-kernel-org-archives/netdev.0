From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] net: tulip: Remove private "strncmp"
Date: Thu,  4 Dec 2014 11:30:40 +0100
Message-ID: <1417689040-14958-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The comment says that the built-in strncmp didn't work. That is not
surprising, as apparently "str" semantics are not really what is
wanted (hint: de4x5_strncmp only stops when two different bytes are
encountered or the end is reached; not if either byte happens to be
0). de4x5_strncmp is actually a memcmp (except for the signature and
that bytes are not necessarily treated as unsigned char); since only
the boolean value of the result is used we can just replace
de4x5_strncmp with memcmp.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---

Notes:
    I don't know if the comment meant to say 3 bytes, or if the code
    compares meaningful chunks of memory (the first three bytes of
    &lp->srom span 1.5 fields, and the three bytes from (char*)&lp->srom +
    0x10 are &lp->srom.{id_block_crc,reserved2,version} - it seems odd
    that these chunks should ever be equal to each other and to the
    enet_det[i]). Whether or not the current code works, this patch
    shouldn't change the semantics, and I'd like to get rid of
    de4x5_strncmp since it is not, in fact, a strncmp.

 drivers/net/ethernet/dec/tulip/de4x5.c | 20 +++-----------------
 1 file changed, 3 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index cf8b6ff..badff18 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -995,7 +995,6 @@ static void    de4x5_dbg_mii(struct net_device *dev, int k);
 static void    de4x5_dbg_media(struct net_device *dev);
 static void    de4x5_dbg_srom(struct de4x5_srom *p);
 static void    de4x5_dbg_rx(struct sk_buff *skb, int len);
-static int     de4x5_strncmp(char *a, char *b, int n);
 static int     dc21041_infoleaf(struct net_device *dev);
 static int     dc21140_infoleaf(struct net_device *dev);
 static int     dc21142_infoleaf(struct net_device *dev);
@@ -4102,8 +4101,7 @@ get_hw_addr(struct net_device *dev)
 }
 
 /*
-** Test for enet addresses in the first 32 bytes. The built-in strncmp
-** didn't seem to work here...?
+** Test for enet addresses in the first 32 bytes.
 */
 static int
 de4x5_bad_srom(struct de4x5_private *lp)
@@ -4111,8 +4109,8 @@ de4x5_bad_srom(struct de4x5_private *lp)
     int i, status = 0;
 
     for (i = 0; i < ARRAY_SIZE(enet_det); i++) {
-	if (!de4x5_strncmp((char *)&lp->srom, (char *)&enet_det[i], 3) &&
-	    !de4x5_strncmp((char *)&lp->srom+0x10, (char *)&enet_det[i], 3)) {
+	if (!memcmp(&lp->srom, &enet_det[i], 3) &&
+	    !memcmp((char *)&lp->srom+0x10, &enet_det[i], 3)) {
 	    if (i == 0) {
 		status = SMC;
 	    } else if (i == 1) {
@@ -4125,18 +4123,6 @@ de4x5_bad_srom(struct de4x5_private *lp)
     return status;
 }
 
-static int
-de4x5_strncmp(char *a, char *b, int n)
-{
-    int ret=0;
-
-    for (;n && !ret; n--) {
-	ret = *a++ - *b++;
-    }
-
-    return ret;
-}
-
 static void
 srom_repair(struct net_device *dev, int card)
 {
-- 
2.0.4
