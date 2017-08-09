From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: fix xmit recursion detection on ppp channels
Date: Tue, 08 Aug 2017 21:07:06 -0700 (PDT)
Message-ID: <20170808.210706.206603185784182097.davem@davemloft.net>
References: <e45ed6ea02e2665ec8b868279ad9afcb9b34fc81.1502185216.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gfree.wind@vip.163.com,
        jianying.liu@ikuai8.com, linux-ppp@vger.kernel.org,
        paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <e45ed6ea02e2665ec8b868279ad9afcb9b34fc81.1502185216.git.g.nault@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 8 Aug 2017 11:43:24 +0200

> Commit e5dadc65f9e0 ("ppp: Fix false xmit recursion detect with two ppp
> devices") dropped the xmit_recursion counter incrementation in
> ppp_channel_push() and relied on ppp_xmit_process() for this task.
> But __ppp_channel_push() can also send packets directly (using the
> .start_xmit() channel callback), in which case the xmit_recursion
> counter isn't incremented anymore. If such packets get routed back to
> the parent ppp unit, ppp_xmit_process() won't notice the recursion and
> will call ppp_channel_push() on the same channel, effectively creating
> the deadlock situation that the xmit_recursion mechanism was supposed
> to prevent.
> 
> This patch re-introduces the xmit_recursion counter incrementation in
> ppp_channel_push(). Since the xmit_recursion variable is now part of
> the parent ppp unit, incrementation is skipped if the channel doesn't
> have any. This is fine because only packets routed through the parent
> unit may enter the channel recursively.
> 
> Finally, we have to ensure that pch->ppp is not going to be modified
> while executing ppp_channel_push(). Instead of taking this lock only
> while calling ppp_xmit_process(), we now have to hold it for the full
> ppp_channel_push() execution. This respects the ppp locks ordering
> which requires locking ->upl before ->downl.
> 
> Fixes: e5dadc65f9e0 ("ppp: Fix false xmit recursion detect with two ppp devices")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied, thank you.
