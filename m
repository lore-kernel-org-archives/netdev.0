From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net] ipv6: Fix mem leak in rt6i_pcpu
Date: Tue, 5 Jul 2016 12:10:23 -0700
Message-ID: <1467745823-1402823-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Petr Novopashenniy <pety@rusnet.ru>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:4082 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751805AbcGETK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 15:10:27 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65J7L3J028509
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2016 12:10:26 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 240jkxg341-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 12:10:26 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 2062486242e411e6ba1f24be0595f910-3ebe7af0 for <netdev@vger.kernel.org>;	Tue,
 05 Jul 2016 12:10:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was first reported and reproduced by Petr (thanks!) in
https://bugzilla.kernel.org/show_bug.cgi?id=119581

free_percpu(rt->rt6i_pcpu) used to always happen in ip6_dst_destroy().

However, after fixing a deadlock bug in
commit 9c7370a166b4 ("ipv6: Fix a potential deadlock when creating pcpu rt"),
free_percpu() is not called before setting non_pcpu_rt->rt6i_pcpu to NULL.

It is worth to note that rt6i_pcpu is protected by table->tb6_lock.

kmemleak somehow did not report it.  We nailed it down by
observing the pcpu entries in /proc/vmallocinfo (first suggested
by Hannes, thanks!).

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Fixes: 9c7370a166b4 ("ipv6: Fix a potential deadlock when creating pcpu rt")
Reported-by: Petr Novopashenniy <pety@rusnet.ru>
Tested-by: Petr Novopashenniy <pety@rusnet.ru>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Petr Novopashenniy <pety@rusnet.ru>
---
 net/ipv6/ip6_fib.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 1bcef23..771be1f 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -177,6 +177,7 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 		}
 	}
 
+	free_percpu(non_pcpu_rt->rt6i_pcpu);
 	non_pcpu_rt->rt6i_pcpu = NULL;
 }
 
-- 
2.5.1
