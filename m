From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] bpf_dbg: always close socket in bpf_runnable
Date: Mon, 16 Dec 2013 11:45:00 +0100
Message-ID: <1387190701-1893-2-git-send-email-dborkman@redhat.com>
References: <1387190701-1893-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752350Ab3LPKpK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 05:45:10 -0500
In-Reply-To: <1387190701-1893-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must not leave the socket intact in bpf_runnable(). The socket
is used to test if the filter code is being accepted by the kernel
or not. So right after we do the setsockopt(2), we need to close
it again.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 tools/net/bpf_dbg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
index 0fdcb70..65dc757 100644
--- a/tools/net/bpf_dbg.c
+++ b/tools/net/bpf_dbg.c
@@ -512,11 +512,11 @@ static bool bpf_runnable(struct sock_filter *f, unsigned int len)
 		return false;
 	}
 	ret = setsockopt(sock, SOL_SOCKET, SO_ATTACH_FILTER, &bpf, sizeof(bpf));
+	close(sock);
 	if (ret < 0) {
 		rl_printf("program not allowed to run by kernel!\n");
 		return false;
 	}
-	close(sock);
 	for (i = 0; i < len; i++) {
 		if (BPF_CLASS(f[i].code) == BPF_LD &&
 		    f[i].k > SKF_AD_OFF) {
-- 
1.8.3.1
