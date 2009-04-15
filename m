From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 12954] New: SAMEIP --nodst functionality gone
 missing
Date: Wed, 15 Apr 2009 13:53:25 +0200
Message-ID: <49E5CAB5.3060605@trash.net>
References: <bug-12954-10286@http.bugzilla.kernel.org/> <20090407143509.05ab3b28.akpm@linux-foundation.org> <Pine.LNX.4.62.0904080941370.10428@wlug.westbo.se> <49DCC3A0.7050001@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020606070008020805070305"
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, berni@birkenwald.de,
	netfilter-devel@vger.kernel.org
To: Martin Josefsson <gandalf@mjufs.se>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49DCC3A0.7050001@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020606070008020805070305
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> [Resend to mailing list, I didn't notice this had left bugzilla]
> 
> Martin Josefsson wrote:
>> Patrick, how about making the ipaddress selection based on only client 
>> ipaddress behaviour selectable with an SNAT parameter if the problem 
>> with the patch is that the distribution can be uneven for a small 
>> number of clients?
> 
> Actually I think the results back then were incorrect or it was
> just bad luck or something. Ideally we would just enable this
> unconditionally I think. I'll do some testing of the distribution
> myself during the next days and see how it goes.

The distribution did suffer noticably in some cases, so offering
this optionally seems better.

How about this patch? If the IP_NAT_RANGE_PERSISTENT flag is set
on a NAT range, we ignore the destination address in the selection.


--------------020606070008020805070305
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

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

--------------020606070008020805070305--
