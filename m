From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: [PATCH] bridge-utils: Add 'hairpin' port forwarding mode
Date: Thu, 13 Aug 2009 17:02:24 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E6D6B0C70DC@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"kaber@trash.net" <kaber@trash.net>, Arnd Bergmann <arnd@arndb.de>,
	"Dickson, Mike (ISS Software)" <mike.dickson@hp.com>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"bridge@osdl.org" <bridge@osdl.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:33286 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755034AbZHMRDJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 13:03:09 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a 'hairpin' (also called 'reflective relay') mode
port configuration to the Linux Ethernet bridge utilities.
A bridge supporting hairpin forwarding mode can send frames back
out through the port the frame was received on.

Hairpin mode is required to support basic VEPA (Virtual
Ethernet Port Aggregator) capabilities.

You can find additional information on VEPA here:
http://tech.groups.yahoo.com/group/evb/
http://www.ieee802.org/1/files/public/docs2009/new-hudson-vepa_seminar-20090514d.pdf
http://www.internet2.edu/presentations/jt2009jul/20090719-congdon.pdf

Hairpin forwarding requires support from the kernel. A further kernel 
patch 'net/bridge: Add 'hairpin' port forwarding mode' is provided
for this.

Signed-off-by: Paul Congdon <paul.congdon@hp.com>
Signed-off-by: Anna Fischer <anna.fischer@hp.com>

---

 brctl/brctl_cmd.c           |   38 ++++++++++++++++++++++++++++++++++++++
 brctl/brctl_disp.c          |    2 ++
 libbridge/libbridge.h       |    3 +++
 libbridge/libbridge_devif.c |   24 ++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/brctl/brctl_cmd.c b/brctl/brctl_cmd.c
index c93dd55..d37e99c 100644
--- a/brctl/brctl_cmd.c
+++ b/brctl/brctl_cmd.c
@@ -395,6 +395,42 @@ static int br_cmd_showmacs(int argc, char *const* argv)
 	return 0;
 }
 
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
 static const struct command commands[] = {
 	{ 1, "addbr", br_cmd_addbr, "<bridge>\t\tadd bridge" },
 	{ 1, "delbr", br_cmd_delbr, "<bridge>\t\tdelete bridge" },
@@ -402,6 +438,8 @@ static const struct command commands[] = {
 	  "<bridge> <device>\tadd interface to bridge" },
 	{ 2, "delif", br_cmd_delif,
 	  "<bridge> <device>\tdelete interface from bridge" },
+	{ 3, "hairpin", br_cmd_hairpin,
+	  "<bridge> <port> {on|off}\tturn hairpin on/off" },
 	{ 2, "setageing", br_cmd_setageing,
 	  "<bridge> <time>\t\tset ageing time" },
 	{ 2, "setbridgeprio", br_cmd_setbridgeprio,
diff --git a/brctl/brctl_disp.c b/brctl/brctl_disp.c
index 27ce6d2..3e81241 100644
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
diff --git a/libbridge/libbridge.h b/libbridge/libbridge.h
index 016acea..39964f2 100644
--- a/libbridge/libbridge.h
+++ b/libbridge/libbridge.h
@@ -80,6 +80,7 @@ struct port_info
 	struct timeval message_age_timer_value;
 	struct timeval forward_delay_timer_value;
 	struct timeval hold_timer_value;
+	unsigned char hairpin_mode;
 };
 
 extern int br_init(void);
@@ -113,4 +114,6 @@ extern int br_set_path_cost(const char *br, const char *p,
 			    int path_cost);
 extern int br_read_fdb(const char *br, struct fdb_entry *fdbs, 
 		       unsigned long skip, int num);
+extern int br_set_hairpin_mode(const char *bridge, const char *dev,
+			       int hairpin_mode);
 #endif
diff --git a/libbridge/libbridge_devif.c b/libbridge/libbridge_devif.c
index 34e3cc8..ca40325 100644
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
@@ -73,6 +81,12 @@ static void fetch_tv(const char *dev, const char *name,
 	__jiffies_to_tv(tv, fetch_int(dev, name));
 }
 
+/* Check if a feature is supported. */
+static int feature_supported(const char *dev, const char *feature)
+{
+	return !fpaccess(dev, feature);
+}
+
 /*
  * Convert device name to an index in the list of ports in bridge.
  *
@@ -239,6 +253,7 @@ static int old_get_port_info(const char *brname, const char *port,
 	__jiffies_to_tv(&info->forward_delay_timer_value, 
 			i.forward_delay_timer_value);
 	__jiffies_to_tv(&info->hold_timer_value, i.hold_timer_value);
+	info->hairpin_mode = 0;
 	return 0;
 }
 
@@ -271,6 +286,10 @@ int br_get_port_info(const char *brname, const char *port,
 	fetch_tv(path, "message_age_timer", &info->message_age_timer_value);
 	fetch_tv(path, "forward_delay_timer", &info->forward_delay_timer_value);
 	fetch_tv(path, "hold_timer", &info->hold_timer_value);
+	if (feature_supported(path, "hairpin_mode"))
+		info->hairpin_mode = fetch_int(path, "hairpin_mode");
+	else
+		info->hairpin_mode = 0;
 	closedir(d);
 
 	return 0;
@@ -381,6 +400,11 @@ int br_set_path_cost(const char *bridge, const char *port, int cost)
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
