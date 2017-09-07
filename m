From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] net: bonding: Fix transmit load balancing in balance-alb
 mode if specified by sysfs
Date: Fri, 8 Sep 2017 02:09:26 +0300
Message-ID: <c9b6ae59-741b-3ecd-47ff-1d5b41710607@cumulusnetworks.com>
References: <17EC94B0A072C34B8DCF0D30AD16044A02985CB5@BPXM09GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Reinis Rozitis <r@roze.lv>
To: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A02985CB5@BPXM09GP.gisp.nec.co.jp>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On  7.09.2017 01:47, Kosuke Tatsukawa wrote:
> Commit cbf5ecb30560 ("net: bonding: Fix transmit load balancing in
> balance-alb mode") tried to fix transmit dynamic load balancing in
> balance-alb mode, which wasn't working after commit 8b426dc54cf4
> ("bonding: remove hardcoded value").
> 
> It turned out that my previous patch only fixed the case when
> balance-alb was specified as bonding module parameter, and not when
> balance-alb mode was set using /sys/class/net/*/bonding/mode (the most
> common usage).  In the latter case, tlb_dynamic_lb was set up according
> to the default mode of the bonding interface, which happens to be
> balance-rr.
> 
> This additional patch addresses this issue by setting up tlb_dynamic_lb
> to 1 if "mode" is set to balance-alb through the sysfs interface.
> 
> I didn't add code to change tlb_balance_lb back to the default value for
> other modes, because "mode" is usually set up only once during
> initialization, and it's not worthwhile to change the static variable
> bonding_defaults in bond_main.c to a global variable just for this
> purpose.
> 
> Commit 8b426dc54cf4 also changes the value of tlb_dynamic_lb for
> balance-tlb mode if it is set up using the sysfs interface.  I didn't
> change that behavior, because the value of tlb_balance_lb can be changed
> using the sysfs interface for balance-tlb, and I didn't like changing
> the default value back and forth for balance-tlb.
> 
> As for balance-alb, /sys/class/net/*/bonding/tlb_balance_lb cannot be
> written to.  However, I think balance-alb with tlb_dynamic_lb set to 0
> is not an intended usage, so there is little use making it writable at
> this moment.
> 
> Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value")
> Reported-by: Reinis Rozitis <r@roze.lv>
> Signed-off-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
> Cc: stable@vger.kernel.org  # v4.12+
> ---
>  drivers/net/bonding/bond_options.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 

I don't believe this to be the right solution, hardcoding it like this
changes user-visible behaviour. The issue is that if someone configured
it to be 0 in tlb mode, suddenly it will become 1 and will silently
override their config if they switch the mode to alb. Also it robs users
from their choice.

If you think this should be settable in ALB mode, then IMO you should
edit tlb_dynamic_lb option's unsuppmodes and allow it to be set in ALB.
That would also be consistent with how it's handled in TLB mode.

Going back and looking at your previous fix I'd argue that it is also
wrong, you should've removed the mode check altogether to return the
original behaviour where the dynamic_lb is set to 1 (enabled) by
default and then ALB mode would've had it, of course that would've left
the case of setting it to 0 in TLB mode and switching to ALB, but that
is a different issue.

Cheers,
 Nik
