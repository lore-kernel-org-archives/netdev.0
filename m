From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Mon, 1 Nov 2004 14:38:21 -0600
Message-ID: <20041101203821.GA15086@lists.us.dell.com>
References: <20041030013700.GA21540@lists.us.dell.com> <E1CNiOT-0008GU-00@gondolin.me.apana.org.au> <20041030030936.GA25102@lists.us.dell.com> <1099163419.1039.97.camel@jzny.localdomain> <20041101044433.GA18772@lists.us.dell.com> <20041101173434.GA12437@lists.us.dell.com> <20041101202754.GA23149@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jamal <hadi@cyberus.ca>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20041101202754.GA23149@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 02, 2004 at 07:27:54AM +1100, Herbert Xu wrote:
> Same problem as before.  If dev->addr_len is greater than zero but less
> than sizeof ifr->ifr_hwaddr.sa_data, then you've got garbage in there.
> Zero is not a special case.

OK, I'll unconditionally clear it all first.  How's this?

Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

===== net/core/dev.c 1.169 vs edited =====
--- 1.169/net/core/dev.c	2004-10-26 11:09:33 -05:00
+++ edited/net/core/dev.c	2004-11-01 14:35:02 -06:00
@@ -2375,6 +2375,12 @@
 			return dev_set_mtu(dev, ifr->ifr_mtu);
 
 		case SIOCGIFHWADDR:
+			if (net_ratelimit())
+				printk(KERN_DEBUG "Warning: %s uses obsolete ioctl(SIOCGIFHWADDR), please convert it to rtnetlink(3,7)\n", current->comm);
+
+			if ((size_t) dev->addr_len > sizeof ifr->ifr_hwaddr.sa_data)
+				return -EOVERFLOW;
+			memset(ifr->ifr_hwaddr.sa_data, 0, sizeof ifr->ifr_hwaddr.sa_data);
 			memcpy(ifr->ifr_hwaddr.sa_data, dev->dev_addr,
 			       min(sizeof ifr->ifr_hwaddr.sa_data, (size_t) dev->addr_len));
 			ifr->ifr_hwaddr.sa_family = dev->type;
