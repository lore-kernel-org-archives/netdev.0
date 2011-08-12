From: Tonda <as@strmilov.cz>
Subject: TCP port firewall incl. description and english variable names
Date: Fri, 12 Aug 2011 17:10:43 +0200
Message-ID: <1313161843-18226-1-git-send-email-as@strmilov.cz>
Cc: Antoine Steinhauser <as@strmilov.cz>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.jhcomp.cz ([178.23.218.35]:33141 "EHLO
	jhcinternet.jhcomp.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189Ab1HLPKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 11:10:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Module that is used to open, close or filter specified TCP port by sending certain sequence of UDP packets to predefined UDP ports (password-like firewall). One sequence of UDP ports is the opening key and sending packets successively to them opens the TCP port and the second sequence of UDP ports is the closing key and sending packets successively to them closes the TCP port. If between two UDP packets in the sequence comes more than 16 another UDP packets, the sequence (either opening or closing) is aborted. The configuration and view of affected TCP port, opening and closing key and other firewall parameters is made throw use of sysfs.

Signed-off-by: Antoine Steinhauser <as@strmilov.cz>

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
+static int *openkeys;
+static int *closekeys;
+
+static int openkeyscount;
+static int closekeyscount;
+static int fastate;
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
+	if (openkeyscount == 0)
+		return udprecv(skb);
+
+	if (!open) {
+		if (uh->dest == openkeys[fastate]) {
+			++fastate;
+			packetcounter = 0;
+
+			if (fastate == openkeyscount) {
+				open = 1;
+				fastate = 0;
+			}
+		} else {
+			if (packetcounter <= 16) {
+				++packetcounter;
+				if (packetcounter > 16)
+					fastate = 0;
+			}
+		}
+	} else {
+		if (uh->dest == closekeys[fastate]) {
+			++fastate;
+			packetcounter = 0;
+
+			if (fastate == closekeyscount) {
+				open = 0;
+				fastate = 0;
+			}
+		} else {
+			if (packetcounter <= 16) {
+				++packetcounter;
+				if (packetcounter > 16)
+					fastate = 0;
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
+static struct net_protocol *backuptcp;
+static struct net_protocol *backupudp;
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
+		if (openkeyscount == 0)
+			return 0;
+		buffer[0] = '\0';
+		znak = kmalloc(10, GFP_KERNEL);
+		for (i = 0; i < openkeyscount; ++i) {
+			sprintf(znak, "%d ", ntohs(openkeys[i]));
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
+		if (closekeyscount == 0)
+			return 0;
+		buffer[0] = '\0';
+		znak = kmalloc(10, GFP_KERNEL);
+		for (i = 0; i < closekeyscount; ++i) {
+			sprintf(znak, "%d ", ntohs(closekeys[i]));
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
+		sprintf(buffer, "%d\n", fastate);
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
+		fastate = 0;
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
+		fastate = 0;
+		return size;
+	}
+
+	if (!strcmp(attr->name, "openers")) {
+		int udpport, i;
+		int *noveopenkeys;
+		int *stareopenkeys;
+		cislo = kmalloc(size+1, GFP_KERNEL);
+		for (i = 0; i < size; ++i)
+			cislo[i] = buffer[i];
+		cislo[size] = '\0';
+
+		if (!strcmp(cislo, "reset") || !strcmp(cislo, "reset\n")) {
+			if (openkeyscount)
+				kfree(openkeys);
+			openkeyscount = 0;
+		}
+
+		if (kstrtoint(cislo, 10, &i) < 0)
+			i = -1;
+		kfree(cislo);
+
+		if (i > 0 && i < 65536 && (openkeyscount == 0 ||
+			openkeys[openkeyscount-1] != i))
+				udpport = htons(i);
+		else
+			return size;
+
+		if (openkeyscount < 10) {
+			noveopenkeys = kmalloc((openkeyscount+1)*sizeof(int),
+				GFP_KERNEL);
+
+			for (i = 0; i < openkeyscount; ++i)
+				noveopenkeys[i] = openkeys[i];
+
+			noveopenkeys[openkeyscount] = udpport;
+			stareopenkeys = openkeys;
+			openkeys = noveopenkeys;
+			if (openkeyscount)
+				kfree(stareopenkeys);
+
+			++openkeyscount;
+		}
+		fastate = 0;
+		return size;
+	}
+
+	if (!strcmp(attr->name, "closers")) {
+		int udpport, i;
+		int *noveclosekeys;
+		int *stareclosekeys;
+		cislo = kmalloc(size+1, GFP_KERNEL);
+		for (i = 0; i < size; ++i)
+			cislo[i] = buffer[i];
+		cislo[size] = '\0';
+
+		if (!strcmp(cislo, "reset") || !strcmp(cislo, "reset\n")) {
+			if (closekeyscount)
+				kfree(closekeys);
+			closekeyscount = 0;
+		}
+
+		if (kstrtoint(cislo, 10, &i) < 0)
+			i = -1;
+		kfree(cislo);
+
+		if (i > 0 && i < 65536 && (closekeyscount == 0 ||
+			closekeys[closekeyscount-1] != i))
+				udpport = htons(i);
+		else
+			return size;
+
+		if (closekeyscount < 10) {
+			noveclosekeys = kmalloc((closekeyscount+1)*sizeof(int),
+				GFP_KERNEL);
+
+			for (i = 0; i < closekeyscount; ++i)
+				noveclosekeys[i] = closekeys[i];
+
+			noveclosekeys[closekeyscount] = udpport;
+			stareclosekeys = closekeys;
+			closekeys = noveclosekeys;
+			if (closekeyscount)
+				kfree(stareclosekeys);
+
+			++closekeyscount;
+		}
+		fastate = 0;
+		return size;
+	}
+
+	if (!strcmp(attr->name, "open")) {
+		if (size > 0 && buffer[0] == '1')
+			open = 1;
+		else
+			open = 0;
+
+		fastate = 0;
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
+	openkeyscount = 0;
+	closekeyscount = 0;
+	fastate = -1;
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
+	backuptcp = _inet_protos[IPPROTO_TCP];
+	backupudp = _inet_protos[IPPROTO_UDP];
+	mytcp = *backuptcp;
+	myudp = *backupudp;
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
+	_inet_protos[IPPROTO_TCP] = backuptcp;
+	_inet_protos[IPPROTO_UDP] = backupudp;
+
+	if (openkeyscount)
+		kfree(openkeys);
+	if (closekeyscount)
+		kfree(closekeys);
+
+	kobject_del(&kobj);
+}
+
+module_init(start);
+module_exit(konec);
