From: Florian Westphal <fw@strlen.de>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Mon, 27 Jun 2016 16:22:38 +0200
Message-ID: <20160627142238.GA10613@breakpoint.cc>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Marc Dionne <marc.c.dionne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:42268 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751664AbcF0OWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 10:22:44 -0400
Content-Disposition: inline
In-Reply-To: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marc Dionne <marc.c.dionne@gmail.com> wrote:
> Hi,
> 
> I've been seeing issues with 4.7-rc kernels with some of our
> multi-thread test cases.  I've bisected it down to this commit:
> 
>   commit 71d8c47fc653711c41bc3282e5b0e605b3727956
>   Author: Pablo Neira Ayuso <pablo@netfilter.org>
>   Date:   Sun May 1 00:28:40 2016 +0200
> 
>       netfilter: conntrack: introduce clash resolution on insertion race
> 
> 
> .. and verified that reverting the commit restores the expected behaviour.

Does this change help?

Subject: Restrict clash resolution to original direction

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -721,13 +721,18 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	   not in the hash.  If there is, we lost race. */
 	hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
-				    zone, net))
-			goto out;
+				    zone, net)) {
+			nf_ct_add_to_dying_list(ct);
+			ret = nf_ct_resolve_clash(net, skb, ctinfo, h);
+			goto dying;
+		}
 
 	hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[reply_hash], hnnode)
 		if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_REPLY].tuple,
-				    zone, net))
-			goto out;
+				    zone, net)) {
+			nf_ct_add_to_dying_list(ct);
+			goto dying;
+		}
 
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
@@ -763,9 +768,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 				 IPCT_RELATED : IPCT_NEW, ct);
 	return NF_ACCEPT;
 
-out:
-	nf_ct_add_to_dying_list(ct);
-	ret = nf_ct_resolve_clash(net, skb, ctinfo, h);
 dying:
 	nf_conntrack_double_unlock(hash, reply_hash);
 	NF_CT_STAT_INC(net, insert_failed);
