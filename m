From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/2] tools: psock_lib: tighten conditions checked in sock_setfilter
Date: Tue,  3 Jan 2017 15:27:38 -0800
Message-ID: <04d240e80be0455040f7b641e2c59ff86754edd1.1483482971.git.sowmini.varadhan@oracle.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net,
        shuah@kernel.org
To: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20535 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761976AbdACX2I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 18:28:08 -0500
In-Reply-To: <cover.1483482971.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1483482971.git.sowmini.varadhan@oracle.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bpf_prog used in sock_setfilter() only attempts to check for
ip pktlen, and verifies that the contents of the 80'th packet in
the ethernet frame is 'a' or 'b'. Offsets used for checking these
conditions are incorrectly computed.  Thus many non-udp packets
could incorrectly pass through this filter and cause the test to
fail.

This commit tightens the conditions checked by the filter so
that only UDP/IPv4 packets with the matching length and test-character
will be permitted by the filter. The filter has been cleaned up
to explicitly use the BPF macros to make it more readable.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 tools/testing/selftests/net/psock_lib.h |   28 +++++++++++++++++++++-------
 1 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/tools/testing/selftests/net/psock_lib.h b/tools/testing/selftests/net/psock_lib.h
index 24bc7ec..e62540e 100644
--- a/tools/testing/selftests/net/psock_lib.h
+++ b/tools/testing/selftests/net/psock_lib.h
@@ -27,6 +27,7 @@
 #include <string.h>
 #include <arpa/inet.h>
 #include <unistd.h>
+#include <netinet/udp.h>
 
 #define DATA_LEN			100
 #define DATA_CHAR			'a'
@@ -40,14 +41,27 @@
 
 static __maybe_unused void sock_setfilter(int fd, int lvl, int optnum)
 {
+	uint16_t ip_len = DATA_LEN +
+			  sizeof(struct iphdr) + sizeof(struct udphdr);
+	/* the filter below checks for all of the following conditions that
+	 * are based on the contents of create_payload()
+	 *  ether type 0x800 and
+	 *  ip proto udp     and
+	 *  ip len == ip_len and
+	 *  udp[38] == 'a' or udp[38] == 'b'
+	 */
 	struct sock_filter bpf_filter[] = {
-		{ 0x80, 0, 0, 0x00000000 },  /* LD  pktlen		      */
-		{ 0x35, 0, 4, DATA_LEN   },  /* JGE DATA_LEN  [f goto nomatch]*/
-		{ 0x30, 0, 0, 0x00000050 },  /* LD  ip[80]		      */
-		{ 0x15, 1, 0, DATA_CHAR  },  /* JEQ DATA_CHAR   [t goto match]*/
-		{ 0x15, 0, 1, DATA_CHAR_1},  /* JEQ DATA_CHAR_1 [t goto match]*/
-		{ 0x06, 0, 0, 0x00000060 },  /* RET match	              */
-		{ 0x06, 0, 0, 0x00000000 },  /* RET no match		      */
+		BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 12),	/* LD ethertype */
+		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, ETH_P_IP, 0, 8),
+		BPF_STMT(BPF_LD|BPF_B|BPF_ABS, 23),	/* LD ip_proto */
+		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, IPPROTO_UDP, 0, 6),
+		BPF_STMT(BPF_LD|BPF_H|BPF_ABS, 16),	/* LD ip_len */
+		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, ip_len, 0, 4),
+		BPF_STMT(BPF_LD|BPF_B|BPF_ABS, 80),	/* LD udp[38] */
+		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, DATA_CHAR, 1, 0),
+		BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, DATA_CHAR_1, 0, 1),
+		BPF_STMT(BPF_RET | BPF_K, ~0),		/* match */
+		BPF_STMT(BPF_RET | BPF_K, 0)		/* no match */
 	};
 	struct sock_fprog bpf_prog;
 
-- 
1.7.1
