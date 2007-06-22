From: Dustin Marquess <jailbird@alcatraz.fdf.net>
Subject: Re: [patch] alpha: fix alignment problem in csum_ipv6_magic()
Date: Fri, 22 Jun 2007 11:27:24 -0500
Message-ID: <467BF86C.3000208@alcatraz.fdf.net>
References: <20070617012020.A7626@jurassic.park.msu.ru> <20070621163501.00903134.akpm@linux-foundation.org> <20070622152626.A9096@jurassic.park.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, rth@twiddle.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta11.adelphia.net ([68.168.78.205]:41356 "EHLO
	mta11.adelphia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbXFVRKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 13:10:39 -0400
In-Reply-To: <20070622152626.A9096@jurassic.park.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ivan Kokshaysky wrote:
> On Thu, Jun 21, 2007 at 04:35:01PM -0700, Andrew Morton wrote:
>> In http://bugzilla.kernel.org/show_bug.cgi?id=8659, Dustin is reporting
>> that this patch broke tcp-on-ipv6.
> 
> Oops. Two instructions operating on the 'len' arg ($18) got swapped...
> This should fix ev6 version, ev5 one seems to be ok.
> 
> Signed-off-by: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
> 
> Ivan.
> 
> --- 2.6.22-rc4-mm2/arch/alpha/lib/ev6-csum_ipv6_magic.S	Fri Jun 22 15:02:23 2007
> +++ linux/arch/alpha/lib/ev6-csum_ipv6_magic.S	Fri Jun 22 15:05:38 2007
> @@ -76,18 +76,18 @@ csum_ipv6_magic:
>  
>  	cmoveq	$6,$31,$22	# E : src aligned?
>  	ldq_u	$23,15($17)	# L : Latency: 3
> -	or	$18,$4,$18	# E : 000000CCDDAABBCC
> -	extql	$1,$6,$1	# U : U L L U :
> +	inswl	$18,3,$18	# U : 000000CCDD000000
> +	addl	$19,$7,$19	# E : U L U L : <sign bits>bbaabb00
>  
>  	or	$0,$22,$0	# E : 1st src word complete
> -	extqh	$5,$6,$5	# U :
> -	addl	$19,$7,$19	# E : <sign bits>bbaabb00
> -	and	$17,7,$6	# E : L U L U : dst misalignment
> +	extql	$1,$6,$1	# U :
> +	or	$18,$4,$18	# E : 000000CCDDAABBCC
> +	extqh	$5,$6,$5	# U : L U L U
>  
> -	inswl	$18,3,$18	# U : 000000CCDD000000
> -	or	$1,$5,$1	# E : 2nd src word complete
> +	and	$17,7,$6	# E : dst misalignment
>  	extql	$2,$6,$2	# U :
> -	extqh	$3,$6,$22	# U : U L U U :
> +	or	$1,$5,$1	# E : 2nd src word complete
> +	extqh	$3,$6,$22	# U : L U L U :
>  
>  	cmoveq	$6,$31,$22	# E : dst aligned?
>  	extql	$3,$6,$3	# U :
> 


Awesome! Works like a champ! Thank you guys so very much! You rock!

-Dustin
