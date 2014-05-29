From: Chema Gonzalez <chema@google.com>
Subject: [PATCH v1 net-next] net: filter: fix length calculation in BPF testsuite
Date: Thu, 29 May 2014 12:29:17 -0700
Message-ID: <1401391757-27620-1-git-send-email-chema@google.com>
Cc: netdev@vger.kernel.org, Chema Gonzalez <chema@google.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:60370 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932109AbaE2T3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 15:29:19 -0400
Received: by mail-ob0-f201.google.com with SMTP id wn1so168753obc.2
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 12:29:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current probe_filter_length() (the function that calculates the
length of a test BPF filter) behavior is to declare the end of the
filter as soon as it finds {0, *, *, 0}. This is actually a valid
insn ("ld #0"), so any filter with includes "BPF_STMT(BPF_LD | BPF_IMM, 0)"
fails (its length is cut short).

We are changing probe_filter_length() so as to start from the end, and
declare the end of the filter as the first instruction which is not
{0, *, *, 0}. This solution produces a simpler patch than the
alternative of using an explicit end-of-filter mark. It is technically
incorrect if your filter ends up with "ld #0", but that should not
happen anyway.

We also add a new test (LD_IMM_0) that includes ld #0 (does not work
without this patch).

Signed-off-by: Chema Gonzalez <chema@google.com>
---
 lib/test_bpf.c | 21 ++++++++++++++++-----
 1 file changed, 16 insertions(+), 5 deletions(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index af677cb..e893e3b 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -158,6 +158,18 @@ static struct bpf_test tests[] = {
 		{ { 0, 0x800000ff }, { 1, 0x800000ff } },
 	},
 	{
+		"LD_IMM_0",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_IMM, 0), /* ld #0 */
+			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 0, 1, 0),
+			BPF_STMT(BPF_RET | BPF_K, 0),
+			BPF_STMT(BPF_RET | BPF_K, 1),
+		},
+		CLASSIC,
+		{ },
+		{ { 1, 1 } },
+	},
+	{
 		"LD_IND",
 		.u.insns = {
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
@@ -1542,12 +1554,11 @@ static int probe_filter_length(struct sock_filter *fp)
 {
 	int len = 0;
 
-	while (fp->code != 0 || fp->k != 0) {
-		fp++;
-		len++;
-	}
+	for (len = MAX_INSNS-1; len > 0; --len)
+		if (fp[len].code != 0 || fp[len].k != 0)
+			break;
 
-	return len;
+	return len+1;
 }
 
 static struct sk_filter *generate_filter(int which, int *err)
-- 
1.9.1.423.g4596e3a
