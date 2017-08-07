From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCHv2] bpf: fix selftest/bpf/test_pkt_md_access on s390x
Date: Mon,  7 Aug 2017 10:16:36 +0200
Message-ID: <20170807081636.65099-1-tmricht@linux.vnet.ibm.com>
Cc: heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
        brueckner@linux.vnet.ibm.com,
        Thomas Richter <tmricht@linux.vnet.ibm.com>
To: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:51884 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752495AbdHGIRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:17:00 -0400
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v778FHNo085753
        for <netdev@vger.kernel.org>; Mon, 7 Aug 2017 04:16:59 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c6m3499h5-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 04:16:59 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
        Mon, 7 Aug 2017 09:16:57 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 18f3d6be6be1 ("selftests/bpf: Add test cases to test narrower ctx field loads")
introduced new eBPF test cases. One of them (test_pkt_md_access.c)
fails on s390x. The BPF verifier error message is:

[root@s8360046 bpf]# ./test_progs
test_pkt_access:PASS:ipv4 349 nsec
test_pkt_access:PASS:ipv6 212 nsec
[....]
libbpf: load bpf program failed: Permission denied
libbpf: -- BEGIN DUMP LOG ---
libbpf:
0: (71) r2 = *(u8 *)(r1 +0)
invalid bpf_context access off=0 size=1

libbpf: -- END LOG --
libbpf: failed to load program 'test1'
libbpf: failed to load object './test_pkt_md_access.o'
Summary: 29 PASSED, 1 FAILED
[root@s8360046 bpf]#

This is caused by a byte endianness issue. S390x is a big endian
architecture.  Pointer access to the lowest byte or halfword of a
four byte value need to add an offset.
On little endian architectures this offset is not needed.

Fix this and use the same approach as the originator used for other files
(for example test_verifier.c) in his original commit.

With this fix the test program test_progs succeeds on s390x:
[root@s8360046 bpf]# ./test_progs
test_pkt_access:PASS:ipv4 236 nsec
test_pkt_access:PASS:ipv6 217 nsec
test_xdp:PASS:ipv4 3624 nsec
test_xdp:PASS:ipv6 1722 nsec
test_l4lb:PASS:ipv4 926 nsec
test_l4lb:PASS:ipv6 1322 nsec
test_tcp_estats:PASS: 0 nsec
test_bpf_obj_id:PASS:get-fd-by-notexist-prog-id 0 nsec
test_bpf_obj_id:PASS:get-fd-by-notexist-map-id 0 nsec
test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-map-info(fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:get-prog-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-prog-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:check total prog id found by get_next_id 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:get-map-fd(next_id) 0 nsec
test_bpf_obj_id:PASS:check get-map-info(next_id->fd) 0 nsec
test_bpf_obj_id:PASS:check total map id found by get_next_id 0 nsec
test_pkt_md_access:PASS: 277 nsec
Summary: 30 PASSED, 0 FAILED
[root@s8360046 bpf]#

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/testing/selftests/bpf/test_pkt_md_access.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_pkt_md_access.c b/tools/testing/selftests/bpf/test_pkt_md_access.c
index 71729d4..7956302 100644
--- a/tools/testing/selftests/bpf/test_pkt_md_access.c
+++ b/tools/testing/selftests/bpf/test_pkt_md_access.c
@@ -12,12 +12,23 @@
 
 int _version SEC("version") = 1;
 
+#if  __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
 #define TEST_FIELD(TYPE, FIELD, MASK)					\
 	{								\
 		TYPE tmp = *(volatile TYPE *)&skb->FIELD;		\
 		if (tmp != ((*(volatile __u32 *)&skb->FIELD) & MASK))	\
 			return TC_ACT_SHOT;				\
 	}
+#else
+#define TEST_FIELD_OFFSET(a, b)	((sizeof(a) - sizeof(b)) / sizeof(b))
+#define TEST_FIELD(TYPE, FIELD, MASK)					\
+	{								\
+		TYPE tmp = *((volatile TYPE *)&skb->FIELD +		\
+			      TEST_FIELD_OFFSET(skb->FIELD, TYPE));	\
+		if (tmp != ((*(volatile __u32 *)&skb->FIELD) & MASK))	\
+			return TC_ACT_SHOT;				\
+	}
+#endif
 
 SEC("test1")
 int process(struct __sk_buff *skb)
-- 
2.9.3
