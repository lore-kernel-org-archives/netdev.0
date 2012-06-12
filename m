From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible deadlock in ipv6?
Date: Tue, 12 Jun 2012 11:09:44 +0200
Message-ID: <1339492184.22704.26.camel@edumazet-glaptop>
References: <4FCF6DF4.2090304@parallels.com>
	 <1338998019.26966.10.camel@edumazet-glaptop>
	 <1338998314.26966.12.camel@edumazet-glaptop>
	 <20120611.235453.953830769326224643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vdavydov@parallels.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64520 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480Ab2FLJJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 05:09:49 -0400
Received: by eeit10 with SMTP id t10so2117729eei.19
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2012 02:09:48 -0700 (PDT)
In-Reply-To: <20120611.235453.953830769326224643.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-11 at 23:54 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 06 Jun 2012 17:58:34 +0200
> 
> > And it seems this neigh_down() can be removed, its called later
> > (after dev->ip6_ptr is cleared)
> 
> It is unclear whether we need to do the the neigh_down() in both
> the 'how' and '!how' cases.  If so then we can't make this change.
> 

Hmm...

Is it expected we send traffic on device dismantle ?

If no, we could do :

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d81d026..16e0ddb 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -681,8 +681,6 @@ static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 		while ((n = *np) != NULL) {
 			if (!dev || n->dev == dev) {
 				*np = n->next;
-				if (tbl->pdestructor)
-					tbl->pdestructor(n);
 				if (n->dev)
 					dev_put(n->dev);
 				release_net(pneigh_net(n));
