From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/6] net: ethernet: ti: cpts: add ptp pps support
Date: Wed, 30 Nov 2016 23:17:38 +0100
Message-ID: <20161130221738.GA13099@localhost.localdomain>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-5-grygorii.strashko@ti.com>
 <20161130184511.GB8209@netboy>
 <875d4cc2-8a47-b06d-fb46-0cacc28dbaee@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <875d4cc2-8a47-b06d-fb46-0cacc28dbaee@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 30, 2016 at 02:43:57PM -0600, Grygorii Strashko wrote:
> > In order to produce the PPS edge correctly, you would have to adjust
> > the comparison value whenever cc.mult changes, 
> 
> yes. And that is done in cpts_ptp_adjfreq()
> 	if (cpts->ts_comp_enabled)
> 		cpts->ts_comp_one_sec_cycs = cpts_cc_ns2cyc(cpts, NSEC_PER_SEC);
> 	^^^ re-calculate reload value for 
>  
> 	cpts_ts_comp_settime(cpts, ns);
> 	^^^ adjust the ts_comp

And it races with the pulse itself.  You forgot about this part:

> @@ -172,14 +232,31 @@ static int cpts_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
>  	adj *= ppb;
>  	diff = div_u64(adj, 1000000000ULL);
>  
> +	mutex_lock(&cpts->ptp_clk_mutex);
> +
>  	spin_lock_irqsave(&cpts->lock, flags);
> +	if (cpts->ts_comp_enabled) {
> +		cpts_ts_comp_disable(cpts);

Sorry, but this is a train wreck.

> > but of course this is unworkable.
> > 
> 
> Sry, but this is questionable - code for pps comes from TI internal
> branches (SDK releases) where it survived for a pretty long time.

That doesn't mean the code is any good.  If you adjust at the right
moment, then no pulse occurs at all!

> I'm, of course, agree that without HW support for freq adjustment
> this PPS feature is not super precise and has some limitation,
> but that is what we agree to live with. 

I do NOT agree to live with this.  I am one who is going to have to
explain to the world why their beagle bone PPS sucks.
 
Thanks,
Richard
