From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [RESEND][PATCH net-drivers-2.6 3/6] e100: Synchronize interface link
 state with poll routine (fwd)
Date: Wed, 27 Apr 2005 10:40:56 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504271040330.16797-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Synchronize interface link state with e100 poll routine

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
@@ -1743,8 +1743,11 @@ static int e100_up(struct nic *nic)
=A0=A0=A0=A0=A0=A0=A0 if((err =3D request_irq(nic->pdev->irq, e100_intr, =
SA_SHIRQ,
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 nic->netdev->name, nic->netde=
v)))
=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0 goto err_no_irq;
-=A0=A0=A0=A0=A0=A0 e100_enable_irq(nic);
=A0=A0=A0=A0=A0=A0=A0 netif_wake_queue(nic->netdev);
+=A0=A0=A0=A0=A0=A0 netif_poll_enable(nic->netdev);
+=A0=A0=A0=A0=A0=A0 /* enable ints _after_ enabling poll, preventing a ra=
ce between
+=A0=A0=A0=A0=A0=A0=A0 * disable ints+schedule */
+=A0=A0=A0=A0=A0=A0 e100_enable_irq(nic);
=A0=A0=A0=A0=A0=A0=A0 return 0;
=A0
=A0err_no_irq:
@@ -1758,11 +1758,13 @@ err_rx_clean_list:
=A0
=A0static void e100_down(struct nic *nic)
=A0{
+=A0=A0=A0=A0=A0=A0 /* wait here for poll to complete */
+=A0=A0=A0=A0=A0=A0 netif_poll_disable(nic->netdev);
+=A0=A0=A0=A0=A0=A0 netif_stop_queue(nic->netdev);
=A0=A0=A0=A0=A0=A0=A0 e100_hw_reset(nic);
=A0=A0=A0=A0=A0=A0=A0 free_irq(nic->pdev->irq, nic->netdev);
=A0=A0=A0=A0=A0=A0=A0 del_timer_sync(&nic->watchdog);
=A0=A0=A0=A0=A0=A0=A0 netif_carrier_off(nic->netdev);
-=A0=A0=A0=A0=A0=A0 netif_stop_queue(nic->netdev);
=A0=A0=A0=A0=A0=A0=A0 e100_clean_cbs(nic);
=A0=A0=A0=A0=A0=A0=A0 e100_rx_clean_list(nic);
=A0}
