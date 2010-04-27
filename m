From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ptp: Added a brand new class driver for ptp clocks.
Date: Tue, 27 Apr 2010 13:07:21 -0700 (PDT)
Message-ID: <20100427.130721.137847511.davem@davemloft.net>
References: <20100427091405.GA5098@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752300Ab0D0UHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 16:07:15 -0400
In-Reply-To: <20100427091405.GA5098@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue, 27 Apr 2010 11:14:05 +0200

> +struct ptp_clock {
> +	struct cdev cdev;
> +	struct device *dev;
> +	struct ptp_clock_info *info;
> +	dev_t devid;
> +	int index; /* index into clocks[], also the minor number */
> +	struct semaphore mux; /* one process at a time on a device */
> +};

A mutex works just as well and is preferable to a semaphore.

> +/* private globals */
> +
> +static const struct file_operations ptp_fops;
> +static dev_t ptp_devt;
> +static struct class *ptp_class;
> +struct ptp_clock *clocks[PTP_MAX_CLOCKS];
> +DEFINE_SPINLOCK(clocks_lock);

The clocks[] table is not protected by any mutual exclusion in the
unregister method, it needs at least a spinlock or similar.  Probably
clocks_lock was meant to be used for this purpose.

Also, having arbitray limits like PTP_MAX_CLOCKS and a linear scan
when registering or unregistering is suboptimal.

Even if we're not expecting to have many of these things, use linux/list.h
list to manage these things.

In fact, if you keep them in a list you don't need to look them up at
all during at least unregister, you can return the real "struct
ptp_clock *" as an opaque ERR_PTR() back to the caller on register and
on unregister you can just list_del() on it.

Don't expose the layout of struct ptp_clock to the users, you don't have
do.  Just:

struct ptp_clock;

in the exported header file, and then you can return "struct ptp_clock *'
from ptp_clock_register() just fine.

