From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Sat, 25 Dec 2004 13:56:50 -0800
Message-ID: <20041225135650.55dca29f.davem@davemloft.net>
References: <Pine.LNX.4.44.0409200806460.22679-100000@netcore.fi>
	<20040920.152012.114156249.yoshfuji@linux-ipv6.org>
	<20040921195752.015e3d1d.davem@davemloft.net>
	<20040922.120630.96674716.yoshfuji@linux-ipv6.org>
	<20041225115415.GI24142@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@oss.sgi.com,
        usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20041225115415.GI24142@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 25 Dec 2004 12:54:15 +0100
Harald Welte <laforge@gnumonks.org> wrote:

> As far as I can see (please correct me) no such patch was included so
> far, at least with 2.6.10-rc3 I still have the old behaviour.

This specific issue was not resolved, but the issue of loading
the ipv6 module after bringing up your interfaces was fixed
via this patch below.

I've also discussed this with Herbert Xu a bit, and no one
solution is really clear yet.  IPV4 has similar issues, just
in a slightly different form.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/15 14:09:05-08:00 davem@nuts.davemloft.net 
#   [IPV6]: Temp fix for ipv6 link-local address problem.
#   
#   Make sure loopback_dev, if up, has the ipv6 bits
#   for it setup before the addrconf netdev notifier
#   is registered.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv6/addrconf.c
#   2004/11/15 14:08:09-08:00 davem@nuts.davemloft.net +23 -0
#   [IPV6]: Temp fix for ipv6 link-local address problem.
# 
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-12-25 13:26:13 -08:00
+++ b/net/ipv6/addrconf.c	2004-12-25 13:26:13 -08:00
@@ -3387,6 +3387,29 @@
 
 void __init addrconf_init(void)
 {
+	/* The addrconf netdev notifier requires that loopback_dev
+	 * has it's ipv6 private information allocated and setup
+	 * before it can bring up and give link-local addresses
+	 * to other devices which are up.
+	 *
+	 * Unfortunately, loopback_dev is not necessarily the first
+	 * entry in the global dev_base list of net devices.  In fact,
+	 * it is likely to be the very last entry on that list.
+	 * So this causes the notifier registry below to try and
+	 * give link-local addresses to all devices besides loopback_dev
+	 * first, then loopback_dev, which cases all the non-loopback_dev
+	 * devices to fail to get a link-local address.
+	 *
+	 * So, as a temporary fix, register loopback_dev first by hand.
+	 * Longer term, all of the dependencies ipv6 has upon the loopback
+	 * device and it being up should be removed.
+	 */
+	rtnl_lock();
+	addrconf_notify(&ipv6_dev_notf, NETDEV_REGISTER, &loopback_dev);
+	if (loopback_dev.flags & IFF_UP)
+		addrconf_notify(&ipv6_dev_notf, NETDEV_UP, &loopback_dev);
+	rtnl_unlock();
+
 	register_netdevice_notifier(&ipv6_dev_notf);
 
 #ifdef CONFIG_IPV6_PRIVACY
