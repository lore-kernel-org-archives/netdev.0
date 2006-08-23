From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 22/44] [IPV6]: Find option offset by type.
Date: Thu, 24 Aug 2006 00:02:23 +0900
Message-ID: <11563453663400-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:4233 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964937AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453662913-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

This is a helper to search option offset from extension header which
can carry TLV option like destination options header.
Mobile IPv6 home address option will use it.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h |    2 ++
 net/ipv6/exthdrs.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ece7e8a..c4ea127 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -506,6 +506,8 @@ extern int			ipv6_skip_exthdr(const stru
 
 extern int 			ipv6_ext_hdr(u8 nexthdr);
 
+extern int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
+
 extern struct ipv6_txoptions *	ipv6_invert_rthdr(struct sock *sk,
 						  struct ipv6_rt_hdr *hdr);
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 8d4af75..72e8175 100644
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
1.4.0

