From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V2] New Xen netback implementation
Date: Fri, 27 Jan 2012 14:22:14 -0500
Message-ID: <20120127192214.GA14437@phenom.dumpdata.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, david.vrabel@citrix.com,
	paul.durrant@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:61541 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852Ab2A0TYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 14:24:46 -0500
Content-Disposition: inline
In-Reply-To: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2012 at 01:46:56PM +0000, Wei Liu wrote:
> A new netback implementation which includes three major features:
> 
>  - Global page pool support
>  - NAPI + kthread 1:1 model
>  - Netback internal name changes
> 
> Changes in V2:
>  - Fix minor bugs in V1
>  - Embed pending_tx_info into page pool
>  - Per-cpu scratch space
>  - Notification code path clean up
> 
> This patch series is the foundation of furture work. So it is better
> to get it right first. Patch 1 and 3 have the real meat.

I've been playing with these patches and couple of things
came to my mind: 
 - would it make sense to also register to the shrinker API? This way
   if the host is running low on memory it can squeeze it out of the
   pool code. Perhaps a future TODO..
 - I like the pool code. I was thinking that perhaps (in the future)
   it could be used by blkback as well, as it runs into "not enought
   request structure" with the default setting. And making this dynamic
   would be pretty sweet.
 - This patch set solves the CPU banding problem I've seen with the
   older netback. The older one  I could see X netback threads eating 80%
   of CPU. With this one, the number is down to 13-14%.

So you can definitly stick 'Tested-by: Konrad.." on them. And definitly
Reviewed-by on the first two - hadn't had a chance to look at the rest.

> 
> The first benifit of 1:1 model will be scheduling fairness.
> 
> The rational behind a global page pool is that we need to limit
> overall memory consumed by all vifs.
> 
> Utilization of NAPI enables the possibility to mitigate
> interrupts/events, the code path is cleaned up in a separated patch.
> 
> Netback internal changes cleans up the code structure after switching
> to 1:1 model. It also prepares netback for further code layout
> changes.
> 
> ---
>  drivers/net/xen-netback/Makefile    |    2 +-
>  drivers/net/xen-netback/common.h    |   78 ++--
>  drivers/net/xen-netback/interface.c |  117 ++++--
>  drivers/net/xen-netback/netback.c   |  836 ++++++++++++++---------------------
>  drivers/net/xen-netback/page_pool.c |  185 ++++++++
>  drivers/net/xen-netback/page_pool.h |   66 +++
>  drivers/net/xen-netback/xenbus.c    |    6 +-
>  7 files changed, 704 insertions(+), 586 deletions(-)
> 
