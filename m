From: Rahul Sharma <rsharma@arista.com>
Subject: [PATCH net v2] ipv6: Prevent ipv6_find_hdr() from returning ENOENT
 for valid non-first fragments
Date: Fri, 9 Jan 2015 13:56:39 +0530
Message-ID: <CAFB3abzM2ApxMH6C7vSDJ8JikKEkE46bOH3jbsis2NiF-ieUxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 net/ipv6/exthdrs_core.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 8af3eb5..5949f87 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
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
@@ -250,9 +251,7 @@ int ipv6_find_hdr(const struct sk_buff *skb,
unsigned int *offset,

                        _frag_off = ntohs(*fp) & ~0x7;
                        if (_frag_off) {
-                               if (target < 0 &&
-                                   ((!ipv6_ext_hdr(hp->nexthdr)) ||
-                                    hp->nexthdr == NEXTHDR_NONE)) {
+                               if (target < 0) {
                                        if (fragoff)
                                                *fragoff = _frag_off;
                                        return hp->nexthdr;
--
1.7.4.4
