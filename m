From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH RESEND net 0/9] Fixes, cleanup and modernization for some
 legacy ethernet NIC drivers
Date: Wed, 4 Oct 2017 17:16:04 +1100 (AEDT)
Message-ID: <alpine.LNX.2.00.1710041542170.3@nippy.intranet>
References: <cover.1506992619.git.fthain@telegraphics.com.au> <20171003.214121.339749620339054592.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171003.214121.339749620339054592.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Oct 2017, David Miller wrote:

> From: Finn Thain <fthain@telegraphics.com.au>
> Date: Mon,  2 Oct 2017 21:07:17 -0400 (EDT)
> 
> > This patch series fixes some logging bugs and adds some missing 
> > message severity levels.
> > 
> > There are also cleanup patches for dead code and some Kconfig cruft.
> > 
> > Custom debug message logging is converted to netif_* calls to reduce 
> > code duplication.
> > 
> > All up, about 150 lines of code are eliminated.
> > 
> > My apologies for duplicated messages. I messed up the addressing.
> 
> Finn, I'm finding real bugs in this series and seriously if you cannot 
> test these changes in some way please leave this code alone.
> 

Well, this series has been tested on SONIC, MACE and 8390 devices. I do 
have 89x0 hardware but it is stored elsewhere and I can't get to it right 
now.

> For example, you're removing the "once_is_enough" logic from 
> mac89x0_probe().
> 
> But you can't do that.

I take your point. I overlooked the Space.c logic. But that's not the 
whole story here.

> The probe function can in fact be called multiple times, from 
> drivers/net/Space.c It gets called in a loop iterating over different 
> 'unit' argument values.
> 

Testing shows that mac8390 doesn't probe any devices unless it is modular. 
In the CONFIG_MAC8390=m case, the mac8390_probe() call in Space.c is 
elided by '#ifdef CONFIG_MAC8390' and the device gets probed by 
init_module() instead. (And the binaries published in the Debian archive 
and the mac68k project on sourceforge all use CONFIG_MAC8390=m and 
CONFIG_MAC89x0=m.)

In the CONFIG_MAC8390=y case, no device is probed (for some reason). This 
test result suggests that the probe function is not actually called. Its 
safe to assume that mac89x0 has the same problem as mac8390, and it 
follows that the once_is_enough logic is redundant. At least, that was my 
thinking when I made the change; that is, init_module() must be the only 
caller of the probe function.

BTW, mac8390 does this,

                if (slots & (1 << ndev->board->slot))
                        continue;

which is equivalent to the once_is_enough test, and I went looking for 
some way to avoid this too.

Anyway, I see now that changing the once_is_enough logic is wrong. First 
the bug has to be found or else bus matching implemented for nubus 
drivers.

> Unless you're making stylistic changes where you can prove the object 
> code resulting is still the same, you really should not be playing with 
> fire by trying to remove "dead code" like this in legacy drivers you 
> cannot fully test.
> 

I agree, and that's why I've been careful with any code I cannot test 
(like xtsonic) by making only changes that I can test (with macsonic).
I should have added tested-by tags...

> Thank you.
> 

Thanks for your review. I will revert the once_is_enough change, describe 
the testing better and re-submit.

-- 
