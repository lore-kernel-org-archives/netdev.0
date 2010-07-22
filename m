From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next-2.6] netfilter: add xt_cpu match
Date: Thu, 22 Jul 2010 17:18:59 +0200
Message-ID: <1279811939.2467.79.camel@edumazet-laptop>
References: <1279807385.2467.67.camel@edumazet-laptop>
	 <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1007221611510.1619@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 22 juillet 2010 =C3=A0 16:19 +0200, Jan Engelhardt a =C3=A9cri=
t :
> On Thursday 2010-07-22 16:03, Eric Dumazet wrote:
>=20
> >This match is a bit strange, being packet content agnostic...
> >+/*
> >+ * Yes, packet content is not interesting for us, we only take care
> >+ * of cpu handling this packet
> >+ */
>=20
> That is not so strange after all, we have many packet agnostic matche=
s:=20
> xt_time, xt_condition, xt_IDLETIMER, xt_iface.
> So this little comment looks a bit redundant.
>=20
> Or it seems that academia can't come up with enough new protocols in =
time that
> we have to resort to do -m coffeemaker :)
>=20
> >@@ -0,0 +1,8 @@
> >+#ifndef _XT_CPU_H
> >+#define _XT_CPU_H
> >+
> >+struct xt_cpu_info {
> >+	unsigned int	cpu;
> >+	int		invert;
> >+};
> >+#endif /*_XT_MAC_H*/
>=20
> Please take a read in "Writing Netfilter Modules" e-book :-)
> It will tell you that types other than fixed ones are a no-no.

Ok, let's do that, but I doubt sizeof(int) can be different than 4 on a
Linux 2.6 host right now.

I prefer not doing the !!info->invert, and do the check only once.

Thanks

[PATCH nf-next-2.6] netfilter: add xt_cpu match

In some situations a CPU match permits a better spreading of
connections, or select targets only for a given cpu.

With Remote Packet Steering or multiqueue NIC and appropriate IRQ
affinities, we can distribute trafic on available cpus, per session.
(all RX packets for a given flow is handled by a given cpu)

Some legacy applications being not SMP friendly, one way to scale a
server is to run multiple copies of them.

Instead of randomly choosing an instance, we can use the cpu number as =
a
key so that softirq handler for a whole instance is running on a single
cpu, maximizing cache effects in TCP/UDP stacks.

Using NAT for example, a four ways machine might run four copies of
server application, using a separate listening port for each instance,
but still presenting an unique external port :

iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 0 \
        -j REDIRECT --to-port 8080

iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 1 \
        -j REDIRECT --to-port 8081

iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 2 \
        -j REDIRECT --to-port 8082

iptables -t nat -A PREROUTING -p tcp --dport 80 -m cpu --cpu 3 \
        -j REDIRECT --to-port 8083


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netfilter/Kbuild   |    3 -
 include/linux/netfilter/xt_cpu.h |   11 +++++
 net/netfilter/Kconfig            |    9 ++++
 net/netfilter/Makefile           |    1=20
 net/netfilter/xt_cpu.c           |   63 +++++++++++++++++++++++++++++
 5 files changed, 86 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/K=
build
index bb103f4..1041a1d 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -19,12 +19,13 @@ header-y +=3D xt_TCPMSS.h
 header-y +=3D xt_TCPOPTSTRIP.h
 header-y +=3D xt_TEE.h
 header-y +=3D xt_TPROXY.h
+header-y +=3D xt_cluster.h
 header-y +=3D xt_comment.h
 header-y +=3D xt_connbytes.h
 header-y +=3D xt_connlimit.h
 header-y +=3D xt_connmark.h
 header-y +=3D xt_conntrack.h
-header-y +=3D xt_cluster.h
+header-y +=3D xt_cpu.h
 header-y +=3D xt_dccp.h
 header-y +=3D xt_dscp.h
 header-y +=3D xt_esp.h
diff --git a/include/linux/netfilter/xt_cpu.h b/include/linux/netfilter=
/xt_cpu.h
index e69de29..93c7f11 100644
--- a/include/linux/netfilter/xt_cpu.h
+++ b/include/linux/netfilter/xt_cpu.h
@@ -0,0 +1,11 @@
+#ifndef _XT_CPU_H
+#define _XT_CPU_H
+
+#include <linux/types.h>
+
+struct xt_cpu_info {
+	__u32	cpu;
+	__u32	invert;
+};
+
+#endif /*_XT_CPU_H*/
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index aa2f106..523e8d0 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -647,6 +647,15 @@ config NETFILTER_XT_MATCH_CONNTRACK
=20
 	  To compile it as a module, choose M here.  If unsure, say N.
=20
+config NETFILTER_XT_MATCH_CPU
+	tristate '"cpu" match support'
+	depends on NETFILTER_ADVANCED
+	help
+	  CPU matching allows you to match packets based on the CPU
+	  currently handling the packet.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 config NETFILTER_XT_MATCH_DCCP
 	tristate '"dccp" protocol match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index e28420a..6da84c3 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -69,6 +69,7 @@ obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) +=3D xt_comm=
ent.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) +=3D xt_connbytes.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNLIMIT) +=3D xt_connlimit.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNTRACK) +=3D xt_conntrack.o
+obj-$(CONFIG_NETFILTER_XT_MATCH_CPU) +=3D xt_cpu.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_DCCP) +=3D xt_dccp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_DSCP) +=3D xt_dscp.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_ESP) +=3D xt_esp.o
diff --git a/net/netfilter/xt_cpu.c b/net/netfilter/xt_cpu.c
index e69de29..b39db8a 100644
--- a/net/netfilter/xt_cpu.c
+++ b/net/netfilter/xt_cpu.c
@@ -0,0 +1,63 @@
+/* Kernel module to match running CPU */
+
+/*
+ * Might be used to distribute connections on several daemons, if
+ * RPS (Remote Packet Steering) is enabled or NIC is multiqueue capabl=
e,
+ * each RX queue IRQ affined to one CPU (1:1 mapping)
+ *
+ */
+
+/* (C) 2010 Eric Dumazet
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter/xt_cpu.h>
+#include <linux/netfilter/x_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Eric Dumazet <eric.dumazet@gmail.com>");
+MODULE_DESCRIPTION("Xtables: CPU match");
+
+static int cpu_mt_check(const struct xt_mtchk_param *par)
+{
+	const struct xt_cpu_info *info =3D par->matchinfo;
+
+	if (info->invert & ~1)
+		return -EINVAL;
+	return 0;
+}
+
+static bool cpu_mt(const struct sk_buff *skb, struct xt_action_param *=
par)
+{
+	const struct xt_cpu_info *info =3D par->matchinfo;
+
+	return (info->cpu =3D=3D smp_processor_id()) ^ info->invert;
+}
+
+static struct xt_match cpu_mt_reg __read_mostly =3D {
+	.name       =3D "cpu",
+	.revision   =3D 0,
+	.family     =3D NFPROTO_UNSPEC,
+	.checkentry =3D cpu_mt_check,
+	.match      =3D cpu_mt,
+	.matchsize  =3D sizeof(struct xt_cpu_info),
+	.me         =3D THIS_MODULE,
+};
+
+static int __init cpu_mt_init(void)
+{
+	return xt_register_match(&cpu_mt_reg);
+}
+
+static void __exit cpu_mt_exit(void)
+{
+	xt_unregister_match(&cpu_mt_reg);
+}
+
+module_init(cpu_mt_init);
+module_exit(cpu_mt_exit);


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
