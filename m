From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V2 1/9] net: frag evictor, avoid killing warm
 frag queues
Date: Fri, 30 Nov 2012 08:37:49 -0800
Message-ID: <1354293469.3299.81.camel@edumazet-glaptop>
References: <20121129161019.17754.29670.stgit@dragon>
	 <20121129161052.17754.85017.stgit@dragon>
	 <20121129.124427.1093031685966728935.davem@davemloft.net>
	 <1354227470.11754.348.camel@localhost>
	 <1354230100.3299.40.camel@edumazet-glaptop>
	 <1354269846.11754.381.camel@localhost>
	 <1354287134.3299.67.camel@edumazet-glaptop>
	 <1354290335.11754.447.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org, pablo@netfilter.org, tgraf@suug.ch,
	amwang@redhat.com, kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55321 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932472Ab2K3QiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 11:38:00 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so545618pbc.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 08:38:00 -0800 (PST)
In-Reply-To: <1354290335.11754.447.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 16:45 +0100, Jesper Dangaard Brouer wrote:
> On Fri, 2012-11-30 at 06:52 -0800, Eric Dumazet wrote:

> 
> > I dont know how you expect that many
> > datagrams being correctly reassembled with ipfrag_high_thresh=262144 
> 
> That's my point... I'm showing that its not possible, with out current
> implementation!

What I was saying is that the limits are too small, and we should
increase them for this particular need.

This has little to do with the underlying algo.

Assuming we have a hash table size of 1024 buckets, you could
easily add the following :

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 448e685..bc1bdf9 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -849,13 +849,13 @@ static inline void ip4_frags_ctl_register(void)
 static int __net_init ipv4_frags_init_net(struct net *net)
 {
 	/*
-	 * Fragment cache limits. We will commit 256K at one time. Should we
-	 * cross that limit we will prune down to 192K. This should cope with
+	 * Fragment cache limits. We will commit 4M at one time. Should we
+	 * cross that limit we will prune down to 3M. This should cope with
 	 * even the most extreme cases without allowing an attacker to
 	 * measurably harm machine performance.
 	 */
-	net->ipv4.frags.high_thresh = 256 * 1024;
-	net->ipv4.frags.low_thresh = 192 * 1024;
+	net->ipv4.frags.high_thresh = 4 << 20;
+	net->ipv4.frags.low_thresh = 3 << 20;
 	/*
 	 * Important NOTE! Fragment queue must be destroyed before MSL expires.
 	 * RFC791 is wrong proposing to prolongate timer each fragment arrival
