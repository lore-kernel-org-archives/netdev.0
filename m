From: Jon Mason <jon.mason@exar.com>
Subject: Re: [patch] vxge: potential NULL dereference
Date: Fri, 10 Sep 2010 17:32:15 -0400
Message-ID: <20100910213214.GH22321@exar.com>
References: <20100910115423.GC5959@bicker> <20100910.133255.137830993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "error27@gmail.com" <error27@gmail.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.26.186.52] ([64.26.186.52]:21362 "EHLO carlsberg.s2io.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750936Ab0IJV5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Sep 2010 17:57:20 -0400
Content-Disposition: inline
In-Reply-To: <20100910.133255.137830993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 10, 2010 at 01:32:55PM -0700, David Miller wrote:
> From: Dan Carpenter <error27@gmail.com>
> Date: Fri, 10 Sep 2010 13:54:23 +0200
> 
> > At the start of the function we test whether the "vpath" is NULL but we
> > need another test here as well.
> > 
> > Signed-off-by: Dan Carpenter <error27@gmail.com>
> > ---
> > This is a static checker bug, I'm not sure if we ever pass a NULL
> > pointer for "vpath".
> 
> I cannot see any case where this can happen.  There are two
> cases:
> 
> 1) __vxge_hw_vpath_alarm_process() is invoked via vxge_hw_device_begin_irq(),
>    which looks like:
> 
> 			ret = __vxge_hw_vpath_alarm_process(
> 				&hldev->virtual_paths[i], skip_alarms);
> 
>    that vpath pointer first argument will never be NULL.

It is possible to the vpath to be NULL in this array if it is not
populated in __vxge_hw_vp_initialize due to the vpath being masked off
my the adapter.  vxge_hw_device_begin_irq calls
__vxge_hw_vpath_alarm_process on all possible vpaths regardless of
their allocation.  This is the case we need to worry about.

It is not an issue because in the first instance of the vpath being
NULL, its sets the alarm_event to be VXGE_HW_EVENT_UNKNOWN.  The first
check in the out2 error path checks for VXGE_HW_EVENT_UNKNOWN and
returns.  So its not possible to hit this...though it is ugly code.  I
welcome a reworking of the code to something mroe elegant. :)

Thanks,
Jon

> 
> 2) __vxge_hw_vpath_alarm_process() is invoked via vxge_hw_vpath_alarm_process()
>    which uses:
> 
> 	status = __vxge_hw_vpath_alarm_process(vp->vpath, skip_alarms);
> 
>    All vpath valid active vpath handles always have a non-NULL vp->vpath
>    virtual path back pointer, as setup by vxge_hw_vpath_open():
> 
>  ...
> 	vp->vpath = vpath;
> ...
> 	*vpath_handle = vp;
> 
> 	attr->fifo_attr.userdata = vpath->fifoh;
> 	attr->ring_attr.userdata = vpath->ringh;
> 
> 	return VXGE_HW_OK;
> 
> So we can simply remove the first NULL check as this can never actually
> be NULL.
