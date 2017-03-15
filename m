From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/10] netfilter: nf_nat_sctp: fix ICMP packet to be dropped accidently
Date: Wed, 15 Mar 2017 18:01:04 +0100
Message-ID: <1489597272-30347-3-git-send-email-pablo@netfilter.org>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37460 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752182AbdCORBk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 13:01:40 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C00C71324C7
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:20 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B13FDDA8F7
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:20 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 521D9DA874
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:01:18 +0100 (CET)
In-Reply-To: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Regarding RFC 792, the first 64 bits of the original SCTP datagram's
data could be contained in ICMP packet, such as:

    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Type      |     Code      |          Checksum             |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                             unused                            |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |      Internet Header + 64 bits of Original Data Datagram      |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

However, according to RFC 4960, SCTP datagram header is as below:

    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |     Source Port Number        |     Destination Port Number   |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                      Verification Tag                         |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                           Checksum                            |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

It means only the first three fields of SCTP header can be carried in
ICMP packet except for Checksum field.

At present in sctp_manip_pkt(), no matter whether the packet is ICMP or
not, it always calculates SCTP packet checksum. However, not only the
calculation of checksum is unnecessary for ICMP, but also it causes
another fatal issue that ICMP packet is dropped. The header size of
SCTP is used to identify whether the writeable length of skb is bigger
than skb->len through skb_make_writable() in sctp_manip_pkt(). But
when it deals with ICMP packet, skb_make_writable() directly returns
false as the writeable length of skb is bigger than skb->len.
Subsequently ICMP is dropped.

Now we correct this misbahavior. When sctp_manip_pkt() handles ICMP
packet, 8 bytes rather than the whole SCTP header size is used to check
if writeable length of skb is overflowed. Meanwhile, as it's meaningless
to calculate checksum when packet is ICMP, the computation of checksum
is ignored as well.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_proto_sctp.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
index 31d358691af0..804e8a0ab36e 100644
--- a/net/netfilter/nf_nat_proto_sctp.c
+++ b/net/netfilter/nf_nat_proto_sctp.c
@@ -33,8 +33,16 @@ sctp_manip_pkt(struct sk_buff *skb,
 	       enum nf_nat_manip_type maniptype)
 {
 	sctp_sctphdr_t *hdr;
+	int hdrsize = 8;
 
-	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
+	/* This could be an inner header returned in imcp packet; in such
+	 * cases we cannot update the checksum field since it is outside
+	 * of the 8 bytes of transport layer headers we are guaranteed.
+	 */
+	if (skb->len >= hdroff + sizeof(*hdr))
+		hdrsize = sizeof(*hdr);
+
+	if (!skb_make_writable(skb, hdroff + hdrsize))
 		return false;
 
 	hdr = (struct sctphdr *)(skb->data + hdroff);
@@ -47,6 +55,9 @@ sctp_manip_pkt(struct sk_buff *skb,
 		hdr->dest = tuple->dst.u.sctp.port;
 	}
 
+	if (hdrsize < sizeof(*hdr))
+		return true;
+
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		hdr->checksum = sctp_compute_cksum(skb, hdroff);
 		skb->ip_summed = CHECKSUM_NONE;
-- 
2.1.4
