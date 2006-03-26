From: "Darren Jenkins\\" <darrenrjenkins@gmail.com>
Subject: [KJ][Patch] fix array overflows in de4x5.c
Date: Sun, 26 Mar 2006 17:45:49 +1100
Message-ID: <1143355550.8088.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6788772498607738=="
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: kernel Janitors <kernel-janitors@lists.osdl.org>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============6788772498607738==
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

G'day list

Coverity found 3 'OVERRUN_STATIC' in de4x5.c, @ lines 4814, 5115 and
5125.

Looking at the code these look like very minor problems, but as they are
easy to fix I though I would do a patch.

The patch below just adds an explicit check for the array index in
type3_infoblock() and corrects a loop exit check, to eliminate an 
(array+1) error in mii_get_phy().

Note: A better solution in type3_infoblock() may be to change 
- #define MOTO_SROM_BUG    ((lp->active == 8) && (((le32_to_cpu(get_unaligned(((s32 *)dev->dev_addr))))&0x00ffffff)==0x3e0008))
+ #define MOTO_SROM_BUG    ((lp->active >= DE4X5_MAX_PHY) || (((le32_to_cpu(get_unaligned(((s32 *)dev->dev_addr))))&0x00ffffff)==0x3e0008

as this seems to make sense, but as i am not sure that this bug happens
when (lp->active < 8) I am reluctant to change this.



Signed-off-by: Darren Jenkins <darrenrjenkins@gmail.com>

--- linux-2.6.16-git8/drivers/net/tulip/de4x5.c.orig	2006-03-26 14:36:17.000000000 +1100
+++ linux-2.6.16-git8/drivers/net/tulip/de4x5.c	2006-03-26 17:06:06.000000000 +1100
@@ -4810,7 +4810,8 @@ type3_infoblock(struct net_device *dev, 
     if (lp->state == INITIALISED) {
         lp->ibn = 3;
         lp->active = *p++;
-	if (MOTO_SROM_BUG) lp->active = 0;
+	if (MOTO_SROM_BUG || lp->active >= DE4X5_MAX_PHY)
+		lp->active = 0;
 	lp->phy[lp->active].gep = (*p ? p : NULL); p += (2 * (*p) + 1);
 	lp->phy[lp->active].rst = (*p ? p : NULL); p += (2 * (*p) + 1);
 	lp->phy[lp->active].mc  = TWIDDLE(p); p += 2;
@@ -5111,7 +5112,7 @@ mii_get_phy(struct net_device *dev)
 	    break;
 	}
 	if ((j == limit) && (i < DE4X5_MAX_MII)) {
-	    for (k=0; lp->phy[k].id && (k < DE4X5_MAX_PHY); k++);
+	    for (k=0; lp->phy[k].id && (k < DE4X5_MAX_PHY - 1); k++);
 	    lp->phy[k].addr = i;
 	    lp->phy[k].id = id;
 	    lp->phy[k].spd.reg = GENERIC_REG;      /* ANLPA register         */



--===============6788772498607738==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============6788772498607738==--
