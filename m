From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] qede: fix CONFIG_INFINIBAND_QEDR=m build error
Date: Thu, 13 Oct 2016 11:09:36 +0200
Message-ID: <6935319.6Adbod0g1H@wuerfel>
References: <20161012103340.978726-1-arnd@arndb.de> <BL2PR07MB23069C99213F4E89A7DC162A8DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
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
In-Reply-To: <BL2PR07MB23069C99213F4E89A7DC162A8DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, October 13, 2016 8:50:21 AM CEST Mintz, Yuval wrote:
> >  config INFINIBAND_QEDR
> > -	tristate "QLogic qede RoCE sources [debug]"
> > +	bool "QLogic qede RoCE sources [debug]"
> 
> Given that the qedr submission is going to turn this back into a tristate,
> are you certain this is a good thing [from compilation coverage perspective]?

I haven't seen that submission, I just looked at the current
state in linux-next. If we want this to be a separately loadable
module, that seems fine too, but then we should fix the Makefile
to do that, and add the necessary Kconfig magic to ensure that
INFINIBAND_QED cannot be built-in when INFINIBAND_QEDR=m.

> > -		if (cond)
> > +		if (IS_ENABLED(CONFIG_INFINIBAND_QEDR) && cond)
> >			qed_rdma_dpm_bar(p_hwfn, p_ptt);
> 
> Why not simply fix the qed_roce.h empty implementation?

Mainly for consistency: we have a couple of interfaces that
are called from the qed driver that are implemented in
qed_roce.c. We can either use a 'static inline' helper for
all of them, or use if(IS_ENABLED()) everywhere. Since this
was the only function that had a helper and that helper
was defined incorrectly, I went with the second option.

> > -#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> >  	/* Roce CNQ each requires: 1 status block + 1 CNQ. We divide the
> >  	 * status blocks equally between L2 / RoCE but with consideration as
> >  	 * to how many l2 queues / cnqs we have
> >  	 */
> > -	if (p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
> > +	if (IS_ENABLED(CONFIG_INFINIBAND_QEDR) &&
> > +	    p_hwfn->hw_info.personality == QED_PCI_ETH_ROCE) {
> >  		num_features++;
> > 
> >  		feat_num[QED_RDMA_CNQ] =
> >  			min_t(u32, RESC_NUM(p_hwfn, QED_SB) /
> > num_features,
> >  			      RESC_NUM(p_hwfn, QED_RDMA_CNQ_RAM));
> >  	}
> > -#endif
> 
> Is there any non-cosmetic gain here?
> I would gain that having the comment under the #ifdef is more meaningful
> than having the check in the actual condition.

No, it's purely cosmetic. Moving the comment inside of the if()
block seems fine, I just didn't want to touch that as it was
unrelated.

> > -#if IS_ENABLED(CONFIG_INFINIBAND_QEDR)
> > +	if (!IS_ENABLED(CONFIG_INFINIBAND_QEDR))
> > +		return 0;
> > +
> >  	num_l2_queues = 0;
> >  	for_each_hwfn(cdev, i)
> >  		num_l2_queues += FEAT_NUM(&cdev->hwfns[i],
> > QED_PF_L2_QUE); @@ -738,7 +736,6 @@ static int
> > qed_slowpath_setup_int(struct qed_dev *cdev,
> >  	DP_VERBOSE(cdev, QED_MSG_RDMA, "roce_msix_cnt=%d
> > roce_msix_base=%d\n",
> >  		   cdev->int_params.rdma_msix_cnt,
> >  		   cdev->int_params.rdma_msix_base);
> > -#endif
> 
> While I don't mind, you could have argued is that we're not
> removing enough, not too much.
> I.e., perhaps the rdma_msix_* fields should also have been
> ifdef-ed instead. [in which case this solution would not have worked]

That would add even more #ifdefs though.

	Arnd
