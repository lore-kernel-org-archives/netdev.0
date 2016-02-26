From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH] IPv6: Use a 16 bit length field when computing a
 IPv6 UDP checksum
Date: Thu, 25 Feb 2016 19:10:59 -0800
Message-ID: <20160226025738.16760.41163.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34452 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbcBZDLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 22:11:01 -0500
Received: by mail-pa0-f49.google.com with SMTP id fy10so42994145pac.1
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 19:11:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we only use a 16 bit length field instead of a
32 bit length field when computing a UDP checksum for IPv6.

This fixes an issue found with UDP tunnels over IPv6 where the total size
exceeded 65536 for a frame that was to be segmented.  As a result the
checksum being computed didn't match the frame data so we ended up being
off by 1 for the final checksum value since we didn't cancel out the upper
16 bits of the length.

The reasoning behind this is that RFC2460 states that for protocols such as
UDP that carry their own length field we should use that when computing the
checksum for the pseudo-header.  As such we should be using a 16 bit value,
not a 32 bit as is currently occurring when computing the UDP checksum for
IPv6.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

I don't have the highest of confidence that this patch is the correct
solution for this, however the way I see it we only have a few
alternatives.  For now I am using this patch to get the conversation
started.

There ends up really being two issues here.

The first issue is that IPv4 and IPv6 GSO frames are being assembled that
have a length that is greater than 65535 and the truncated value is being
placed in the length fields.  The problem as I see it is that I am not sure
there is any definitive way to prevent this without reducing the maximum
GSO size for all sources within a given network namespace.  In addition I
am not sure what the impact on performance would be if we were to implement
such an approach.

The second issue is that if we cannot prevent the first issue we really
need to have a consistent way of doing the IPv4 and IPv6 checksums.  The
IPv4 checksum passes the length value as a short, while the IPv6 passes
this value as an integer.  As a result we get different behavior between
the two which makes it difficult for us to put together a generic routine
for handling checksums for segmentation at higher levels.

 include/net/ip6_checksum.h |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 1a49b73f7f6e..c55529ac12cf 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -95,6 +95,15 @@ static inline __sum16 udp_v6_check(int len,
 				   const struct in6_addr *daddr,
 				   __wsum base)
 {
+	/* RFC 2460 states that for protocols such as UDP which include
+	 * a length in their header we should use that value when computing
+	 * the pseudo-header instead of the total payload length minus
+	 * extension headers.  Since UDP has a length field that is only
+	 * 16 bits in length we need to cap the length field to 16 bits to
+	 * match what will be present in the header.
+	 */
+	len &= 0xFFFF;
+
 	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_UDP, base);
 }
 
