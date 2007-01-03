From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH  v4 01/13] Linux RDMA Core Changes
Date: Wed, 03 Jan 2007 08:56:12 -0600
Message-ID: <1167836172.4187.9.camel@stevo-desktop>
References: <1167834348.4187.3.camel@stevo-desktop>
	 <20070103144153.GN6019@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, openib-general@openib.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750826AbXACO4N@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@mellanox.co.il>
In-Reply-To: <20070103144153.GN6019@mellanox.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > 
> > > It seems all Chelsio needs is to pass in a consumer index - so, how about a new
> > > entry point? Something like void set_cq_udata(struct ib_cq *cq, struct ib_udata *udata)?
> > > 
> > 
> > Adding a new entry point would hurt chelsio's user mode performance if
> > if then requires 2 kernel transitions to rearm the cq.  
> 
> No, it won't need 2 transitions - just an extra function call,
> so it won't hurt performance - it would improve performance.
> 
> ib_uverbs_req_notify_cq would call
> 
> 	ib_uverbs_req_notify_cq()
> 	{
> 			ib_set_cq_udata(cq, udata)
> 			ib_req_notify_cq(cq, cmd.solicited_only ?
> 				IB_CQ_SOLICITED : IB_CQ_NEXT_COMP);
> 	}
> 

ib_set_cq_udata() would transition into the kernel to pass in the
consumer's index.  In addition, ib_req_notify_cq would also transition
into the kernel since its not a bypass function for chelsio.

> This way kernel consumers don't incur any overhead,
> and in userspace users extra function call is dwarfed
> by system call overhead.
> 
> > Passing in user data is sort of SOP for these sorts of verbs.  
> 
> I don't see other examples. Where we did pass extra user data
> is in non-data pass verbs such as create QP.
> 
> This is most inner tight loop in many ULPs, so we should be very careful
> about adding code there - these things do add up.
> See recent IRQ API update in kernel.

Roland, do you have any comments on this?  You previously indicated
these patches were good to go once chelsio's ethernet driver gets pulled
in. 

> > How much does passing one more param cost for kernel users?  
> 
> Donnu. I just reviewed the code.
> It really should be up to patch submitter to check the performance
> effect of his patch, if there might be any.

I've run this code with mthca and didn't notice any performance
degradation, but I wasn't specifically measuring cq_poll overhead in a
tight loop...
