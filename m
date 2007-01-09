From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PACKET]: Add optional checksum computation for recvmsg
Date: Tue, 9 Jan 2007 11:42:12 +1100
Message-ID: <20070109004211.GA29703@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2558 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750784AbXAIAma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 19:42:30 -0500
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

[PACKET]: Add optional checksum computation for recvmsg

This patch is needed to make ISC's DHCP server (and probably other
DHCP servers/clients using AF_PACKET) to be able to serve another
client on the same Xen host.

The problem is that packets between different domains on the same
Xen host only have partial checksums.  Unfortunately this piece of
information is not passed along in AF_PACKET unless you're using
the mmap interface.  Since the standard libpcap doesn't support
mmap (and even the ones which do support it don't pass along the
flag anyway), UDP packets from the same host come out with apparently
bogus checksums.

Since there is no way to pass the flag for the recvmsg(2) interface,
an alternative is to compute the checksum in the kernel.  This is a
bit of waste but can be useful for other user-space applications such
as tcpdump.

The following patch taps into the existing sockopt of SO_NO_CHECK.
It changes the default sk_no_check value for packet sockets to 1
so that the default behaviour is identical to the status quo.  If
the application disables SO_NO_CHECK, then partial checksums will
be computed for recvmsg(2) (mmap is unaffected).  The checksum
computation will only proceed if the packet is not truncated by
the socket.

In addition, this patch removes the GSO check from skb_checksum_help
so that checksums are computed for GSO packets too for consistency.

That check is no longer relevant since netfilter now computes the
checksum updates for GSO packets correctly.  Even without the fixes
to netfilter, that check is only a small optimisation since all it
does is avoid an unnecessary checksum computation on GSO packets.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
diff --git a/net/core/dev.c b/net/core/dev.c
index e660cb5..142194f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1175,11 +1175,6 @@ int skb_checksum_help(struct sk_buff *skb)
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
 		goto out_set_summed;
 
-	if (unlikely(skb_shinfo(skb)->gso_size)) {
-		/* Let GSO fix up the checksum. */
-		goto out_set_summed;
-	}
-
 	if (skb_cloned(skb)) {
 		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
 		if (ret)
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index da73e8a..a5efa31 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -526,8 +526,11 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	if (dev->hard_header_parse)
 		sll->sll_halen = dev->hard_header_parse(skb, sll->sll_addr);
 
-	if (pskb_trim(skb, snaplen))
-		goto drop_n_acct;
+	if (snaplen < skb->len) {
+		if (__pskb_trim(skb, snaplen))
+			goto drop_n_acct;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
 
 	skb_set_owner_r(skb, sk);
 	skb->dev = NULL;
@@ -1017,6 +1020,9 @@ static int packet_create(struct socket *sock, int protocol)
 	sk->sk_destruct = packet_sock_destruct;
 	atomic_inc(&packet_socks_nr);
 
+	/* We don't want checksums by default for performance reasons. */
+	sk->sk_no_check = 1;
+
 	/*
 	 *	Attach a protocol block
 	 */
@@ -1110,6 +1116,12 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 		msg->msg_flags|=MSG_TRUNC;
 	}
 
+	if (unlikely(!sk->sk_no_check && skb->ip_summed == CHECKSUM_PARTIAL)) {
+		err = skb_checksum_help(skb);
+		if (err)
+			goto out_free;
+	}
+
 	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
 	if (err)
 		goto out_free;
