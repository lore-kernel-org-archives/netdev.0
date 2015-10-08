From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next] m_bpf: don't require default opcode on ebpf actions
Date: Thu,  8 Oct 2015 15:22:05 +0200
Message-ID: <605ab2e3b1957b5f268214b165b7b27a527ee3a9.1444307491.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43611 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbbJHNWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 09:22:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the patch, the most minimal command to load an eBPF action
for late binding with auto index selection through tc is:

  tc actions add action bpf obj prog.o

We already set TC_ACT_PIPE in tc as default opcode, so if nothing
further has been specified, just use it. Also, allow "ok" next to
"pass" for matching cmdline on TC_ACT_OK.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 [ In future work, we need to consolidate some bigger sections.
   Patch is on top of http://patchwork.ozlabs.org/patch/522713/ ]

 tc/m_bpf.c | 47 +++++++++++++++++++++++------------------------
 1 file changed, 23 insertions(+), 24 deletions(-)

diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index e1bb6a4..fb4c3c7 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -111,25 +111,28 @@ opt_bpf:
 			if (ebpf) {
 				bpf_uds_name = getenv(BPF_ENV_UDS);
 				bpf_obj = *argv;
-				NEXT_ARG();
 
-				if (strcmp(*argv, "section") == 0 ||
-				    strcmp(*argv, "sec") == 0) {
+				NEXT_ARG_FWD();
+
+				if (argc > 0 &&
+				    (strcmp(*argv, "section") == 0 ||
+				     strcmp(*argv, "sec") == 0)) {
 					NEXT_ARG();
 					bpf_sec_name = *argv;
-					NEXT_ARG();
+					NEXT_ARG_FWD();
 				}
-				if (!bpf_uds_name &&
+				if (argc > 0 && !bpf_uds_name &&
 				    (strcmp(*argv, "export") == 0 ||
 				     strcmp(*argv, "exp") == 0)) {
 					NEXT_ARG();
 					bpf_uds_name = *argv;
-					NEXT_ARG();
+					NEXT_ARG_FWD();
 				}
-				if (strcmp(*argv, "verbose") == 0 ||
-				    strcmp(*argv, "verb") == 0) {
+				if (argc > 0 &&
+				    (strcmp(*argv, "verbose") == 0 ||
+				     strcmp(*argv, "verb") == 0)) {
 					bpf_verbose = true;
-					NEXT_ARG();
+					NEXT_ARG_FWD();
 				}
 
 				PREV_ARG();
@@ -166,33 +169,29 @@ opt_bpf:
 				goto opt_bpf;
 			break;
 		}
-		argc--;
-		argv++;
+
+		NEXT_ARG_FWD();
 	}
 
 	parm.action = TC_ACT_PIPE;
 	if (argc) {
 		if (matches(*argv, "reclassify") == 0) {
 			parm.action = TC_ACT_RECLASSIFY;
-			argc--;
-			argv++;
+			NEXT_ARG_FWD();
 		} else if (matches(*argv, "pipe") == 0) {
 			parm.action = TC_ACT_PIPE;
-			argc--;
-			argv++;
+			NEXT_ARG_FWD();
 		} else if (matches(*argv, "drop") == 0 ||
 			   matches(*argv, "shot") == 0) {
 			parm.action = TC_ACT_SHOT;
-			argc--;
-			argv++;
+			NEXT_ARG_FWD();
 		} else if (matches(*argv, "continue") == 0) {
 			parm.action = TC_ACT_UNSPEC;
-			argc--;
-			argv++;
-		} else if (matches(*argv, "pass") == 0) {
+			NEXT_ARG_FWD();
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
 			parm.action = TC_ACT_OK;
-			argc--;
-			argv++;
+			NEXT_ARG_FWD();
 		}
 	}
 
@@ -203,8 +202,8 @@ opt_bpf:
 				fprintf(stderr, "bpf: Illegal \"index\"\n");
 				return -1;
 			}
-			argc--;
-			argv++;
+
+			NEXT_ARG_FWD();
 		}
 	}
 
-- 
1.9.3
