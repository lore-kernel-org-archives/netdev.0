From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.10-rc2: still no ipv6 link-local addresses
Date: Mon, 15 Nov 2004 12:35:58 -0800
Message-ID: <20041115123558.7965d6e2.davem@davemloft.net>
References: <Pine.SOC.4.61.0411151159230.3321@math.ut.ee>
	<E1CTgOY-00019E-Nq@rhn.tartu-labor>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <E1CTgOY-00019E-Nq@rhn.tartu-labor>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Nov 2004 14:55:46 +0200
Meelis Roos <mroos@linux.ee> wrote:

> MR> I tried 2.6.10-rc2 and it still does not give lipv6 link-local address 
> MR> to Ethernet interfaces (I tried NICs with e100 and 8139too drivers).
> 
> Hmm, eth1 with 8139too has gotten a link-local address meanwhile - maybe
> after up'ing the interface. e100 is my primary NIC and is up and working
> but still does not have link-local address.

I know what the problem is, I discovered this while analyzing another
ipv6 bug with Herbert Xu over the past week.  I'm still undecided on
how to fix this, though.

It only happens if you first bring your interfaces up, then the
ipv6 module gets loaded.  The problem will never occur if either:

1) You build ipv6 statically
2) You bring your interfaces up after the ipv6 module loads.

The problem is in addrconf_init().  The registry of the netdev
notifier for the addrconf layer assumes that loopback will be
the first device it does UP processing on.  If that is not the
case, then addition of the link-local addresses for other devices
will fail.

This is because link-local address addition in ipv6 uses a dummy
route which uses loopback_dev as it's netdev reference.

So if loopback_dev does not have it's ipv6 specific info setup yet,
the creation of that dummy route for the link-local address of other
devices will fail.

In general, I am incredibly displeased with all of the loopback
device dependencies in the ipv6 code and I'm going to work to
gradually remove them all.  They are the source of many problems,
and this bug in particular.

Here is a hack fix to this problem which is probably what I'll
send to Linus for 2.6.10

===== net/ipv6/addrconf.c 1.119 vs edited =====
--- 1.119/net/ipv6/addrconf.c	2004-11-11 15:07:25 -08:00
+++ edited/net/ipv6/addrconf.c	2004-11-15 12:22:22 -08:00
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
