From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: 2.6.6: IPv6 initialisation bug
Date: Tue, 29 Jun 2004 09:59:03 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629.095903.58985982.yoshfuji@linux-ipv6.org>
References: <20040628010200.A15067@flint.arm.linux.org.uk>
	<20040629.020627.76560474.yoshfuji@linux-ipv6.org>
	<20040628184758.C9214@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rmk+lkml@arm.linux.org.uk
In-Reply-To: <20040628184758.C9214@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040628184758.C9214@flint.arm.linux.org.uk> (at Mon, 28 Jun 2004 18:47:58 +0100), Russell King <rmk+lkml@arm.linux.org.uk> says:

> On Tue, Jun 29, 2004 at 02:06:27AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B wrote:
> > In article <20040628010200.A15067@flint.arm.linux.org.uk> (at Mon, 28 Jun 2004 01:02:01 +0100), Russell King <rmk+lkml@arm.linux.org.uk> says:
> > 
> > > Ok, I've just tried 2.6.7 out on my root-NFS'd firewall with IPv6 built
> > > in, and it doesn't work because of the problem I described below.
> > :
> > > What's the solution?
> > 
> > Bring lo up before bring others up.
> > What does prevent you from doing this?
> > (Do we need some bits to do this automatically?)
> 
> When you use root-NFS, the kernel itself brings up the interfaces,
> and IPv6 immediately comes in and tries to configure itself to them,
> trying to create the routes.
> 
> Unfortunately, the kernel doesn't bring up lo first because it
> doesn't know to do that.

Okay, would you try the following patch, please?


D: Bring loopback device up first

Signed-Off-By: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv4/ipconfig.c 1.38 vs edited =====
--- 1.38/net/ipv4/ipconfig.c	2004-06-23 09:06:18 +09:00
+++ edited/net/ipv4/ipconfig.c	2004-06-29 09:53:36 +09:00
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
