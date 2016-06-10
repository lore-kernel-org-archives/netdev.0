From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: reject wrong sized filters earlier
Date: Fri, 10 Jun 2016 21:19:07 +0200
Message-ID: <7653ebf6ed9002d60f61eeab66303a577e45226f.1465578089.git.daniel@iogearbox.net>
References: <cover.1465578089.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52773 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776AbcFJTTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 15:19:13 -0400
In-Reply-To: <cover.1465578089.git.daniel@iogearbox.net>
In-Reply-To: <cover.1465578089.git.daniel@iogearbox.net>
References: <cover.1465578089.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a bpf_check_basics_ok() and reject filters that are of invalid
size much earlier, so we don't do any useless work such as invoking
bpf_prog_alloc(). Currently, rejection happens in bpf_check_classic()
only, but it's really unnecessarily late and they should be rejected
at earliest point. While at it, also clean up one bpf_prog_size() to
make it consistent with the remaining invocations.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index d11744d..df6860c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -748,6 +748,17 @@ static bool chk_code_allowed(u16 code_to_probe)
 	return codes[code_to_probe];
 }
 
+static bool bpf_check_basics_ok(const struct sock_filter *filter,
+				unsigned int flen)
+{
+	if (filter == NULL)
+		return false;
+	if (flen == 0 || flen > BPF_MAXINSNS)
+		return false;
+
+	return true;
+}
+
 /**
  *	bpf_check_classic - verify socket filter code
  *	@filter: filter to verify
@@ -768,9 +779,6 @@ static int bpf_check_classic(const struct sock_filter *filter,
 	bool anc_found;
 	int pc;
 
-	if (flen == 0 || flen > BPF_MAXINSNS)
-		return -EINVAL;
-
 	/* Check the filter code now */
 	for (pc = 0; pc < flen; pc++) {
 		const struct sock_filter *ftest = &filter[pc];
@@ -1065,7 +1073,7 @@ int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog)
 	struct bpf_prog *fp;
 
 	/* Make sure new filter is there and in the right amounts. */
-	if (fprog->filter == NULL)
+	if (!bpf_check_basics_ok(fprog->filter, fprog->len))
 		return -EINVAL;
 
 	fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
@@ -1112,7 +1120,7 @@ int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
 	int err;
 
 	/* Make sure new filter is there and in the right amounts. */
-	if (fprog->filter == NULL)
+	if (!bpf_check_basics_ok(fprog->filter, fprog->len))
 		return -EINVAL;
 
 	fp = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
@@ -1207,7 +1215,6 @@ static
 struct bpf_prog *__get_filter(struct sock_fprog *fprog, struct sock *sk)
 {
 	unsigned int fsize = bpf_classic_proglen(fprog);
-	unsigned int bpf_fsize = bpf_prog_size(fprog->len);
 	struct bpf_prog *prog;
 	int err;
 
@@ -1215,10 +1222,10 @@ struct bpf_prog *__get_filter(struct sock_fprog *fprog, struct sock *sk)
 		return ERR_PTR(-EPERM);
 
 	/* Make sure new filter is there and in the right amounts. */
-	if (fprog->filter == NULL)
+	if (!bpf_check_basics_ok(fprog->filter, fprog->len))
 		return ERR_PTR(-EINVAL);
 
-	prog = bpf_prog_alloc(bpf_fsize, 0);
+	prog = bpf_prog_alloc(bpf_prog_size(fprog->len), 0);
 	if (!prog)
 		return ERR_PTR(-ENOMEM);
 
-- 
1.9.3
