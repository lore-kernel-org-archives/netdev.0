From: chas williams <3chas3@gmail.com>
Subject: [RFC] net: ipv6: hold locks around mrt->mfc6_cache_array[]
Date: Mon, 06 Apr 2015 19:18:50 -0400
Message-ID: <1428362330.1872.9.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-7"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33354 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752673AbbDFXSx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 19:18:53 -0400
Received: by qkx62 with SMTP id 62so34629785qkx.0
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 16:18:52 -0700 (PDT)
Received: from foobar (pool-71-163-182-203.washdc.fios.verizon.net. [71.163.182.203])
        by mx.google.com with ESMTPSA id m68sm4257653qge.15.2015.04.06.16.18.51
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Apr 2015 16:18:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears to me that the locking of the mfc6+AF8-cache+AF8-array is a little
bit broken.  The list heads in this array appear be mainly protected
by the rtnl in most cases but there are a few were this isn't the case.
Regardless, based on the comments at the head of the code, that probably
wasn't the author's intent:

	/+ACo We return to original Alan's scheme. Hash table of resolved
	   entries is changed only in process context and protected
	   with weak lock mrt+AF8-lock. Queue of unresolved entries is protected
	   with strong spinlock mfc+AF8-unres+AF8-lock.

	   In this case data path is free of exclusive locks at all.
	 +ACo-/

setsocketopt() -+AD4 ip6mr+AF8-mfc+AF8-add() -+AD4 ip6mr+AF8-cache+AF8-resolved() -+AD4 ip6+AF8-mr+AF8-foward()
needs some lock since it is going to read the cache array.

ipm4+AF8-mfc+AF8-add() probably should hold the write lock to prevent races when
adding entries.

mroute+AF8-clean+AF8-tables() should also probably hold the write lock across
the entire iteration, otherwise readers have a small chance to get a
reference while the entry is being removed.

Comments?


diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f9a3fd3..1210f5c 100644
--- a/net/ipv6/ip6mr.c
+-+-+- b/net/ipv6/ip6mr.c
+AEAAQA -1306,12 +-1306,12 +AEAAQA static int ip6mr+AF8-mfc+AF8-delete(struct mr6+AF8-table +ACo-mrt, struct mf6cctl +ACo-mfc,
 
 	line +AD0 MFC6+AF8-HASH(+ACY-mfc-+AD4-mf6cc+AF8-mcastgrp.sin6+AF8-addr, +ACY-mfc-+AD4-mf6cc+AF8-origin.sin6+AF8-addr)+ADs
 
+-	write+AF8-lock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 	list+AF8-for+AF8-each+AF8-entry+AF8-safe(c, next, +ACY-mrt-+AD4-mfc6+AF8-cache+AF8-array+AFs-line+AF0, list) +AHs
 		if (ipv6+AF8-addr+AF8-equal(+ACY-c-+AD4-mf6c+AF8-origin, +ACY-mfc-+AD4-mf6cc+AF8-origin.sin6+AF8-addr) +ACYAJg
 		    ipv6+AF8-addr+AF8-equal(+ACY-c-+AD4-mf6c+AF8-mcastgrp,
 				    +ACY-mfc-+AD4-mf6cc+AF8-mcastgrp.sin6+AF8-addr) +ACYAJg
 		    (parent +AD0APQ -1 +AHwAfA parent +AD0APQ c-+AD4-mf6c+AF8-parent)) +AHs
-			write+AF8-lock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 			list+AF8-del(+ACY-c-+AD4-list)+ADs
 			write+AF8-unlock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 
+AEAAQA -1320,6 +-1320,7 +AEAAQA static int ip6mr+AF8-mfc+AF8-delete(struct mr6+AF8-table +ACo-mrt, struct mf6cctl +ACo-mfc,
 			return 0+ADs
 		+AH0
 	+AH0
+-	write+AF8-unlock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 	return -ENOENT+ADs
 +AH0
 
+AEAAQA -1465,6 +-1466,7 +AEAAQA static int ip6mr+AF8-mfc+AF8-add(struct net +ACo-net, struct mr6+AF8-table +ACo-mrt,
 
 	line +AD0 MFC6+AF8-HASH(+ACY-mfc-+AD4-mf6cc+AF8-mcastgrp.sin6+AF8-addr, +ACY-mfc-+AD4-mf6cc+AF8-origin.sin6+AF8-addr)+ADs
 
+-	write+AF8-lock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 	list+AF8-for+AF8-each+AF8-entry(c, +ACY-mrt-+AD4-mfc6+AF8-cache+AF8-array+AFs-line+AF0, list) +AHs
 		if (ipv6+AF8-addr+AF8-equal(+ACY-c-+AD4-mf6c+AF8-origin, +ACY-mfc-+AD4-mf6cc+AF8-origin.sin6+AF8-addr) +ACYAJg
 		    ipv6+AF8-addr+AF8-equal(+ACY-c-+AD4-mf6c+AF8-mcastgrp,
+AEAAQA -1476,7 +-1478,6 +AEAAQA static int ip6mr+AF8-mfc+AF8-add(struct net +ACo-net, struct mr6+AF8-table +ACo-mrt,
 	+AH0
 
 	if (found) +AHs
-		write+AF8-lock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 		c-+AD4-mf6c+AF8-parent +AD0 mfc-+AD4-mf6cc+AF8-parent+ADs
 		ip6mr+AF8-update+AF8-thresholds(mrt, c, ttls)+ADs
 		if (+ACE-mrtsock)
+AEAAQA -1501,7 +-1502,6 +AEAAQA static int ip6mr+AF8-mfc+AF8-add(struct net +ACo-net, struct mr6+AF8-table +ACo-mrt,
 	if (+ACE-mrtsock)
 		c-+AD4-mfc+AF8-flags +AHwAPQ MFC+AF8-STATIC+ADs
 
-	write+AF8-lock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 	list+AF8-add(+ACY-c-+AD4-list, +ACY-mrt-+AD4-mfc6+AF8-cache+AF8-array+AFs-line+AF0)+ADs
 	write+AF8-unlock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 
+AEAAQA -1525,8 +-1525,10 +AEAAQA static int ip6mr+AF8-mfc+AF8-add(struct net +ACo-net, struct mr6+AF8-table +ACo-mrt,
 	spin+AF8-unlock+AF8-bh(+ACY-mfc+AF8-unres+AF8-lock)+ADs
 
 	if (found) +AHs
+-		read+AF8-lock(+ACY-mrt+AF8-lock)+ADs
 		ip6mr+AF8-cache+AF8-resolve(net, mrt, uc, c)+ADs
 		ip6mr+AF8-cache+AF8-free(uc)+ADs
+-		read+AF8-unlock(+ACY-mrt+AF8-lock)+ADs
 	+AH0
 	mr6+AF8-netlink+AF8-event(mrt, c, RTM+AF8-NEWROUTE)+ADs
 	return 0+ADs
+AEAAQA -1554,18 +-1556,18 +AEAAQA static void mroute+AF8-clean+AF8-tables(struct mr6+AF8-table +ACo-mrt)
 	/+ACo
 	 +ACo	Wipe the cache
 	 +ACo-/
+-	write+AF8-lock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 	for (i +AD0 0+ADs i +ADw MFC6+AF8-LINES+ADs i+-+-) +AHs
 		list+AF8-for+AF8-each+AF8-entry+AF8-safe(c, next, +ACY-mrt-+AD4-mfc6+AF8-cache+AF8-array+AFs-i+AF0, list) +AHs
 			if (c-+AD4-mfc+AF8-flags +ACY MFC+AF8-STATIC)
 				continue+ADs
-			write+AF8-lock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 			list+AF8-del(+ACY-c-+AD4-list)+ADs
-			write+AF8-unlock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 
 			mr6+AF8-netlink+AF8-event(mrt, c, RTM+AF8-DELROUTE)+ADs
 			ip6mr+AF8-cache+AF8-free(c)+ADs
 		+AH0
 	+AH0
+-	write+AF8-unlock+AF8-bh(+ACY-mrt+AF8-lock)+ADs
 
 	if (atomic+AF8-read(+ACY-mrt-+AD4-cache+AF8-resolve+AF8-queue+AF8-len) +ACEAPQ 0) +AHs
 		spin+AF8-lock+AF8-bh(+ACY-mfc+AF8-unres+AF8-lock)+ADs
