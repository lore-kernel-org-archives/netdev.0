From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Sun, 18 Oct 2015 08:11:58 -0700
Message-ID: <20151018151157.GA19163@Alexeis-MBP.westell.com>
References: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Haller <thaller@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34777 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbbJRPLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 11:11:54 -0400
Received: by padhk11 with SMTP id hk11so3937652pad.1
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 08:11:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2015 at 01:07:59PM +0200, Jiri Benc wrote:
> When moving interfaces to a different netns, the ifindex of the interface is
> kept if possible. However, this is not kept in sync with allocation of new
> interfaces in the target netns. While the ifindex will be skipped when
> creating a new interface in the netns, it will be reused when the old
> interface disappeared since.
> 
> This causes races for GUI tools in situations like this:
> 
> 1. create netns 'new_netns'
> 2. in root netns, move the interface with ifindex 2 to new_netns
> 3. in new_netns, delete the interface with ifindex 2
> 4. in new_netns, create an interface - it will get ifindex 2
> 
> Ensure that newly allocated interfaces in a netns get ifindex higher than
> any interface that has appeared in the netns. This of course does not fix
> the reuse problem for the applications; it just makes it less likely to be
> hit in common usage patterns.
> 
> Reported-by: Thomas Haller <thaller@redhat.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  net/core/dev.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6bb6470f5b7b..e3d05c20f0ef 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6137,6 +6137,23 @@ static int dev_new_index(struct net *net)
>  	}
>  }
>  
> +/**
> + *	dev_update_index - update the ifindex used for allocation
> + *	@net: the applicable net namespace
> + *	@ifindex: the assigned ifindex
> + *
> + *	Updates the notion of currently allocated maximal ifindex to
> + *	decrease likelihood of ifindex reuse when the ifindex was assigned
> + *	by other means than calling dev_new_index (e.g. when moving
> + *	interface across net namespaces).  The caller must hold the rtnl
> + *	semaphore or the dev_base_lock.
> + */
> +static void dev_update_index(struct net *net, int ifindex)
> +{
> +	if (ifindex > net->ifindex)
> +		net->ifindex = ifindex;
> +}
> +

it looks dangerous.
Does it mean that 'for (4B) { create new dev; free old dev; }
will keep incrementing that max index and dos it eventually?
