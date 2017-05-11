From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net] samples/bpf: run cleanup routines when receiving SIGTERM
Date: Thu, 11 May 2017 15:52:30 -0400
Message-ID: <1494532350-23945-1-git-send-email-andy@greyhouse.net>
Cc: shahid.habib@broadcom.com, Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33723 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756338AbdEKTwm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 15:52:42 -0400
Received: by mail-qt0-f196.google.com with SMTP id a46so4218930qte.0
        for <netdev@vger.kernel.org>; Thu, 11 May 2017 12:52:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shahid Habib noticed that when xdp1 was killed from a different console the xdp
program was not cleaned-up properly in the kernel and it continued to forward
traffic.

Most of the applications in samples/bpf cleanup properly, but only when getting
SIGINT.  Since kill defaults to using SIGTERM, add support to cleanup when the
application receives either SIGINT or SIGTERM.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Reported-by: Shahid Habib <shahid.habib@broadcom.com>
---
 samples/bpf/cookie_uid_helper_example.c | 4 +++-
 samples/bpf/offwaketime_user.c          | 1 +
 samples/bpf/sampleip_user.c             | 1 +
 samples/bpf/trace_event_user.c          | 1 +
 samples/bpf/tracex2_user.c              | 1 +
 samples/bpf/xdp1_user.c                 | 1 +
 samples/bpf/xdp_tx_iptunnel_user.c      | 1 +
 7 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/cookie_uid_helper_example.c b/samples/bpf/cookie_uid_helper_example.c
index b08ab4e..9d751e2 100644
--- a/samples/bpf/cookie_uid_helper_example.c
+++ b/samples/bpf/cookie_uid_helper_example.c
@@ -306,7 +306,9 @@ int main(int argc, char *argv[])
 	prog_attach_iptables(argv[2]);
 	if (cfg_test_traffic) {
 		if (signal(SIGINT, finish) == SIG_ERR)
-			error(1, errno, "register handler failed");
+			error(1, errno, "register SIGINT handler failed");
+		if (signal(SIGTERM, finish) == SIG_ERR)
+			error(1, errno, "register SIGTERM handler failed");
 		while (!test_finish) {
 			print_table();
 			printf("\n");
diff --git a/samples/bpf/offwaketime_user.c b/samples/bpf/offwaketime_user.c
index 9cce2a6..512f87a 100644
--- a/samples/bpf/offwaketime_user.c
+++ b/samples/bpf/offwaketime_user.c
@@ -100,6 +100,7 @@ int main(int argc, char **argv)
 	setrlimit(RLIMIT_MEMLOCK, &r);
 
 	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
 
 	if (load_kallsyms()) {
 		printf("failed to process /proc/kallsyms\n");
diff --git a/samples/bpf/sampleip_user.c b/samples/bpf/sampleip_user.c
index be59d7d..4ed690b 100644
--- a/samples/bpf/sampleip_user.c
+++ b/samples/bpf/sampleip_user.c
@@ -180,6 +180,7 @@ int main(int argc, char **argv)
 		return 1;
 	}
 	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
 
 	/* do sampling */
 	printf("Sampling at %d Hertz for %d seconds. Ctrl-C also ends.\n",
diff --git a/samples/bpf/trace_event_user.c b/samples/bpf/trace_event_user.c
index 0c5561d..fa43364 100644
--- a/samples/bpf/trace_event_user.c
+++ b/samples/bpf/trace_event_user.c
@@ -192,6 +192,7 @@ int main(int argc, char **argv)
 	setrlimit(RLIMIT_MEMLOCK, &r);
 
 	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
 
 	if (load_kallsyms()) {
 		printf("failed to process /proc/kallsyms\n");
diff --git a/samples/bpf/tracex2_user.c b/samples/bpf/tracex2_user.c
index 7fee0f1..7321a3f 100644
--- a/samples/bpf/tracex2_user.c
+++ b/samples/bpf/tracex2_user.c
@@ -127,6 +127,7 @@ int main(int ac, char **argv)
 	}
 
 	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
 
 	/* start 'ping' in the background to have some kfree_skb events */
 	f = popen("ping -c5 localhost", "r");
diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
index 378850c..c5dc13f 100644
--- a/samples/bpf/xdp1_user.c
+++ b/samples/bpf/xdp1_user.c
@@ -102,6 +102,7 @@ int main(int argc, char **argv)
 	}
 
 	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
 
 	if (set_link_xdp_fd(ifindex, prog_fd[0], xdp_flags) < 0) {
 		printf("link set xdp fd failed\n");
diff --git a/samples/bpf/xdp_tx_iptunnel_user.c b/samples/bpf/xdp_tx_iptunnel_user.c
index 92b8bde..cf09f08 100644
--- a/samples/bpf/xdp_tx_iptunnel_user.c
+++ b/samples/bpf/xdp_tx_iptunnel_user.c
@@ -239,6 +239,7 @@ int main(int argc, char **argv)
 	}
 
 	signal(SIGINT, int_exit);
+	signal(SIGTERM, int_exit);
 
 	while (min_port <= max_port) {
 		vip.dport = htons(min_port++);
-- 
2.7.4
