From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 10/21] Add test cases for command-line parsing
Date: Tue, 1 Nov 2011 23:17:19 +0000
Message-ID: <1320189439.2758.40.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38179 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553Ab1KAXRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:17:23 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preparation for refactoring command-line parsing.
All these test cases pass.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 Makefile.am    |    7 ++
 configure.ac   |    1 +
 ethtool.c      |    5 ++
 internal.h     |    4 +
 test-cmdline.c |  206 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 test-common.c  |   92 +++++++++++++++++++++++++
 6 files changed, 315 insertions(+), 0 deletions(-)
 create mode 100644 test-cmdline.c
 create mode 100644 test-common.c

diff --git a/Makefile.am b/Makefile.am
index 1e05640..4b0eb17 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -11,6 +11,13 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h internal.h \
 		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
 		  rxclass.c
 
+TESTS = test-cmdline
+check_PROGRAMS = test-cmdline test-one-cmdline
+test_cmdline_SOURCES = test-cmdline.c test-common.c
+test_cmdline_CFLAGS = -DTEST_ETHTOOL
+test_one_cmdline_SOURCES = $(ethtool_SOURCES)
+test_one_cmdline_CFLAGS = -DTEST_ETHTOOL
+
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
 
diff --git a/configure.ac b/configure.ac
index 8bc8a56..ac5142b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -10,6 +10,7 @@ AM_MAINTAINER_MODE
 dnl Checks for programs.
 AC_PROG_CC
 AC_PROG_GCC_TRADITIONAL
+AM_PROG_CC_C_O
 
 dnl Checks for libraries.
 
diff --git a/ethtool.c b/ethtool.c
index b6f535c..7a26043 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3444,8 +3444,13 @@ static int do_setfwdump(struct cmd_context *ctx)
 
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
+#ifndef TEST_ETHTOOL
 	ctx->ifr.ifr_data = cmd;
 	return ioctl(ctx->fd, SIOCETHTOOL, &ctx->ifr);
+#else
+	/* If we get this far then parsing succeeded */
+	exit(0);
+#endif
 }
 
 int main(int argc, char **argp, char **envp)
diff --git a/internal.h b/internal.h
index c2f504a..ba7d719 100644
--- a/internal.h
+++ b/internal.h
@@ -94,6 +94,10 @@ struct cmd_context {
 	struct ifreq ifr;	/* ifreq suitable for ethtool ioctl */
 };
 
+#ifdef TEST_ETHTOOL
+int test_cmdline(const char *args);
+#endif
+
 int send_ioctl(struct cmd_context *ctx, void *cmd);
 
 /* National Semiconductor DP83815, DP83816 */
diff --git a/test-cmdline.c b/test-cmdline.c
new file mode 100644
index 0000000..88591df
--- /dev/null
+++ b/test-cmdline.c
@@ -0,0 +1,206 @@
+/****************************************************************************
+ * Test cases for ethtool command-line parsing
+ * Copyright 2011 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include "internal.h"
+
+static struct test_case {
+	int rc;
+	const char *args;
+} test_cases[] = {
+	{ 1, "" },
+	{ 0, "devname" },
+	{ 0, "15_char_devname" },
+	{ 1, "16_char_devname!" },
+	/* Argument parsing for -s is specialised */
+	{ 0, "-s devname" },
+	{ 0, "--change devname speed 100 duplex half" },
+	{ 1, "-s devname speed foo" },
+	{ 1, "--change devname speed" },
+	{ 0, "-s devname duplex half" },
+	{ 1, "--change devname duplex foo" },
+	{ 1, "-s devname duplex" },
+	{ 0, "--change devname port tp" },
+	{ 1, "-s devname port foo" },
+	{ 1, "--change devname port" },
+	{ 0, "-s devname autoneg on" },
+	{ 1, "--change devname autoneg foo" },
+	{ 1, "-s devname autoneg" },
+	{ 0, "--change devname advertise 0x1" },
+	{ 1, "-s devname advertise foo" },
+	{ 1, "--change devname advertise" },
+	{ 0, "-s devname phyad 1" },
+	{ 1, "--change devname phyad foo" },
+	{ 1, "-s devname phyad" },
+	{ 0, "--change devname xcvr external" },
+	{ 1, "-s devname xcvr foo" },
+	{ 1, "--change devname xcvr" },
+	{ 0, "-s devname wol p" },
+	{ 1, "--change devname wol" },
+	{ 0, "-s devname sopass 01:23:45:67:89:ab" },
+	{ 1, "--change devname sopass 01:23:45:67:89:" },
+	{ 1, "-s devname sopass 01:23:45:67:89" },
+	{ 1, "--change devname sopass" },
+	{ 0, "-s devname msglvl 1" },
+	{ 1, "--change devname msglvl" },
+	{ 0, "-s devname msglvl hw on rx_status off" },
+	{ 1, "--change devname msglvl hw foo" },
+	{ 1, "-s devname msglvl hw" },
+	{ 0, "--change devname speed 100 duplex half port tp autoneg on advertise 0x1 phyad 1 xcvr external wol p sopass 01:23:45:67:89:ab msglvl 1" },
+	{ 1, "-s devname foo" },
+	{ 0, "-a devname" },
+	{ 0, "--show-pause devname" },
+	/* Many other sub-commands use parse_generic_cmdline() and
+	 * don't need to be check in that much detail. */
+	{ 0, "-A devname autoneg on" },
+	{ 1, "--pause devname autoneg foo" },
+	{ 1, "-A devname autoneg" },
+	{ 0, "--pause devname rx off" },
+	{ 0, "-A devname tx on rx on autoneg off" },
+	{ 1, "--pause devname foo on" },
+	{ 0, "-c devname" },
+	{ 0, "--show-coalesce devname" },
+	{ 0, "-C devname adaptive-rx on adaptive-tx off rx-usecs 1 rx-frames 2 rx-usecs-irq 3 rx-frames-irq 4 tx-usecs 5 tx-frames 6 tx-usecs-irq 7 tx-frames-irq 8 stats-block-usecs 9 pkt-rate-low 10" },
+	{ 0, "--coalesce devname rx-usecs-low 11 rx-frames-low 12 tx-usecs-low 13 tx-frames-low 14 pkt-rate-high 15 rx-usecs-high 16 rx-frames-high 17 tx-usecs-high 18 tx-frames-high 19 sample-interval 20" },
+	{ 1, "-C devname adaptive-rx foo" },
+	{ 1, "--coalesce devname adaptive-rx" },
+	{ 1, "-C devname foo on" },
+	{ 0, "-g devname" },
+	{ 0, "--show-ring devname" },
+	{ 0, "-G devname rx 1 rx-mini 2 rx-jumbo 3 tx 4" },
+	{ 0, "--set-ring devname rx 1 rx-mini 2 rx-jumbo 3 tx 4" },
+	{ 1, "-G devname rx foo" },
+	{ 1, "--set-ring devname rx" },
+	{ 1, "-G devname foo 1" },
+	{ 0, "-k devname" },
+	{ 0, "--show-offload devname" },
+	{ 0, "-K devname rx on tx off sg on tso off ufo on gso off gro on" },
+	{ 0, "--offload devname lro off rxvlan on txvlan off ntuple on rxhash off" },
+	{ 1, "-K devname rx foo" },
+	{ 1, "--offload devname rx" },
+	{ 1, "-K devname foo on" },
+	{ 0, "-i devname" },
+	{ 0, "--driver devname" },
+	{ 0, "-d devname" },
+	{ 0, "--register-dump devname raw on file foo" },
+	{ 1, "-d devname raw foo" },
+	{ 1, "--register-dump devname file" },
+	{ 1, "-d devname foo" },
+	{ 0, "-e devname" },
+	{ 0, "--eeprom-dump devname raw on offset 1 length 2" },
+	{ 1, "-e devname raw foo" },
+	{ 1, "--eeprom-dump devname offset foo" },
+	{ 1, "-e devname length" },
+	{ 1, "--eeprom-dump devname foo" },
+	{ 0, "-E devname" },
+	{ 0, "--change-eeprom devname magic 0x87654321 offset 0 value 1" },
+	{ 0, "-E devname magic 0x87654321 offset 0 length 2" },
+	{ 0, "-r devname" },
+	{ 0, "--negotiate devname" },
+	{ 0, "-p devname" },
+	{ 0, "--identify devname 1" },
+	{ 1, "-p devname 1 foo" },
+	{ 1, "--identify devname foo" },
+	/* Argument parsing for -t is specialised */
+	{ 0, "-t devname" },
+	{ 0, "--test devname online" },
+	{ 1, "-t devname foo" },
+	{ 1, "--test devname online foo" },
+	{ 0, "-S devname" },
+	{ 0, "--statistics devname" },
+	/* Argument parsing for -n is specialised */
+	{ 0, "-n devname rx-flow-hash tcp4" },
+	{ 0, "--show-nfc devname rx-flow-hash udp6" },
+	{ 1, "-n devname rx-flow-hash foo" },
+	{ 1, "--show-nfc devname rx-flow-hash" },
+	{ 1, "-n devname foo" },
+	/* Argument parsing for -f is specialised */
+	{ 1, "-f devname" },
+	{ 0, "--flash devname filename" },
+	{ 0, "-f devname filename 1" },
+	/* Argument parsing for -N is specialised */
+	{ 0, "-N devname rx-flow-hash tcp4 mvtsdfn" },
+	{ 0, "--config-nfc devname rx-flow-hash tcp4 r" },
+	{ 1, "-N devname rx-flow-hash tcp4" },
+	{ 1, "--config-nfc devname rx-flow-hash foo" },
+	{ 1, "-N devname rx-flow-hash" },
+	{ 1, "--config-nfc devname foo" },
+	{ 0, "-x devname" },
+	{ 0, "--show-rxfh-indir devname" },
+	/* Argument parsing for -X is specialised */
+	{ 0, "-X devname equal 2" },
+	{ 0, "--set-rxfh-indir devname equal 256" },
+	{ 1, "-X devname equal 0" },
+	{ 1, "--set-rxfh-indir devname equal foo" },
+	{ 1, "-X devname equal" },
+	{ 0, "--set-rxfh-indir devname weight 1 2 3 4" },
+	{ 1, "-X devname foo" },
+	/* Argument parsing for -U is specialised */
+	{ 0, "-U devname delete 1" },
+	{ 1, "--config-ntuple devname delete foo" },
+	{ 1, "-U devname delete" },
+	{ 0, "--config-ntuple devname flow-type ether src 01:23:45:67:89:ab m cd:ef:01:23:45:67 dst 89:ab:cd:ef:01:23 m 45:67:89:ab:cd:ef proto 0x0123 m 0x4567 vlan 0x89ab m 0xcdef action 0" },
+	{ 0, "-U devname flow-type ether src 01:23:45:67:89:ab src-mask cd:ef:01:23:45:67 dst 89:ab:cd:ef:01:23 dst-mask 45:67:89:ab:cd:ef proto 0x0123 proto-mask 0x4567 vlan 0x89ab vlan-mask 0xcdef action 1" },
+	{ 1, "--config-ntuple devname flow-type ether src 01:23:45:67:89: action 3" },
+	{ 1, "-U devname flow-type ether src 01:23:45:67:89 action 4" },
+	{ 0, "--config-ntuple devname flow-type ip4 src-ip 0.123.45.67 m 89.0.123.45 dst-ip 67.89.0.123 m 45.67.89.0 tos 1 m 1 l4proto 0x23 m 0x45 l4data 0xfedcba98 m 76543210 vlan 0x89ab m 0xcdef action 6" },
+	{ 0, "-U devname flow-type ip4 src-ip 0.123.45.67 src-ip-mask 89.0.123.45 dst-ip 67.89.0.123 dst-ip-mask 45.67.89.0 tos 1 tos-mask 1 l4proto 0x23 l4proto-mask 0x45 l4data 0xfedcba98 l4data-mask 76543210 vlan 0x89ab vlan-mask 0xcdef action 7" },
+	{ 0, "--config-ntuple devname flow-type tcp4 src-ip 0.123.45.67 m 89.0.123.45 dst-ip 67.89.0.123 m 45.67.89.0 tos 1 m 1 src-port 23456 m 7890 dst-port 12345 m 6789 vlan 0x89ab m 0xcdef action 8" },
+	{ 0, "-U devname flow-type tcp4 src-ip 0.123.45.67 src-ip-mask 89.0.123.45 dst-ip 67.89.0.123 dst-ip-mask 45.67.89.0 tos 1 tos-mask 1 src-port 23456 src-port-mask 7890 dst-port 12345 dst-port-mask 6789 vlan 0x89ab vlan-mask 0xcdef action 9" },
+	{ 0, "--config-ntuple devname flow-type ah4 src-ip 0.123.45.67 m 89.0.123.45 dst-ip 67.89.0.123 m 45.67.89.0 tos 1 m 1 spi 2 m 3 vlan 0x89ab m 0xcdef action 10" },
+	{ 0, "-U devname flow-type ah4 src-ip 0.123.45.67 src-ip-mask 89.0.123.45 dst-ip 67.89.0.123 dst-ip-mask 45.67.89.0 tos 1 tos-mask 1 spi 2 spi-mask 3 vlan 0x89ab vlan-mask 0xcdef action 11" },
+	{ 1, "--config-ntuple devname flow-type tcp4 action foo" },
+	{ 1, "-U devname flow-type foo" },
+	{ 1, "--config-ntuple devname flow-type" },
+	{ 1, "-U devname foo" },
+	{ 0, "-P devname" },
+	{ 0, "--show-permaddr devname" },
+	{ 0, "-w devname" },
+	{ 0, "--get-dump devname data filename" },
+	{ 0, "-w devname data filename" },
+	{ 1, "--get-dump devname data" },
+	{ 1, "-w devname foo" },
+	{ 0, "-W devname 1" },
+	{ 0, "--set-dump devname 2" },
+	{ 1, "-W devname foo" },
+	{ 0, "-l devname" },
+	{ 0, "--show-channels devname" },
+	{ 0, "-L devname rx 1 tx 2 other 3 combined 4" },
+	{ 0, "--set-channels devname rx 1 tx 2 other 3 combined 4" },
+	{ 1, "-L devname rx foo" },
+	{ 1, "--set-channels devname rx" },
+	{ 0, "-L devname" },
+	{ 0, "-h" },
+	{ 0, "--help" },
+	{ 0, "--version" },
+	{ 1, "--foo" },
+	{ 1, "-foo" },
+	{ 1, "-0" },
+};
+
+int main(void)
+{
+	struct test_case *tc;
+	int test_rc;
+	int rc = 0;
+
+	for (tc = test_cases; tc < test_cases + ARRAY_SIZE(test_cases); tc++) {
+		if (getenv("ETHTOOL_TEST_VERBOSE"))
+			printf("I: Test command line: ethtool %s\n", tc->args);
+		test_rc = test_cmdline(tc->args);
+		if (test_rc != tc->rc) {
+			fprintf(stderr, "E: ethtool %s returns %d\n",
+				tc->args, test_rc);
+			rc = 1;
+		}
+	}
+
+	return rc;
+}
diff --git a/test-common.c b/test-common.c
new file mode 100644
index 0000000..4ea84c8
--- /dev/null
+++ b/test-common.c
@@ -0,0 +1,92 @@
+/****************************************************************************
+ * Common test functions for ethtool
+ * Copyright 2011 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <stdlib.h>
+#include <string.h>
+#include <sys/fcntl.h>
+#include <sys/wait.h>
+#include <unistd.h>
+#include "internal.h"
+
+int test_cmdline(const char *args)
+{
+	int argc, i;
+	char **argv;
+	const char *arg;
+	size_t len;
+	pid_t pid;
+	int dev_null;
+	int status;
+	int rc;
+
+	/* Convert line to argv */
+	argc = 1;
+	arg = args;
+	for (;;) {
+		len = strcspn(arg, " ");
+		if (len == 0)
+			break;
+		argc++;
+		if (arg[len] == 0)
+			break;
+		arg += len + 1;
+	}
+	argv = calloc(argc + 1, sizeof(argv[0]));
+	argv[0] = strdup("ethtool");
+	arg = args;
+	for (i = 1; i < argc; i++) {
+		len = strcspn(arg, " ");
+		argv[i] = malloc(len + 1);
+		memcpy(argv[i], arg, len);
+		argv[i][len] = 0;
+		arg += len + 1;
+	}
+
+	dev_null = open("/dev/null", O_RDWR);
+	if (dev_null < 0) {
+		perror("open /dev/null");
+		rc = -1;
+		goto out;
+	}
+
+	fflush(NULL);
+	pid = fork();
+
+	/* Child */
+	if (pid == 0) {
+		dup2(dev_null, STDIN_FILENO);
+		if (!getenv("ETHTOOL_TEST_VERBOSE")) {
+			dup2(dev_null, STDOUT_FILENO);
+			dup2(dev_null, STDERR_FILENO);
+		}
+		execv("./test-one-cmdline", argv);
+		_exit(126);
+	}
+
+	/* Parent */
+	if (pid < 0) {
+		perror("fork");
+		close(dev_null);
+		rc = -1;
+		goto out;
+	}
+	close(dev_null);
+	if (waitpid(pid, &status, 0) < 0) {
+		perror("waitpid");
+		rc = -1;
+		goto out;
+	}
+	rc = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
+
+out:
+	for (i = 0; i < argc; i++)
+		free(argv[i]);
+	free(argv);
+	return rc;
+}
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
