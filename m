From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/6) tr - better hash function
Date: Wed, 20 Aug 2003 17:14:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820171434.3174a152.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-tr@linuxtr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rather than a simple for loop sum, use a better hash function
for the mac address.

Function repurposed from Lennert's bridge code.

diff -Nru a/net/802/tr.c b/net/802/tr.c
--- a/net/802/tr.c	Wed Aug 20 15:52:05 2003
+++ b/net/802/tr.c	Wed Aug 20 15:52:05 2003
@@ -78,6 +78,22 @@
 
 int sysctl_tr_rif_timeout = RIF_TIMEOUT;
 
+static inline unsigned long rif_hash(const unsigned char *addr)
+{
+	unsigned long x;
+
+	x = addr[0];
+	x = (x << 2) ^ addr[1];
+	x = (x << 2) ^ addr[2];
+	x = (x << 2) ^ addr[3];
+	x = (x << 2) ^ addr[4];
+	x = (x << 2) ^ addr[5];
+
+	x ^= x >> 8;
+
+	return x & (RIF_TABLE_SIZE - 1);
+}
+
 /*
  *	Put the headers on a token ring packet. Token ring source routing
  *	makes this a little more exciting than on ethernet.
@@ -231,7 +247,7 @@
 
 void tr_source_route(struct sk_buff *skb,struct trh_hdr *trh,struct net_device *dev) 
 {
-	int i, slack;
+	int slack;
 	unsigned int hash;
 	struct rif_cache_s *entry;
 	unsigned char *olddata;
@@ -252,8 +268,7 @@
 	}
 	else 
 	{
-		for(i=0,hash=0;i<TR_ALEN;hash+=trh->daddr[i++]);
-		hash&=RIF_TABLE_SIZE-1;
+		hash = rif_hash(trh->daddr);
 		/*
 		 *	Walk the hash table and look for an entry
 		 */
@@ -321,7 +336,6 @@
  
 static void tr_add_rif_info(struct trh_hdr *trh, struct net_device *dev)
 {
-	int i;
 	unsigned int hash, rii_p = 0;
 	struct rif_cache_s *entry;
 
@@ -341,8 +355,7 @@
 	        }
 	}
 
-	for(i=0,hash=0;i<TR_ALEN;hash+=trh->saddr[i++]);
-	hash&=RIF_TABLE_SIZE-1;
+	hash = rif_hash(trh->saddr);
 	for(entry=rif_table[hash];entry && memcmp(&(entry->addr[0]),&(trh->saddr[0]),TR_ALEN);entry=entry->next);
 
 	if(entry==NULL) 
