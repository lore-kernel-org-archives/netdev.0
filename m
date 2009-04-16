From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/03: nf_nat: add support for persistent mappings
Date: Thu, 16 Apr 2009 19:16:26 +0200 (MEST)
Message-ID: <20090416171625.11406.88464.sendpatchset@x2.localnet>
References: <20090416171621.11406.78609.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090416171621.11406.78609.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 98d500d66cb7940747b424b245fc6a51ecfbf005
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Apr 16 18:33:01 2009 +0200

    netfilter: nf_nat: add support for persistent mappings
    
    The removal of the SAME target accidentally removed one feature that is
    not available from the normal NAT targets so far, having multi-range
    mappings that use the same mapping for each connection from a single
    client. The current behaviour is to choose the address from the range
    based on source and destination IP, which breaks when communicating
    with sites having multiple addresses that require all connections to
    originate from the same IP address.
    
    Introduce a IP_NAT_RANGE_PERSISTENT option that controls whether the
    destination address is taken into account for selecting addresses.
    
    http://bugzilla.kernel.org/show_bug.cgi?id=12954
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index 9dc1039..8df0b7f 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -18,6 +18,7 @@ enum nf_nat_manip_type
 #define IP_NAT_RANGE_MAP_IPS 1
 #define IP_NAT_RANGE_PROTO_SPECIFIED 2
 #define IP_NAT_RANGE_PROTO_RANDOM 4
+#define IP_NAT_RANGE_PERSISTENT 8
 
 /* NAT sequence number modifications */
 struct nf_nat_seq {
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index fe65187..3229e0a 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -211,7 +211,8 @@ find_best_ips_proto(struct nf_conntrack_tuple *tuple,
 	minip = ntohl(range->min_ip);
 	maxip = ntohl(range->max_ip);
 	j = jhash_2words((__force u32)tuple->src.u3.ip,
-			 (__force u32)tuple->dst.u3.ip, 0);
+			 range->flags & IP_NAT_RANGE_PERSISTENT ?
+				(__force u32)tuple->dst.u3.ip : 0, 0);
 	j = ((u64)j * (maxip - minip + 1)) >> 32;
 	*var_ipp = htonl(minip + j);
 }
