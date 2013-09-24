From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 05:35:05 +0200
Message-ID: <20130924033505.GB22393@order.stressinduktion.org>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com> <1379980991.3165.37.camel@edumazet-glaptop> <20130924023038.GA22393@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46741 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab3IXDfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 23:35:08 -0400
Content-Disposition: inline
In-Reply-To: <20130924023038.GA22393@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 04:30:38AM +0200, Hannes Frederic Sowa wrote:
> On Mon, Sep 23, 2013 at 05:03:11PM -0700, Eric Dumazet wrote:
> > On Mon, 2013-09-23 at 15:41 -0700, Tom Herbert wrote:
> > 
> > > +#ifdef CONFIG_NET_TOEPLITZ
> > > +	toeplitz_net = toeplitz_alloc();
> > > +	if (!toeplitz_net)
> > > +		goto out;
> > > +
> > > +	toeplitz_init(toeplitz_net, NULL);
> > > +#endif
> > > +
> > 
> > Hmm
> > 
> > 1) Security alert here.
> > 
> > Many devices (lets say Android phones) have no entropy at this point,
> > all devices will have same toeplitz key.
> > 
> > Check build_ehash_secret() for a possible point for the feeding of the
> > key. (and commit 08dcdbf6a7b9d14c2302c5bd0c5390ddf122f664 )
> > 
> > If hardware toeplitz is ever used, we want to make sure every host uses
> > a private and hidden Toeplitz key.
> build_ehash_secret builds up the data which seeds fragmentation ids, ephermal
> port randomization etc. Could we drop the check of sock->type? I guess the
> idea was that in-kernel sockets of type raw/udp do not seed the keys when no
> entropy is available?

Would this be better (I checked inet_ehash_secret, ipv6_hash_secret
and net_secret to actual get initialized)?

[PATCH] inet: initialize hash secret values on first non-kernel socket creation

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/af_inet.c  | 5 ++---
 net/ipv6/af_inet6.c | 4 +---
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7a1874b..489834a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -286,9 +286,8 @@ static int inet_create(struct net *net, struct socket *sock, int protocol,
 	int try_loading_module = 0;
 	int err;
 
-	if (unlikely(!inet_ehash_secret))
-		if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
-			build_ehash_secret();
+	if (unlikely(!inet_ehash_secret && !kern))
+		build_ehash_secret();
 
 	sock->state = SS_UNCONNECTED;
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 7c96100..dbf8c35 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -110,9 +110,7 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 	int try_loading_module = 0;
 	int err;
 
-	if (sock->type != SOCK_RAW &&
-	    sock->type != SOCK_DGRAM &&
-	    !inet_ehash_secret)
+	if (unlikely(!inet_ehash_secret && !kern))
 		build_ehash_secret();
 
 	/* Look for the requested type/protocol pair. */
-- 
1.8.3.1
