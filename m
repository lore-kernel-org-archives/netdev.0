From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] Scalable TCP
Date: Wed, 25 May 2005 15:50:41 -0400
Message-ID: <200505251550.42252.jheffner@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch implements Tom Kelly's Scalable TCP congestion control algorit=
hm=20
for the modular framework.

The algorithm has some nice scaling properties, and has been used a fair =
bit=20
in research, though is known to have significant fairness issues, so it's=
 not=20
really suitable for general purpose use.

Signed-off-by: John Heffner <jheffner@psc.edu>

Index: net/ipv4/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- ba5d2c7b7d035e88291b9692bd7006907e4c46f5/net/ipv4/Kconfig =A0(mode:10=
0644)
+++ 4130df8533b79d0ccfd0195e707f4aa60a527e41/net/ipv4/Kconfig =A0(mode:10=
0644)
@@ -481,6 +481,15 @@
=A0=A0=A0=A0=A0=A0=A0=A0window. TCP Vegas should provide less packet loss=
, but it is
=A0=A0=A0=A0=A0=A0=A0=A0not as aggressive as TCP Reno.
=A0
+config TCP_CONG_SCALABLE
+=A0=A0=A0=A0=A0=A0=A0tristate "Scalable TCP"
+=A0=A0=A0=A0=A0=A0=A0depends on EXPERIMENTAL
+=A0=A0=A0=A0=A0=A0=A0default n
+=A0=A0=A0=A0=A0=A0=A0---help---
+=A0=A0=A0=A0=A0=A0=A0Scalable TCP is a sender-side only change to TCP wh=
ich uses a
+=A0=A0=A0=A0=A0=A0=A0MIMD congestion control algorithm which has some ni=
ce scaling
+=A0=A0=A0=A0=A0=A0=A0properties, though is known to have fairness issues.
+=A0=A0=A0=A0=A0=A0=A0See http://www-lce.eng.cam.ac.uk/~ctk21/scalable/
=A0
=A0endmenu
=A0
Index: net/ipv4/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- ba5d2c7b7d035e88291b9692bd7006907e4c46f5/net/ipv4/Makefile =A0(mode:1=
00644)
+++ 4130df8533b79d0ccfd0195e707f4aa60a527e41/net/ipv4/Makefile =A0(mode:1=
00644)
@@ -35,6 +35,7 @@
=A0obj-$(CONFIG_TCP_CONG_HYBLA) +=3D tcp_hybla.o
=A0obj-$(CONFIG_TCP_CONG_HTCP) +=3D tcp_htcp.o
=A0obj-$(CONFIG_TCP_CONG_VEGAS) +=3D tcp_vegas.o
+obj-$(CONFIG_TCP_CONG_SCALABLE) +=3D tcp_scalable.o
=A0
=A0obj-$(CONFIG_XFRM) +=3D xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0 =A0 =A0xfrm4_output.=
o
Index: net/ipv4/tcp_scalable.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null =A0(tree:ba5d2c7b7d035e88291b9692bd7006907e4c46f5)
+++=20
4130df8533b79d0ccfd0195e707f4aa60a527e41/net/ipv4/tcp_scalable.c =A0(mode=
:100644)
@@ -0,0 +1,71 @@
+/* Tom Kelly's Scalable TCP
+ *
+ * See http://www-lce.eng.cam.ac.uk/~ctk21/scalable/
+ *
+ * John Heffner <jheffner@psc.edu>
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <net/tcp.h>
+
+/* These factors derived from the recommended values in the paper:
+ * .01 and and 7/8. =A0We use 50 instead of 100 to account for
+ * delayed ack. */
+#define TCP_SCALABLE_AI_CNT=A0=A0=A0=A050U
+#define TCP_SCALABLE_MD_SCALE=A0=A03
+
+static void tcp_scalable_cong_avoid(struct tcp_sock *tp, u32 ack, u32 rt=
t,
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32=
 in_flight, int flag)
+{
+=A0=A0=A0=A0=A0=A0=A0if (in_flight < tp->snd_cwnd)
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0return;
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0if (tp->snd_cwnd <=3D tp->snd_ssthresh) {
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0tp->snd_cwnd++;
+=A0=A0=A0=A0=A0=A0=A0} else {
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0tp->snd_cwnd_cnt++;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if (tp->snd_cwnd_cnt > min(=
tp->snd_cwnd, TCP_SCALABLE_AI_CNT))=20
{
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0tp-=
>snd_cwnd++;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0tp-=
>snd_cwnd_cnt =3D 0;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0}
+=A0=A0=A0=A0=A0=A0=A0}
+=A0=A0=A0=A0=A0=A0=A0tp->snd_cwnd =3D min(tp->snd_cwnd, (__u32)tp->snd_c=
wnd_clamp);
+=A0=A0=A0=A0=A0=A0=A0tp->snd_cwnd_stamp =3D tcp_time_stamp;
+}
+
+static u32 tcp_scalable_ssthresh(struct tcp_sock *tp)
+{
+=A0=A0=A0=A0=A0=A0=A0return max(tp->snd_cwnd - (tp->snd_cwnd>>TCP_SCALAB=
LE_MD_SCALE), 2U);
+}
+
+static u32 tcp_scalable_min_cwnd(struct tcp_sock *tp)
+{
+=A0=A0=A0=A0=A0=A0=A0return tp->snd_ssthresh / 2;
+}
+
+static struct tcp_congestion_ops tcp_scalable =3D {
+=A0=A0=A0=A0=A0=A0=A0.ssthresh=A0=A0=A0=A0=A0=A0=A0=3D tcp_scalable_ssth=
resh,
+=A0=A0=A0=A0=A0=A0=A0.cong_avoid=A0=A0=A0=A0=A0=3D tcp_scalable_cong_avo=
id,
+=A0=A0=A0=A0=A0=A0=A0.min_cwnd=A0=A0=A0=A0=A0=A0=A0=3D tcp_scalable_min_=
cwnd,
+=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0.owner=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D THIS_MODULE=
,
+=A0=A0=A0=A0=A0=A0=A0.name=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=3D "scalable=
"
+};
+
+static int __init tcp_scalable_register(void)
+{
+=A0=A0=A0=A0=A0=A0=A0return tcp_register_congestion_control(&tcp_scalabl=
e);
+}
+
+static void __exit tcp_scalable_unregister(void)
+{
+=A0=A0=A0=A0=A0=A0=A0tcp_unregister_congestion_control(&tcp_scalable);
+}
+
+module_init(tcp_scalable_register);
+module_exit(tcp_scalable_unregister);
+
+MODULE_AUTHOR("John Heffner");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Scalable TCP");
