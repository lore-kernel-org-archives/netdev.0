From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.6: IPv6 initialisation bug
Date: Mon, 05 Jul 2004 12:33:21 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705.123321.91002396.yoshfuji@linux-ipv6.org>
References: <20040628184758.C9214@flint.arm.linux.org.uk>
	<20040629.095903.58985982.yoshfuji@linux-ipv6.org>
	<20040704170259.A16596@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmk+lkml@arm.linux.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040704170259.A16596@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040704170259.A16596@flint.arm.linux.org.uk> (at Sun, 4 Jul 2004 17:02:59 +0100), Russell King <rmk+lkml@arm.linux.org.uk> says:

> On Tue, Jun 29, 2004 at 09:59:03AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B wrote:
> > In article <20040628184758.C9214@flint.arm.linux.org.uk> (at Mon, 28 Jun 2004 18:47:58 +0100), Russell King <rmk+lkml@arm.linux.org.uk> says:
> > > On Tue, Jun 29, 2004 at 02:06:27AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B wrote:
> > > > In article <20040628010200.A15067@flint.arm.linux.org.uk> (at Mon, 28 Jun 2004 01:02:01 +0100), Russell King <rmk+lkml@arm.linux.org.uk> says:
> > > > 
> > > > > Ok, I've just tried 2.6.7 out on my root-NFS'd firewall with IPv6 built
> > > > > in, and it doesn't work because of the problem I described below.
> > > > :
> > > > > What's the solution?
> > > > 
> > > > Bring lo up before bring others up.
> > > > What does prevent you from doing this?
> > > > (Do we need some bits to do this automatically?)
> > > 
> > > When you use root-NFS, the kernel itself brings up the interfaces,
> > > and IPv6 immediately comes in and tries to configure itself to them,
> > > trying to create the routes.
> > > 
> > > Unfortunately, the kernel doesn't bring up lo first because it
> > > doesn't know to do that.
> > 
> > Okay, would you try the following patch, please?
> 
> This does appear to fix the problem.

Thanks.

David, please apply.

---------------
[IPV6] Bring lo up before setting other interface up.

IPv6 was not configured appropriately without lo.
Noticed by / tested by Russell King <rmk+lkml@arm.linux.org.uk>.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv4/ipconfig.c 1.39 vs edited =====
--- 1.39/net/ipv4/ipconfig.c	2004-07-01 07:26:09 +09:00
+++ edited/net/ipv4/ipconfig.c	2004-07-05 12:22:27 +09:00
@@ -183,7 +183,14 @@
 
 	last = &ic_first_dev;
 	rtnl_shlock();
+
+	/* bring loopback device up first */
+	if (dev_change_flags(&loopback_dev, loopback_dev.flags | IFF_UP) < 0)
+		printk(KERN_ERR "IP-Config: Failed to open %s\n", loopback_dev.name);
+
 	for (dev = dev_base; dev; dev = dev->next) {
+		if (dev == &loopback_dev)
+			continue;
 		if (user_dev_name[0] ? !strcmp(dev->name, user_dev_name) :
 		    (!(dev->flags & IFF_LOOPBACK) &&
 		     (dev->flags & (IFF_POINTOPOINT|IFF_BROADCAST)) &&


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
