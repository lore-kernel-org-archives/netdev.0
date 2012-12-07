From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [RFC PATCH] ipv6: do not create neighbor entries for local delivery
Date: Fri, 07 Dec 2012 15:30:28 -0200
Message-ID: <50C227B4.6040502@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090601070000080707070405"
Cc: Thomas Graf <tgraf@redhat.com>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755147Ab2LGRau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 12:30:50 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id qB7HUj44012674
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 12:30:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090601070000080707070405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

RFC comment:

Please note that I do not fully understand the impacts of this, thus why 
RFC. I don't know if this is the best way to address the issue.

I have a report that when using TPROXY and IPv6, neighbor cache gets 
flooded with empty entries, while this does not happen with IPv4. These 
empty entries looks like:

# ip -6 neigh show nud all   (I masked some bits)
...
20xx::f0xx:x:3xdb dev lo lladdr 00:00:00:00:00:00 NOARP
...

Note that this address was not directly reachable by this host. It was 1 
hop away, and still got a neighbor entry.

These entries seems to be not used during input. I disabled their 
creation and I could not notice any abnormal results.

Bellow the dashes, my original patch description. Applies to net-next.

Please advise.

Thanks,
Marcelo.

----------------

They will be created at output, if ever needed. This avoids creating
empty neighbor entries when TPROXYing/Forwarding packets for addresses
that are not even directly reachable.

Note that IPv4 already handles it this way. No neighbor entries are
created for local input.
---
  net/ipv6/route.c | 2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 
e229a3bc345dc4138a188282c4ab4f1717882832..e6058ab0bb94233da1eec3349e098175d5abf831 
100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -928,7 +928,7 @@ restart:
  	dst_hold(&rt->dst);
  	read_unlock_bh(&table->tb6_lock);
-	if (!rt->n && !(rt->rt6i_flags & RTF_NONEXTHOP))
+	if (!rt->n && !(rt->rt6i_flags & (RTF_NONEXTHOP|RTF_LOCAL)))
  		nrt = rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
  	else if (!(rt->dst.flags & DST_HOST))
  		nrt = rt6_alloc_clone(rt, &fl6->daddr);
-- 
1.7.11.7


--------------090601070000080707070405
Content-Type: text/plain; charset=UTF-8;
 name="=?ISO-8859-1?Q?Se=E7=E3o_da_mensagem_anexada?="
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0*=ISO-8859-1''%53%65%E7%E3%6F%20%64%61%20%6D%65%6E%73%61%67%65;
 filename*1*=%6D%20%61%6E%65%78%61%64%61


--------------090601070000080707070405--
