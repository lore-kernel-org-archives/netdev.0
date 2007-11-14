From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : rt_check_expire() can take a long time, add a cond_resched()
Date: Wed, 14 Nov 2007 22:34:13 +0100
Message-ID: <473B69D5.2050805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050403000608020803030007"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35342 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755389AbXKNVe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 16:34:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050403000608020803030007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On commit 39c90ece7565f5c47110c2fa77409d7a9478bd5b we converted 
rt_check_expire() from softirq to workqueue, allowing the function to perform 
all work it was supposed to do.

When the IP route cache is big, rt_check_expire() can take a long time to run.
(default settings : 20% of the hash table is scanned at each invocation)

Adding cond_resched() helps giving cpu to higher priority tasks if necessary.

Using a "if (need_resched())" test before calling "cond_resched();" is 
necessary to avoid spending too much time doing the resched check.
(My tests gave a time reduction from 88 ms to 25 ms per rt_check_expire() run 
on my i686 test machine)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------050403000608020803030007
Content-Type: text/plain;
 name="rt_check_expire_resched.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rt_check_expire_resched.patch"

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a9471b7..f0b28f9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -580,6 +580,9 @@ static void rt_check_expire(struct work_struct *work)
 		i = (i + 1) & rt_hash_mask;
 		rthp = &rt_hash_table[i].chain;
 
+		if (need_resched())
+			cond_resched();
+
 		if (*rthp == NULL)
 			continue;
 		spin_lock_bh(rt_hash_lock_addr(i));

--------------050403000608020803030007--
