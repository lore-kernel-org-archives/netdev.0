From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] bpf: Need to call bpf_prog_uncharge_memlock from bpf_prog_put
Date: Wed, 14 Oct 2015 14:40:44 -0700
Message-ID: <1444858844-883196-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>, <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:30983 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753811AbbJNVku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 17:40:50 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id t9ELe8nb025645
	for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 14:40:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1xg665haya-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 14:40:49 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 3ba4ebfa72bc11e5922f0002c99293a0-7f5bd6b0 for <netdev@vger.kernel.org>;	Wed,
 14 Oct 2015 14:40:48 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, is only called from __prog_put_rcu in the bpf_prog_release
path. Need this to call this from bpf_prog_put also to get correct
accounting.

Fixes: commit aaac3ba95e4c8b49 ("bpf: charge user for creation of BPF maps and programs")
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 kernel/bpf/syscall.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index f640e5f..687dd6c 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -520,6 +520,7 @@ void bpf_prog_put(struct bpf_prog *prog)
 {
 	if (atomic_dec_and_test(&prog->aux->refcnt)) {
 		free_used_maps(prog->aux);
+		bpf_prog_uncharge_memlock(prog);
 		bpf_prog_free(prog);
 	}
 }
-- 
2.4.6
