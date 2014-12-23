From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3] 3c59x: Fix memory leaks in vortex_open
Date: Tue, 23 Dec 2014 10:43:13 -0500
Message-ID: <20141223154313.GE31876@hmsreliant.think-freely.org>
References: <1419303290-27565-1-git-send-email-baijiaju1990@163.com>
 <20141223142439.GD31876@hmsreliant.think-freely.org>
 <54998371.7060109@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ebiederm@xmission.com,
	dingtianhong@huawei.com, paul.gortmaker@windriver.com,
	justinvanwijngaarden@gmail.com, netdev@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48399 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756104AbaLWPoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 10:44:04 -0500
Content-Disposition: inline
In-Reply-To: <54998371.7060109@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 23, 2014 at 11:00:01PM +0800, Jia-Ju Bai wrote:
> Thanks for the reply!
> 
> >This doesn't make sense.  We free all the skbs in vortex_open if we don't
> >allocate all of them (the if (i != RX_RING_SIZE) check), the only place we miss
> >is if vortex_up fails, and you didn't remove the if (!retval) goto out check, so
> >this code won't get run appropriately.
> 
> In the code, when vortex_up is failed and does not returns 0,
> "if (!retval)" is failed and "goto out" is not executed, so error handling
> code
> below is executed, including my added code.
> Is it right?
> 
Yup, you're right, I missed the sense of the check.

> >
> >That said, it does seem we need to clean up if vortex_up fails, but it would
> >seem to me to be easier to just call vortex_close if it does, since that will do
> >all of the approriate cleanup.
> >
> >Neil
> >
> 
> In the code, vortex_close does too many releasing operations, such as free
> vp->tx_skbuff, but vortex_open only allocates memory for vp->rx_skbuff
> before
> vortex_up is called.
> So I think it is enough to just free the memory of vp->rx_skbuff when
> vortex_up
> is failed.
> 
No, I don't think so.  vortex_close predicates each free with a NULL check, so
if its not been allocated, it shouldn't be freed.  vortex_close also puts the
adapter back into a known state (undoing all the setup that vortex_open does).
I really think its better to go with the proper close path than just unwinding
the allocation

Neil

> 
