From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH v3 5/5] bpf: save the program the user actually supplied
Date: Wed, 30 Sep 2015 12:13:40 -0600
Message-ID: <1443636820-17083-6-git-send-email-tycho.andersen@canonical.com>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Cc: Will Drewry <wad@chromium.org>, Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>
To: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37829 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933305AbbI3SOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:14:39 -0400
Received: by igbni9 with SMTP id ni9so37160442igb.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:14:38 -0700 (PDT)
In-Reply-To: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases (e.g. seccomp) the program result might be translated from
the original program the user supplied. If we're saving the result for
checkpoint/restore, we should save exactly the program the user initially
supplied.

This causes problems when the translations seccomp makes are not allowed by
bpf_check_classic.

Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
CC: Kees Cook <keescook@chromium.org>
CC: Will Drewry <wad@chromium.org>
CC: Oleg Nesterov <oleg@redhat.com>
CC: Andy Lutomirski <luto@amacapital.net>
CC: Pavel Emelyanov <xemul@parallels.com>
CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/filter.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 70995dd..5a4596b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -845,8 +845,7 @@ int bpf_prog_store_orig_filter(struct bpf_prog *fp,
 	fkprog = fp->orig_prog;
 	fkprog->len = fprog->len;
 
-	fkprog->filter = kmemdup(fp->insns, fsize,
-				 GFP_KERNEL | __GFP_NOWARN);
+	fkprog->filter = memdup_user(fprog->filter, fsize);
 	if (!fkprog->filter) {
 		kfree(fp->orig_prog);
 		return -ENOMEM;
-- 
2.5.0
