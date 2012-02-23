From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Re: WARNING: at kernel/softirq.c:159
 _local_bh_enable_ip+0x35/0x71()
Date: Thu, 23 Feb 2012 14:22:34 +0100
Message-ID: <1330003354.11248.9.camel@twins>
References: <1422860.157191329872584374.JavaMail.weblogic@epml01>
	 <20120223104237.GA2127@electric-eye.fr.zoreil.com>
	 <1329998028.15610.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Jongman Heo <jongman.heo@samsung.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Scott J. Goldman" <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:37251 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805Ab2BWNWn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 08:22:43 -0500
In-Reply-To: <1329998028.15610.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-23 at 12:53 +0100, Eric Dumazet wrote:
> Hmm, I am not sure we still need local_bh_disable()/local_bh_enable() in
> kmap_skb_frag()/ kunmap_skb_frag() anymore after commit 3e4d3af501ccc
> (mm: stack based kmap_atomic() )

The only thing to consider is keeping the total stack size under
control, this is somewhat non-trivial since its non-obvious what all
nests.

That said, you're probably right, and we do have a WARN in there
(dependent on CONFIG_DEBUG_HIGHMEM) that yells if we exceed the
available stack size.

The more 'interesting' exercise is determining a better upper bound on
the stack size and updating kmap_types.h accordingly.

> diff --git a/net/core/kmap_skb.h b/net/core/kmap_skb.h
> index 81e1ed7..06be5ee 100644
> --- a/net/core/kmap_skb.h
> +++ b/net/core/kmap_skb.h
> @@ -2,18 +2,10 @@
>  
>  static inline void *kmap_skb_frag(const skb_frag_t *frag)
>  {
> -#ifdef CONFIG_HIGHMEM
> -       BUG_ON(in_irq());
> -
> -       local_bh_disable();
> -#endif
>         return kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ);
>  }
>  
>  static inline void kunmap_skb_frag(void *vaddr)
>  {
>         kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
> -#ifdef CONFIG_HIGHMEM
> -       local_bh_enable();
> -#endif
>  } 

The nicer patch would of course be a patch that does:

 s/kunmap_skb_frag/kunmap_atomic/
 s/kmap_skb_frag(\([^)]*\))/kmap_atomic(skb_frag_page(\1))/

There is no need to retain the KM_* argument and the 'helper' functions
are quite pointless at that point.
