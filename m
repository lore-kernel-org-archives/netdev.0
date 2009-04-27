From: Christophe Saout <christophe@saout.de>
Subject: [PATCH][RFC][resend] xfrm: Fix up TCP/UDP checksum for UDP encap.
 ESP4 packets in transport mode
Date: Mon, 27 Apr 2009 10:30:16 +0200
Message-ID: <1240821016.7949.0.camel@leto.intern.saout.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from websrv.werbeagentur-aufwind.de ([88.198.253.206]:47475 "EHLO
	websrv.werbeagentur-aufwind.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753735AbZD0Ia0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 04:30:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I was happily running an transport-mode IPSEC connection where I was
running NAT at one endpoint.  This means that decrypted packets can be
forwarded to another machine, as opposed to being delivered to a local
application.

Later I was forced to encapsulate the IPSEC traffic into UDP because I
had no choice but pass through a NAT device.  Then, unfortunately,
things started to break.  The machine that would receive the answer to a
TCP/SYN packet from the gateway box (that decrypts the packed and then
forwards it) discarded the packets because of a wrong TCP checksum.

I checked the kernel code - esp4.c is just setting CHECKSUM_UNNECESSARY
on these packets, so that they are accepted by local applications.
However, when the packages leaves the machine via a NIC, the packet
still carries the broken checksum.  I checked the RFC on the issue and
one of the suggestions is to recompute the checksum for carried TCP/UDP
packets.

I have a working (but possibly inelegant version), which I am proposing.
I know there are obvious things that can be improved, but I'm just
posting it here for discussion.  Also, I'm not sure my skb handling is
fully correct.

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 18bb383..b0eba8f 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -295,6 +295,33 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
+	if (x->encap && x->props.mode == XFRM_MODE_TRANSPORT &&
+	    (nexthdr[1] == IPPROTO_TCP || nexthdr[1] == IPPROTO_UDP)) {
+		int datalen, thlen;
+		unsigned char *th;
+
+		if (nexthdr[1] == IPPROTO_TCP) {
+			thlen = sizeof(struct tcphdr);
+			skb->csum_offset = offsetof(struct tcphdr, check);
+		} else {
+			thlen = sizeof(struct udphdr);
+			skb->csum_offset = offsetof(struct udphdr, check);
+		}
+
+		datalen = skb->len - alen - padlen - 2 - hlen;
+		if (datalen < 0 || !pskb_may_pull(skb, hlen + thlen))
+			goto out;
+
+		iph = ip_hdr(skb);
+		th = skb_transport_header(skb) + hlen;
+
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = th - skb->head;
+		*(__u16 *)(th + skb->csum_offset) =
+				~csum_tcpudp_magic(iph->saddr, iph->daddr,
+				                   datalen, nexthdr[1], 0);
+	}
+
 	pskb_trim(skb, skb->len - alen - padlen - 2);
 	__skb_pull(skb, hlen);
 	skb_set_transport_header(skb, -ihl);


