From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/4] net: filter: add test for loading SKF_AD_OFF limits
Date: Thu, 29 May 2014 10:22:49 +0200
Message-ID: <1401351771-5367-3-git-send-email-dborkman@redhat.com>
References: <1401351771-5367-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932508AbaE2IW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 04:22:59 -0400
In-Reply-To: <1401351771-5367-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This check tests that overloading BPF_LD | BPF_ABS with an
always invalid BPF extension, that is SKF_AD_MAX, fails to
make sure classic BPF behaviour is correct in filter checker.

Also, we add a test for loading at packet offset SKF_AD_OFF-1
which should pass the filter, but later on fail during runtime.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 lib/test_bpf.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 2d0a0d1..f8d2b2a 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1655,6 +1655,28 @@ static struct bpf_test tests[] = {
 		{ },
 		{ { 0, 0x2a5a5e5 } },
 	},
+	{
+		"check: SKF_AD_MAX",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
+				 SKF_AD_OFF + SKF_AD_MAX),
+			BPF_STMT(BPF_RET | BPF_A, 0),
+		},
+		CLASSIC | FLAG_NO_DATA | FLAG_EXPECTED_FAIL,
+		{ },
+		{ },
+	},
+	{	/* Passes checker but fails during runtime. */
+		"LD [SKF_AD_OFF-1]",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
+				 SKF_AD_OFF - 1),
+			BPF_STMT(BPF_RET | BPF_K, 1),
+		},
+		CLASSIC,
+		{ },
+		{ { 1, 0 } },
+	},
 };
 
 static struct net_device dev;
-- 
1.7.11.7
