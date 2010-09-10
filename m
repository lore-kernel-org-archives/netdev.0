From: David Miller <davem@davemloft.net>
Subject: Re: [patch] vxge: potential NULL dereference
Date: Fri, 10 Sep 2010 13:32:55 -0700 (PDT)
Message-ID: <20100910.133255.137830993.davem@davemloft.net>
References: <20100910115423.GC5959@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ramkrishna.vepa@exar.com, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, jon.mason@exar.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50656
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754699Ab0IJUch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 16:32:37 -0400
In-Reply-To: <20100910115423.GC5959@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 10 Sep 2010 13:54:23 +0200

> At the start of the function we test whether the "vpath" is NULL but we
> need another test here as well.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> This is a static checker bug, I'm not sure if we ever pass a NULL
> pointer for "vpath".

I cannot see any case where this can happen.  There are two
cases:

1) __vxge_hw_vpath_alarm_process() is invoked via vxge_hw_device_begin_irq(),
   which looks like:

			ret = __vxge_hw_vpath_alarm_process(
				&hldev->virtual_paths[i], skip_alarms);

   that vpath pointer first argument will never be NULL.

2) __vxge_hw_vpath_alarm_process() is invoked via vxge_hw_vpath_alarm_process()
   which uses:

	status = __vxge_hw_vpath_alarm_process(vp->vpath, skip_alarms);

   All vpath valid active vpath handles always have a non-NULL vp->vpath
   virtual path back pointer, as setup by vxge_hw_vpath_open():

 ...
	vp->vpath = vpath;
...
	*vpath_handle = vp;

	attr->fifo_attr.userdata = vpath->fifoh;
	attr->ring_attr.userdata = vpath->ringh;

	return VXGE_HW_OK;

So we can simply remove the first NULL check as this can never actually
be NULL.
