From: Werner Almesberger <werner@almesberger.net>
Subject: [PATCH net-next 2/2] icmpv6_filter: allow ICMPv6 messages with
 bodies < 4 bytes
Date: Fri, 2 Aug 2013 10:51:34 -0300
Message-ID: <9ad5a4d95d70d8f75127207d796a544aed1947cc.1375417279.git.werner@almesberger.net>
References: <cover.1375417279.git.werner@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.openmoko.org ([144.76.72.4]:60942 "EHLO
	hydra.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967Ab3HBNxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 09:53:23 -0400
Received: from 201-160-231-201.fibertel.com.ar ([201.231.160.201] helo=ws)
	by hydra.openmoko.org with esmtpsa (TLS1.0:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <werner@almesberger.net>)
	id 1V5FnF-0001g4-D6
	for netdev@vger.kernel.org; Fri, 02 Aug 2013 15:53:22 +0200
Content-Disposition: inline
In-Reply-To: <cover.1375417279.git.werner@almesberger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By using sizeof(_hdr), net/ipv6/raw.c:icmpv6_filter implicitly assumes
that any valid ICMPv6 message is at least eight bytes long, i.e., that
the message body is at least four bytes.

The DIS message of RPL (RFC 6550 section 6.2, from the 6LoWPAN world),
has a minimum length of only six bytes, and is thus blocked by
icmpv6_filter.

RFC 4443 seems to allow even a zero-sized body, making the minimum
allowable message size four bytes.

Signed-off-by: Werner Almesberger <werner@almesberger.net>
---
 net/ipv6/raw.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 164fb5f..c1e5334 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -63,6 +63,8 @@
 #include <linux/seq_file.h>
 #include <linux/export.h>
 
+#define	ICMPV6_HDRLEN	4	/* ICMPv6 header, RFC 4443 Section 2.1 */
+
 static struct raw_hashinfo raw_v6_hashinfo = {
 	.lock = __RW_LOCK_UNLOCKED(raw_v6_hashinfo.lock),
 };
@@ -111,8 +113,11 @@ static int icmpv6_filter(const struct sock *sk, const struct sk_buff *skb)
 	struct icmp6hdr _hdr;
 	const struct icmp6hdr *hdr;
 
+	/* We require only the four bytes of the ICMPv6 header, not any
+	 * additional bytes of message body in "struct icmp6hdr".
+	 */
 	hdr = skb_header_pointer(skb, skb_transport_offset(skb),
-				 sizeof(_hdr), &_hdr);
+				 ICMPV6_HDRLEN, &_hdr);
 	if (hdr) {
 		const __u32 *data = &raw6_sk(sk)->filter.data[0];
 		unsigned int type = hdr->icmp6_type;
-- 
1.8.1.2
