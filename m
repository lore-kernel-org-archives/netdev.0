From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 2/8] net: hns3: Add support of the HNAE3
 framework
Date: Sat, 17 Jun 2017 11:12:53 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2C35@FRAEML521-MBS.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-3-salil.mehta@huawei.com>
 <20170614013223.GF23384@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614013223.GF23384@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, June 14, 2017 2:32 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 2/8] net: hns3: Add support of the
> HNAE3 framework
> 
> On Wed, Jun 14, 2017 at 12:10:29AM +0100, Salil Mehta wrote:
> > This patch adds the support of the HNAE3 (Hisilicon Network
> > Acceleration Engine 3) framework support to the HNS3 driver.
> >
> > Framework facilitates clients like ENET(HNS3 Ethernet Driver), RoCE
> > and user-space Ethernet drivers (like ODP etc.) to register with
> HNAE3
> > devices and their associated operations.
> >
> > Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> > Signed-off-by: lipeng <lipeng321@huawei.com>
> > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> > ---
> >  drivers/net/ethernet/hisilicon/hns3/hnae3.c | 305
> +++++++++++++++++++
> >  drivers/net/ethernet/hisilicon/hns3/hnae3.h | 449
> ++++++++++++++++++++++++++++
> >  2 files changed, 754 insertions(+)
> >  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.c
> >  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hnae3.h
> >
> > diff --git a/drivers/net/ethernet/hisilicon/hns3/hnae3.c
> b/drivers/net/ethernet/hisilicon/hns3/hnae3.c
> > new file mode 100644
> > index 0000000..f133e1d
> > --- /dev/null
> > +++ b/drivers/net/ethernet/hisilicon/hns3/hnae3.c
> > @@ -0,0 +1,305 @@
> > +/*
> > + * Copyright (c) 2016-2017 Hisilicon Limited.
> > + *
> > + * This program is free software; you can redistribute it and/or
> modify
> > + * it under the terms of the GNU General Public License as published
> by
> > + * the Free Software Foundation; either version 2 of the License, or
> > + * (at your option) any later version.
> > + */
> > +
> > +#include <linux/slab.h>
> > +#include <linux/list.h>
> > +#include <linux/spinlock.h>
> > +
> > +#include "hnae3.h"
> > +
> > +static LIST_HEAD(hnae3_ae_algo_list);
> > +static LIST_HEAD(hnae3_client_list);
> > +static LIST_HEAD(hnae3_ae_dev_list);
> > +
> > +static DEFINE_SPINLOCK(hnae3_list_ae_algo_lock);
> > +static DEFINE_SPINLOCK(hnae3_list_client_lock);
> > +static DEFINE_SPINLOCK(hnae3_list_ae_dev_lock);
> > +
> > +static void hnae3_list_add(spinlock_t *lock, struct list_head *node,
> > +			   struct list_head *head)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(lock, flags);
> > +	list_add_tail_rcu(node, head);
> > +	spin_unlock_irqrestore(lock, flags);
> > +}
> > +
> > +static void hnae3_list_del(spinlock_t *lock, struct list_head *node)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(lock, flags);
> > +	list_del_rcu(node);
> > +	spin_unlock_irqrestore(lock, flags);
> > +}
> 
> 
> You have these two _rcu operations here, and no others. I don't see
> any rcu_read_lock(), or call_rcu(), etc.
> 
> I'm not an RCU expert, but this looks odd to me.
> 
>     Andrew
Thanks for identifying this. I think we would be okay here even without
rcu version. Will change this.

Thanks
Salil
