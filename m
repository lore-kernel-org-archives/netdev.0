From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH iproute2 net-next] bpf: Fix number of retries when growing log buffer
Date: Wed,  7 Dec 2016 10:47:59 +0100
Message-ID: <fc3866340db64ff7400c14342578b9a104f02fe9.1481103964.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47107 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbcLGJsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 04:48:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The log buffer is automatically grown when the verifier output does not
fit into the default buffer size. The number of growing attempts was
not sufficient to reach the maximum buffer size so far.

Perform 9 iterations to reach max and let the 10th one fail.

j:0     i:65536         max:16777215
j:1     i:131072        max:16777215
j:2     i:262144        max:16777215
j:3     i:524288        max:16777215
j:4     i:1048576       max:16777215
j:5     i:2097152       max:16777215
j:6     i:4194304       max:16777215
j:7     i:8388608       max:16777215
j:8     i:16777216      max:16777215

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/bpf.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/lib/bpf.c b/lib/bpf.c
index 8a5b84b..f3dace2 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -912,15 +912,18 @@ bpf_dump_error(struct bpf_elf_ctx *ctx, const char *format, ...)
 
 static int bpf_log_realloc(struct bpf_elf_ctx *ctx)
 {
+	const size_t log_max = UINT_MAX >> 8;
 	size_t log_size = ctx->log_size;
 	void *ptr;
 
 	if (!ctx->log) {
 		log_size = 65536;
-	} else {
+	} else if (log_size < log_max) {
 		log_size <<= 1;
-		if (log_size > (UINT_MAX >> 8))
-			return -EINVAL;
+		if (log_size > log_max)
+			log_size = log_max;
+	} else {
+		return -EINVAL;
 	}
 
 	ptr = realloc(ctx->log, log_size);
@@ -1259,7 +1262,7 @@ retry:
 		 * log for the user, so enlarge it and re-fail.
 		 */
 		if (fd < 0 && (errno == ENOSPC || !ctx->log_size)) {
-			if (tries++ < 6 && !bpf_log_realloc(ctx))
+			if (tries++ < 10 && !bpf_log_realloc(ctx))
 				goto retry;
 
 			fprintf(stderr, "Log buffer too small to dump verifier log %zu bytes (%d tries)!\n",
-- 
2.7.4
