From: Al Viro <viro@ftp.linux.org.uk>
Subject: why do we mangle checksums for v6 ICMP?
Date: Wed, 8 Nov 2006 22:13:32 +0000
Message-ID: <20061108221332.GI29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47259 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1161742AbWKHWNd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 17:13:33 -0500
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.52 #1 (Red Hat Linux))
	id 1Ghvfo-00085e-2P
	for netdev@vger.kernel.org; Wed, 08 Nov 2006 22:13:32 +0000
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	AFAICS, the rules are:

(1) checksum is 16-bit one's complement of the one's complement sum of
relevant 16bit words.

(2) for v4 UDP all-zeroes has special meaning - no checksum; if you get
it from (1), send all-ones instead.

(3) for v6 UDP we have the same remapping as in (2), but all-zeroes has
different meaning - not "ignore checksum" as in v4, but "reject the
packet".

(4) there is no (4).

	IOW, nobody except UDP has any business doing that 0->0xffff
replacement.  However, we have
       if (icmp6h->icmp6_cksum == 0)
               icmp6h->icmp6_cksum = -1;
and similar in net/ipv6/raw.c

AFAICS, both went in with (commit ID by linux-hist repository)
commit 6bac90985c8b65ffc25839c001aa7ef4831d2915
Author: Kazunori Miyazawa <kazunori@miyazawa.org>
Date:   Mon May 12 00:21:19 2003 -0700

    [IPV4]: Introduce ip6_append_data.

That changeset has very similar changes done in udp.c, icmp.c and raw.c;
remapping of UDP checksum used to be in the area affected by the changeset
and it looks like it got not just preserved in udp.c (as it should), but
copied to icmp.c and raw.c instances.

So... is it really needed there?
