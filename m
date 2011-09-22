From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC PATCH V2] ethtool:  Add command to configure IOV features
Date: Thu, 22 Sep 2011 14:35:43 -0700
Message-ID: <20110922213543.26713.23525.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50787 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939Ab1IVVfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 17:35:46 -0400
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id p8MLZhXq026742
	for <netdev@vger.kernel.org>; Thu, 22 Sep 2011 14:35:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New command to allow configuration of IOV features such as the number of
Virtual Functions to allocate for a given Physical Function interface,
the number of semi-independent net devices to allocate from partitioned
I/O resources in the PF and to set the number of queues per VF.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 ethtool.c |   94 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 93 insertions(+), 1 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 35c3733..1ebf6f3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -99,6 +99,8 @@ static int do_flash(int fd, struct ifreq *ifr);
 static int do_permaddr(int fd, struct ifreq *ifr);
 static int do_getfwdump(int fd, struct ifreq *ifr);
 static int do_setfwdump(int fd, struct ifreq *ifr);
+static int do_get_iov(int fd, struct ifreq *ifr);
+static int do_set_iov(int fd, struct ifreq *ifr);
 
 static int send_ioctl(int fd, struct ifreq *ifr);
 
@@ -133,6 +135,8 @@ static enum {
 	MODE_PERMADDR,
 	MODE_SET_DUMP,
 	MODE_GET_DUMP,
+	MODE_GET_IOV,
+	MODE_SET_IOV,
 } mode = MODE_GSET;
 
 static struct option {
@@ -266,6 +270,8 @@ static struct option {
     { "-W", "--set-dump", MODE_SET_DUMP,
 		"Set dump flag of the device",
 		"		N\n"},
+    { "-v", "--get-iov", MODE_GET_IOV, "Get IOV parameters", "\n" },
+    { "-V", "--set_iov", MODE_SET_IOV, "Set IOV parameters", "[ N ]\n" },
     { "-h", "--help", MODE_HELP, "Show this help" },
     { NULL, "--version", MODE_VERSION, "Show version number" },
     {}
@@ -392,6 +398,10 @@ static char **rxfhindir_weight = NULL;
 static char *flash_file = NULL;
 static int flash = -1;
 static int flash_region = -1;
+static int iov_changed = 0;
+static int iov_numvfs_wanted = -1;
+static int iov_numnetdevs_wanted = -1;
+static int iov_numvqueues_wanted = -1;
 
 static int msglvl_changed;
 static u32 msglvl_wanted = 0;
@@ -549,6 +559,12 @@ static struct cmdline_info cmdline_msglvl[] = {
 	  NETIF_MSG_WOL, &msglvl_mask },
 };
 
+static struct cmdline_info cmdline_iov[] = {
+	{ "vfs", CMDL_S32, &iov_numvfs_wanted, NULL },
+	{ "netdevs", CMDL_S32, &iov_numnetdevs_wanted, NULL },
+	{ "vqueues", CMDL_S32, &iov_numvqueues_wanted, NULL },
+};
+
 static long long
 get_int_range(char *str, int base, long long min, long long max)
 {
@@ -792,7 +808,9 @@ static void parse_cmdline(int argc, char **argp)
 			    (mode == MODE_FLASHDEV) ||
 			    (mode == MODE_PERMADDR) ||
 			    (mode == MODE_SET_DUMP) ||
-			    (mode == MODE_GET_DUMP)) {
+			    (mode == MODE_GET_DUMP) ||
+			    (mode == MODE_GET_IOV) ||
+			    (mode == MODE_SET_IOV)) {
 				devname = argp[i];
 				break;
 			}
@@ -1007,6 +1025,14 @@ static void parse_cmdline(int argc, char **argp)
 				i = argc;
 				break;
 			}
+			if (mode == MODE_SET_IOV) {
+				parse_generic_cmdline(argc, argp, i,
+					&iov_changed,
+					cmdline_iov,
+					ARRAY_SIZE(cmdline_iov));
+				i = argc;
+				break;
+			}
 			if (mode != MODE_SSET)
 				exit_bad_args();
 			if (!strcmp(argp[i], "speed")) {
@@ -1949,6 +1975,10 @@ static int doit(void)
 		return do_getfwdump(fd, &ifr);
 	} else if (mode == MODE_SET_DUMP) {
 		return do_setfwdump(fd, &ifr);
+	} else if (mode == MODE_GET_IOV) {
+		return do_get_iov(fd, &ifr);
+	} else if (mode == MODE_SET_IOV) {
+		return do_set_iov(fd, &ifr);
 	}
 
 	return 69;
@@ -3338,6 +3368,68 @@ static int do_setfwdump(int fd, struct ifreq *ifr)
 	return 0;
 }
 
+static int do_get_iov(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_iov_get_cmd iov_cmd;
+
+	iov_cmd.cmd = ETHTOOL_IOV_GET_CMD;
+	ifr->ifr_data = (caddr_t)&iov_cmd;
+	err = send_ioctl(fd, ifr);
+	if (err < 0) {
+		perror("Can not get current IOV mode\n");
+		return 1;
+	}
+
+	memcpy(&iov_cmd, ifr->ifr_data, sizeof(iov_cmd));
+
+	switch(iov_cmd.mode) {
+	case ETHTOOL_IOV_MODE_SRIOV:
+		printf("Device %s is configured for SR-IOV mode\n", devname);
+		break;
+	case ETHTOOL_IOV_MODE_VM_QUEUES:
+		printf("Device %s is configured for VM Queues mode\n", devname);
+		break;
+	case ETHTOOL_IOV_MODE_NONE:
+	default:
+		printf("Device %s is not configured for IO Virtualization\n",
+				devname);
+		break;
+	}
+
+	return 0;
+}
+
+static int do_set_iov(int fd, struct ifreq *ifr)
+{
+	int err;
+	struct ethtool_iov_set_cmd iov_cmd;
+
+	if (iov_changed) {
+		iov_cmd.cmd = ETHTOOL_IOV_SET_CMD;
+		if (iov_numvfs_wanted >= 0) {
+			iov_cmd.set_cmd = ETHTOOL_IOV_CMD_CONFIGURE_SRIOV;
+			iov_cmd.cmd_param = iov_numvfs_wanted;
+		} else if (iov_numnetdevs_wanted >= 0) {
+			iov_cmd.set_cmd = ETHTOOL_IOV_CMD_CONFIGURE_NETDEVS;
+			iov_cmd.cmd_param = iov_numnetdevs_wanted;
+		} else if (iov_numvqueues_wanted >= 0) {
+			iov_cmd.set_cmd = ETHTOOL_IOV_CMD_CONFIGURE_VF_QUEUES;
+			iov_cmd.cmd_param = iov_numvqueues_wanted;
+		} else {
+			return -EINVAL;
+		}
+		ifr->ifr_data = (caddr_t)&iov_cmd;
+		err = send_ioctl(fd, ifr);
+		if (err < 0) {
+			perror("Can not set new IOV mode\n");
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 static int send_ioctl(int fd, struct ifreq *ifr)
 {
 	return ioctl(fd, SIOCETHTOOL, ifr);
