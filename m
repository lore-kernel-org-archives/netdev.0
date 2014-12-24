From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3] 3c59x: Fix memory leaks in vortex_open
Date: Tue, 23 Dec 2014 22:27:28 -0500
Message-ID: <20141224032728.GA20392@localhost.localdomain>
References: <1419303290-27565-1-git-send-email-baijiaju1990@163.com>
 <20141223142439.GD31876@hmsreliant.think-freely.org>
 <54998371.7060109@163.com>
 <20141223154313.GE31876@hmsreliant.think-freely.org>
 <549A212A.60001@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ebiederm@xmission.com,
	dingtianhong@huawei.com, paul.gortmaker@windriver.com,
	justinvanwijngaarden@gmail.com, netdev@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38995 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbaLXD2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 22:28:06 -0500
Content-Disposition: inline
In-Reply-To: <549A212A.60001@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2014 at 10:12:58AM +0800, Jia-Ju Bai wrote:
> On 12/23/2014 11:43 PM, Neil Horman wrote:
> >No, I don't think so.  vortex_close predicates each free with a NULL check, so
> >if its not been allocated, it shouldn't be freed.  vortex_close also puts the
> >adapter back into a known state (undoing all the setup that vortex_open does).
> >I really think its better to go with the proper close path than just unwinding
> >the allocation
> >
> >Neil
> >
> 
> Firstly, I run my match on the real hardware(3com 3c905B 100Base
> PCI Ethernet Controller) and make vortex_up failed on purpose
> (make "pci_enable_device" in vortex_up failed). During runtime, the driver
> works well and memory leaks are fixed.
> 
> Secondly, I revise the code according to your opinion:
> 
>         retval = vortex_up(dev);
>         if (!retval)
>             goto out;
> 
> +      vortex_close(dev);
> +      return -ENOMEM;
> 
> Then I repeat my experiment, but system hang occurs!
> 
> After adding some "printk"s into the code and running the driver, I find
> the problem's source:
> vortex_close calls vortex_down in runtime, and vortex_down calls
> "del_timer_sync(&vp->rx_oom_timer);" in the code. However, I make
> "pci_enable_device" failed in vortext_up to let vortex_up return an
> error code directly, but "vp->rx_oom_timer" is initialized only by
> "init_timer" after "pci_enable_device". Thus when
> "del_timer_sync(&vp->rx_oom_timer);" is called in vortex_down,
> a null dereference may occur.
> Moreover, only "pci_enable_device" can make vortex_up failed.
> 
> 
Sooo, fix it.  Add some checks to not delete the timer if its not been
initalized.  Its really preferable to have a single teardown path and a single
bringup path if at all possible
Neil
