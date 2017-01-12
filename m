From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] tools: psock_lib: harden socket filter used by psock tests
Date: Thu, 12 Jan 2017 05:10:11 -0800
Message-ID: <2dbc0b384193b76bcb7f1845e1f81768610cc2b5.1484060892.git.sowmini.varadhan@oracle.com>
References: <cover.1484060892.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net
To: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41259 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750856AbdALNKi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:10:38 -0500
In-Reply-To: <cover.1484060892.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The filter added by sock_setfilter is intended to only permit
packets matching the pattern set up by create_payload(), but
we only check the ip_len, and a single test-character in
the IP packet to ensure this condition.

Harden the filter by adding additional constraints so that we only
permit UDP/IPv4 packets that meet the ip_len and test-character
requirements. Include the bpf_asm src as a comment, in case this
needs to be enhanced in the future

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 tools/testing/selftests/net/psock_lib.h |   39 +++++++++++++++++++++++++-----
 1 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/tools/testing/selftests/net/psock_lib.h b/tools/testing/selftests/net/psock_lib.h
index 24bc7ec..a77da88 100644
--- a/tools/testing/selftests/net/psock_lib.h
+++ b/tools/testing/selftests/net/psock_lib.h
@@ -40,14 +40,39 @@
 
 static __maybe_unused void sock_setfilter(int fd, int lvl, int optnum)
 {
+	/* the filter below checks for all of the following conditions that
+	 * are based on the contents of create_payload()
+	 *  ether type 0x800 and
+	 *  ip proto udp     and
+	 *  skb->len == DATA_LEN and
+	 *  udp[38] == 'a' or udp[38] == 'b'
+	 * It can be generated from the following bpf_asm input:
+	 *	ldh [12]
+	 *	jne #0x800, drop	; ETH_P_IP
+	 *	ldb [23]
+	 *	jneq #17, drop		; IPPROTO_UDP
+	 *	ld len			; ld skb->len
+	 *	jlt #100, drop		; DATA_LEN
+	 *	ldb [80]
+	 *	jeq #97, pass		; DATA_CHAR
+	 *	jne #98, drop		; DATA_CHAR_1
+	 *	pass:
+	 *	  ret #-1
+	 *	drop:
+	 *	  ret #0
+	 */
 	struct sock_filter bpf_filter[] = {
-		{ 0x80, 0, 0, 0x00000000 },  /* LD  pktlen		      */
-		{ 0x35, 0, 4, DATA_LEN   },  /* JGE DATA_LEN  [f goto nomatch]*/
-		{ 0x30, 0, 0, 0x00000050 },  /* LD  ip[80]		      */
-		{ 0x15, 1, 0, DATA_CHAR  },  /* JEQ DATA_CHAR   [t goto match]*/
-		{ 0x15, 0, 1, DATA_CHAR_1},  /* JEQ DATA_CHAR_1 [t goto match]*/
-		{ 0x06, 0, 0, 0x00000060 },  /* RET match	              */
-		{ 0x06, 0, 0, 0x00000000 },  /* RET no match		      */
+		{ 0x28,  0,  0, 0x0000000c },
+		{ 0x15,  0,  8, 0x00000800 },
+		{ 0x30,  0,  0, 0x00000017 },
+		{ 0x15,  0,  6, 0x00000011 },
+		{ 0x80,  0,  0, 0000000000 },
+		{ 0x35,  0,  4, 0x00000064 },
+		{ 0x30,  0,  0, 0x00000050 },
+		{ 0x15,  1,  0, 0x00000061 },
+		{ 0x15,  0,  1, 0x00000062 },
+		{ 0x06,  0,  0, 0xffffffff },
+		{ 0x06,  0,  0, 0000000000 },
 	};
 	struct sock_fprog bpf_prog;
 
-- 
1.7.1
