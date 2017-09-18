From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next 2/3] bpf: Add uniqueness invariant to trivial lpm test implementation
Date: Mon, 18 Sep 2017 15:30:56 -0400
Message-ID: <20170918193057.37644-3-kraigatgoog@gmail.com>
References: <20170918193057.37644-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: Daniel Mack <daniel@zonque.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:45520 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdIRTbB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:31:01 -0400
Received: by mail-qt0-f178.google.com with SMTP id t46so1666376qtj.2
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 12:31:01 -0700 (PDT)
In-Reply-To: <20170918193057.37644-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

The 'trivial' lpm implementation in this test allows equivalent nodes
to be added (that is, nodes consisting of the same prefix and prefix
length).  For lookup operations, this is fine because insertion happens
at the head of the (singly linked) list and the first, best match is
returned.  In order to support deletion, the tlpm data structue must
first enforce uniqueness.  This change modifies the insertion algorithm
to search for equivalent nodes and remove them.  Note: the
BPF_MAP_TYPE_LPM_TRIE already has a uniqueness invariant that is
implemented as node replacement.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 tools/testing/selftests/bpf/test_lpm_map.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/bpf/test_lpm_map.c b/tools/testing/selftests/bpf/test_lpm_map.c
index e97565243d59..a5ed7c4f1819 100644
--- a/tools/testing/selftests/bpf/test_lpm_map.c
+++ b/tools/testing/selftests/bpf/test_lpm_map.c
@@ -31,6 +31,10 @@ struct tlpm_node {
 	uint8_t key[];
 };
 
+static struct tlpm_node *tlpm_match(struct tlpm_node *list,
+				    const uint8_t *key,
+				    size_t n_bits);
+
 static struct tlpm_node *tlpm_add(struct tlpm_node *list,
 				  const uint8_t *key,
 				  size_t n_bits)
@@ -38,9 +42,17 @@ static struct tlpm_node *tlpm_add(struct tlpm_node *list,
 	struct tlpm_node *node;
 	size_t n;
 
+	n = (n_bits + 7) / 8;
+
+	/* 'overwrite' an equivalent entry if one already exists */
+	node = tlpm_match(list, key, n_bits);
+	if (node && node->n_bits == n_bits) {
+		memcpy(node->key, key, n);
+		return list;
+	}
+
 	/* add new entry with @key/@n_bits to @list and return new head */
 
-	n = (n_bits + 7) / 8;
 	node = malloc(sizeof(*node) + n);
 	assert(node);
 
-- 
2.14.1.690.gbb1197296e-goog
