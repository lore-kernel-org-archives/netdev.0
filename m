From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 5/5] NET : Reorder fields of struct dst_entry
Date: Thu, 08 Feb 2007 22:41:11 +0100
Message-ID: <45CB98F7.1000902@cosmosbay.com>
References: <20070202120528.GA10392@de.ibm.com> <20070206.144106.39659974.davem@davemloft.net> <45C9093D.1030605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080801080508000105010200"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58008 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423449AbXBHVlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:41:24 -0500
In-Reply-To: <45C9093D.1030605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080801080508000105010200
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This last patch (but not least :) ) finally moves the next pointer at the end 
of struct dst_entry. This permits to perform route cache lookups with a 
minimal cost of one cache line per entry, instead of two.

Both 32bits and 64bits platforms benefit from this new layout.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>



--------------080801080508000105010200
Content-Type: text/plain;
 name="reorder_struct_dst.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="reorder_struct_dst.patch"

--- linux-2.6.20/include/net/dst.h.inter	2007-02-08 21:43:21.000000000 +0100
+++ linux-2.6.20-ed/include/net/dst.h	2007-02-08 21:43:21.000000000 +0100
@@ -37,14 +37,7 @@ struct sk_buff;
 
 struct dst_entry
 {
-	union {
-		struct dst_entry *next;
-		struct rtable    *rt_next;
-		struct rt6_info   *rt6_next;
-		struct dn_route  *dn_next;
-	};
-	atomic_t		__refcnt;	/* client references	*/
-	int			__use;
+	struct rcu_head		rcu_head;
 	struct dst_entry	*child;
 	struct net_device       *dev;
 	short			error;
@@ -55,7 +48,6 @@ struct dst_entry
 #define DST_NOPOLICY		4
 #define DST_NOHASH		8
 #define DST_BALANCED            0x10
-	unsigned long		lastuse;
 	unsigned long		expires;
 
 	unsigned short		header_len;	/* more space at head required */
@@ -80,8 +72,16 @@ struct dst_entry
 #endif
 
 	struct  dst_ops	        *ops;
-	struct rcu_head		rcu_head;
 		
+	unsigned long		lastuse;
+	atomic_t		__refcnt;	/* client references	*/
+	int			__use;
+	union {
+		struct dst_entry *next;
+		struct rtable    *rt_next;
+		struct rt6_info   *rt6_next;
+		struct dn_route  *dn_next;
+	};
 	char			info[0];
 };
 

--------------080801080508000105010200--
