From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (13/13) ddp - convert to new protocol interface
Date: Fri, 29 Aug 2003 14:20:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829142034.6caff2bc.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert ddp to the new protocol interface which means it has to
handle fragmented skb's.  The only big change is in the checksum
routine which has to do more work (like skb_checksum).

Minor speedup is folding the carry to avoid a branch.

Tested against a 2.4 system and by running both code over
a range of packets.

diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Fri Aug 29 13:33:48 2003
+++ b/net/appletalk/ddp.c	Fri Aug 29 13:33:48 2003
@@ -932,24 +932,95 @@
  * Checksum: This is 'optional'. It's quite likely also a good
  * candidate for assembler hackery 8)
  */
-unsigned short atalk_checksum(struct ddpehdr *ddp, int len)
+static unsigned long atalk_sum_partial(const unsigned char *data, 
+				       int len, unsigned long sum)
 {
-	unsigned long sum = 0;	/* Assume unsigned long is >16 bits */
-	unsigned char *data = (unsigned char *)ddp;
-
-	len  -= 4;		/* skip header 4 bytes */
-	data += 4;
-
 	/* This ought to be unwrapped neatly. I'll trust gcc for now */
 	while (len--) {
-		sum += *data;
+		sum += *data++;
 		sum <<= 1;
-		if (sum & 0x10000) {
-			sum++;
-			sum &= 0xFFFF;
+		sum = ((sum >> 16) + sum) & 0xFFFF;
+	}
+	return sum;
+}
+
+/*  Checksum skb data --  similar to skb_checksum  */
+static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
+				   int len, unsigned long sum)
+{
+	int start = skb_headlen(skb);
+	int i, copy;
+
+	/* checksum stuff in header space */
+	if ( (copy = start - offset) > 0) {
+		if (copy > len)
+			copy = len;
+		sum = atalk_sum_partial(skb->data + offset, copy, sum);
+		if ( (len -= copy) == 0) 
+			return sum;
+
+		offset += copy;
+	}
+
+	/* checksum stuff in frags */
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		int end;
+
+		BUG_TRAP(start <= offset + len);
+
+		end = start + skb_shinfo(skb)->frags[i].size;
+		if ((copy = end - offset) > 0) {
+			u8 *vaddr;
+			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+			if (copy > len)
+				copy = len;
+			vaddr = kmap_skb_frag(frag);
+			sum = atalk_sum_partial(vaddr + frag->page_offset +
+						  offset - start, copy, sum);
+			kunmap_skb_frag(vaddr);
+
+			if (!(len -= copy))
+				return sum;
+			offset += copy;
 		}
-		data++;
+		start = end;
 	}
+
+	if (skb_shinfo(skb)->frag_list) {
+		struct sk_buff *list = skb_shinfo(skb)->frag_list;
+
+		for (; list; list = list->next) {
+			int end;
+
+			BUG_TRAP(start <= offset + len);
+
+			end = start + list->len;
+			if ((copy = end - offset) > 0) {
+				if (copy > len)
+					copy = len;
+				sum = atalk_sum_skb(list, offset - start,
+						    copy, sum);
+				if ((len -= copy) == 0)
+					return sum;
+				offset += copy;
+			}
+			start = end;
+		}
+	}
+
+	BUG_ON(len > 0);
+
+	return sum;
+}
+
+static unsigned short atalk_checksum(const struct sk_buff *skb, int len)
+{
+	unsigned long sum;
+
+	/* skip header 4 bytes */
+	sum = atalk_sum_skb(skb, 4, len-4, 0);
+
 	/* Use 0xFFFF for 0. 0 itself means none */
 	return sum ? htons((unsigned short)sum) : 0xFFFF;
 }
@@ -1331,25 +1402,27 @@
 static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		     struct packet_type *pt)
 {
-	struct ddpehdr *ddp = ddp_hdr(skb);
+	struct ddpehdr *ddp;
 	struct sock *sock;
 	struct atalk_iface *atif;
 	struct sockaddr_at tosat;
         int origlen;
         struct ddpebits ddphv;
 
-	/* Size check */
-	if (skb->len < sizeof(*ddp))
+	/* Don't mangle buffer if shared */
+	if (!(skb = skb_share_check(skb, GFP_ATOMIC))) 
+		goto out;
+		
+	/* Size check and make sure header is contiguous */
+	if (!pskb_may_pull(skb, sizeof(*ddp)))
 		goto freeit;
 
+	ddp = ddp_hdr(skb);
+
 	/*
 	 *	Fix up the length field	[Ok this is horrible but otherwise
 	 *	I end up with unions of bit fields and messy bit field order
 	 *	compiler/endian dependencies..]
-	 *
-	 *	FIXME: This is a write to a shared object. Granted it
-	 *	happens to be safe BUT.. (Its safe as user space will not
-	 *	run until we put it back)
 	 */
 	*((__u16 *)&ddphv) = ntohs(*((__u16 *)ddp));
 
@@ -1370,7 +1443,7 @@
 	 * valid for net byte orders all over the networking code...
 	 */
 	if (ddp->deh_sum &&
-	    atalk_checksum(ddp, ddphv.deh_len) != ddp->deh_sum)
+	    atalk_checksum(skb, ddphv.deh_len) != ddp->deh_sum)
 		/* Not a valid AppleTalk frame - dustbin time */
 		goto freeit;
 
@@ -1429,14 +1502,16 @@
 
 		if (!ap || skb->len < sizeof(struct ddpshdr))
 			goto freeit;
+
+		/* Don't mangle buffer if shared */
+		if (!(skb = skb_share_check(skb, GFP_ATOMIC))) 
+			return 0;
+
 		/*
 		 * The push leaves us with a ddephdr not an shdr, and
 		 * handily the port bytes in the right place preset.
 		 */
-
-		skb_push(skb, sizeof(*ddp) - 4);
-		/* FIXME: use skb->cb to be able to use shared skbs */
-		ddp = (struct ddpehdr *)skb->data;
+		ddp = (struct ddpehdr *) skb_push(skb, sizeof(*ddp) - 4);
 
 		/* Now fill in the long header */
 
@@ -1588,7 +1663,7 @@
 	if (sk->sk_no_check == 1)
 		ddp->deh_sum = 0;
 	else
-		ddp->deh_sum = atalk_checksum(ddp, len + sizeof(*ddp));
+		ddp->deh_sum = atalk_checksum(skb, len + sizeof(*ddp));
 
 	/*
 	 * Loopback broadcast packets to non gateway targets (ie routes
@@ -1797,11 +1872,13 @@
 struct packet_type ltalk_packet_type = {
 	.type		= __constant_htons(ETH_P_LOCALTALK),
 	.func		= ltalk_rcv,
+	.data		= (void *)1,
 };
 
 struct packet_type ppptalk_packet_type = {
 	.type		= __constant_htons(ETH_P_PPPTALK),
 	.func		= atalk_rcv,
+	.data		= (void *)1,
 };
 
 static unsigned char ddp_snap_id[] = { 0x08, 0x00, 0x07, 0x80, 0x9B };
