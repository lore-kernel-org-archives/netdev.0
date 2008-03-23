From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: sungem triggers NAPI warning
Date: Sun, 23 Mar 2008 23:07:37 +1100
Message-ID: <1206274057.7197.23.camel@pasglop>
References: <1203457124.3874.2.camel@johannes.berg>
	 <20080323.033558.118223124.davem@davemloft.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51709 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754472AbYCWMIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 08:08:25 -0400
In-Reply-To: <20080323.033558.118223124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2008-03-23 at 03:35 -0700, David Miller wrote:
> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Tue, 19 Feb 2008 22:38:43 +0100
> 
> > In order to trigger it, I have to transfer a lot of data. I have
> > triggered it now with a full kernel recompilation using -j6 and distcc
> > onto a fast machine (with tg3 network, direct cable, gbit), and with
> > rsync transferring 26GiB data between the machines.
> 
> I'll push the following fix.
> 
> Ben, thanks for letting this fall through the cracks :-)

OOps... sorry.

> commit da990a2402aeaee84837f29054c4628eb02f7493
> Author: David S. Miller <davem@davemloft.net>
> Date:   Sun Mar 23 03:35:12 2008 -0700
> 
>     [SUNGEM]: Fix NAPI assertion failure.
>     
>     As reported by Johannes Berg:
>     
>     I started getting this warning with recent kernels:
>     
>     [  773.908927] ------------[ cut here ]------------
>     [  773.908954] Badness at net/core/dev.c:2204
>      ...
>     
>     If we loop more than once in gem_poll(), we'll
>     use more than the real budget in our gem_rx()
>     calls, thus eventually trigger the caller's
>     assertions in net_rx_action().
>     
>     Subtract "work_done" from "budget" for the second
>     arg to gem_rx() to fix the bug.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
> index 9721279..4291458 100644
> --- a/drivers/net/sungem.c
> +++ b/drivers/net/sungem.c
> @@ -912,7 +912,7 @@ static int gem_poll(struct napi_struct *napi, int budget)
>  		 * rx ring - must call napi_disable(), which
>  		 * schedule_timeout()'s if polling is already disabled.
>  		 */
> -		work_done += gem_rx(gp, budget);
> +		work_done += gem_rx(gp, budget - work_done);
>  
>  		if (work_done >= budget)
>  			return work_done;

