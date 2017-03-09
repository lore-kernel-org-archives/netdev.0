From: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Subject: Re: [PATCH 5/7] net: stmmac: Program RX queue size and flow control
Date: Thu, 9 Mar 2017 13:18:11 -0700
Message-ID: <83aaa3b1-a2d4-8ddd-d31a-2fd6c653e3d1@wwwdotorg.org>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-6-thierry.reding@gmail.com>
 <74ee5bff-8893-ebd4-bcf8-bb92c476f581@kapsi.fi>
 <20170309194231.GD5554@ulmo.ba.sec>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170309194231.GD5554-EkSeR96xj6Pcmrwk2tT4+A@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 12:42 PM, Thierry Reding wrote:
> On Mon, Feb 27, 2017 at 12:09:02PM +0200, Mikko Perttunen wrote:
>> On 23.02.2017 19:24, Thierry Reding wrote:
>>> From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
>>>
>>> Program the receive queue size based on the RX FIFO size and enable
>>> hardware flow control for large FIFOs.

>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c

>>> @@ -252,6 +253,44 @@ static void dwmac4_dma_chan_op_mode(void __iomem *ioaddr, int txmode,
>>>  			mtl_rx_op |= MTL_OP_MODE_RTC_128;
>>>  	}
>>>
>>> +	mtl_rx_op &= ~MTL_OP_MODE_RQS_MASK;
>>> +	mtl_rx_op |= rqs << MTL_OP_MODE_RQS_SHIFT;
>>> +
>>> +	/* enable flow control only if each channel gets 4 KiB or more FIFO */
>>> +	if (rxfifosz >= 4096) {
>>> +		unsigned int rfd, rfa;
>>> +
>>> +		mtl_rx_op |= MTL_OP_MODE_EHFC;
>>> +
>>> +		switch (rxfifosz) {
>>> +		case 4096:
>>> +			rfd = 0x03;
>>> +			rfa = 0x01;
>>> +			break;
>>> +
>>> +		case 8192:
>>> +			rfd = 0x06;
>>> +			rfa = 0x0a;
>>> +			break;
>>> +
>>> +		case 16384:
>>> +			rfd = 0x06;
>>> +			rfa = 0x12;
>>> +			break;
>>> +
>>> +		default:
>>> +			rfd = 0x06;
>>> +			rfa = 0x1e;
>>> +			break;
>>> +		}
>>
>> Are these values correct? In the 4096 case, rfd > rfa, in all other cases
>> the other way around. In any case it would be useful to have a comment
>> clarifying the thresholds in bytes.
>
> I'll investigate. To be honest I simply took this from Stephen's U-Boot
> driver since that's already tested. I trust Stephen, so I didn't bother
> double-checking.

I don't recall for sure, but I think these values came directly from 
either the upstream kernel (the non-stmmac driver) or NV downstream 
kernel EQoS driver, and I re-used them without investigating. I'm not 
even sure if the outer if() expression is true; these numbers might not 
even end up being used?
