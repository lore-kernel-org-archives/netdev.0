From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [patch, -rc5-mm1] lock validator: special locking: net/ipv4/igmp.c #2
Date: Thu, 1 Jun 2006 23:47:50 -0700
Message-ID: <4807377b0606012347o7e1ca193lda3c3654dbda3323@mail.gmail.com>
References: <4807377b0605311704g44fe10f1oc54315276890071@mail.gmail.com>
	 <20060601063537.GA19931@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux-Kernel," <linux-kernel@vger.kernel.org>,
	"Andrew Morton" <akpm@osdl.org>,
	"Arjan van de Ven" <arjan@infradead.org>,
	"NetDEV list" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:1000 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751209AbWFBGrw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 02:47:52 -0400
Received: by nf-out-0910.google.com with SMTP id c31so1079060nfb
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2006 23:47:51 -0700 (PDT)
To: "Ingo Molnar" <mingo@elte.hu>
In-Reply-To: <20060601063537.GA19931@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/31/06, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Jesse Brandeburg <jesse.brandeburg@gmail.com> wrote:
>
> > well, when running e1000 through some code paths on FC4 +
> > 2.6.17-rc5-mm1 + ingo's latest rollup patch, with this lockdep debug
> > option enabled I got this:
> >
> > e1000: eth1: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex
> >
> > ======================================
> > [ BUG: bad unlock ordering detected! ]
> > --------------------------------------
> > mDNSResponder/2361 is trying to release lock (&in_dev->mc_list_lock) at:
> > [<ffffffff81233f5a>] ip_mc_add_src+0x85/0x1f8
>
> ok, could you try the patch below? (i also updated the rollup with this
> fix)
>
>         Ingo
>
> ---------------------
> Subject: lock validator: special locking: net/ipv4/igmp.c #2
> From: Ingo Molnar <mingo@elte.hu>
>
> another case of non-nested unlocking igmp.c.
>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  net/ipv4/igmp.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: linux/net/ipv4/igmp.c
> ===================================================================
> --- linux.orig/net/ipv4/igmp.c
> +++ linux/net/ipv4/igmp.c
> @@ -1646,7 +1646,7 @@ static int ip_mc_add_src(struct in_devic
>                 return -ESRCH;
>         }
>         spin_lock_bh(&pmc->lock);
> -       read_unlock(&in_dev->mc_list_lock);
> +       read_unlock_non_nested(&in_dev->mc_list_lock);
>
>  #ifdef CONFIG_IP_MULTICAST
>         sf_markstate(pmc);
>

yep, this fixes it.
