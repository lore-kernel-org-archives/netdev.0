From: Romain KUNTZ <r.kuntz@ipflavors.com>
Subject: [PATCH 2/2] ipv6: fix packet corruption when Dest/RT2 options are used
Date: Sat, 5 Jan 2013 17:19:46 +0100
Message-ID: <C7895CAA-0AF7-4EED-B9E7-9D8E4A21442B@ipflavors.com>
References: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:52491 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755814Ab3AEQTq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 11:19:46 -0500
Received: by mail-we0-f177.google.com with SMTP id x48so8394684wey.8
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 08:19:44 -0800 (PST)
In-Reply-To: <0CC79564-4AF2-42F9-8D06-1BCC912A1AF7@ipflavors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 299b0767 (ipv6: Fix IPsec slowpath fragmentation problem)
has introduced a bug that provokes corrupted packets when Destination
Options or Routing Header Type 2 are used (such as with Mobile IPv6):
rt->rt6i_nfheader_len should be substracted to rt->dst.header_len,
and not to exthdrlen.

This patch reverts to the original and correct behavior. Successfully
tested with and without IPsec activated for MH packets.

Signed-off-by: Romain Kuntz <r.kuntz@ipflavors.com>
---
 net/ipv6/ip6_output.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 5552d13..0c7c03d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1213,10 +1213,10 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		if (dst_allfrag(rt->dst.path))
 			cork->flags |= IPCORK_ALLFRAG;
 		cork->length = 0;
-		exthdrlen = (opt ? opt->opt_flen : 0) - rt->rt6i_nfheader_len;
+		exthdrlen = (opt ? opt->opt_flen : 0);
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
-		dst_exthdrlen = rt->dst.header_len;
+		dst_exthdrlen = rt->dst.header_len - rt->rt6i_nfheader_len;
 	} else {
 		rt = (struct rt6_info *)cork->dst;
 		fl6 = &inet->cork.fl.u.ip6;
-- 
1.7.2.5
