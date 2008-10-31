From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 07/13] net: add SIOCSHWTSTAMP - hardware time stamping
	of packets
Date: Fri, 31 Oct 2008 12:43:36 +0100
Message-ID: <1226415430.31699.6.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30128 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756149AbYKKO5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:57:11 -0500
In-Reply-To: <1226414697.17450.852.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In its current form the new ioctl allows time stamping
PTP packets (all currently useful flavors) and all packets.
This should be good enough for the use cases discussed
on Linux netdev so far.

It does not yet allow user space control over the clock
in the NIC. If this should become necessary, then it will
have to be extended.

Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 Documentation/networking/timestamping.txt          |   23 ++++++++++++++++-
 .../networking/timestamping/timestamping.c         |   26 ++++++++++++++++++++
 fs/compat_ioctl.c                                  |    1 +
 include/net/timestamping.h                         |    7 ++++-
 net/core/dev.c                                     |    2 +
 5 files changed, 56 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 6a87a96..537e55b 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -96,6 +96,24 @@ struct hwtstamp_config {
     int rx_filter_type;  /**< HWTSTAMP_RX_* */
 };
 
+Desired behavior is passed into the kernel and to a specific device by
+calling ioctl(SIOCSHWTSTAMP) with a pointer to a struct ifreq whose
+ifr_data points to a struct hwtstamp_config. The tx_type and
+rx_filter_type are hints to the driver what it is expected to do. If
+the requested fine-grained filtering for incoming packets is not
+supported, the driver may time stamp more than just the requested types
+of packets.
+
+A driver which supports hardware time stamping shall update the struct
+with the actual, possibly more permissive configuration. If the
+requested packets cannot be time stamped, then nothing should be
+changed and ERANGE shall be returned (in contrast to EINVAL, which
+indicates that SIOCSHWTSTAMP is not supported at all).
+
+Only a processes with admin rights may change the configuration. User
+space is responsible to ensure that multiple processes don't interfere
+with each other and that the settings are reset.
+
 /** possible values for hwtstamp_config->tx_type */
 enum {
 	/**
@@ -111,7 +129,7 @@ enum {
 	 * time stamped by setting SOF_TIMESTAMPING_TX_SOFTWARE
 	 * before sending the packet
 	 */
-	HWSTAMP_TX_ON,
+	HWTSTAMP_TX_ON,
 };
 
 /** possible values for hwtstamp_config->rx_filter_type */
@@ -122,6 +140,9 @@ enum {
 	/** time stamp any incoming packet */
 	HWTSTAMP_FILTER_ALL,
 
+        /** return value: time stamp all packets requested plus some others */
+        HWTSTAMP_FILTER_SOME,
+
 	/** PTP v1, UDP, any kind of event packet */
 	HWTSTAMP_FILTER_PTP_V1_L4_EVENT,
 
diff --git a/Documentation/networking/timestamping/timestamping.c b/Documentation/networking/timestamping/timestamping.c
index abb2b79..bfb6cd6 100644
--- a/Documentation/networking/timestamping/timestamping.c
+++ b/Documentation/networking/timestamping/timestamping.c
@@ -270,6 +270,8 @@ int main(int argc, char **argv)
 	int enabled = 1;
 	int sock;
 	struct ifreq device;
+	struct ifreq hwtstamp;
+	struct hwtstamp_config hwconfig, hwconfig_requested;
 	struct sockaddr_in addr;
 	struct ip_mreq imr;
 	struct in_addr iaddr;
@@ -323,6 +325,30 @@ int main(int argc, char **argv)
 		bail("getting interface IP address");
 	}
 
+	memset(&hwtstamp, 0, sizeof(hwtstamp));
+	strncpy(hwtstamp.ifr_name, interface, sizeof(hwtstamp.ifr_name));
+	hwtstamp.ifr_data = (void *)&hwconfig;
+	memset(&hwconfig, 0, sizeof(&hwconfig));
+	hwconfig.tx_type =
+		(so_timestamping_flags & SOF_TIMESTAMPING_TX_HARDWARE) ?
+		HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
+	hwconfig.rx_filter_type =
+		(so_timestamping_flags & SOF_TIMESTAMPING_RX_HARDWARE) ?
+		HWTSTAMP_FILTER_PTP_V1_L4_SYNC : HWTSTAMP_FILTER_NONE;
+	hwconfig_requested = hwconfig;
+	if (ioctl(sock, SIOCSHWTSTAMP, &hwtstamp) < 0) {
+		if (errno == EINVAL &&
+			hwconfig_requested.tx_type == HWTSTAMP_TX_OFF &&
+			hwconfig_requested.rx_filter_type == HWTSTAMP_FILTER_NONE) {
+			printf("SIOCSHWTSTAMP: disabling hardware time stamping not possible\n");
+		} else {
+			bail("SIOCSHWTSTAMP");
+		}
+	}
+	printf("SIOCSHWTSTAMP: tx_type %d requested, got %d; rx_filter_type %d requested, got %d\n",
+		hwconfig_requested.tx_type, hwconfig.tx_type,
+		hwconfig_requested.rx_filter_type, hwconfig.rx_filter_type);
+
 	/* bind to PTP port */
 	addr.sin_family = AF_INET;
 	addr.sin_addr.s_addr = htonl(INADDR_ANY);
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 5235c67..a5001a6 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -2555,6 +2555,7 @@ HANDLE_IOCTL(SIOCSIFMAP, dev_ifsioc)
 HANDLE_IOCTL(SIOCGIFADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFADDR, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFHWBROADCAST, dev_ifsioc)
+HANDLE_IOCTL(SIOCSHWTSTAMP, dev_ifsioc)
 
 /* ioctls used by appletalk ddp.c */
 HANDLE_IOCTL(SIOCATALKDIFADDR, dev_ifsioc)
diff --git a/include/net/timestamping.h b/include/net/timestamping.h
index 53cb603..c271caa 100644
--- a/include/net/timestamping.h
+++ b/include/net/timestamping.h
@@ -28,7 +28,7 @@ enum {
 # define SIOCSHWTSTAMP 0x89b0
 #endif
 
-/** %SIOCSHWTSTAMP expects a pointer to this struct */
+/** %SIOCSHWTSTAMP expects a struct ifreq with a ifr_data pointer to this struct  */
 struct hwtstamp_config {
 	int flags;           /**< no flags defined right now, must be zero */
 	int tx_type;         /**< one of HWTSTAMP_TX_* */
@@ -50,7 +50,7 @@ enum {
 	 * time stamped by setting SOF_TIMESTAMPING_TX_SOFTWARE
 	 * before sending the packet
 	 */
-	HWSTAMP_TX_ON,
+	HWTSTAMP_TX_ON,
 };
 
 /** possible values for hwtstamp_config->rx_filter_type */
@@ -61,6 +61,9 @@ enum {
 	/** time stamp any incoming packet */
 	HWTSTAMP_FILTER_ALL,
 
+        /** return value: time stamp all packets requested plus some others */
+        HWTSTAMP_FILTER_SOME,
+
 	/** PTP v1, UDP, any kind of event packet */
 	HWTSTAMP_FILTER_PTP_V1_L4_EVENT,
 	/** PTP v1, UDP, Sync packet */
diff --git a/net/core/dev.c b/net/core/dev.c
index 7cf31fb..69d7c04 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3621,6 +3621,7 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 			    cmd == SIOCSMIIREG ||
 			    cmd == SIOCBRADDIF ||
 			    cmd == SIOCBRDELIF ||
+			    cmd == SIOCSHWTSTAMP ||
 			    cmd == SIOCWANDEV) {
 				err = -EOPNOTSUPP;
 				if (dev->do_ioctl) {
@@ -3776,6 +3777,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		case SIOCBONDCHANGEACTIVE:
 		case SIOCBRADDIF:
 		case SIOCBRDELIF:
+		case SIOCSHWTSTAMP:
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			/* fall through */
-- 
1.6.0.4


