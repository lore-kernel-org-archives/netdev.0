From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #14016] mm/ipw2200 regression
Date: Thu, 27 Aug 2009 17:11:29 +0800
Message-ID: <1251364289.3704.176.camel@debian>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera>
	 <_yaHeGjHEzG.A.FIH.7sGlKB@chimera>
	 <84144f020908252309u5cff8afdh2214577ca4db9b5d@mail.gmail.com>
	 <20090826082741.GA25955@cmpxchg.org>	<20090826093747.GA10955@csn.ul.ie>
	 <20090826074409.606b5124.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mel Gorman <mel-wJa12IhQEiizQB+pC5nmwQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090826074409.606b5124.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-08-26 at 22:44 +0800, Andrew Morton wrote:
> 
> It is perhaps pretty simple to make the second (GFP_ATOMIC) allocation
> go away.  The code is already conveniently structured to do this:
> 
>         do {
>                 chunk = (struct fw_chunk *)(data + offset);
>                 offset += sizeof(struct fw_chunk);
>                 /* build DMA packet and queue up for sending */
>                 /* dma to chunk->address, the chunk->length bytes from
> data +
>                  * offeset*/
>                 /* Dma loading */
>                 rc = ipw_fw_dma_add_buffer(priv, shared_phys + offset,
> 
> le32_to_cpu(chunk->address),
> 
> le32_to_cpu(chunk->length));
>                 if (rc) {
>                         IPW_DEBUG_INFO("dmaAddBuffer Failed\n");
>                         goto out;
>                 }
> 
>                 offset += le32_to_cpu(chunk->length);
>         } while (offset < len);
> 
> what is the typical/expected value of chunk->length here?  If it's
> significantly less than 4096*(2^6), could we convert this function to
> use a separate DMAable allocation per fw_chunk?

Unfortunately, the largest chunk size for the latest 3.1 firmware is
0x20040, which also requires order 6 page allocation. I'll try to use
the firmware DMA command block (64 slots) to handle the image (each for
4k, totally 256k).

Thanks,
-yi
