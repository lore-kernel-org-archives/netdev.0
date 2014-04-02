From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Wed, 02 Apr 2014 16:35:20 +0200
Message-ID: <533C2028.7030604@ahsoftware.de>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <533BF9CE.3050302@cogentembedded.com> <533BFD6B.7050503@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	Michal Simek <michal.simek@xilinx.com>, stable@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-kernel@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <533BFD6B.7050503@cogentembedded.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 02.04.2014 14:07, schrieb Sergei Shtylyov:
> On 02-04-2014 15:51, Sergei Shtylyov wrote:
> 
>>> Commit 7cd1463664c2a15721ff4ccfb61d4d970815cb3d (introduced with 3.14)
>>> changed the initialization of the mv643xx_eth driver to use
>>> phy_init_hw()
>>> to reset the PHY. Unfortunately the initialization for the 88E1116R PHY
>>> was broken such, that it used mdelay() instead of really waiting for a
>>> reset to finish.

(...)

>>>
>>> -    mdelay(500);
>>> +    do
>>> +        temp = phy_read(phydev, MII_BMCR);
>>> +    while (temp & BMCR_RESET);
> 
>>     Not clear why it's necessary to reset one more time... Also, tight
>> loop
>> without a timeout (0.5 sec, specified by IEEE 802.3) doesn't look
>> good. The
>> comment above phy_poll_reset() suggests that it could be used in the PHY
>> drivers as well. Florian?
> 
>    Ah, I was looking at Linus' tree, not net-next.git, and hadn't read
> Florian's replies before commenting on this...

Just to be clear, this patch isn't a change request, it's a bugfix
because the ethernet doesn't come up on my Kirkwood device(s) using
kernel 3.14. So it's mainly meant for other people which want to use
3.14 with similiar devices and have problems too.

Reverting the above commit does do the trick here too.

I haven't looked at the datasheet nor any possible erratas. So I don't
know why and if there are multiple resets necessary. I've just made the
code more similiar to what was used before the above commit changed the
reset of the PHY. The tight loop is a copy from other m*_config_inits in
the same file and was in use in mv643xx_eth before the above commit too.
So at least the tight loop is proven to work. And genphy_soft_reset(),
which does not wait indefinitely long if the phy never does come out of
reset, is only available in some -next tree, definitely not where I look
at and need it for a bugfix.

But I agree, all the stuff looks very curious, tight loops without a
timeout, multiple resets in order and such things more.

But this patch isn't a cleanup, it's meant to be as small as possible to
make things work again. And I decided that instead of just suggesting a
revert, it's better to fix m88e1116r_config_init() which might be used
at other places too.

It might make sense to wait for some other users to complain, I think it
won't need long as this SOC is used in Sheevaplugs and Dockstars, some
ARMv5 devices which were quiet popular. Or if nobody else complains,
maybe someone might test my change. Ut could be possible that the
failing sequence is through the/my use of netconsole, which is, I
assume, not very common.

Regards,

Alexander Holler
