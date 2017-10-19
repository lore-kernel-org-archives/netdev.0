From: John Fastabend <john.r.fastabend@gmail.com>
Subject: [net PATCH] bpf: devmap fix arithmetic overflow in bitmap_size
 calculation
Date: Thu, 19 Oct 2017 09:03:52 -0700
Message-ID: <150842903200.12537.10765604428561566031.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net
To: richard@nod.at, alexei.starovoitov@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:54743 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752579AbdJSQEQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 12:04:16 -0400
Received: by mail-pf0-f193.google.com with SMTP id n89so6878140pfk.11
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 09:04:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An integer overflow is possible in dev_map_bitmap_size() when
calculating the BITS_TO_LONG logic which becomes, after macro
replacement,

	(((n) + (d) - 1)/ (d))

where 'n' is a __u32 and 'd' is (8 * sizeof(long)). To avoid
overflow cast to u64 before arithmetic.

Reported-by: Richard Weinberger <richard@nod.at>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 kernel/bpf/devmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index 7d9f32f..6d3ec97 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -69,7 +69,7 @@ static LIST_HEAD(dev_map_list);
 
 static u64 dev_map_bitmap_size(const union bpf_attr *attr)
 {
-	return BITS_TO_LONGS(attr->max_entries) * sizeof(unsigned long);
+	return BITS_TO_LONGS((u64) attr->max_entries) * sizeof(unsigned long);
 }
 
 static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
