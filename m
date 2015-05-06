From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/4] net: filter: add __GFP_NOWARN flag for larger kmem allocs
Date: Wed,  6 May 2015 16:12:29 +0200
Message-ID: <0ea8655bc24a1ea3da6da66adcb2410aebc55db6.1430908146.git.daniel@iogearbox.net>
References: <cover.1430908145.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, keescook@chromium.org, nschichan@freebox.fr,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59844 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbbEFOMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 10:12:42 -0400
In-Reply-To: <cover.1430908145.git.daniel@iogearbox.net>
In-Reply-To: <cover.1430908145.git.daniel@iogearbox.net>
References: <cover.1430908145.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When seccomp BPF was added, it was discussed to add __GFP_NOWARN
flag for their configuration path as f.e. up to 32K allocations are
more prone to fail under stress. As we're going to reuse BPF API,
add __GFP_NOWARN flags where larger kmalloc() and friends allocations
could fail.

It doesn't make much sense to pass around __GFP_NOWARN everywhere as
an extra argument only for seccomp while we just as well could run
into similar issues for socket filters, where it's not desired to
have a user application throw a WARN() due to allocation failure.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Nicolas Schichan <nschichan@freebox.fr>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Kees Cook <keescook@chromium.org>
---
 net/core/filter.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index f887084..45c015d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -371,7 +371,8 @@ static int bpf_convert_filter(struct sock_filter *prog, int len,
 		return -EINVAL;
 
 	if (new_prog) {
-		addrs = kcalloc(len, sizeof(*addrs), GFP_KERNEL);
+		addrs = kcalloc(len, sizeof(*addrs),
+				GFP_KERNEL | __GFP_NOWARN);
 		if (!addrs)
 			return -ENOMEM;
 	}
@@ -839,7 +840,9 @@ static int bpf_prog_store_orig_filter(struct bpf_prog *fp,
 
 	fkprog = fp->orig_prog;
 	fkprog->len = fprog->len;
-	fkprog->filter = kmemdup(fp->insns, fsize, GFP_KERNEL);
+
+	fkprog->filter = kmemdup(fp->insns, fsize,
+				 GFP_KERNEL | __GFP_NOWARN);
 	if (!fkprog->filter) {
 		kfree(fp->orig_prog);
 		return -ENOMEM;
@@ -941,7 +944,7 @@ static struct bpf_prog *bpf_migrate_filter(struct bpf_prog *fp)
 	 * pass. At this time, the user BPF is stored in fp->insns.
 	 */
 	old_prog = kmemdup(fp->insns, old_len * sizeof(struct sock_filter),
-			   GFP_KERNEL);
+			   GFP_KERNEL | __GFP_NOWARN);
 	if (!old_prog) {
 		err = -ENOMEM;
 		goto out_err;
-- 
1.9.3
