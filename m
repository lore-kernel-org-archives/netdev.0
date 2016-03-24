From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: mlxsw: avoid unused variable warnings
Date: Thu, 24 Mar 2016 14:14:26 +0100
Message-ID: <4334841.LFOAxr44mX@wuerfel>
References: <1458751080-2044921-1-git-send-email-arnd@arndb.de> <20160323165111.GJ5250@lunn.ch> <20160323.143805.310789862506977932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: andrew@lunn.ch, jiri@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:55957 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbcCXNOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 09:14:46 -0400
In-Reply-To: <20160323.143805.310789862506977932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 March 2016 14:38:05 David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Wed, 23 Mar 2016 17:51:11 +0100
> 
> > On Wed, Mar 23, 2016 at 05:37:38PM +0100, Arnd Bergmann wrote:
> >> dev_dbg_ratelimited() is a macro that ignores its arguments when DEBUG is
> >> not set, which can lead to unused variable warnings:
> >> 
> >> ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cqe_sdq_handle':
> >> ethernet/mellanox/mlxsw/pci.c:646:18: warning: unused variable 'pdev' [-Wunused-variable]
> >> ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cqe_rdq_handle':
> >> ethernet/mellanox/mlxsw/pci.c:671:18: warning: unused variable 'pdev' [-Wunused-variable]
> >> 
> >> This changes the mlxsw driver to remove the local variables we get
> >> warnings for and instead pass the device directly into the API.
> > 
> > Hi Arnd
> > 
> > Would it not be better to fix the macro?
> > 
> > I think the issue is that dev_dbg_ratelimited calls no_printk(),
> > without making use of dev. So how about:
> > 
> > #define dev_dbg_ratelimited(dev, fmt, ...)                              \
> > ({                                                                      \
> >         if (0)                                                          \
> >                 dev_printk(KERN_DEBUG, dev, fmt, ##__VA_ARGS__);        \
> > })
> > 
> > This follows the pattern for other macros for when DEBUG is not defined.
> 
> Yeah, this is probably a better way to fix this problem.

Makes sense. I was thrown off by how a related patch recently
modified the no_printk() definition in Fixes: fe22cd9b7c98 ("printk:
help pr_debug and pr_devel to optimize out arguments") around the
same time I ran into the problem in the mlxsw driver.

I'll test build the patch below for a while and submit that if it doesn't
cause any other problems.

diff --git a/include/linux/device.h b/include/linux/device.h
index 002c59728dbe..07f74c246cac 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -1293,8 +1293,11 @@ do {									\
 		dev_printk(KERN_DEBUG, dev, fmt, ##__VA_ARGS__);	\
 } while (0)
 #else
-#define dev_dbg_ratelimited(dev, fmt, ...)			\
-	no_printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
+#define dev_dbg_ratelimited(dev, fmt, ...)				\
+do {									\
+	if (0)								\
+		dev_printk(KERN_DEBUG, dev, fmt, ##__VA_ARGS__);	\
+} while (0)
 #endif
 
 #ifdef VERBOSE_DEBUG

Thanks,

	Arnd
