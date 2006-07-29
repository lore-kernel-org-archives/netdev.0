From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 6/20] [PATCH] [IPV6]: Find option offset by type.
Date: Sat, 29 Jul 2006 18:38:28 +0900
Message-ID: <11541659083944-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:40579 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422714AbWG2Ji3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:29 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a helper to search option offset from extension header which
can carry TLV option like destination options header.
Mobile IPv6 home address option will use it.
Based on MIPL2 kernel patch.
---
 include/net/ipv6.h |    2 ++
 net/ipv6/exthdrs.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4abedb8..2e78433 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -504,6 +504,8 @@ extern int			ipv6_skip_exthdr(const stru
 
 extern int 			ipv6_ext_hdr(u8 nexthdr);
 
+extern int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
+
 extern struct ipv6_txoptions *	ipv6_invert_rthdr(struct sock *sk,
 						  struct ipv6_rt_hdr *hdr);
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 138cb12..fbedad9 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -49,6 +49,49 @@ #endif
 
 #include <asm/uaccess.h>
 
+int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
+{
+	int packet_len = skb->tail - skb->nh.raw;
+	struct ipv6_opt_hdr *hdr;
+	int len;
+
+	if (offset + 2 > packet_len)
+		goto bad;
+	hdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+	len = ((hdr->hdrlen + 1) << 3);
+
+	if (offset + len > packet_len)
+		goto bad;
+
+	offset += 2;
+	len -= 2;
+
+	while (len > 0) {
+		int opttype = skb->nh.raw[offset];
+		int optlen;
+
+		if (opttype == type)
+			return offset;
+
+		switch (opttype) {
+		case IPV6_TLV_PAD0:
+			optlen = 1;
+			break;
+		default:
+			optlen = skb->nh.raw[offset + 1] + 2;
+			if (optlen > len)
+				goto bad;
+			break;
+		}
+		offset += optlen;
+		len -= optlen;
+	}
+	/* not_found */
+	return -1;
+ bad:
+	return -1;
+}
+
 /*
  *	Parsing tlv encoded headers.
  *
-- 
1.4.1

