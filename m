From: Niklas Cassel <niklas.cassel@axis.com>
Subject: Re: stmmac tx timeout
Date: Tue, 6 Jun 2017 12:45:41 +0200
Message-ID: <9f7d2198-073f-435c-fd9a-f25889968b9d@axis.com>
References: <fc8e5141-5815-9a6d-51ed-ddd7e5c2bbc8@axis.com>
 <20170523133946.GA7713@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        Lars Persson <larper@axis.com>, netdev <netdev@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:36600 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751384AbdFFKpv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 06:45:51 -0400
In-Reply-To: <20170523133946.GA7713@amd>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2017 03:39 PM, Pavel Machek wrote:
> Hi!
> 
>> I'm debugging a transmit queue 0 timeout on stmmac with DWMAC4 (4.10a).
>> I'm using kernel v4.9.23, which is before multi queue support was added.
>> I've cherry-picked
>> 98a29944774a ("net: ethernet: stmmac: remove private tx queue lock")
>> 84c53b4baef8 ("stmmac: fix memory barriers")
>> but I still get tx timeouts with these patches.
>>
>> I've managed to reproduce the problem several times,
>> mainly by transmitting the syslog over HTTP.
> 
> How long does it take till timeout? Umm. And if you go through the
> list... I believe we understood what was wrong with the timeout
> handling and how to fix it...
> 
> You may want to tweak tx coalescing parameters. If you set them
> "right" you should get timeouts every 5 minutes or so. That makes it
> easier to debug. This should do the trick:
> 
> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> -#define STMMAC_COAL_TX_TIMER   40000
> +#define STMMAC_COAL_TX_TIMER   1000
> 
> Now that you have driver that crashes early, you might want to do some
> voodoo to stop the crashing. This worked for me:
> 
> @@ -2043,7 +2063,11 @@ static netdev_tx_t stmmac_xmit(struct sk_buff
> *skb, stru\
> ct net_device *dev)
>         } else
> 	                priv->tx_count_frames = 0;
> 
> +       dma_rmb();
> +       dma_wmb();
>         /* To avoid raise condition */
> +       BUG_ON(first->des01.etx.own); /* This BUG_ON seems to be enough.
> +                                          Replacing it with barriers is _not_enough. */
>         priv->hw->desc->set_tx_owner(first);
>  	wmb();
> 
> No, the BUG_ON() does not trigger. Yes, it still fixes the driver for
> me. You may want to verify it has same effect for you.

Hello Pavel,

I am sincerely grateful for you help.

I forward ported your patch to 4.9,
however, I could still get tx timeouts.

Thankfully I finally found the root cause of
my tx timeouts, see the patch I've submitted
here:

http://marc.info/?l=linux-kernel&m=149673393525236


Best regards,
Niklas
