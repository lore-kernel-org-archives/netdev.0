From: David Stevens <dlstevens@us.ibm.com>
Subject: MLD compatibility mode doesn't account for extension headers [PATCH]
Date: Fri, 21 Nov 2003 17:08:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF7F1DDE00.E61D92DC-ON88256DE6.00004F45@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE775DF93C9D58f9e8a93df938690918c07BBE775DF93C9D5"
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE775DF93C9D58f9e8a93df938690918c07BBE775DF93C9D5
Content-type: text/plain; charset=US-ASCII





Dave,
      The MLD v1 compatibility mode checks don't account for the
fact that extension headers are included in the ipv6 payload_len field.
That makes MLDv1 queries that include extension headers (like
Router Alert) appear to be v2 packets.
      The below patch fixes the problem.

                              +-DLS

--- linux-2.6.0-test9-bk23F2/net/ipv6/mcast.c   2003-11-21 15:53:23.916402736 -0800
+++ linux-2.6.0-test9-bk23F3/net/ipv6/mcast.c   2003-11-21 15:51:31.360513832 -0800
@@ -1017,7 +1017,9 @@
      if (!pskb_may_pull(skb, sizeof(struct in6_addr)))
            return -EINVAL;

-     len = ntohs(skb->nh.ipv6h->payload_len);
+     /* compute payload length excluding extension headers */
+     len = ntohs(skb->nh.ipv6h->payload_len) + sizeof(struct ipv6hdr);
+     len -= (char *)skb->h.raw - (char *)skb->nh.ipv6h;

      /* Drop queries with not link local source */
      if (!(ipv6_addr_type(&skb->nh.ipv6h->saddr)&IPV6_ADDR_LINKLOCAL))

(See attached file: MLDext.patch)
--0__=07BBE775DF93C9D58f9e8a93df938690918c07BBE775DF93C9D5
Content-type: application/octet-stream;
	name="MLDext.patch"
Content-Disposition: attachment; filename="MLDext.patch"
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4wLXRlc3Q5LWJrMjNGMi9uZXQvaXB2Ni9tY2FzdC5jCTIwMDMtMTEtMjEg
MTU6NTM6MjMuOTE2NDAyNzM2IC0wODAwCisrKyBsaW51eC0yLjYuMC10ZXN0OS1iazIzRjMvbmV0
L2lwdjYvbWNhc3QuYwkyMDAzLTExLTIxIDE1OjUxOjMxLjM2MDUxMzgzMiAtMDgwMApAQCAtMTAx
Nyw3ICsxMDE3LDkgQEAKIAlpZiAoIXBza2JfbWF5X3B1bGwoc2tiLCBzaXplb2Yoc3RydWN0IGlu
Nl9hZGRyKSkpCiAJCXJldHVybiAtRUlOVkFMOwogCi0JbGVuID0gbnRvaHMoc2tiLT5uaC5pcHY2
aC0+cGF5bG9hZF9sZW4pOworCS8qIGNvbXB1dGUgcGF5bG9hZCBsZW5ndGggZXhjbHVkaW5nIGV4
dGVuc2lvbiBoZWFkZXJzICovCisJbGVuID0gbnRvaHMoc2tiLT5uaC5pcHY2aC0+cGF5bG9hZF9s
ZW4pICsgc2l6ZW9mKHN0cnVjdCBpcHY2aGRyKTsKKwlsZW4gLT0gKGNoYXIgKilza2ItPmgucmF3
IC0gKGNoYXIgKilza2ItPm5oLmlwdjZoOyAKIAogCS8qIERyb3AgcXVlcmllcyB3aXRoIG5vdCBs
aW5rIGxvY2FsIHNvdXJjZSAqLwogCWlmICghKGlwdjZfYWRkcl90eXBlKCZza2ItPm5oLmlwdjZo
LT5zYWRkcikmSVBWNl9BRERSX0xJTktMT0NBTCkpCg==

--0__=07BBE775DF93C9D58f9e8a93df938690918c07BBE775DF93C9D5--
