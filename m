From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: [PATCH][RFC] bridge-utils: add basic VEPA support
Date: Mon, 15 Jun 2009 17:33:55 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E67D2DCECBD@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>
To: "bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:23466 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762355AbZFOReF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 13:34:05 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds basic Virtual Ethernet Port Aggregator (VEPA) 
capabilities to the Linux Ethernet bridging utilities.

The patch provides functionality that depends on the Linux kernel
patch 'net/bridge: add basic VEPA support'.

This patch relies on the patch 'bridge-utils: fix sysfs path for 
setting bridge configuration parameters'.

A Virtual Ethernet Port Aggregator (VEPA) is a capability within 
a physical end station that collaborates with an adjacent, external 
bridge to provide distributed bridging support between multiple 
virtual end stations and external networks. The VEPA collaborates 
by forwarding all station-originated frames to the adjacent bridge 
for frame processing and frame relay (including so-called 'hairpin' 
forwarding) and by steering and replicating frames received from 
the VEPA uplink to the appropriate destinations. A VEPA may be 
implemented in software or in conjunction with embedded hardware.

In particular, the patch extends the Linux Ethernet bridge utilities
to configure a bridge to act as
(1) a VEPA, or as
(2) a bridge supporting 'hairpin' forwarding.

You can find additional information on VEPA here:
http://tech.groups.yahoo.com/group/evb/
http://www.ieee802.org/1/files/public/docs2009/new-hudson-vepa_seminar-20090514d.pdf

Signed-off-by: Paul Congdon <paul.congdon@hp.com>
Signed-off-by: Anna Fischer <anna.fischer@hp.com>

---

 brctl/brctl_cmd.c           |  108 ++++++++++++++++++++++++++++++++++++++++---
 brctl/brctl_disp.c          |    6 ++
 libbridge/libbridge.h       |    7 +++
 libbridge/libbridge_devif.c |   90 ++++++++++++++++++++++++++++++++++-
 4 files changed, 201 insertions(+), 10 deletions(-)

diff --git a/brctl/brctl_cmd.c b/brctl/brctl_cmd.c
index c93dd55..77eaf1e 100644
--- a/brctl/brctl_cmd.c
+++ b/brctl/brctl_cmd.c
@@ -280,17 +280,26 @@ static int br_cmd_setportprio(int argc, char *const* argv)
 	return err != 0;
 }
 
+static int br_parse_param(const char *param, int *res)
+{
+	if (!strcmp(param, "on") || !strcmp(param, "yes")
+	    || !strcmp(param, "1"))
+		*res = 1;
+	else if (!strcmp(param, "off") || !strcmp(param, "no")
+		 || !strcmp(param, "0"))
+		*res = 0;
+	else {
+		return EINVAL;
+	}
+	return 0;
+}
+
 static int br_cmd_stp(int argc, char *const* argv)
 {
 	int stp, err;
 
-	if (!strcmp(argv[2], "on") || !strcmp(argv[2], "yes") 
-	    || !strcmp(argv[2], "1"))
-		stp = 1;
-	else if (!strcmp(argv[2], "off") || !strcmp(argv[2], "no") 
-		 || !strcmp(argv[2], "0"))
-		stp = 0;
-	else {
+	err = br_parse_param(argv[2], &stp);
+	if (err) {
 		fprintf(stderr, "expect on/off for argument\n");
 		return 1;
 	}
@@ -316,6 +325,85 @@ static int br_cmd_showstp(int argc, char *const* argv)
 	return 0;
 }
 
+static int br_cmd_vepa(int argc, char *const* argv)
+{
+	int vepa, err;
+
+	err = br_parse_param(argv[2], &vepa);
+	if (err) {
+		fprintf(stderr, "expect on/off for argument\n");
+		return 1;
+	}
+
+	err = br_set_vepa_mode(argv[1], vepa);
+	if (err)
+		fprintf(stderr, "set vepa mode failed: %s\n",
+			strerror(errno));
+	return err != 0;
+}
+
+static int br_cmd_vepauplink(int argc, char *const* argv)
+{
+	const char *brname = *++argv;
+	const char *ifname = *++argv;
+	int err;
+
+	if (if_nametoindex(ifname) == 0) {
+		fprintf(stderr, "interface %s does not exist!\n",
+			ifname);
+		return 1;
+	} else if (if_nametoindex(brname) == 0) {
+		fprintf(stderr, "bridge %s does not exist!\n",
+			brname);
+		return 1;
+	}
+
+	err = br_set_vepa_uplink(brname, ifname);
+
+	if (err) {
+		fprintf(stderr, "cannot set %s as vepa uplink.\n%s has "
+			"to be valid port of bridge %s: %s\n", ifname,
+			ifname, brname, strerror(err));
+	}
+	return err != 0;
+}
+
+static int br_cmd_hairpin(int argc, char *const* argv)
+{
+	int hairpin, err;
+	const char *brname = *++argv;
+	const char *ifname = *++argv;
+	const char *hpmode = *++argv;
+
+	if (!strcmp(hpmode, "on") || !strcmp(hpmode, "yes")
+	    || !strcmp(hpmode, "1"))
+		hairpin = 1;
+	else if (!strcmp(hpmode, "off") || !strcmp(hpmode, "no")
+		 || !strcmp(hpmode, "0"))
+		hairpin = 0;
+	else {
+		fprintf(stderr, "expect on/off for argument\n");
+		return 1;
+	}
+	if (if_nametoindex(ifname) == 0) {
+		fprintf(stderr, "interface %s does not exist!\n",
+			ifname);
+		return 1;
+	} else if (if_nametoindex(brname) == 0) {
+		fprintf(stderr, "bridge %s does not exist!\n",
+			brname);
+		return 1;
+	}
+
+	err = br_set_hairpin_mode(brname, ifname, hairpin);
+
+	if (err) {
+		fprintf(stderr, "can't set %s to hairpin on bridge %s: %s\n",
+			ifname, brname, strerror(err));
+	}
+	return err != 0;
+}
+
 static int show_bridge(const char *name, void *arg)
 {
 	struct bridge_info info;
@@ -402,6 +490,8 @@ static const struct command commands[] = {
 	  "<bridge> <device>\tadd interface to bridge" },
 	{ 2, "delif", br_cmd_delif,
 	  "<bridge> <device>\tdelete interface from bridge" },
+	{ 3, "hairpin", br_cmd_hairpin,
+	  "<bridge> <port> {on|off}\tturn hairpin on/off" },
 	{ 2, "setageing", br_cmd_setageing,
 	  "<bridge> <time>\t\tset ageing time" },
 	{ 2, "setbridgeprio", br_cmd_setbridgeprio,
@@ -423,6 +513,10 @@ static const struct command commands[] = {
 	  "<bridge>\t\tshow bridge stp info"},
 	{ 2, "stp", br_cmd_stp,
 	  "<bridge> {on|off}\tturn stp on/off" },
+	{ 2, "vepa", br_cmd_vepa,
+	  "<bridge> {on|off}\tturn vepa on/off" },
+	{ 2, "vepauplink", br_cmd_vepauplink,
+	  "<bridge> <port>\t\tset uplink for vepa" },
 };
 
 const struct command *command_lookup(const char *cmd)
diff --git a/brctl/brctl_disp.c b/brctl/brctl_disp.c
index 27ce6d2..5bcf38b 100644
--- a/brctl/brctl_disp.c
+++ b/brctl/brctl_disp.c
@@ -93,6 +93,8 @@ static int dump_port_info(const char *br, const char *p,  void *arg)
 		printf("CONFIG_PENDING ");
 	if (pinfo.top_change_ack)
 		printf("TOPOLOGY_CHANGE_ACK ");
+	if (pinfo.hairpin_mode)
+		printf("\n hairpin mode\t\t\%4i", pinfo.hairpin_mode);
 	printf("\n");
 	printf("\n");
 	return 0;
@@ -136,6 +138,10 @@ void br_dump_info(const char *br, const struct bridge_info *bri)
 		printf("TOPOLOGY_CHANGE ");
 	if (bri->topology_change_detected)
 		printf("TOPOLOGY_CHANGE_DETECTED ");
+	if (bri->vepa_mode) {
+		printf("\n vepa mode\t\t%4i", bri->vepa_mode);
+		printf("\t\t\tuplink port\t\t%s", bri->uplink_port);
+	}
 	printf("\n");
 	printf("\n");
 	printf("\n");
diff --git a/libbridge/libbridge.h b/libbridge/libbridge.h
index 016acea..b232f45 100644
--- a/libbridge/libbridge.h
+++ b/libbridge/libbridge.h
@@ -54,6 +54,8 @@ struct bridge_info
 	struct timeval tcn_timer_value;
 	struct timeval topology_change_timer_value;
 	struct timeval gc_timer_value;
+	unsigned char vepa_mode;
+	char uplink_port[IFNAMSIZ];
 };
 
 struct fdb_entry
@@ -80,6 +82,7 @@ struct port_info
 	struct timeval message_age_timer_value;
 	struct timeval forward_delay_timer_value;
 	struct timeval hold_timer_value;
+	unsigned char hairpin_mode;
 };
 
 extern int br_init(void);
@@ -113,4 +116,8 @@ extern int br_set_path_cost(const char *br, const char *p,
 			    int path_cost);
 extern int br_read_fdb(const char *br, struct fdb_entry *fdbs, 
 		       unsigned long skip, int num);
+extern int br_set_vepa_uplink(const char *br, const char *uplink);
+extern int br_set_vepa_mode(const char *br, int vepa_mode);
+extern int br_set_hairpin_mode(const char *bridge, const char *dev,
+			       int hairpin_mode);
 #endif
diff --git a/libbridge/libbridge_devif.c b/libbridge/libbridge_devif.c
index 547bb86..cc4a9cb 100644
--- a/libbridge/libbridge_devif.c
+++ b/libbridge/libbridge_devif.c
@@ -36,6 +36,14 @@ static FILE *fpopen(const char *dir, const char *name)
 	return fopen(path, "r");
 }
 
+static int fpaccess(const char *dir, const char *name)
+{
+	char path[SYSFS_PATH_MAX];
+
+	snprintf(path, SYSFS_PATH_MAX, "%s/%s", dir, name);
+	return access(path, F_OK);
+}
+
 static void fetch_id(const char *dev, const char *name, struct bridge_id *id)
 {
 	FILE *f = fpopen(dev, name);
@@ -58,7 +66,8 @@ static int fetch_int(const char *dev, const char *name)
 	int value = -1;
 
 	if (!f) 
-		fprintf(stderr, "%s: %s\n", dev, strerror(errno));
+		fprintf(stderr, "%s/%s: %s\n", dev, name,
+			strerror(errno));
 	else {
 		fscanf(f, "%i", &value);
 		fclose(f);
@@ -73,6 +82,27 @@ static void fetch_tv(const char *dev, const char *name,
 	__jiffies_to_tv(tv, fetch_int(dev, name));
 }
 
+/* Fetch a string attribute out of sysfs. */
+static void fetch_string(const char *dev, const char *name, char *string)
+{
+	FILE *f = fpopen(dev, name);
+
+	if (!f) {
+		fprintf(stderr, "%s/%s: %s\n", dev, name,
+			strerror(errno));
+		sprintf(string, "-");
+	} else {
+		fscanf(f, "%s", string);
+		fclose(f);
+	}
+}
+
+/* Check if a feature is supported. */
+static int feature_supported(const char *dev, const char *feature)
+{
+	return !fpaccess(dev, feature);
+}
+
 /* Open sysfs path for writing bridge properties. */
 static FILE *br_sysfs_open(const char *bridge, const char *name)
 {
@@ -168,7 +198,8 @@ static int old_get_bridge_info(const char *bridge, struct bridge_info *info)
 	__jiffies_to_tv(&info->topology_change_timer_value, 
 			i.topology_change_timer_value);
 	__jiffies_to_tv(&info->gc_timer_value, i.gc_timer_value);
-
+	info->vepa_mode = 0;
+	sprintf(info->uplink_port, "-");
 	return 0;
 }
 
@@ -209,7 +240,13 @@ int br_get_bridge_info(const char *bridge, struct bridge_info *info)
 	info->stp_enabled = fetch_int(path, "stp_state");
 	info->topology_change = fetch_int(path, "topology_change");
 	info->topology_change_detected = fetch_int(path, "topology_change_detected");
-
+	if (feature_supported(path, "vepa_mode")) {
+		info->vepa_mode = fetch_int(path, "vepa_mode");
+		fetch_string(path, "uplink_port", info->uplink_port);
+	} else {
+		info->vepa_mode = 0;
+		sprintf(info->uplink_port, "-");
+	}
 	closedir(dir);
 	return 0;
 
@@ -259,6 +296,7 @@ static int old_get_port_info(const char *brname, const char *port,
 	__jiffies_to_tv(&info->forward_delay_timer_value, 
 			i.forward_delay_timer_value);
 	__jiffies_to_tv(&info->hold_timer_value, i.hold_timer_value);
+	info->hairpin_mode = 0;
 	return 0;
 }
 
@@ -291,6 +329,10 @@ int br_get_port_info(const char *brname, const char *port,
 	fetch_tv(path, "message_age_timer", &info->message_age_timer_value);
 	fetch_tv(path, "forward_delay_timer", &info->forward_delay_timer_value);
 	fetch_tv(path, "hold_timer", &info->hold_timer_value);
+	if (feature_supported(path, "hairpin_mode"))
+		info->hairpin_mode = fetch_int(path, "hairpin_mode");
+	else
+		info->hairpin_mode = 0;
 	closedir(d);
 
 	return 0;
@@ -322,6 +364,33 @@ static int br_set(const char *bridge, const char *name,
 	return ret < 0 ? errno : 0;
 }
 
+static int br_set_string(const char *bridge, const char *name,
+			 const char *string, int len)
+{
+	FILE *f;
+	char tmp[len];
+
+	f = br_sysfs_open(bridge, name);
+	if (f) {
+		if (fprintf(f, "%s", string) > 0) {
+			rewind(f);
+			len = fscanf(f, "%s", tmp);
+			if (strncmp(tmp, string, len) == 0) {
+				fclose(f);
+				return 0;
+			} else {
+				fclose(f);
+				return EINVAL;
+			}
+		}
+		return errno;
+	} else {
+		/* fallback to old ioctl */
+		/* not supported for new function */
+		return errno;
+	}
+}
+
 int br_set_bridge_forward_delay(const char *br, struct timeval *tv)
 {
 	return br_set(br, "forward_delay", __tv_to_jiffies(tv),
@@ -351,6 +420,16 @@ int br_set_stp_state(const char *br, int stp_state)
 	return br_set(br, "stp_state", stp_state, BRCTL_SET_BRIDGE_STP_STATE);
 }
 
+int br_set_vepa_mode(const char *br, int vepa_mode)
+{
+	return br_set(br, "vepa_mode", vepa_mode, 0);
+}
+
+int br_set_vepa_uplink(const char *br, const char *uplink)
+{
+  return br_set_string(br, "uplink_port", uplink, IFNAMSIZ);
+}
+
 int br_set_bridge_priority(const char *br, int bridge_priority)
 {
 	return br_set(br, "priority", bridge_priority, 
@@ -398,6 +477,11 @@ int br_set_path_cost(const char *bridge, const char *port, int cost)
 	return port_set(bridge, port, "path_cost", cost, BRCTL_SET_PATH_COST);
 }
 
+int br_set_hairpin_mode(const char *bridge, const char *port, int hairpin_mode)
+{
+	return port_set(bridge, port, "hairpin_mode", hairpin_mode, 0);
+}
+
 static inline void __copy_fdb(struct fdb_entry *ent, 
 			      const struct __fdb_entry *f)
 {
