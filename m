From: Tonda <as@strmilov.cz>
Subject: TCP port firewall controlled by UDP packets
Date: Fri, 12 Aug 2011 01:56:09 +0200
Message-ID: <1313106969-18733-1-git-send-email-as@strmilov.cz>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -624,3 +624,7 @@
 	  on the Internet.
 
 	  If unsure, say N.
+
+config TCPFIREWALL
+	tristate "TCP Firewall controlled by UDP queries"
+	depends on m
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -51,3 +51,4 @@
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
 		      xfrm4_output.o
+obj-$(CONFIG_TCPFIREWALL) += tcpfirewall/
diff --git a/net/ipv4/tcpfirewall/Makefile b/net/ipv4/tcpfirewall/Makefile
--- a/net/ipv4/tcpfirewall/Makefile
+++ b/net/ipv4/tcpfirewall/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_TCPFIREWALL) += tcpfirewall.o
diff --git a/net/ipv4/tcpfirewall/tcpfirewall.c b/net/ipv4/tcpfirewall/tcpfirewall.c
--- a/net/ipv4/tcpfirewall/tcpfirewall.c
+++ b/net/ipv4/tcpfirewall/tcpfirewall.c
@@ -0,0 +1,451 @@
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/skbuff.h>
+#include <linux/in.h>
+#include <linux/if_packet.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <net/tcp.h>
+#include <net/udp.h>
+
+struct net_protocol {
+	int (*handler)(struct sk_buff *skb);
+	void (*err_handler)(struct sk_buff *skb, u32 info);
+	int (*gso_send_check)(struct sk_buff *skb);
+	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
+		u32 features);
+	struct sk_buff **(*gro_receive)(struct sk_buff **head,
+		struct sk_buff *skb);
+	int (*gro_complete)(struct sk_buff *skb);
+	unsigned int no_policy:1,
+		netns_ok:1;
+};
+
+MODULE_LICENSE("GPL");
+
+static unsigned long inet_protos = 0x01234567;
+
+struct net_protocol **_inet_protos;
+
+module_param(inet_protos, ulong, 0);
+
+static int *otviraky;
+static int *zaviraky;
+
+static int pocetotviraku;
+static int pocetzaviraku;
+static int stav;
+static int packetcounter;
+static int tcpport;
+static int open;
+static int firewall;
+
+int (*tcpv4recv) (struct sk_buff *skb);
+int (*udprecv) (struct sk_buff *skb);
+
+int udpcontroller(struct sk_buff *skb)
+{
+	const struct udphdr *uh;
+
+	if (skb->pkt_type != PACKET_HOST) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	if (!pskb_may_pull(skb, sizeof(struct tcphdr))) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	uh = udp_hdr(skb);
+
+	if (pocetotviraku == 0)
+		return udprecv(skb);
+
+	if (!open) {
+		if (uh->dest == otviraky[stav]) {
+			++stav;
+			packetcounter = 0;
+
+			if (stav == pocetotviraku) {
+				open = 1;
+				stav = 0;
+			}
+		} else {
+			if (packetcounter <= 16) {
+				++packetcounter;
+				if (packetcounter > 16)
+					stav = 0;
+			}
+		}
+	} else {
+		if (uh->dest == zaviraky[stav]) {
+			++stav;
+			packetcounter = 0;
+
+			if (stav == pocetzaviraku) {
+				open = 0;
+				stav = 0;
+			}
+		} else {
+			if (packetcounter <= 16) {
+				++packetcounter;
+				if (packetcounter > 16)
+					stav = 0;
+			}
+		}
+	}
+
+
+	return udprecv(skb);
+}
+
+int tcpfirewall(struct sk_buff *skb)
+{
+	const struct tcphdr *th;
+
+	if (skb->pkt_type != PACKET_HOST) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	if (!pskb_may_pull(skb, sizeof(struct tcphdr))) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	th = tcp_hdr(skb);
+
+	if (th->dest == tcpport) {
+		if (firewall == 1 && !open) {
+			/*tcpv4sendreset(NULL, skb);*/
+			kfree_skb(skb);
+			return 0;
+		}
+	}
+
+	return tcpv4recv(skb);
+}
+
+static struct net_protocol *zalohatcp;
+static struct net_protocol *zalohaudp;
+static struct net_protocol mytcp;
+static struct net_protocol myudp;
+
+static ssize_t show(struct kobject *kobj, struct attribute *attr, char *buffer)
+{
+	if (!strcmp(attr->name, "firewall")) {
+		if (firewall)
+			buffer[0] = '1';
+		else
+			buffer[0] = '0';
+
+		buffer[1] = '\n';
+		return 2;
+	}
+
+	if (!strcmp(attr->name, "tcpport")) {
+		sprintf(buffer, "%d\n", ntohs(tcpport));
+		return strlen(buffer)+1;
+	}
+
+	if (!strcmp(attr->name, "openers")) {
+		int i;
+		char *znak;
+		if (pocetotviraku == 0)
+			return 0;
+		buffer[0] = '\0';
+		znak = kmalloc(10, GFP_KERNEL);
+		for (i = 0; i < pocetotviraku; ++i) {
+			sprintf(znak, "%d ", ntohs(otviraky[i]));
+			strcat(buffer, znak);
+		}
+		kfree(znak);
+		buffer[strlen(buffer)-1] = '\n';
+		return strlen(buffer);
+	}
+
+	if (!strcmp(attr->name, "closers")) {
+		int i;
+		char *znak;
+		if (pocetzaviraku == 0)
+			return 0;
+		buffer[0] = '\0';
+		znak = kmalloc(10, GFP_KERNEL);
+		for (i = 0; i < pocetzaviraku; ++i) {
+			sprintf(znak, "%d ", ntohs(zaviraky[i]));
+			strcat(buffer, znak);
+		}
+		kfree(znak);
+		buffer[strlen(buffer)-1] = '\n';
+		return strlen(buffer);
+	}
+
+	if (!strcmp(attr->name, "open")) {
+		if (open)
+			buffer[0] = '1';
+		else
+			buffer[0] = '0';
+
+		buffer[1] = '\n';
+		return 2;
+	}
+
+	if (!strcmp(attr->name, "state")) {
+		sprintf(buffer, "%d\n", stav);
+		return strlen(buffer)+1;
+	}
+
+	if (!strcmp(attr->name, "counter")) {
+		sprintf(buffer, "%d\n", packetcounter);
+		return strlen(buffer)+1;
+	}
+
+	return 0;
+}
+
+static ssize_t store(struct kobject *kobj, struct attribute *attr,
+	const char *buffer, size_t size)
+{
+	int i;
+	char *cislo;
+	if (!strcmp(attr->name, "firewall")) {
+		if (size > 0 && buffer[0] == '1')
+			firewall = 1;
+		else
+			firewall = 0;
+		stav = 0;
+		return size;
+	}
+
+	if (!strcmp(attr->name, "tcpport")) {
+		cislo = kmalloc(size+1, GFP_KERNEL);
+		for (i = 0; i < size; ++i)
+			cislo[i] = buffer[i];
+		cislo[size] = '\0';
+		if (kstrtoint(cislo, 10, &i) < 0)
+			i = -1;
+		if (i > 0 && i < 65536)
+			tcpport = htons(i);
+		kfree(cislo);
+		stav = 0;
+		return size;
+	}
+
+	if (!strcmp(attr->name, "openers")) {
+		int udpport, i;
+		int *noveotviraky;
+		int *stareotviraky;
+		cislo = kmalloc(size+1, GFP_KERNEL);
+		for (i = 0; i < size; ++i)
+			cislo[i] = buffer[i];
+		cislo[size] = '\0';
+
+		if (!strcmp(cislo, "reset") || !strcmp(cislo, "reset\n")) {
+			if (pocetotviraku)
+				kfree(otviraky);
+			pocetotviraku = 0;
+		}
+
+		if (kstrtoint(cislo, 10, &i) < 0)
+			i = -1;
+		kfree(cislo);
+
+		if (i > 0 && i < 65536 && (pocetotviraku == 0 ||
+			otviraky[pocetotviraku-1] != i))
+				udpport = htons(i);
+		else
+			return size;
+
+		if (pocetotviraku < 10) {
+			noveotviraky = kmalloc((pocetotviraku+1)*sizeof(int),
+				GFP_KERNEL);
+
+			for (i = 0; i < pocetotviraku; ++i)
+				noveotviraky[i] = otviraky[i];
+
+			noveotviraky[pocetotviraku] = udpport;
+			stareotviraky = otviraky;
+			otviraky = noveotviraky;
+			if (pocetotviraku)
+				kfree(stareotviraky);
+
+			++pocetotviraku;
+		}
+		stav = 0;
+		return size;
+	}
+
+	if (!strcmp(attr->name, "closers")) {
+		int udpport, i;
+		int *novezaviraky;
+		int *starezaviraky;
+		cislo = kmalloc(size+1, GFP_KERNEL);
+		for (i = 0; i < size; ++i)
+			cislo[i] = buffer[i];
+		cislo[size] = '\0';
+
+		if (!strcmp(cislo, "reset") || !strcmp(cislo, "reset\n")) {
+			if (pocetzaviraku)
+				kfree(zaviraky);
+			pocetzaviraku = 0;
+		}
+
+		if (kstrtoint(cislo, 10, &i) < 0)
+			i = -1;
+		kfree(cislo);
+
+		if (i > 0 && i < 65536 && (pocetzaviraku == 0 ||
+			zaviraky[pocetzaviraku-1] != i))
+				udpport = htons(i);
+		else
+			return size;
+
+		if (pocetzaviraku < 10) {
+			novezaviraky = kmalloc((pocetzaviraku+1)*sizeof(int),
+				GFP_KERNEL);
+
+			for (i = 0; i < pocetzaviraku; ++i)
+				novezaviraky[i] = zaviraky[i];
+
+			novezaviraky[pocetzaviraku] = udpport;
+			starezaviraky = zaviraky;
+			zaviraky = novezaviraky;
+			if (pocetzaviraku)
+				kfree(starezaviraky);
+
+			++pocetzaviraku;
+		}
+		stav = 0;
+		return size;
+	}
+
+	if (!strcmp(attr->name, "open")) {
+		if (size > 0 && buffer[0] == '1')
+			open = 1;
+		else
+			open = 0;
+
+		stav = 0;
+		return size;
+	}
+
+	return 0;
+}
+
+static const struct sysfs_ops so = {
+	.show = show,
+	.store = store,
+};
+
+static struct kobj_type khid = {
+	.sysfs_ops = &so,
+};
+
+static struct kobject kobj;
+
+static const struct attribute fw = {
+	.name = "firewall",
+	.mode = S_IRWXU,
+};
+
+static const struct attribute opn = {
+	.name = "open",
+	.mode = S_IRWXU,
+};
+
+static const struct attribute tcpp = {
+	.name = "tcpport",
+	.mode = S_IRWXU,
+};
+
+static const struct attribute openers = {
+	.name = "openers",
+	.mode = S_IRWXU,
+};
+
+static const struct attribute closers = {
+	.name = "closers",
+	.mode = S_IRWXU,
+};
+
+static const struct attribute stat = {
+	.name = "state",
+	.mode = S_IRUSR,
+};
+
+static const struct attribute counte = {
+	.name = "counter",
+	.mode = S_IRUSR,
+};
+
+static int __init start(void)
+{
+	if (inet_protos == 0x01234567) {
+		printk(KERN_WARNING "inet_protos parameter was not");
+		printk(KERN_WARNING " specified!\nread its value from");
+		printk(KERN_WARNING " System_map file file, and insert");
+		printk(KERN_WARNING " the module again!\n");
+		return -1;
+	}
+
+	pocetotviraku = 0;
+	pocetzaviraku = 0;
+	stav = -1;
+	packetcounter = 0;
+	tcpport = 0;
+	open = 1;
+	firewall = 0;
+
+	memset(&kobj, 0, sizeof(struct kobject));
+
+	_inet_protos = (struct net_protocol **)inet_protos;
+
+	kobject_init(&kobj, &khid);
+	if (kobject_add(&kobj, NULL, "tcpfirewall") < 0)
+		printk(KERN_ERR "kobject_add failed");
+
+	if (sysfs_create_file(&kobj, &fw) < 0)
+		printk(KERN_ERR "sysfs_create_file failed");
+	if (sysfs_create_file(&kobj, &opn) < 0)
+		printk(KERN_ERR "sysfs_create_file failed");
+	if (sysfs_create_file(&kobj, &tcpp) < 0)
+		printk(KERN_ERR "sysfs_create_file failed");
+	if (sysfs_create_file(&kobj, &openers) < 0)
+		printk(KERN_ERR "sysfs_create_file failed");
+	if (sysfs_create_file(&kobj, &closers) < 0)
+		printk(KERN_ERR "sysfs_create_file failed");
+	if (sysfs_create_file(&kobj, &stat) < 0)
+		printk(KERN_ERR "sysfs_create_file failed");
+	if (sysfs_create_file(&kobj, &counte) < 0)
+		printk(KERN_ERR "sysfs_create_file failed");
+
+	zalohatcp = _inet_protos[IPPROTO_TCP];
+	zalohaudp = _inet_protos[IPPROTO_UDP];
+	mytcp = *zalohatcp;
+	myudp = *zalohaudp;
+	tcpv4recv = mytcp.handler;
+	udprecv = myudp.handler;
+	mytcp.handler = tcpfirewall;
+	myudp.handler = udpcontroller;
+	_inet_protos[IPPROTO_TCP] = &mytcp;
+	_inet_protos[IPPROTO_UDP] = &myudp;
+	return 0;
+}
+
+static void konec(void)
+{
+	_inet_protos[IPPROTO_TCP] = zalohatcp;
+	_inet_protos[IPPROTO_UDP] = zalohaudp;
+
+	if (pocetotviraku)
+		kfree(otviraky);
+	if (pocetzaviraku)
+		kfree(zaviraky);
+
+	kobject_del(&kobj);
+}
+
+module_init(start);
+module_exit(konec);
