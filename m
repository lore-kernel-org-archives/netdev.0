From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] qede: fix CONFIG_INFINIBAND_QEDR=m build error
Date: Thu, 13 Oct 2016 12:20:59 +0200
Message-ID: <5662883.yo8OytxU65@wuerfel>
References: <20161012103340.978726-1-arnd@arndb.de> <6935319.6Adbod0g1H@wuerfel> <BY2PR07MB2309D9E2BEBC5A2091AC79E98DDC0@BY2PR07MB2309.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
        "everest-linux-l2@qlogic.com" <everest-linux-l2@qlogic.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR07MB2309D9E2BEBC5A2091AC79E98DDC0@BY2PR07MB2309.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, October 13, 2016 9:34:41 AM CEST Mintz, Yuval wrote:
> 
> > > > -		if (cond)
> > > > +		if (IS_ENABLED(CONFIG_INFINIBAND_QEDR) && cond)
> > > >			qed_rdma_dpm_bar(p_hwfn, p_ptt);
> > >
> > > Why not simply fix the qed_roce.h empty implementation?
> > 
> > Mainly for consistency: we have a couple of interfaces that are called from the
> > qed driver that are implemented in qed_roce.c. We can either use a 'static inline'
> > helper for all of them, or use if(IS_ENABLED()) everywhere. Since this was the
> > only function that had a helper and that helper was defined incorrectly, I went
> > with the second option.
> 
> Actually, that's not the case. I think with this exception, all the rest of the prototypes
> in qed_roce.h aren't really needed, as those functions should only be accessed via
> the qed_rdma_ops. I'll remove those later [or we can remove them as part of v2].

Ok, making those functions static and removing the prototypes would be
a good improvement. Note that building with 'make C=1' or 'make W=1'
will also warn if you have a global function that has no prototype,
so just removing the prototypes without making the functions static
would be bad (there is currently work going on to enable the warning
by default).

The functions I was thinking of are qed_async_roce_event,
qed_ll2b_complete_tx_gsi_packet, qed_ll2b_complete_rx_gsi_packet
and qed_ll2b_release_tx_gsi_packet, all of which do get called
from the qed driver, so you will still need to add inline wrappers
for those.

> The genereal qed* preference is to have empty static-inline implementations
> in case content is compiled-out [Look at iov for example].

Ok, fair enough.

> > > > -#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> > > > +	if (!IS_ENABLED(CONFIG_INFINIBAND_QEDR))
> > > > +		return 0;
> > > > +
> > > >  	num_l2_queues = 0;
> > > >  	for_each_hwfn(cdev, i)
> > > >  		num_l2_queues += FEAT_NUM(&cdev->hwfns[i],
> > QED_PF_L2_QUE); @@
> > > > -738,7 +736,6 @@ static int qed_slowpath_setup_int(struct qed_dev
> > > > *cdev,
> > > >  	DP_VERBOSE(cdev, QED_MSG_RDMA, "roce_msix_cnt=%d
> > > > roce_msix_base=%d\n",
> > > >  		   cdev->int_params.rdma_msix_cnt,
> > > >  		   cdev->int_params.rdma_msix_base); -#endif
> > >
> > > While I don't mind, you could have argued is that we're not removing
> > > enough, not too much.
> > > I.e., perhaps the rdma_msix_* fields should also have been ifdef-ed
> > > instead. [in which case this solution would not have worked]
> > 
> > That would add even more #ifdefs though.
> 
> I agree. Although I'm never clear on the guidelines for the tradeoff - 
> How much memory/code is considered too much so that you'd have
> To ifdef code out instead of 'wasting'?
> [I obviously don't claim 64 bytes of memory hit that threshold]

I don't think code size should ever be a reason for an #ifdef in a .c
file: if the code is well-structured, you can always get the same
object code using if(IS_ENABLED()) checks within the code at better
readability or better compile-time coverage.

Between if(IS_ENABLED()) checks and inline helpers, it usually
doesn't matter much either way as long as the separation between
the modules is clear enough. In the example above, removing
the structure fields however would require to move the debugging
output into another inline function though.
  
> BTW, are you interested in doing a v2 for this? Or would you prefer
> if we'd pick it up from here?

I think it's better if you do a v2, as you better understand the
long-term plans. I'd be happy to test your patch in my randconfig
build setup if you like.

	Arnd
