From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] net: free ip_vs_dest structs when refcnt=0
Date: Tue, 24 Jan 2017 23:14:29 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1701242255570.2743@ja.home.ssi.bg>
References: <1485262100-12366-1-git-send-email-dwindsor@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kernel-hardening@lists.openwall.com,
        keescook@chromium.org, elena.reshetova@intel.com,
        ishkamiel@gmail.com
To: David Windsor <dwindsor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:33279 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750792AbdAXVOw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 16:14:52 -0500
In-Reply-To: <1485262100-12366-1-git-send-email-dwindsor@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 24 Jan 2017, David Windsor wrote:

> Currently, the ip_vs_dest cache frees ip_vs_dest objects when their reference
> count becomes < 0.  Aside from not being semantically sound, this is problematic
> for the new type refcount_t, which will be introduced shortly in a separate patch.
> refcount_t is the new kernel type for holding reference counts, and provides
> overflow protection and a constrained interface relative to atomic_t (the type
> currently being used for kernel reference counts).
> 
> Per Juilan Anastasov: "The problem is that dest_trash currently holds deleted

	Julian

> dests (unlinked from RCU lists) with refcnt=0."  Changing dest_trash to hold
> dest with refcnt=1 will allow us to free ip_vs_dest structs when their refcnt=0,
> in ip_vs_dest_put_and_free().

	Too long lines, should be up to 75 columns as per
Documentation/process/submitting-patches.rst

	Check with: scripts/checkpatch.pl --strict /tmp/file.patch

> Signed-off-by: David Windsor <dwindsor@gmail.com>
> ---
>  include/net/ip_vs.h            | 2 +-
>  net/netfilter/ipvs/ip_vs_ctl.c | 4 +---
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 

> diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
> index 55e0169..6b5492e 100644
> --- a/net/netfilter/ipvs/ip_vs_ctl.c
> +++ b/net/netfilter/ipvs/ip_vs_ctl.c
> @@ -711,7 +711,6 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
>  		      dest->vport == svc->port))) {
>  			/* HIT */
>  			list_del(&dest->t_list);
> -			ip_vs_dest_hold(dest);
>  			goto out;
>  		}
>  	}

	The changes look ok to me but as this is a net-next
material I also prefer some comments in the code to be updated:

- "be 0, so we simply release them here" before ip_vs_trash_cleanup
should become "be 1, so we simply release them here".

- "dest lives in trash with[out] reference" in __ip_vs_del_dest

	When sending v2 for net-next please also CC:

Simon Horman <horms@verge.net.au>
Pablo Neira Ayuso <pablo@netfilter.org>
lvs-devel@vger.kernel.org

	I'll ack the next version after some tests...

Regards
