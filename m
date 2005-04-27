From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.6 1/6] e100: Execute tx_timeout task
 outside interrupt context (fwd)
Date: Wed, 27 Apr 2005 10:35:20 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271034140.16686-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Execute tx_timeout task outside the interrupt context

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com=
>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e=
100.c.new
--- net-drivers-2.6/drivers/net/e100.c=A0 2005-04-07 03:22:36.805273784 -=
0700
+++ net-drivers-2.6/drivers/net/e100.c.new=A0=A0=A0=A0=A0 2005-04-07 03:2=
2:37.251205992 -0700
@@ -539,6 +539,7 @@ struct nic {
=A0=A0=A0=A0=A0=A0=A0 struct timer_list watchdog;
=A0=A0=A0=A0=A0=A0=A0 struct timer_list blink_timer;
=A0=A0=A0=A0=A0=A0=A0 struct mii_if_info mii;
+=A0=A0=A0=A0=A0=A0 struct work_struct tx_timeout_task;
=A0=A0=A0=A0=A0=A0=A0 enum loopback loopback;
=A0
=A0=A0=A0=A0=A0=A0=A0 struct mem *mem;
@@ -1716,6 +1717,15 @@ static void e100_tx_timeout(struct net_d
=A0{
=A0=A0=A0=A0=A0=A0=A0 struct nic *nic =3D netdev_priv(netdev);
=A0
+=A0=A0=A0=A0=A0=A0 /* Reset outside of interrupt context, to avoid reque=
st_irq
+=A0=A0=A0=A0=A0=A0=A0 * in interrupt context */
+=A0=A0=A0=A0=A0=A0 schedule_work(&nic->tx_timeout_task);
+}
+
+static void e100_tx_timeout_task(struct net_device *netdev)
+{
+=A0=A0=A0=A0=A0=A0 struct nic *nic =3D netdev_priv(netdev);
+
=A0=A0=A0=A0=A0=A0=A0 DPRINTK(TX_ERR, DEBUG, "scb.status=3D0x%02X\n",
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 readb(&nic->csr->scb.status))=
;
=A0=A0=A0=A0=A0=A0=A0 e100_down(netdev_priv(netdev));
@@ -2240,6 +2250,9 @@ static int __devinit e100_probe(struct p
=A0=A0=A0=A0=A0=A0=A0 nic->blink_timer.function =3D e100_blink_led;
=A0=A0=A0=A0=A0=A0=A0 nic->blink_timer.data =3D (unsigned long)nic;
=A0
+=A0=A0=A0=A0=A0=A0 INIT_WORK(&nic->tx_timeout_task,
+=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 (void (*)(void *))e100_tx_timeo=
ut_task, netdev);
+
=A0=A0=A0=A0=A0=A0=A0 if((err =3D e100_alloc(nic))) {
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 DPRINTK(PROBE, ERR, "Cannot a=
lloc driver memory, aborting.\n");
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 goto err_out_iounmap;
