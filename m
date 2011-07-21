From: Joe Perches <joe@perches.com>
Subject: RE: [Pv-drivers] [PATCH net-next] vmxnet3: set netdev parant
 device before calling netdev_info
Date: Wed, 20 Jul 2011 20:49:01 -0700
Message-ID: <1311220141.1663.24.camel@Joe-Laptop>
References: <alpine.LRH.2.00.1107201834220.19334@sbhatewara-dev1.eng.vmware.com>
	 <03E840D17E263A48A5766AD576E0423A03C5836359@exch-mbx-111.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: Scott Goldman <scottjg@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4217 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751951Ab1GUDtE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 23:49:04 -0400
In-Reply-To: <03E840D17E263A48A5766AD576E0423A03C5836359@exch-mbx-111.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-07-20 at 20:06 -0700, Scott Goldman wrote:
> > Parent device for netdev should be set before netdev_info() can be called
> > otherwise there is a NULL pointer dereference and probe() fails.

I believe this is not true.
I don't see any NULL pointer dereference here.
functions and macros reordered top to bottom.

define_netdev_printk_level(netdev_info, KERN_INFO);

#define define_netdev_printk_level(func, level)			\
int func(const struct net_device *dev, const char *fmt, ...)	\
{								\
	int r;							\
	struct va_format vaf;					\
	va_list args;						\
								\
	va_start(args, fmt);					\
								\
	vaf.fmt = fmt;						\
	vaf.va = &args;						\
								\
	r = __netdev_printk(level, dev, &vaf);			\
	va_end(args);						\
								\
	return r;						\
}								\
EXPORT_SYMBOL(func);

static int __netdev_printk(const char *level, const struct net_device *dev,
			   struct va_format *vaf)
{
	int r;

	if (dev && dev->dev.parent)
		r = dev_printk(level, dev->dev.parent, "%s: %pV",
			       netdev_name(dev), vaf);
	else if (dev)
		r = printk("%s%s: %pV", level, netdev_name(dev), vaf);
	else
		r = printk("%s(NULL net_device): %pV", level, vaf);

	return r;
}

static inline const char *netdev_name(const struct net_device *dev)
{
	if (dev->reg_state != NETREG_REGISTERED)
		return "(unregistered net_device)";
	return dev->name;
}


