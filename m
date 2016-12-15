From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH 1/2] net: ethernet: sxgbe: remove private tx queue lock
Date: Thu, 15 Dec 2016 20:27:41 +0100
Message-ID: <cfad6b84-de23-2e03-6d34-2b3451975179@gmx.de>
References: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
 <1481141138-19466-2-git-send-email-LinoSanfilippo@gmx.de>
 <20161207231534.GB5889@electric-eye.fr.zoreil.com>
 <051e3043-8b58-0591-36e3-99e2267f67f4@gmx.de>
 <20161208231943.GA13102@electric-eye.fr.zoreil.com>
 <20161209112142.GA22710@amd> <c76124b9-6376-42b9-2821-b5a8185f5034@gmx.de>
 <20161211201104.GB20574@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, bh74.an@samsung.com,
        ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161211201104.GB20574@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pavel,

sorry for the late reply.

On 11.12.2016 21:11, Pavel Machek wrote:
> 
> Do you understand what stmmac_tx_err(priv); is supposed to do? In
> particular, if it is called while the driver is working ok -- should
> the driver survive that?

As far as I understood it is supposed to fixup an errorneous tx path, e.g. a
missing tx completion for transmitted frames.

Some drivers do this by restarting only the HW parts responsible for tx, some
others by restarting the complete hardware. 
But IMO it should also be ok to be called if the HW is still working fine.

> Because it does not currently, and I don't know how to test that
> code. Unplugging the cable does not provoke that.
> 
> I tried
> 
>         } else if (unlikely(status == tx_hard_error))
>                 stmmac_tx_err(priv);
> +
> +       {
> +               static int i;
> +               i++;
> +               if (i==1000) {
> +                       i = 0;
> +                       printk("Simulated error\n");
> +                       stmmac_tx_err(priv);
> +               }
> +       }
>  }
> 

Ok, there is this race that Francois mentioned so it is not surprising that
the driver does not survive the call of stmmac_tx_err() as it is called now.
Thats why I suggested to do a proper shutdown and restart of the tx path to
avoid the race.

Regards,
Lino
