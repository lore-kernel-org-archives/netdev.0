From: Stephen Hemminger <shemminger@osdl.org>
Subject: [[RFT] convert appletalk over to new protocol
Date: Wed, 9 Jul 2003 13:13:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709131300.660c052f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-atalk@lists.netspace.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jay Schulist <jschlst@samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This fixes appletalk ddp protocol to address a couple of issues:
	- routing code was holding a reference to device without doing ref counting.
	- packet interface was old style
	   - add shared buffer checks
	   - add pullup's where needed
	   - change checksum to handle fragmented sk_buff's
	- clean up comments to match above changes.

I don't have real appletalk test infrastructure, and given the checksum change it should
be tested against real Apple hardware.  It does build, and loads/unloads fine.  I can
bring up the netatalk stuff without problem but have nothing to talk to it.

diff -Nru a/net/appletalk/ddp.c b/net/appletalk/ddp.c
--- a/net/appletalk/ddp.c	Wed Jul  9 12:55:00 2003
+++ b/net/appletalk/ddp.c	Wed Jul  9 12:55:00 2003
@@ -239,6 +239,7 @@
 	while ((tmp = *iface) != NULL) {
 		if (tmp->dev == dev) {
 			*iface = tmp->next;
+			dev_put(dev);
 			kfree(tmp);
 			dev->atalk_ptr = NULL;
 		} else
@@ -256,6 +257,7 @@
 		goto out;
 
 	iface->dev = dev;
+	dev_hold(dev);
 	dev->atalk_ptr = iface;
 	iface->address = *sa;
 	iface->status = 0;
@@ -665,9 +667,13 @@
 static int ddp_device_event(struct notifier_block *this, unsigned long event,
 			    void *ptr)
 {
-	if (event == NETDEV_DOWN)
+	switch (event) {
+	case NETDEV_DOWN:
+	case NETDEV_UNREGISTER:
 		/* Discard any use of this */
 	        atalk_dev_down(ptr);
+		break;
+	}
 
 	return NOTIFY_DONE;
 }
@@ -935,13 +941,10 @@
  * Checksum: This is 'optional'. It's quite likely also a good
  * candidate for assembler hackery 8)
  */
-unsigned short atalk_checksum(struct ddpehdr *ddp, int len)
-{
-	unsigned long sum = 0;	/* Assume unsigned long is >16 bits */
-	unsigned char *data = (unsigned char *)ddp;
 
-	len  -= 4;		/* skip header 4 bytes */
-	data += 4;
+static unsigned long atalk_sum_partial(const unsigned char *data, 
+					      int len, unsigned long sum)
+{
 
 	/* This ought to be unwrapped neatly. I'll trust gcc for now */
 	while (len--) {
@@ -953,10 +956,94 @@
 		}
 		data++;
 	}
+	return sum;
+}
+
+/*  Checksum skb data --  similar to skb_checksum  */
+static unsigned long atalk_sum_skb(const struct sk_buff *skb, int offset,
+				   int len, unsigned long sum)
+{
+	int start = skb_headlen(skb);
+	int i, copy;
+	int pos = 0;
+
+	/* checksum stuff in header space */
+	if ( (copy = start - offset) > 0) {
+		if (copy > len)
+			copy = len;
+		sum = atalk_sum_partial(skb->data + offset, copy, sum);
+		if ( (len -= copy) == 0)
+			return sum;
+		offset += copy;
+		pos    = copy;
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
+			pos    += copy;
+		}
+		start = end;
+	}
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
+				pos    += copy;
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
 
+
 /*
  * Create a socket. Initialise the socket, blank the addresses
  * set the state.
@@ -1335,25 +1422,26 @@
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
 
@@ -1374,7 +1462,7 @@
 	 * valid for net byte orders all over the networking code...
 	 */
 	if (ddp->deh_sum &&
-	    atalk_checksum(ddp, ddphv.deh_len) != ddp->deh_sum)
+	    atalk_checksum(skb, ddphv.deh_len) != ddp->deh_sum)
 		/* Not a valid AppleTalk frame - dustbin time */
 		goto freeit;
 
@@ -1433,14 +1521,16 @@
 
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
 
@@ -1583,6 +1673,7 @@
 
 	SOCK_DEBUG(sk, "SK %p: Copy user data (%d bytes).\n", sk, len);
 
+	/* TODO: copy and checksum in one pass */
 	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
 	if (err) {
 		kfree_skb(skb);
@@ -1592,7 +1683,7 @@
 	if (sk->sk_no_check == 1)
 		ddp->deh_sum = 0;
 	else
-		ddp->deh_sum = atalk_checksum(ddp, len + sizeof(*ddp));
+		ddp->deh_sum = atalk_checksum(skb, len + sizeof(*ddp));
 
 	/*
 	 * Loopback broadcast packets to non gateway targets (ie routes
@@ -1801,11 +1892,13 @@
 struct packet_type ltalk_packet_type = {
 	.type		= __constant_htons(ETH_P_LOCALTALK),
 	.func		= ltalk_rcv,
+	.data		= (void *) 1,
 };
 
 struct packet_type ppptalk_packet_type = {
 	.type		= __constant_htons(ETH_P_PPPTALK),
 	.func		= atalk_rcv,
+	.data		= (void *) 1,
 };
 
 static unsigned char ddp_snap_id[] = { 0x08, 0x00, 0x07, 0x80, 0x9B };
