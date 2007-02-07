From: Levitsky Maxim <maximlevitsky@yahoo.com>
Subject: [PATCH] [003] dmfe : fix link detection
Date: Wed, 7 Feb 2007 10:32:42 -0800 (PST)
Message-ID: <721494.85498.qm@web38509.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tori@unhappy.mine.nu, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web38509.mail.mud.yahoo.com ([209.191.125.55]:25740 "HELO
	web38509.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1161044AbXBGScn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 13:32:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Maxim Levitsky <maximlevitsky@yahoo.com>
Subject: [PATCH] [NET] [003] dmfe : fix link detection

Cleanup link detection
=46ix link not detected when using external PHY

Signed-off-by: Maxim Levitsky <maximlevitsky@yahoo.com>

---

CR12's bits 0 and 1 show link status/speed only for internal PHY.
In case external one is used, only bit 6 shows link status via special =
line , and can be left
unnconected
Thus we need to check bit 6 and also query PHY for link status
Note: internal phy is standard phy , so will indicate link status too.

--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c=A0=A0=A02007-02-07 18:40:=
33.000000000 +0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c=A0=A02007-02-07 18:44:01=
=2E000000000 +0200
@@ -147,7 +147,7 @@
=A0=A0=A0=A0=A0=A0=A0=A0printk(KERN_ERR DRV_NAME ": %s %lx\n", (msg), (=
long) (value))
=A0
=A0#define SHOW_MEDIA_TYPE(mode) \
-=A0=A0=A0=A0=A0=A0=A0printk(KERN_ERR DRV_NAME ": \
+=A0=A0=A0=A0=A0=A0=A0printk(KERN_INFO DRV_NAME ": \
=A0=A0=A0=A0=A0=A0=A0=A0Change Speed to %sMhz %s duplex\n",mode & 1 ?"1=
00":"10", \
=A0=A0=A0=A0=A0=A0=A0=A0mode & 4 ? "full":"half");
=A0
@@ -242,7 +242,6 @@ struct dmfe_board_info {
=A0=A0=A0=A0=A0=A0=A0=A0u8 media_mode;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0/* user specify media mode */
=A0=A0=A0=A0=A0=A0=A0=A0u8 op_mode;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0/* real work media mode */
=A0=A0=A0=A0=A0=A0=A0=A0u8 phy_addr;
-=A0=A0=A0=A0=A0=A0=A0u8 link_failed;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0/* Ever link failed */
=A0=A0=A0=A0=A0=A0=A0=A0u8 wait_reset;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0/* Hardware failed, need to reset */
=A0=A0=A0=A0=A0=A0=A0=A0u8 dm910x_chk_mode;=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0/* Operating mode check */
=A0=A0=A0=A0=A0=A0=A0=A0u8 first_in_callback;=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0/* Flag to record state */
@@ -536,7 +535,6 @@ static int dmfe_open(struct DEVICE *dev)
=A0=A0=A0=A0=A0=A0=A0=A0db->tx_packet_cnt =3D 0;
=A0=A0=A0=A0=A0=A0=A0=A0db->tx_queue_cnt =3D 0;
=A0=A0=A0=A0=A0=A0=A0=A0db->rx_avail_cnt =3D 0;
-=A0=A0=A0=A0=A0=A0=A0db->link_failed =3D 1;
=A0=A0=A0=A0=A0=A0=A0=A0db->wait_reset =3D 0;
=A0
=A0=A0=A0=A0=A0=A0=A0=A0db->first_in_callback =3D 0;
@@ -1091,6 +1089,8 @@ static void dmfe_timer(unsigned long dat
=A0=A0=A0=A0=A0=A0=A0=A0struct dmfe_board_info *db =3D netdev_priv(dev)=
;
=A0 =A0=A0=A0=A0=A0=A0unsigned long flags;
=A0
+=A0=A0=A0=A0=A0=A0=A0int link_ok, link_ok_phy;
+
=A0=A0=A0=A0=A0=A0=A0=A0DMFE_DBUG(0, "dmfe_timer()", 0);
=A0=A0=A0=A0=A0=A0=A0=A0spin_lock_irqsave(&db->lock, flags);
=A0
@@ -1155,22 +1155,45 @@ static void dmfe_timer(unsigned long dat
=A0=A0=A0=A0=A0=A0=A0=A0else
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0tmp_cr12 =3D inb(db->io=
addr + DCR12);=A0=A0=A0=A0=A0/* DM9102/DM9102A */
=A0
+=A0=A0=A0=A0=A0=A0=A0
=A0=A0=A0=A0=A0=A0=A0=A0if ( ((db->chip_id =3D=3D PCI_DM9102_ID) &&
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0(db->chip_revision =3D=3D=
 0x02000030)) ||
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0((db->chip_id =3D=3D PC=
I_DM9132_ID) &&
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0(db->chip_revision =3D=3D=
 0x02000010)) ) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/* DM9102A Chip */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if (tmp_cr12 & 2)
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0t=
mp_cr12 =3D 0x0;=A0=A0=A0=A0=A0=A0=A0=A0=A0/* Link failed */
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0l=
ink_ok =3D 0;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0else
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0t=
mp_cr12 =3D 0x3;=A0/* Link OK */
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0l=
ink_ok =3D 1;
+=A0=A0=A0=A0=A0=A0=A0}
+=A0=A0=A0=A0=A0=A0=A0else
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/*0x43 is used instead of=
 0x3 because bit 6 should be=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0c=
onnected to external PHY and specify its link status.*/
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0link_ok =3D (tmp_cr12 & 0=
x43) ? 1 : 0;
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0/* If chip reports that link is failed it could b=
e because external=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0PHY is not conected corre=
ctly to chip (through pin 89).
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0To be sure ask PHY too.
+=A0=A0=A0=A0=A0=A0=A0*/
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0/* need a dummy read because of PHY's register la=
tch*/
+=A0=A0=A0=A0=A0=A0=A0phy_read (db->ioaddr, db->phy_addr, 1, db->chip_i=
d);=20
+=A0=A0=A0=A0=A0=A0=A0link_ok_phy =3D (phy_read (db->ioaddr,=20
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0 =A0 =A0 db->phy_addr=
, 1, db->chip_id) & 0x4) ? 1 : 0;
+=A0=A0=A0=A0=A0=A0=A0
+
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0if (link_ok_phy !=3D link_ok) {
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0DMFE_DBUG (0, "PHY and ch=
ip report different link status", 0);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0link_ok =3D link_ok | lin=
k_ok_phy;
=A0=A0=A0=A0=A0=A0=A0=A0}
=A0
-=A0=A0=A0=A0=A0=A0=A0if ( !(tmp_cr12 & 0x3) && !db->link_failed ) {
+=A0=A0=A0=A0=A0=A0=A0if ( !link_ok && netif_carrier_ok(dev) ) {
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/* Link Failed */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0DMFE_DBUG(0, "Link Fail=
ed", tmp_cr12);
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0db->link_failed =3D 1;
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0netif_carrier_off(db->dev=
);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0netif_carrier_off(dev);
=A0
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/* For Force 10/100M Ha=
lf/Full mode: Enable Auto-Nego mode */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/* AUTO or force 1M Hom=
erun/Longrun don't need */
@@ -1184,19 +1207,17 @@ static void dmfe_timer(unsigned long dat
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
db->cr6_data&=3D~0x00000200;=A0=A0=A0=A0=A0=A0/* bit9=3D0, HD mode */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
update_cr6(db->cr6_data, db->ioaddr);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0}
-=A0=A0=A0=A0=A0=A0=A0} else
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if ((tmp_cr12 & 0x3) && d=
b->link_failed) {
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0D=
MFE_DBUG(0, "Link link OK", tmp_cr12);
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0d=
b->link_failed =3D 0;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0} else if (!netif_carrier_ok(dev)) {
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0DMFE_DBUG(0, "Link OK", t=
mp_cr12);
=A0
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
/* Auto Sense Speed */
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0i=
f ( (db->media_mode & DMFE_AUTO) &&
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0dmfe_sense_speed(db) )
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0db->link_failed =3D 1;
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0e=
lse
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0netif_carrier_on(db->dev);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if (! (db->media_mode & D=
MFE_AUTO) || !dmfe_sense_speed(db)) {
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0n=
etif_carrier_on(dev);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0S=
HOW_MEDIA_TYPE(db->op_mode);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0}
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
dmfe_process_mode(db);
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/=
* SHOW_MEDIA_TYPE(db->op_mode); */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0}
=A0
=A0=A0=A0=A0=A0=A0=A0=A0/* HPNA remote command check */
@@ -1243,7 +1264,7 @@ static void dmfe_dynamic_reset(struct DE
=A0=A0=A0=A0=A0=A0=A0=A0db->tx_packet_cnt =3D 0;
=A0=A0=A0=A0=A0=A0=A0=A0db->tx_queue_cnt =3D 0;
=A0=A0=A0=A0=A0=A0=A0=A0db->rx_avail_cnt =3D 0;
-=A0=A0=A0=A0=A0=A0=A0db->link_failed =3D 1;
+=A0=A0=A0=A0=A0=A0=A0netif_carrier_off(dev);
=A0=A0=A0=A0=A0=A0=A0=A0db->wait_reset =3D 0;
=A0
=A0=A0=A0=A0=A0=A0=A0=A0/* Re-initilize DM910X board */


=20
_______________________________________________________________________=
_____________
=46ood fight? Enjoy some healthy debate=20
in the Yahoo! Answers Food & Drink Q&A.
http://answers.yahoo.com/dir/?link=3Dlist&sid=3D396545367
