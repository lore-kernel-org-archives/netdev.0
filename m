From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Mon, 1 Nov 2004 11:34:34 -0600
Message-ID: <20041101173434.GA12437@lists.us.dell.com>
References: <20041030013700.GA21540@lists.us.dell.com> <E1CNiOT-0008GU-00@gondolin.me.apana.org.au> <20041030030936.GA25102@lists.us.dell.com> <1099163419.1039.97.camel@jzny.localdomain> <20041101044433.GA18772@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20041101044433.GA18772@lists.us.dell.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 31, 2004 at 10:44:33PM -0600, Matt Domsch wrote:
> I think -EOVERFLOW would be appropriate return for dev->addr_len >
> sizeof sa_data, yes?
> 
> I'd prefer though, that an "obsolete" function, be marked as such
> somehow (perhaps print a net_ratelimit()ed KERN_DEBUG message when
> it's called telling apps to move to rtnetlink), and that the behaviour
> for everything except overflow be consistent with the prior
> implementation, at least until such a time that all the apps in the
> distros are converted to rtnetlink.

How's this look?

This makes ioctl(SIOCIFHWADDR) behavior in 2.6 consistent with that of
previous kernels wherever possible.  It returns -EOVERFLOW if it can't
represent the address, zeros the data if dev->addr_len is zero, and
prints a KERN_DEBUG message telling people to fix their applications
to use rtnetlink.

Compiles on x86 and x86-64 cleanly.

Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>


-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

===== net/core/dev.c 1.169 vs edited =====
--- 1.169/net/core/dev.c	2004-10-26 11:09:33 -05:00
+++ edited/net/core/dev.c	2004-11-01 11:20:25 -06:00
@@ -2375,8 +2375,16 @@
 			return dev_set_mtu(dev, ifr->ifr_mtu);
 
 		case SIOCGIFHWADDR:
-			memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
-			       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
+			if (net_ratelimit())
+				printk(KERN_DEBUG "Warning: %s uses obsolete ioctl(SIOCGIFHWADDR), please convert it to rtnetlink(3,7)\n", current->comm);
+
+			if ((size_t) dev->addr_len > sizeof ifr->ifr_hwaddr.sa_data)
+				return -EOVERFLOW;
+			else if (!dev->addr_len)
+				memset(ifr->ifr_hwaddr.sa_data, 0, sizeof ifr->ifr_hwaddr.sa_data);
+			else
+				memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
+				       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
 			ifr->ifr_hwaddr.sa_family = dev->type;
 			return 0;
 
