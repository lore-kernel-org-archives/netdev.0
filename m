From: Werner Almesberger <werner@almesberger.net>
Subject: minimum ICMPv6 message size vs. RPL's DIS
Date: Wed, 24 Jul 2013 20:28:52 -0300
Message-ID: <20130724232852.GA29572@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.openmoko.org ([144.76.72.4]:52038 "EHLO
	hydra.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151Ab3GYARq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:17:46 -0400
Received: from 201-160-231-201.fibertel.com.ar ([201.231.160.201] helo=ws)
	by hydra.openmoko.org with esmtpsa (TLS1.0:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <werner@almesberger.net>)
	id 1V28Va-0005JQ-H6
	for netdev@vger.kernel.org; Thu, 25 Jul 2013 01:30:15 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel assumes that any valid ICMPv6 message is at least eight
bytes long, for example in net/ipv6/raw.c:icmpv6_filter

The DIS message of RPL (RFC 6550 section 6.2, from the 6LoWPAN
world), has a minimum length of six bytes, and is thus blocked by
icmpv6_filter.

Contiki OS sends this sort of messages and is thus ignored by an
user-space RPL application on Linux (in my case simpleRPL). Nodes
will eventually join the network regardless, but this can take
hours instead of seconds.
 
RFC 4443 seems to allow even a zero-sized body, making the minimum
allowable size four bytes.

A similar restriction exists in net/ipv6/icmp.c:icmpv6_rcv but
causes no harm there since all potential recipients at that point
expect a larger payload.

Now, while this is easy enough to fix on the Linux side (see
below), I wonder if it is really a Linux bug or if I (and the
authors of RPL in Contiki) may have missed some minimum size
requirement for ICMPv6 messages stated elsewhere.

Opinions ?

- Werner

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index c45f7a5..539534c 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -112,7 +112,7 @@ static int icmpv6_filter(const struct sock *sk, const struct sk_buff *skb)
 	const struct icmp6hdr *hdr;
 
 	hdr = skb_header_pointer(skb, skb_transport_offset(skb),
-				 sizeof(_hdr), &_hdr);
+				 4, &_hdr);
 	if (hdr) {
 		const __u32 *data = &raw6_sk(sk)->filter.data[0];
 		unsigned int type = hdr->icmp6_type;
