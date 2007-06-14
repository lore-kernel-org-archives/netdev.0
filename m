From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cannot set IP for ethernet
Date: Thu, 14 Jun 2007 13:53:41 +1000
Message-ID: <20070614035341.GA21010@gondor.apana.org.au>
References: <200706121441.13561.oliver@neukum.org> <466EA861.2070509@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Neukum <oliver@neukum.org>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4157 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752190AbXFNDyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 23:54:00 -0400
Content-Disposition: inline
In-Reply-To: <466EA861.2070509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 04:06:25PM +0200, Patrick McHardy wrote:
> Oliver Neukum wrote:
> > with 2.6.22-rc4-git2 I am getting errors when setting IP for ethernet
> > interfaces:
> > 
> > ioctl(4, SIOCSIFADDR, 0x7fff94931600)   = -1 ENOBUFS (No buffer space available)
> > 
> > The error is independant of the interface. It happens to all interfaces.
> > There's nothing in the syslog.
> > 
> > valisk:/home/oliver # uname -a
> > Linux valisk 2.6.22-rc4-git2-default #3 SMP Tue Jun 12 13:27:54 CEST 2007 x86_64 x86_64 x86_64 GNU/Linux
> 
> This can happen if the initial inetdev allocation when the netdevice is
> registered fails. I think it would make sense to try to allocate again
> when adding addresses in that case, otherwise there is no way of
> recovery other than unregistering and registering the device again.

Actually in his case it's because 2.6.22-rc4-git2 doesn't have the
following changeset.

Let me have a think about your approach too.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
commit 6363097cc4d182f93788131b5d8f72aa91d950a0
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Thu Jun 7 18:35:38 2007 -0700

    [IPV4]: Do not remove idev when addresses are cleared

    Now that we create idev before addresses are added, it no longer makes
    sense to remove them when addresses are all deleted.

    Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
    Signed-off-by: David S. Miller <davem@davemloft.net>

6363097cc4d182f93788131b5d8f72aa91d950a0
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index fa97b96..abf6352 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -327,12 +327,8 @@ static void __inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 		}
 
 	}
-	if (destroy) {
+	if (destroy)
 		inet_free_ifa(ifa1);
-
-		if (!in_dev->ifa_list)
-			inetdev_destroy(in_dev);
-	}
 }
 
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
