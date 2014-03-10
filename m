From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net] x86: bpf_jit: support negative offsets
Date: Mon, 10 Mar 2014 15:56:51 -0700
Message-ID: <1394492211-4268-1-git-send-email-ast@plumgrid.com>
Cc: Jan Seiffert <kaffeemonster@googlemail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:51556 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678AbaCJW44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 18:56:56 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so7906306pbc.34
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 15:56:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a998d4342337 claimed to introduce negative offset support to x86 jit,
but it couldn't be working, since at the time of the execution
of LD+ABS or LD+IND instructions via call into
bpf_internal_load_pointer_neg_helper() the %edx (3rd argument of this func)
had junk value instead of access size in bytes (1 or 2 or 4).

Store size into %edx instead of %ecx (what original commit intended to do)

Fixes: a998d4342337 ("bpf jit: Let the x86 jit handle negative offsets")
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jan Seiffert <kaffeemonster@googlemail.com>
Cc: Eric Dumazet <edumazet@google.com>
--
This is a single bit patch. Is there a leaderboard of shortest patches? ;)

 arch/x86/net/bpf_jit.S |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
index 877b9a1..0149575 100644
--- a/arch/x86/net/bpf_jit.S
+++ b/arch/x86/net/bpf_jit.S
@@ -140,7 +140,7 @@ bpf_slow_path_byte_msh:
 	push	%r9;						\
 	push	SKBDATA;					\
 /* rsi already has offset */					\
-	mov	$SIZE,%ecx;	/* size */			\
+	mov	$SIZE,%edx;	/* size */			\
 	call	bpf_internal_load_pointer_neg_helper;		\
 	test	%rax,%rax;					\
 	pop	SKBDATA;					\
-- 
1.7.9.5
