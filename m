From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] ipconfig schedule fix
Date: Tue, 23 Nov 2004 23:50:35 +0100
Message-ID: <aec7e5c3041123145030b75d14@mail.gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_740_1840492.1101250235964"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_Part_740_1840492.1101250235964
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

This simple patch makes the DHCP/BOOTP/RARP code sleep with
schedule_timeout() instead of hogging the cpu with cpu_relax() in a
loop. This comes handy when a guest kernel is booted inside QEMU.
Without the patch, the host operating system will consume cpu time
busy waiting.

Thanks,

/ magnus

------=_Part_740_1840492.1101250235964
Content-Type: text/x-patch; name="linux-2.6.10-rc2-mm3-ipconfig_schedule.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="linux-2.6.10-rc2-mm3-ipconfig_schedule.patch"

--- linux-2.6.10-rc2-mm3/net/ipv4/ipconfig.c=092004-10-18 23:53:08.00000000=
0 +0200
+++ linux-2.6.10-rc2-mm3-ipconfig_schedule/net/ipv4/ipconfig.c=092004-11-23=
 23:21:26.154463880 +0100
@@ -1102,8 +1102,8 @@
=20
 =09=09jiff =3D jiffies + (d->next ? CONF_INTER_TIMEOUT : timeout);
 =09=09while (time_before(jiffies, jiff) && !ic_got_reply) {
-=09=09=09barrier();
-=09=09=09cpu_relax();
+=09=09=09set_current_state(TASK_UNINTERRUPTIBLE);
+=09=09=09schedule_timeout (1);
 =09=09}
 #ifdef IPCONFIG_DHCP
 =09=09/* DHCP isn't done until we get a DHCPACK. */
@@ -1245,7 +1245,6 @@
=20
 static int __init ip_auto_config(void)
 {
-=09unsigned long jiff;
 =09u32 addr;
=20
 #ifdef CONFIG_PROC_FS
@@ -1260,18 +1259,16 @@
  try_try_again:
 #endif
 =09/* Give hardware a chance to settle */
-=09jiff =3D jiffies + CONF_PRE_OPEN;
-=09while (time_before(jiffies, jiff))
-=09=09cpu_relax();
+=09set_current_state(TASK_UNINTERRUPTIBLE);
+=09schedule_timeout (CONF_PRE_OPEN);
=20
 =09/* Setup all network devices */
 =09if (ic_open_devs() < 0)
 =09=09return -1;
=20
 =09/* Give drivers a chance to settle */
-=09jiff =3D jiffies + CONF_POST_OPEN;
-=09while (time_before(jiffies, jiff))
-=09=09cpu_relax();
+=09set_current_state(TASK_UNINTERRUPTIBLE);
+=09schedule_timeout (CONF_POST_OPEN);
=20
 =09/*
 =09 * If the config information is insufficient (e.g., our IP address or

------=_Part_740_1840492.1101250235964--
