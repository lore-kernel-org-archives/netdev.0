From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RESEND 2.6.27] netlink: Remove compat API for nested attributes
Date: Tue, 02 Sep 2008 14:46:28 -0700
Message-ID: <48BDB434.1040805@intel.com>
References: <20080828140050.GB20815@postel.suug.ch> <20080828140527.GC20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35403 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490AbYIBVqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2008 17:46:47 -0400
In-Reply-To: <20080828140527.GC20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> Removes all _nested_compat() functions from the API. The prio qdisc
> no longer requires them and netem has its own format anyway. Their
> existance is only confusing.
> 
> Resend: Also remove the wrapper macro.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
I don't think we need to do anything as drastic as completely throwing 
out this part of the Kernel ABI.  This is what I have been trying to get 
at all along.  All we need to do is revert the two patches that we 
talked about earlier and everything goes back to working.


> Index: net-2.6/net/sched/sch_prio.c
> ===================================================================
> --- net-2.6.orig/net/sched/sch_prio.c   2008-08-28 12:52:07.000000000 +0200
> +++ net-2.6/net/sched/sch_prio.c        2008-08-28 15:33:14.000000000 +0200
> @@ -254,16 +254,12 @@
>  {
>         struct prio_sched_data *q = qdisc_priv(sch);
>         unsigned char *b = skb_tail_pointer(skb);
> -       struct nlattr *nest;
>         struct tc_prio_qopt opt;
> 
>         opt.bands = q->bands;
>         memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX+1);
> 
> -       nest = nla_nest_compat_start(skb, TCA_OPTIONS, sizeof(opt), &opt);
> -       if (nest == NULL)
> -               goto nla_put_failure;
> -       nla_nest_compat_end(skb, nest);
> +       NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
> 
>         return skb->len;

This is the one section of this patch that I do completely agree with. 
There is no need to generate a nested compat attribute when there is 
nothing there to nest.  Since "multiqueue" is gone, this change can be 
made to just clean up the netlink portion of prio.

Thanks,

Alex
