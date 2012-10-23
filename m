From: Paolo Pisati <p.pisati@gmail.com>
Subject: [PATCH 1/6] macaddr kernel bootargs implementation
Date: Tue, 23 Oct 2012 19:15:28 +0200
Message-ID: <1351012533-3524-2-git-send-email-p.pisati@gmail.com>
References: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35211 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756995Ab2JWRQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:16:08 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so3927995wib.1
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:16:06 -0700 (PDT)
In-Reply-To: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paolo Pisati <p.pisati@gmail.com>
---
 Documentation/kernel-parameters.txt |    4 ++
 net/core/dev.c                      |  101 +++++++++++++++++++++++++++++++++++
 2 files changed, 105 insertions(+)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 57dfe00..098beb6 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1382,6 +1382,10 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
 	ltpc=		[NET]
 			Format: <io>,<irq>,<dma>
 
+	macaddr=	[HW,NET]
+			Set NIC MAC address to given value.
+			Example: macaddr=eth0,00:11:22:33:44:55
+
 	machvec=	[IA-64] Force the use of a particular machine-vector
 			(machvec) in a generic kernel.
 			Example: machvec=hpzx1_swiotlb
diff --git a/net/core/dev.c b/net/core/dev.c
index abe1147..5b3e125 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -598,6 +598,107 @@ int __init netdev_boot_setup(char *str)
 
 __setup("netdev=", netdev_boot_setup);
 
+struct macaddr_data {
+	char ifname[IFNAMSIZ + 1];
+	struct sockaddr so;
+	struct list_head list;
+};
+
+static LIST_HEAD(macaddr_list);
+
+static int macaddr_device_event(struct notifier_block *unused,
+			     unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct macaddr_data *ma;
+
+	if (event == NETDEV_REGISTER) {
+		list_for_each_entry(ma, &macaddr_list, list) {
+			if (strcmp(dev->name, ma->ifname) == 0) {
+				dev_set_mac_address(dev, &ma->so);
+				break;
+			}
+		}
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block macaddr_notifier = {
+	.notifier_call = macaddr_device_event,
+};
+
+static int parse_macaddr(const char *macstr, struct sockaddr *so)
+{
+	int i, h, l;
+
+	for (i = 0; i < 6; i++) {
+		h = hex_to_bin(*macstr);
+		if (h == -1)
+			goto err;
+		macstr++;
+
+		l = hex_to_bin(*macstr);
+		if (l == -1)
+			goto err;
+		macstr++;
+
+		if (i != 5) {
+			if (*macstr != ':')
+				goto err;
+			macstr++;
+		}
+		so->sa_data[i] = (h << 4) + l;
+	}
+	if (is_valid_ether_addr(so->sa_data))
+		return 0;
+err:
+	return -EINVAL;
+}
+
+static int __init if_macaddr(void)
+{
+	char cmdline[] = "macaddr=", *str;
+	int err = -EINVAL, i;
+	struct macaddr_data *ma, *tmp;
+
+	str = boot_command_line;
+	while ((str = strstr(str, cmdline)) != NULL) {
+		ma = kmalloc(sizeof(struct macaddr_data), GFP_KERNEL);
+		if (ma == NULL) {
+			err = -ENOMEM;
+			goto out;
+		}
+
+		/*
+		 * Parse input string, expected format: ethX,00:11:22:33:44:55
+		 */
+		str += sizeof(cmdline) - 1;
+		for (i = 0; i <= IFNAMSIZ; i++, str++) {
+			if (*str == ' ' || *str == '\0')
+				goto out;
+			if (*str == ',')
+				break;
+			ma->ifname[i] = *str;
+		}
+		ma->ifname[++i] = '\0';
+		ma->so.sa_family = ARPHRD_ETHER;
+		if (parse_macaddr(++str, &ma->so))
+			goto out;
+
+		list_add_tail(&ma->list, &macaddr_list);
+	}
+
+	if (!list_empty(&macaddr_list))
+		register_netdevice_notifier(&macaddr_notifier);
+	return 0;
+out:
+	kfree(ma);
+	list_for_each_entry_safe(ma, tmp, &macaddr_list, list)
+		kfree(ma);
+	return err;
+}
+late_initcall(if_macaddr);
+
 /*******************************************************************************
 
 			    Device Interface Subroutines
-- 
1.7.9.5
