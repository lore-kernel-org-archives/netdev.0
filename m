From: Patrick McHardy <kaber@trash.net>
Subject: Re: ipv4_get_l4proto: Frag of proto 17
Date: Sat, 01 Sep 2007 18:19:17 +0200
Message-ID: <46D99105.8030302@trash.net>
References: <Pine.SOC.4.64.0708211355310.24028@math.ut.ee> <46D66D00.7060801@trash.net> <Pine.SOC.4.64.0708301557400.9520@math.ut.ee> <46D8F87A.1080604@trash.net> <Pine.SOC.4.64.0709011803450.14157@math.ut.ee>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040501020701030803030000"
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59889 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755056AbXIAQT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 12:19:28 -0400
In-Reply-To: <Pine.SOC.4.64.0709011803450.14157@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040501020701030803030000
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Meelis Roos wrote:
>>I'm guessing that its ICMP errors containing UDP fragments.
>>
>>Could you add a WARN_ON(1) to ipv4_get_l4proto() in
>>net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c to verify
>>this?
> 
> 
> Yes, it seems to be an ICMP error:
> 
> WARNING: at net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c:93 ipv4_get_l4proto()
>  [<c0103447>] show_trace_log_lvl+0x1a/0x2f
>  [<c0103f2e>] show_trace+0x12/0x14
>  [<c0103f45>] dump_stack+0x15/0x17
>  [<f8cc60fc>] ipv4_get_l4proto+0x78/0xc0 [nf_conntrack_ipv4]
>  [<f8d14fc4>] nf_ct_get_tuplepr+0x45/0xae [nf_conntrack]
>  [<f8cc6777>] icmp_error+0x185/0x1f6 [nf_conntrack_ipv4]


Thanks for testing. This patch removes the error message since its
perfectly valid for ICMP tracking to hand in a fragmented packet.


--------------040501020701030803030000
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NETFILTER]: nf_conntrack_ipv4: fix "Frag of proto ..." messages

Since we're now using a generic tuple decoding function in ICMP
connection tracking, ipv4_get_l4proto() might get called with a
fragmented packet from within an ICMP error. Remove the error
message we used to print when this happens.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4846f19dbc2c1aca93784b08b9e3884ab8c36426
tree 86312e905ea0126863ff701088c94c6641b5e53b
parent 91574ca32eb052b31c976581e9723735e9acb53f
author Patrick McHardy <kaber@trash.net> Sat, 01 Sep 2007 18:17:13 +0200
committer Patrick McHardy <kaber@trash.net> Sat, 01 Sep 2007 18:17:13 +0200

 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index d9b5177..53cb177 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -87,14 +87,10 @@ static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 	if (iph == NULL)
 		return -NF_DROP;
 
-	/* Never happen */
-	if (iph->frag_off & htons(IP_OFFSET)) {
-		if (net_ratelimit()) {
-			printk(KERN_ERR "ipv4_get_l4proto: Frag of proto %u\n",
-			iph->protocol);
-		}
+	/* Conntrack defragments packets, we might still see fragments
+	 * inside ICMP packets though. */
+	if (iph->frag_off & htons(IP_OFFSET))
 		return -NF_DROP;
-	}
 
 	*dataoff = nhoff + (iph->ihl << 2);
 	*protonum = iph->protocol;

--------------040501020701030803030000--
