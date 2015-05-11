From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code
 where it belongs
Date: Mon, 11 May 2015 15:32:45 +0200
Message-ID: <20150511133245.GA4430@salvia>
References: <554FA7A5.5020400@plumgrid.com>
 <20150510190039.GA4938@salvia>
 <554FAC3A.40701@plumgrid.com>
 <20150510192044.GA7173@salvia>
 <554FB366.7080509@plumgrid.com>
 <20150510195018.GA7877@salvia>
 <554FCE24.8020904@iogearbox.net>
 <554FD12F.2020607@iogearbox.net>
 <20150510234313.GA3176@salvia>
 <555044D8.3080606@plumgrid.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="RnlQjJ0d97Da+TV1"
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	davem@davemloft.net, jhs@mojatatu.com
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49397 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023AbbEKN2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2015 09:28:07 -0400
Content-Disposition: inline
In-Reply-To: <555044D8.3080606@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, May 10, 2015 at 10:57:44PM -0700, Alexei Starovoitov wrote:
> On 5/10/15 4:43 PM, Pablo Neira Ayuso wrote:
> >
> >The noop is patched to an unconditional branch to skip that code, but
> >the code is still there in that path, even if it's dormant.
> >
> >What the numbers show is rather simple: The more code is in the path,
> >the less performance you get, and the qdisc ingress specific code
> >embedded there is reducing performance for people that are not using
> >qdisc ingress, hence it should go where it belongs. The static key
> >cannot save you from that.
> 
> hmm, did I miss these numbers ?
> 
> My numbers are showing the opposite. There is no degradation whatsoever.
> To recap, here are the numbers from my box:
> no ingress - 37.6
> ingress on other dev - 36.5
> ingress on this dev - 28.8
> ingress on this dev + u32 - 24.1
> 
> after Daniel's two patches:
> no ingress - 37.6
> ingress on other dev - 36.5
> ingress on this dev - 36.5
> ingress on this dev + u32 - 25.2

I'm refering to the numbers and the scenario that I describe in:
http://patchwork.ozlabs.org/patch/470512/

ie. no qdisc ingress before my patch vs. no qdisc ingress after my patch.

that shows that moving that code to sch_ingress results in a
performance improvements.

Some more numbers. I intentionally added more static key code that
depends on the ingress_needed key, see attached patch, the numbers
show a clear performance drop:

Result: OK: 5049126(c5049126+d0) usec, 100000000 (60byte,0frags)
  19805404pps 9506Mb/sec (9506593920bps) errors: 100000000

Remember that the base (the results with my patch applied) is:

Result: OK: 4747078(c4747078+d0) usec, 100000000 (60byte,0frags)
  21065587pps 10111Mb/sec (10111481760bps) errors: 100000000

That's 1M pps less because of more code that is under the static key.

So I'm measuring an impact on the use of static keys. Yes, I have
jump_label support as I told to Daniel, and I can reproduce this
numbers over and over again. Perf also show that I'm measuring the
right thing.

I'm running exactly the pktgen tests with netif_receive using the
script from the patch description, so it's basically the same test
here.

My old box is a Intel(R) Core(TM) i5-3320M CPU @ 2.60GHz

lscpu on debian shows:

L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              3072K

Please, carefully read my patch description. I think you can rebuild
your work on top of this patch. Thanks.

--RnlQjJ0d97Da+TV1
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="more-static-keys.patch"

diff --git a/net/core/dev.c b/net/core/dev.c
index f5aeaf5..2a2047b1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3689,6 +3689,13 @@ ncls:
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
 
+	if (static_key_false(&ingress_needed)) {
+		int i = 0;
+
+		for (i = 0; i < 10; i++)
+			pr_info("this code depends on qdisc ingress\n");
+	}
+
 	if (skb_vlan_tag_present(skb)) {
 		if (pt_prev) {
 			ret = deliver_skb(skb, pt_prev, orig_dev);
@@ -3721,6 +3728,13 @@ ncls:
 		}
 	}
 
+	if (static_key_false(&ingress_needed)) {
+		int i = 0;
+
+		for (i = 0; i < 10; i++)
+			pr_info("this also depends on qdisc ingress\n");
+	}
+
 	if (unlikely(skb_vlan_tag_present(skb))) {
 		if (skb_vlan_tag_get_id(skb))
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -3748,6 +3762,13 @@ ncls:
 				       &skb->dev->ptype_specific);
 	}
 
+	if (static_key_false(&ingress_needed)) {
+		int i = 0;
+
+		for (i = 0; i < 10; i++)
+			pr_info("more code that depends on qdisc ingress\n");
+	}
+
 	if (pt_prev) {
 		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 			goto drop;

--RnlQjJ0d97Da+TV1--
