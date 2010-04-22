From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: IPv6: race condition in __ipv6_ifa_notify() and dst_free() ?
Date: Thu, 22 Apr 2010 09:17:03 -0700
Message-ID: <20100422091703.463665c0@nehalam>
References: <20100420174401.GB1334@midget.suse.cz>
	<20100421213429.GA2799@midget.suse.cz>
	<20100422023211.GA7109@gondor.apana.org.au>
	<20100422.004324.67422011.davem@davemloft.net>
	<20100422142506.GA15858@gondor.apana.org.au>
	<20100422154908.GA31568@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37948 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967Ab0DVQRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 12:17:19 -0400
In-Reply-To: <20100422154908.GA31568@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Apr 2010 17:49:08 +0200
Jiri Bohac <jbohac@suse.cz> wrote:

> On Thu, Apr 22, 2010 at 10:25:06PM +0800, Herbert Xu wrote:
> > This patch fixes this by using the DADFAILED bit to synchronise
> > the two paths while holding the ifp lock.  It relies on the fact
> > that the TENTATIVE bit is always set during DAD, and that the
> > DADFAILED bit is only set on failure.
> 
> But the addr_dad_failure()->...->ipv6_del_addr() path will
> still race with any other path calling ipv6_del_addr() (e.g. a
> manual address removal). Won't it?
> 
> I still don't see why __ipv6_ifa_notify() needs to call
> dst_free(). Shouldn't that be dst_release() instead, to drop the
> reference obtained by dst_hold(&ifp->rt->u.dst)?

Yes, some more locking and race condition management is needed.

Something like the following (untested):

--- a/net/ipv6/addrconf.c	2010-04-22 09:11:54.594827858 -0700
+++ b/net/ipv6/addrconf.c	2010-04-22 09:15:59.224631752 -0700
@@ -720,13 +720,18 @@ static void ipv6_del_addr(struct inet6_i
 
 	hash = ipv6_addr_hash(&ifp->addr);
 
+	write_lock_bh(&idev->lock);
+	if (ifp->dead) {
+		write_unlock(&idev->lock); /* lost race with DAD */
+		return;
+	}
+
 	ifp->dead = 1;
 
-	spin_lock_bh(&addrconf_hash_lock);
+	spin_lock(&addrconf_hash_lock);
 	hlist_del_init_rcu(&ifp->addr_lst);
-	spin_unlock_bh(&addrconf_hash_lock);
+	spin_unlock(&addrconf_hash_lock);
 
-	write_lock_bh(&idev->lock);
 #ifdef CONFIG_IPV6_PRIVACY
 	if (ifp->flags&IFA_F_TEMPORARY) {
 		list_del(&ifp->tmp_list);



