From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next] bonding: Support for multi function NIC devices
Date: Sun, 15 Jul 2012 21:08:10 -0400
Message-ID: <1342400890-32183-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:13677 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750748Ab2GPBZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jul 2012 21:25:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Add support to disable bonding of interfaces belonging to the same physical port. In
case of SRIOV or NIC partition mode, a single port of the adapter can have multiple
NIC functions. While bonding such interfaces, it is ensured that the NIC functions
belonging to the same physical port are not bonded together.

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 Documentation/networking/ifenslave.c |  208 +++++++++++++++++++++++++++++++++-
 1 files changed, 207 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/ifenslave.c b/Documentation/networking/ifenslave.c
index ac5debb..a0bdab9 100644
--- a/Documentation/networking/ifenslave.c
+++ b/Documentation/networking/ifenslave.c
@@ -92,9 +92,14 @@
  *    - 2003/12/01 - Shmulik Hen <shmulik.hen at intel dot com>
  *	 - Code cleanup and style changes
  *	   set version to 1.1.0
+ *
+ *    - 2012/07/15 - Anirban Chakraborty <anirban.chakraborty at qlogic dot com>
+ *	 - Added support to disable bonding interfaces belonging to the
+ *	   same physical port.
+ *	   set version to 1.1.1
  */
 
-#define APP_VERSION	"1.1.0"
+#define APP_VERSION	"1.1.1"
 #define APP_RELDATE	"December 1, 2003"
 #define APP_NAME	"ifenslave"
 
@@ -111,6 +116,10 @@ static const char *usage_msg =
 "       ifenslave -c   <master-if> <slave-if>\n"
 "       ifenslave --help\n";
 
+static const char *misconfig_msg =
+"Use interfaces from different physical port for an ethernet adapter\n"
+"which has multiple NIC functions belonging to the same physical port\n";
+
 static const char *help_msg =
 "\n"
 "       To create a bond device, simply follow these three steps :\n"
@@ -208,6 +217,18 @@ struct dev_ifr {
 	int req_type;
 };
 
+/* port: physical port
+ * bus: PCI bus no.
+ * ifname: interface name
+ * driver: driver for this device
+ */
+struct dev_prop {
+	u8	port;
+	u16	bus;
+	char	ifname[IFNAMSIZ];
+	char	driver[IFNAMSIZ];
+};
+
 struct dev_ifr master_ifra[] = {
 	{&master_mtu,     "SIOCGIFMTU",     SIOCGIFMTU},
 	{&master_flags,   "SIOCGIFFLAGS",   SIOCGIFFLAGS},
@@ -224,6 +245,10 @@ struct dev_ifr slave_ifra[] = {
 
 static void if_print(char *ifname);
 static int get_drv_info(char *master_ifname);
+static int get_bus_info(struct dev_prop *interface);
+static int get_device_info(int count, struct dev_prop *prop, char *slaves[]);
+static int validate_slaves(char *master, char **spp);
+static int valid_slaves(int count, char *interfaces[]);
 static int get_if_settings(char *ifname, struct dev_ifr ifra[]);
 static int get_slave_flags(char *slave_ifname);
 static int set_master_hwaddr(char *master_ifname, struct sockaddr *hwaddr);
@@ -335,6 +360,15 @@ int main(int argc, char *argv[])
 		goto out;
 	}
 
+	/* validate the slave configuration */
+	if (!opt_d) {
+		res = validate_slaves(master_ifname, spp);
+		if (res) {
+			fprintf(stderr, "%s\n", misconfig_msg);
+			goto out;
+		}
+	}
+
 	slave_ifname = *spp++;
 
 	if (slave_ifname == NULL) {
@@ -643,6 +677,178 @@ out:
 	return 0;
 }
 
+/*
+ * Validate if specified interfaces do not belong to the same physical port
+ */
+static int validate_slaves(char *master, char **spp)
+{
+	int i, count = 0, res = 0;
+	struct ifreq ifr;
+	ifbond bond;
+	ifslave slv;
+	char *bslave;
+	char **slaves, **islaves, **tslaves;
+
+	/* Find a count for existing slave interfaces */
+	memset(&ifr, 0, sizeof(ifr));
+	ifr.ifr_data = (ifbond *)&bond;
+	strncpy(ifr.ifr_name, master, IFNAMSIZ);
+	if (ioctl(skfd, SIOCBONDINFOQUERY, &ifr) < 0) {
+		if (errno == EOPNOTSUPP) {
+			saved_errno = errno;
+			return 1;
+		}
+	}
+	islaves = spp;
+	while (*islaves++ != NULL)
+		count++;
+	if (!count)
+		return 0;
+	count += bond.num_slaves;
+	slaves = malloc(sizeof(char) * count * IFNAMSIZ);
+	if (slaves == NULL)
+		return 1;
+	memset(slaves, 0, (sizeof(char) * count * IFNAMSIZ));
+	tslaves = slaves;
+	/* find new interface names */
+	islaves = spp;
+
+	while (*islaves != NULL)
+		memcpy(slaves++, islaves++, IFNAMSIZ);
+	/* find existing slave interface names */
+	for (i = 0; i < bond.num_slaves; i++) {
+		memset(&slv, 0, sizeof(slv));
+		ifr.ifr_data = (ifslave *)&slv;
+		slv.slave_id = i;
+		if (ioctl(skfd, SIOCBONDSLAVEINFOQUERY, &ifr) < 0) {
+			if (errno == EOPNOTSUPP) {
+				saved_errno = errno;
+				res = 1;
+				goto out;
+			}
+		}
+		bslave = slv.slave_name;
+		memcpy(slaves++, &bslave, IFNAMSIZ);
+	}
+	res = valid_slaves(count, tslaves);
+out:
+	if (tslaves)
+		free(tslaves);
+	return res;
+}
+
+static int get_bus_info(struct dev_prop *interface)
+{
+	struct ifreq ifr;
+	struct ethtool_drvinfo info;
+	char *buf[4], *token, *tmp, *end;
+	int i = 0;
+
+	memset(&ifr, 0, sizeof(ifr));
+	strncpy(ifr.ifr_name, interface->ifname, IFNAMSIZ);
+	ifr.ifr_data = (caddr_t)&info;
+
+	info.cmd = ETHTOOL_GDRVINFO;
+	if (ioctl(skfd, SIOCETHTOOL, &ifr) < 0) {
+		if (errno == EOPNOTSUPP)
+			goto out;
+		saved_errno = errno;
+		v_print("Slave '%s': Error: get bonding info failed %s\n",
+			interface->ifname, strerror(saved_errno));
+		return 1;
+	}
+	memcpy(interface->driver, info.driver, strlen(info.driver) + 1);
+	token = strtok_r(info.bus_info, " :", &tmp);
+	buf[i] =  token;
+	while (token) {
+		token = strtok_r(NULL, " :.", &tmp);
+		buf[++i] = token;
+	}
+	interface->bus = strtoul(buf[1], &end, 16);
+	return 0;
+out:
+	return 1;
+}
+
+static int get_device_info(int count, struct dev_prop *prop, char *slaves[])
+{
+	int ret = -1, i;
+	struct ifreq ifr;
+	struct ethtool_cmd info;
+
+	for (i = 0; i < count; i++) {
+		strncpy(prop[i].ifname, slaves[i], IFNAMSIZ);
+		memset(&ifr, 0, sizeof(ifr));
+		strncpy(ifr.ifr_name, prop[i].ifname, IFNAMSIZ);
+		ifr.ifr_data = (caddr_t)&info;
+
+		info.cmd = ETHTOOL_GSET;
+
+		if (ioctl(skfd, SIOCETHTOOL, &ifr) < 0) {
+			if (errno == EOPNOTSUPP)
+				goto out;
+			saved_errno = errno;
+			v_print("Slave '%s': Error: get bonding info failed"
+				" %s\n", prop[i].ifname,
+				strerror(saved_errno));
+			ret = 1;
+			goto out;
+		}
+		prop[i].port = info.phy_address;
+		ret = get_bus_info(&prop[i]);
+		if (ret)
+			goto out;
+	}
+out:
+	return ret;
+}
+
+/* For a given set of interfaces, find out if they belong to the
+ * same physical port. Return true if two interfaces are found to
+ * be from same physical port, otherwise return false.
+ */
+
+static int valid_slaves(int count, char *slaves[])
+{
+	int i, j, ret = 0;
+	struct dev_prop *ifprop, *searchif;
+	struct dev_prop *prop;
+
+	prop = malloc(count * sizeof(struct dev_prop));
+	if (prop == NULL)
+		return 1;
+
+	memset(prop, 0, sizeof(struct dev_prop) * count);
+	ret = get_device_info(count, prop, slaves);
+	/* Iterate over the array of interfaces and find a match */
+	for (j = 0; j < count; j++) {
+		ifprop = &prop[j];
+		for (i = j + 1; i < count; i++) {
+			searchif = &prop[i];
+			/* Compare driver names */
+			if (!strncmp(ifprop->driver, searchif->driver, IFNAMSIZ)
+				&& !strncmp(ifprop->ifname, searchif->ifname,
+				IFNAMSIZ))
+				continue;
+			/* Compare physical port and bus of the interfaces */
+			if ((searchif->bus == ifprop->bus) &&
+				(searchif->port == ifprop->port)) {
+				ret = 1;
+				fprintf(stderr,
+					"slave interfaces %s and %s "
+					"belong to the same physical "
+					"port of the adapter\n",
+					searchif->ifname, ifprop->ifname);
+				goto out;
+			}
+		}
+	}
+out:
+	free(prop);
+	prop = NULL;
+	return ret;
+}
+
 static int change_active(char *master_ifname, char *slave_ifname)
 {
 	struct ifreq ifr;
-- 
1.7.1
