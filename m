From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/2] bpf_exp: free duplicated labels at exit time
Date: Mon, 16 Dec 2013 11:45:01 +0100
Message-ID: <1387190701-1893-3-git-send-email-dborkman@redhat.com>
References: <1387190701-1893-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190Ab3LPKpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 05:45:11 -0500
In-Reply-To: <1387190701-1893-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valgrind found that extracted labels that are passed from the lexer
weren't freed upon exit. Therefore, add a small helper function that
walks label tables and frees them. Since also NULL can be passed to
free(3), we do not need to take care of that here. While at it, fix
up a spacing error in bpf_set_curr_label().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 tools/net/bpf_exp.y | 27 ++++++++++++++++++++-------
 1 file changed, 20 insertions(+), 7 deletions(-)

diff --git a/tools/net/bpf_exp.y b/tools/net/bpf_exp.y
index f524110..d15efc9 100644
--- a/tools/net/bpf_exp.y
+++ b/tools/net/bpf_exp.y
@@ -40,8 +40,8 @@ extern void yyerror(const char *str);
 
 extern void bpf_asm_compile(FILE *fp, bool cstyle);
 static void bpf_set_curr_instr(uint16_t op, uint8_t jt, uint8_t jf, uint32_t k);
-static void bpf_set_curr_label(const char *label);
-static void bpf_set_jmp_label(const char *label, enum jmp_type type);
+static void bpf_set_curr_label(char *label);
+static void bpf_set_jmp_label(char *label, enum jmp_type type);
 
 %}
 
@@ -573,7 +573,7 @@ txa
 
 static int curr_instr = 0;
 static struct sock_filter out[BPF_MAXINSNS];
-static const char **labels, **labels_jt, **labels_jf, **labels_k;
+static char **labels, **labels_jt, **labels_jf, **labels_k;
 
 static void bpf_assert_max(void)
 {
@@ -594,13 +594,13 @@ static void bpf_set_curr_instr(uint16_t code, uint8_t jt, uint8_t jf,
 	curr_instr++;
 }
 
-static void bpf_set_curr_label(const char *label)
+static void bpf_set_curr_label(char *label)
 {
 	bpf_assert_max();
-        labels[curr_instr] = label;
+	labels[curr_instr] = label;
 }
 
-static void bpf_set_jmp_label(const char *label, enum jmp_type type)
+static void bpf_set_jmp_label(char *label, enum jmp_type type)
 {
 	bpf_assert_max();
 	switch (type) {
@@ -717,12 +717,25 @@ static void bpf_init(void)
 	assert(labels_k);
 }
 
+static void bpf_destroy_labels(void)
+{
+	int i;
+
+	for (i = 0; i < curr_instr; i++) {
+		free(labels_jf[i]);
+		free(labels_jt[i]);
+		free(labels_k[i]);
+		free(labels[i]);
+	}
+}
+
 static void bpf_destroy(void)
 {
-	free(labels);
+	bpf_destroy_labels();
 	free(labels_jt);
 	free(labels_jf);
 	free(labels_k);
+	free(labels);
 }
 
 void bpf_asm_compile(FILE *fp, bool cstyle)
-- 
1.8.3.1
