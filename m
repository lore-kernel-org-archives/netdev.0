From: Tim Gardner <timg@tpi.com>
Subject: [PATCH] IPv4 ARP hash algorithm has poor distribution
Date: Mon, 15 Mar 2004 11:32:31 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200403151132.31368.timg@tpi.com>
Reply-To: timg@tpi.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-net" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

The current IPv4 ARP hash algorithm does not generate evenly distributed hash 
indices.

Included is a patch to fix the hash algorithm such that it will generate an 
even distribution of hash indices within a single subnet. It also uses the 
network bits of the address to attempt to avoid collisions with other 
subnets.

On my my router with 991 ARP entries, this algorithm utilized 669 out of 1024 
hash buckets. The old algorithm utilized 169.

rtg

<-Snip-->

diff -r -u --new-file linux-2.4.bk/net/ipv4/arp.c 
linux-2.4.bk-arp-hash/net/ipv4/arp.c
--- linux-2.4.bk/net/ipv4/arp.c	2004-03-15 11:24:07.000000000 -0700
+++ linux-2.4.bk-arp-hash/net/ipv4/arp.c	2004-03-15 10:15:48.000000000 -0700
@@ -215,11 +215,9 @@
 {
 	u32 hash_val;
 
-	hash_val = *(u32*)pkey;
+	hash_val = ntohl(*(u32*)pkey);
 	hash_val ^= (hash_val>>16);
-	hash_val ^= hash_val>>8;
-	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&(arp_tbl.num_hash_buckets-1);
+	hash_val &= (arp_tbl.num_hash_buckets-1);
 
 	return hash_val;
 }

-- 
Tim Gardner - timg@tpi.com
www.tpi.com 406-443-5357
