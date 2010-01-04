From: Guenter Roeck <guenter.roeck@ericsson.com>
Subject: [RFC] [PATCH] Improve hash function used for full_name_hash()
Date: Mon, 04 Jan 2010 12:09:44 -0800
Message-ID: <1262635784.8178.253.camel@groeck-laptop>
Reply-To: guenter.roeck@ericsson.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgate.redback.com ([155.53.3.41]:39917 "EHLO mgate.redback.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752193Ab0ADUSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 15:18:05 -0500
Received: from localhost (localhost [127.0.0.1])
	by prattle.redback.com (Postfix) with ESMTP id 34B3410EAA29
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2010 12:08:08 -0800 (PST)
Received: from prattle.redback.com ([127.0.0.1])
 by localhost (prattle [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 18889-02 for <netdev@vger.kernel.org>;
 Mon,  4 Jan 2010 12:08:08 -0800 (PST)
Received: from [155.53.128.165] (unknown [155.53.128.165])
	by prattle.redback.com (Postfix) with ESMTP id 2422410EAA28
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2010 12:08:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please comment on this proposed patch. It is similar but more generic than 
a previously proposed change to dev_name_hash() which tried to address 
the same problem.

The hash function currently used for full_name_hash() produces a large number
of collisions if hashed names are similar. This can cause performance problems
if a large number of similar names exist in the kernel (e.g., if there is
a large number of virtual interfaces).

For example, when hashing "eth0" .. "eth9999" with a hash table size of 256,
the resulting minimum hash bucket depth is 0, the maximum depth is 563,
and the standard deviation is ~136.

With this patch applied, the same test results in a minimum bucket depth
of 37, a maximum bucket depth of 42, and a standard deviation of ~1.02.

The hash factor of 41 was chosen for the following reasons:
- The resulting standard deviation is significantly better than the standard
  deviation of the original hash function for all tested hash table sizes
  (2^x, x=4..16).
- The hash function is simple.
- The resulting code does not require a multiply instruction
  (tested: x86, mips, powerpc).
- The resulting code is more efficient than the code generated for the
  original hash (x86, gcc -O2: 3 instead of 7 instructions).
- The resulting code also works well with more random strings
  (tested with all file names in a given Linux system).

Signed-off-by: Guenter Roeck <guenter.roeck@ericsson.com>
---
 include/linux/dcache.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 30b93b2..772755d 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -53,7 +53,7 @@ extern struct dentry_stat_t dentry_stat;
 static inline unsigned long
 partial_name_hash(unsigned long c, unsigned long prevhash)
 {
-	return (prevhash + (c << 4) + (c >> 4)) * 11;
+	return (prevhash + c) * 41;
 }
 
 /*

