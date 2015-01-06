From: Rahul Sharma <rsharma@arista.com>
Subject: [PATCH net] ipv6: Prevent ipv6_find_hdr() from returning ENOENT for
 valid non-first fragments
Date: Wed, 7 Jan 2015 03:03:20 +0530
Message-ID: <CAFB3abzYNYqtzd_n+Ym0Lo=DYbV0HPU=Tqw=stALNnu188hMKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:52069 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932811AbbAFVdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 16:33:21 -0500
Received: by mail-we0-f176.google.com with SMTP id w61so82337wes.21
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 13:33:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_find_hdr() currently assumes that the next-header field in the
fragment header of the non-first fragment is the "protocol number of
the last header" (here last header excludes any extension header
protocol numbers ) which is incorrect as per RFC2460. The next-header
value is the first header of the fragmentable part of the original
packet (which can be extension header as well).
This can create reassembly problems. For example: Fragmented
authenticated OSPFv3 packets (where AH header is inserted before the
protocol header). For the second fragment, the next header value in
the fragment header will be NEXTHDR_AUTH which is correct but
ipv6_find_hdr will return ENOENT since AH is an extension header
resulting in second fragment getting dropped. This check for the
presence of non-extension header needs to be removed.

Signed-off-by: Rahul Sharma <rsharma@arista.com>
---
--- linux-3.18.1/net/ipv6/exthdrs_core.c.orig   2015-01-06
10:25:36.411419863 -0800
+++ linux-3.18.1/net/ipv6/exthdrs_core.c        2015-01-06
10:51:45.819364986 -0800
@@ -171,10 +171,11 @@ EXPORT_SYMBOL_GPL(ipv6_find_tlv);
  * If the first fragment doesn't contain the final protocol header or
  * NEXTHDR_NONE it is considered invalid.
  *
- * Note that non-1st fragment is special case that "the protocol number
- * of last header" is "next header" field in Fragment header. In this case,
- * *offset is meaningless and fragment offset is stored in *fragoff if fragoff
- * isn't NULL.
+ * Note that non-1st fragment is special case that "the protocol number of the
+ * first header of the fragmentable part of the original packet" is
+ * "next header" field in the Fragment header. In this case, *offset is
+ * meaningless and fragment offset is stored in *fragoff if fragoff isn't
+ * NULL.
  *
  * if flags is not NULL and it's a fragment, then the frag flag
  * IP6_FH_F_FRAG will be set. If it's an AH header, the
@@ -250,9 +251,7 @@ int ipv6_find_hdr(const struct sk_buff *

                        _frag_off = ntohs(*fp) & ~0x7;
                        if (_frag_off) {
-                               if (target < 0 &&
-                                   ((!ipv6_ext_hdr(hp->nexthdr)) ||
-                                    hp->nexthdr == NEXTHDR_NONE)) {
+                               if (target < 0) {
                                        if (fragoff)
                                                *fragoff = _frag_off;
                                        return hp->nexthdr;
