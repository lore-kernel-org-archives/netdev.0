From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] tc: fix compilation with old gcc (< 4.6)
Date: Thu,  7 Jan 2016 14:03:13 +0100
Message-ID: <1452171793-5829-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	Julien Floret <julien.floret@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:59707 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbcAGNDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 08:03:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Floret <julien.floret@6wind.com>

gcc < 4.6 does not handle C11 syntax for the static initialization of
anonymous struct/union, hence the following error:

tc_bpf.c:260: error: unknown field map_type specified in initializer

Signed-off-by: Julien Floret <julien.floret@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 tc/tc_bpf.c | 48 +++++++++++++++++++++++++++---------------------
 1 file changed, 27 insertions(+), 21 deletions(-)

diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 276871a5c0a5..47993bad81ca 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -257,12 +257,14 @@ static bool bpf_may_skip_map_creation(int file_fd)
 static int bpf_create_map(enum bpf_map_type type, unsigned int size_key,
 			  unsigned int size_value, unsigned int max_elem)
 {
-	union bpf_attr attr = {
-		.map_type	= type,
-		.key_size	= size_key,
-		.value_size	= size_value,
-		.max_entries	= max_elem,
-	};
+	union bpf_attr attr;
+
+	memset(&attr, 0, sizeof(attr));
+
+	attr.map_type = type;
+	attr.key_size = size_key;
+	attr.value_size = size_value;
+	attr.max_entries = max_elem;
 
 	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
@@ -270,12 +272,14 @@ static int bpf_create_map(enum bpf_map_type type, unsigned int size_key,
 static int bpf_update_map(int fd, const void *key, const void *value,
 			  uint64_t flags)
 {
-	union bpf_attr attr = {
-		.map_fd		= fd,
-		.key		= bpf_ptr_to_u64(key),
-		.value		= bpf_ptr_to_u64(value),
-		.flags		= flags,
-	};
+	union bpf_attr attr;
+
+	memset(&attr, 0, sizeof(attr));
+
+	attr.map_fd = fd;
+	attr.key = bpf_ptr_to_u64(key);
+	attr.value = bpf_ptr_to_u64(value);
+	attr.flags = flags;
 
 	return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
@@ -283,15 +287,17 @@ static int bpf_update_map(int fd, const void *key, const void *value,
 static int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
 			 unsigned int len, const char *license)
 {
-	union bpf_attr attr = {
-		.prog_type	= type,
-		.insns		= bpf_ptr_to_u64(insns),
-		.insn_cnt	= len / sizeof(struct bpf_insn),
-		.license	= bpf_ptr_to_u64(license),
-		.log_buf	= bpf_ptr_to_u64(bpf_log_buf),
-		.log_size	= sizeof(bpf_log_buf),
-		.log_level	= 1,
-	};
+	union bpf_attr attr;
+
+	memset(&attr, 0, sizeof(attr));
+
+	attr.prog_type = type;
+	attr.insns = bpf_ptr_to_u64(insns);
+	attr.insn_cnt = len / sizeof(struct bpf_insn);
+	attr.license = bpf_ptr_to_u64(license);
+	attr.log_buf = bpf_ptr_to_u64(bpf_log_buf);
+	attr.log_size = sizeof(bpf_log_buf);
+	attr.log_level = 1;
 
 	return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 }
-- 
2.4.2
