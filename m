From: Patrick McHardy <kaber@trash.net>
Subject: Re: cannot set IP for ethernet
Date: Tue, 12 Jun 2007 16:06:25 +0200
Message-ID: <466EA861.2070509@trash.net>
References: <200706121441.13561.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020208040209090108060507"
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37019 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbXFLOJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 10:09:18 -0400
In-Reply-To: <200706121441.13561.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020208040209090108060507
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Oliver Neukum wrote:
> with 2.6.22-rc4-git2 I am getting errors when setting IP for ethernet
> interfaces:
> 
> ioctl(4, SIOCSIFADDR, 0x7fff94931600)   = -1 ENOBUFS (No buffer space available)
> 
> The error is independant of the interface. It happens to all interfaces.
> There's nothing in the syslog.
> 
> valisk:/home/oliver # uname -a
> Linux valisk 2.6.22-rc4-git2-default #3 SMP Tue Jun 12 13:27:54 CEST 2007 x86_64 x86_64 x86_64 GNU/Linux


This can happen if the initial inetdev allocation when the netdevice is
registered fails. I think it would make sense to try to allocate again
when adding addresses in that case, otherwise there is no way of
recovery other than unregistering and registering the device again.


--------------020208040209090108060507
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index abf6352..dc77e91 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -401,8 +401,11 @@ static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
 	ASSERT_RTNL();
 
 	if (!in_dev) {
-		inet_free_ifa(ifa);
-		return -ENOBUFS;
+		in_dev = inetdev_init(dev);
+		if (!in_dev) {
+			inet_free_ifa(ifa);
+			return -ENOBUFS;
+		}
 	}
 	ipv4_devconf_setall(in_dev);
 	if (ifa->ifa_dev != in_dev) {
@@ -514,8 +517,11 @@ static struct in_ifaddr *rtm_to_ifaddr(struct nlmsghdr *nlh)
 
 	in_dev = __in_dev_get_rtnl(dev);
 	if (in_dev == NULL) {
-		err = -ENOBUFS;
-		goto errout;
+		in_dev = inetdev_init(dev);
+		if (!in_dev) {
+			err = -ENOBUFS;
+			goto errout;
+		}
 	}
 
 	ipv4_devconf_setall(in_dev);

--------------020208040209090108060507--
