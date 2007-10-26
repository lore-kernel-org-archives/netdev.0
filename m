From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] net: Saner thash_entries default with much memory
Date: Fri, 26 Oct 2007 17:21:31 +0200
Message-ID: <200710261721.32019.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45056 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747AbXJZPSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 11:18:47 -0400
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 6E70A22D7D
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 17:18:46 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On systems with a very large amount of memory, the heuristics in
alloc_large_system_hash() result in a very large TCP established hash
table: 16 millions of entries for a 128 GB ia64 system. This makes
reading from /proc/net/tcp pretty slow (well over a second) and as a
result netstat is slow on these machines. I know that /proc/net/tcp is
deprecated in favor of tcp_diag, however at the moment netstat only
knows of the former.

I am skeptical that such a large TCP established hash is often needed.
Just because a system has a lot of memory doesn't imply that it will
have several millions of concurrent TCP connections. Thus I believe
that we should put an arbitrary high limit to the size of the TCP
established hash by default. Users who really need a bigger hash can
always use the thash_entries boot parameter to get more.

I propose 2 millions of entries as the arbitrary high limit. This
makes /proc/net/tcp reasonably fast on the system in question (0.2 s)
while being still large enough for me to be confident that network
performance won't suffer.

This is just one way to limit the hash size, there are others; I am not
familiar enough with the TCP code to decide which is best. Thus, I
would welcome the proposals of alternatives.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
---
 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.24-rc1.orig/net/ipv4/tcp.c	2007-10-24 09:59:58.000000000 +0200
+++ linux-2.6.24-rc1/net/ipv4/tcp.c	2007-10-26 16:26:41.000000000 +0200
@@ -2453,7 +2453,7 @@ void __init tcp_init(void)
 					0,
 					&tcp_hashinfo.ehash_size,
 					NULL,
-					0);
+					thash_entries ? 0 : 2 * 1024 * 1024);
 	tcp_hashinfo.ehash_size = 1 << tcp_hashinfo.ehash_size;
 	for (i = 0; i < tcp_hashinfo.ehash_size; i++) {
 		rwlock_init(&tcp_hashinfo.ehash[i].lock);

-- 
Jean Delvare
Suse L3
