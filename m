From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Tue, 20 Dec 2016 01:05:32 +0100
Message-ID: <20161220000531.GA7851@electric-eye.fr.zoreil.com>
References: <20161209112142.GA22710@amd>
 <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd>
 <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
 <20161215210324.GA13878@amd>
 <f3fc8035-fb6e-fb06-d9b8-bfc96dc4e1d2@gmx.de>
 <6f43eac8-754b-cfa2-371d-050701deb4cd@gmx.de>
 <20161217173150.GA20231@amd>
 <20161218001507.GA5343@electric-eye.fr.zoreil.com>
 <20161219100215.GA6296@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lino Sanfilippo <LinoSanfilippo@gmx.de>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161219100215.GA6296@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek <pavel@ucw.cz> :
[...]
> Considering the memory barriers... is something like this neccessary
> in the via-rhine ?

Yes.

> AFAICT... we need a barrier after making sure that descriptor is no
> longer owned by DMA (to make sure we don't get stale data in rest of
> descriptor)... and we need a barrier before giving the descriptor to
> the dma, to make sure DMA engine sees the complete update....?

I would not expect stale data while processing a single transmit
descriptor as the transmit completion does not use the rest of the
descriptor at all in the via-rhine driver. However I agree that transmit
descriptors should be read by the cpu with adequate ordering so the
dma_rmb() should stay.

Same kind of narrative for dma_wmb rhine_rx (s/read/written/ and
s/cpu/device/).

> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
> index ba5c542..3806e72 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
[...]
> @@ -2061,6 +2062,7 @@ static int rhine_rx(struct net_device *dev, int limit)
>  
>  		if (desc_status & DescOwn)
>  			break;
> +		dma_rmb();
>  

I agree with your explanation for this one (late vlan processing in a 
different word from the same descriptor).

-- 
Ueimor
