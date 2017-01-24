From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/5] bpf: simplify __is_valid_access test on cb
Date: Tue, 24 Jan 2017 01:06:26 +0100
Message-ID: <9a3c5aeadcc2491e98ebe2353bfb9adf16ef678e.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44964 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751924AbdAXAGv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:06:51 -0500
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
In-Reply-To: <cover.1485214851.git.daniel@iogearbox.net>
References: <cover.1485214851.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The __is_valid_access() test for cb[] from 62c7989b24db ("bpf: allow
b/h/w/dw access for bpf's cb in ctx") was done unnecessarily complex,
we can just simplify it the same way as recent fix from 2d071c643f1c
("bpf, trace: make ctx access checks more robust") did. Overflow can
never happen as size is 1/2/4/8 depending on access.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 9038386..883975f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2784,19 +2784,8 @@ static bool __is_valid_access(int off, int size)
 	switch (off) {
 	case offsetof(struct __sk_buff, cb[0]) ...
 	     offsetof(struct __sk_buff, cb[4]) + sizeof(__u32) - 1:
-		if (size == sizeof(__u16) &&
-		    off > offsetof(struct __sk_buff, cb[4]) + sizeof(__u16))
-			return false;
-		if (size == sizeof(__u32) &&
-		    off > offsetof(struct __sk_buff, cb[4]))
-			return false;
-		if (size == sizeof(__u64) &&
-		    off > offsetof(struct __sk_buff, cb[2]))
-			return false;
-		if (size != sizeof(__u8)  &&
-		    size != sizeof(__u16) &&
-		    size != sizeof(__u32) &&
-		    size != sizeof(__u64))
+		if (off + size >
+		    offsetof(struct __sk_buff, cb[4]) + sizeof(__u32))
 			return false;
 		break;
 	default:
-- 
1.9.3
