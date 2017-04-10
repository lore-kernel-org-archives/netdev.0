From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Subject: Re: [regression v4.11] 617f01211baf ("8139too: use
 napi_complete_done()")
Date: Mon, 10 Apr 2017 15:11:02 +0300
Message-ID: <20170410121102.GM30290@intel.com>
References: <20170407181754.GL30290@intel.com>
 <1491590329.10124.86.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:22914 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752955AbdDJMLH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 08:11:07 -0400
Content-Disposition: inline
In-Reply-To: <1491590329.10124.86.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 07, 2017 at 11:38:49AM -0700, Eric Dumazet wrote:
> On Fri, 2017-04-07 at 21:17 +0300, Ville Syrjälä wrote:
> > Hi,
> > 
> > My old P3 laptop started to die on me in the middle of larger compile
> > jobs (using distcc) after v4.11-rc<something>. I bisected the problem
> > to 617f01211baf ("8139too: use napi_complete_done()").
> > 
> > Unfortunately I wasn't able to capture a full oops as the machine doesn't
> > have serial and ramoops failed me. I did get one partial oops on vgacon
> > which showed rtl8139_poll() being involved (EIP was around
> > _raw_spin_unlock_irqrestore() supposedly), so seems to agree with my
> > bisect result.
> > 
> > So maybe some kind of nasty thing going between the hard irq and
> > softirq? Perhaps UP related? I tried to stare at the locking around
> > rtl8139_poll() for a while but it looked mostly sane to me.
> > 
> 
> Thanks a lot for the detective work, I am so sorry for this !
> 
> Could you try the following patch ?
> 
> I do not really see what could be wrong, the code should run just fine
> on UP.
> 
> Thanks.
> 
> diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
> index 89631753e79962d91456d93b71929af768917da1..cd2dbec331dd796f5296cd378561b3443f231673 100644
> --- a/drivers/net/ethernet/realtek/8139too.c
> +++ b/drivers/net/ethernet/realtek/8139too.c
> @@ -2135,11 +2135,12 @@ static int rtl8139_poll(struct napi_struct *napi, int budget)
>  	if (likely(RTL_R16(IntrStatus) & RxAckBits))
>  		work_done += rtl8139_rx(dev, tp, budget);
>  
> -	if (work_done < budget && napi_complete_done(napi, work_done)) {
> +	if (work_done < budget) {
>  		unsigned long flags;
>  
>  		spin_lock_irqsave(&tp->lock, flags);
> -		RTL_W16_F(IntrMask, rtl8139_intr_mask);
> +		if (napi_complete_done(napi, work_done))
> +			RTL_W16_F(IntrMask, rtl8139_intr_mask);
>  		spin_unlock_irqrestore(&tp->lock, flags);
>  	}
>  	spin_unlock(&tp->rx_lock);
> 
> 

Yep, that patch does appear to make it stable again.

Tested-by: Ville Syrjälä <ville.syrjala@linux.intel.com>

-- 
Ville Syrjälä
Intel OTC
