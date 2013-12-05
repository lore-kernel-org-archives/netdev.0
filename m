From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 16/16] net_tstamp,doc: Add test program for
 SIOC{G,S}HWTSTAMP
Date: Thu, 5 Dec 2013 23:58:21 +0000
Message-ID: <1386287901.1516.143.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6833 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755330Ab3LEX6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:58:24 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 Documentation/networking/timestamping/.gitignore   |   1 +
 Documentation/networking/timestamping/Makefile     |   5 +-
 .../networking/timestamping/hwtstamp_config.c      | 134 +++++++++++++++++++++
 3 files changed, 138 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/networking/timestamping/hwtstamp_config.c

diff --git a/Documentation/networking/timestamping/.gitignore b/Documentation/networking/timestamping/.gitignore
index 71e81eb2e22f..a380159765ce 100644
--- a/Documentation/networking/timestamping/.gitignore
+++ b/Documentation/networking/timestamping/.gitignore
@@ -1 +1,2 @@
 timestamping
+hwtstamp_config
diff --git a/Documentation/networking/timestamping/Makefile b/Documentation/networking/timestamping/Makefile
index e79973443e9f..d934afc8306a 100644
--- a/Documentation/networking/timestamping/Makefile
+++ b/Documentation/networking/timestamping/Makefile
@@ -2,12 +2,13 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := timestamping
+hostprogs-y := timestamping hwtstamp_config
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
 
 HOSTCFLAGS_timestamping.o += -I$(objtree)/usr/include
+HOSTCFLAGS_hwtstamp_config.o += -I$(objtree)/usr/include
 
 clean:
-	rm -f timestamping
+	rm -f timestamping hwtstamp_config
diff --git a/Documentation/networking/timestamping/hwtstamp_config.c b/Documentation/networking/timestamping/hwtstamp_config.c
new file mode 100644
index 000000000000..e8b685a7f15f
--- /dev/null
+++ b/Documentation/networking/timestamping/hwtstamp_config.c
@@ -0,0 +1,134 @@
+/* Test program for SIOC{G,S}HWTSTAMP
+ * Copyright 2013 Solarflare Communications
+ * Author: Ben Hutchings
+ */
+
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+
+#include <sys/socket.h>
+#include <sys/ioctl.h>
+
+#include <linux/if.h>
+#include <linux/net_tstamp.h>
+#include <linux/sockios.h>
+
+static int
+lookup_value(const char **names, int size, const char *name)
+{
+	int value;
+
+	for (value = 0; value < size; value++)
+		if (names[value] && strcasecmp(names[value], name) == 0)
+			return value;
+
+	return -1;
+}
+
+static const char *
+lookup_name(const char **names, int size, int value)
+{
+	return (value >= 0 && value < size) ? names[value] : NULL;
+}
+
+static void list_names(FILE *f, const char **names, int size)
+{
+	int value;
+
+	for (value = 0; value < size; value++)
+		if (names[value])
+			fprintf(f, "    %s\n", names[value]);
+}
+
+static const char *tx_types[] = {
+#define TX_TYPE(name) [HWTSTAMP_TX_ ## name] = #name
+	TX_TYPE(OFF),
+	TX_TYPE(ON),
+	TX_TYPE(ONESTEP_SYNC)
+#undef TX_TYPE
+};
+#define N_TX_TYPES ((int)(sizeof(tx_types) / sizeof(tx_types[0])))
+
+static const char *rx_filters[] = {
+#define RX_FILTER(name) [HWTSTAMP_FILTER_ ## name] = #name
+	RX_FILTER(NONE),
+	RX_FILTER(ALL),
+	RX_FILTER(SOME),
+	RX_FILTER(PTP_V1_L4_EVENT),
+	RX_FILTER(PTP_V1_L4_SYNC),
+	RX_FILTER(PTP_V1_L4_DELAY_REQ),
+	RX_FILTER(PTP_V2_L4_EVENT),
+	RX_FILTER(PTP_V2_L4_SYNC),
+	RX_FILTER(PTP_V2_L4_DELAY_REQ),
+	RX_FILTER(PTP_V2_L2_EVENT),
+	RX_FILTER(PTP_V2_L2_SYNC),
+	RX_FILTER(PTP_V2_L2_DELAY_REQ),
+	RX_FILTER(PTP_V2_EVENT),
+	RX_FILTER(PTP_V2_SYNC),
+	RX_FILTER(PTP_V2_DELAY_REQ),
+#undef RX_FILTER
+};
+#define N_RX_FILTERS ((int)(sizeof(rx_filters) / sizeof(rx_filters[0])))
+
+static void usage(void)
+{
+	fputs("Usage: hwtstamp_config if_name [tx_type rx_filter]\n"
+	      "tx_type is any of (case-insensitive):\n",
+	      stderr);
+	list_names(stderr, tx_types, N_TX_TYPES);
+	fputs("rx_filter is any of (case-insensitive):\n", stderr);
+	list_names(stderr, rx_filters, N_RX_FILTERS);
+}
+
+int main(int argc, char **argv)
+{
+	struct ifreq ifr;
+	struct hwtstamp_config config;
+	const char *name;
+	int sock;
+
+	if ((argc != 2 && argc != 4) || (strlen(argv[1]) >= IFNAMSIZ)) {
+		usage();
+		return 2;
+	}
+
+	if (argc == 4) {
+		config.flags = 0;
+		config.tx_type = lookup_value(tx_types, N_TX_TYPES, argv[2]);
+		config.rx_filter = lookup_value(rx_filters, N_RX_FILTERS, argv[3]);
+		if (config.tx_type < 0 || config.rx_filter < 0) {
+			usage();
+			return 2;
+		}
+	}
+
+	sock = socket(AF_INET, SOCK_DGRAM, 0);
+	if (sock < 0) {
+		perror("socket");
+		return 1;
+	}
+
+	strcpy(ifr.ifr_name, argv[1]);
+	ifr.ifr_data = (caddr_t)&config;
+
+	if (ioctl(sock, (argc == 2) ? SIOCGHWTSTAMP : SIOCSHWTSTAMP, &ifr)) {
+		perror("ioctl");
+		return 1;
+	}
+
+	printf("flags = %#x\n", config.flags);
+	name = lookup_name(tx_types, N_TX_TYPES, config.tx_type);
+	if (name)
+		printf("tx_type = %s\n", name);
+	else
+		printf("tx_type = %d\n", config.tx_type);
+	name = lookup_name(rx_filters, N_RX_FILTERS, config.rx_filter);
+	if (name)
+		printf("rx_filter = %s\n", name);
+	else
+		printf("rx_filter = %d\n", config.rx_filter);
+
+	return 0;
+}

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
