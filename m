From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH for 2.6.33] conntrack: restrict runtime hashsize modifications
Date: Thu, 04 Feb 2010 18:26:45 +0100
Message-ID: <4B6B0355.4010609@trash.net>
References: <20100203203929.GA6168@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jonathan@jonmasters.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100203203929.GA6168@x200>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Jon Masters correctly points out that conntrack hash sizes
> (nf_conntrack_htable_size) are global (not per-netns) and
> modifiable at runtime via /sys/module/nf_conntrack/hashsize .
> 
> Steps to reproduce:
> 	clone(CLONE_NEWNET)
> 	[grow /sys/module/nf_conntrack/hashsize]
> 	exit()
> 
> At netns exit we are going to scan random memory for conntracks to be killed.
> 
> Apparently there is a code which deals with hashtable resize for
> init_net (and it was there befode netns conntrack code), so prohibit
> hashsize modification if there is more than one netns exists.
> 
> To change hashtable sizes, you need to reload module.
> 
> Expectation hashtable size was simply glued to a variable with no code
> to rehash expectations, so it was a bug to allow writing to it.
> Make "expect_hashsize" readonly.

I've applied the expectation part, thanks Alexey.

> --- a/net/netfilter/nf_conntrack_expect.c
> +++ b/net/netfilter/nf_conntrack_expect.c
> @@ -569,7 +569,7 @@ static void exp_proc_remove(struct net *net)
>  #endif /* CONFIG_PROC_FS */
>  }
>  
> -module_param_named(expect_hashsize, nf_ct_expect_hsize, uint, 0600);
> +module_param_named(expect_hashsize, nf_ct_expect_hsize, uint, 0400);
>  
>  int nf_conntrack_expect_init(struct net *net)
>  {
> 

