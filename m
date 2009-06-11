From: Patrick McHardy <kaber@trash.net>
Subject: Re: netfilter 00/31: netfilter update
Date: Thu, 11 Jun 2009 16:54:49 +0200
Message-ID: <4A311AB9.3060205@trash.net>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>	<20090610.234618.116984779.davem@davemloft.net> <20090611.010827.193702616.davem@davemloft.net> <4A310C9E.3050904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000201060308070708080601"
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54333 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763307AbZFKOys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 10:54:48 -0400
In-Reply-To: <4A310C9E.3050904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000201060308070708080601
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> David Miller wrote:
>> This stuff isn't ready, sorry I had to undo my pull:
>>
>> net/netfilter/nf_conntrack_proto_tcp.c: In function 'tcp_packet':
>> net/netfilter/nf_conntrack_proto_tcp.c:947: error: 'tcp_lock' 
>> undeclared (first use in this function)
>> net/netfilter/nf_conntrack_proto_tcp.c:947: error: (Each undeclared 
>> identifier is reported only once
>> net/netfilter/nf_conntrack_proto_tcp.c:947: error: for each function 
>> it appears in.)
>> make[2]: *** [net/netfilter/nf_conntrack_proto_tcp.o] Error 1
>> make[2]: *** Waiting for unfinished jobs....
> 
> That odd, my tree doesn't have a single reference to tcp_lock left.
> I'll check what went wrong, sorry.

This came in through a net-2.6.git merge after I cloned my tree. I
usually do a test merge of a fresh clone of your tree with mine before
sending the pull request, but forgot this time. I guess I'll add this
step to my pull-request-script to make sure it doesn't happen again.

I've now merged your latest tree and added the attached patch on top
to fix the compile error. This will unfortunately leave a small window
of commits that don't compile cleanly. If you prefer to have this fixed
differently, please let me know, otherwise

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


--------------000201060308070708080601
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 334a47f6345560af047f164c356d71c3226965d5
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jun 11 16:16:09 2009 +0200

    netfilter: nf_ct_tcp: fix up build after merge
    
    Replace the last occurence of tcp_lock by the per-conntrack lock.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 5142e60..33fc0a4 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -944,7 +944,7 @@ static int tcp_packet(struct nf_conn *ct,
 		    && (ct->proto.tcp.seen[!dir].flags & IP_CT_TCP_FLAG_MAXACK_SET)
 		    && before(ntohl(th->seq), ct->proto.tcp.seen[!dir].td_maxack)) {
 			/* Invalid RST  */
-			write_unlock_bh(&tcp_lock);
+			spin_unlock_bh(&ct->lock);
 			if (LOG_INVALID(net, IPPROTO_TCP))
 				nf_log_packet(pf, 0, skb, NULL, NULL, NULL,
 					  "nf_ct_tcp: invalid RST ");

--------------000201060308070708080601--
