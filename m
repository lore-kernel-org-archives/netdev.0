From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next V7 PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Fri, 13 Oct 2017 10:17:57 +0200
Message-ID: <20171013101757.58758ed0@redhat.com>
References: <150781116384.9409.2491501775270038284.stgit@firesoul>
        <150781120970.9409.4248519763583438653.stgit@firesoul>
        <de3a227a-da92-b905-11d0-ecc5a05f3bc0@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jakub.kicinski@netronome.com>,
        "Michael S. Tsirkin" <mst@redhat.com>, <pavel.odintsov@gmail.com>,
        Jason Wang <jasowang@redhat.com>, <mchan@broadcom.com>,
        John Fastabend <john.fastabend@gmail.com>,
        <peter.waskiewicz.jr@intel.com>, <ast@fiberby.dk>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, brouer@redhat.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751565AbdJMISJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 04:18:09 -0400
In-Reply-To: <de3a227a-da92-b905-11d0-ecc5a05f3bc0@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 12 Oct 2017 21:35:05 +0100 Edward Cree <ecree@solarflare.com> wrote:

> On 12/10/17 13:26, Jesper Dangaard Brouer wrote:
> > The 'cpumap' is primary used as a backend map for XDP BPF helper  
> s/primary/primarily.
>  [...]  
> Again, s/primary/primarily.
> > + * call bpf_redirect_map() and XDP_REDIRECT action, like 'devmap'.
> > + *
> > + * Unlike devmap which redirect XDP frames out another NIC device,
> > + * this map type redirect raw XDP frames to another CPU.  The remote  
> Also I think both of these 'redirect' should be 'redirects', just a
>  grammatical nit pick ;)
> > + * CPU will do SKB-allocation and call the normal network stack.
> > + *
> > + * This is a scalability and isolation mechanism, that allow
> > + * separating the early driver network XDP layer, from the rest of the
> > + * netstack, and assigning dedicated CPUs for this stage.  This
> > + * basically allows for 10G wirespeed pre-filtering via bpf.
> > + */
> > +#include <linux/bpf.h>
> > +#include <linux/filter.h>
> > +#include <linux/ptr_ring.h>
> > +
> > +#include <linux/sched.h>
> > +#include <linux/workqueue.h>
> > +#include <linux/kthread.h>
> > +#include <linux/capability.h>
> > +
> > +/* General idea: XDP packets getting XDP redirected to another CPU,
> > + * will maximum be stored/queued for one driver ->poll() call.  It is
> > + * guaranteed that setting flush bit and flush operation happen on
> > + * same CPU.  Thus, cpu_map_flush operation can deduct via this_cpu_ptr()
> > + * which queue in bpf_cpu_map_entry contains packets.
> > + */
> > +
> > +#define CPU_MAP_BULK_SIZE 8  /* 8 == one cacheline on 64-bit archs */
> > +struct xdp_bulk_queue {
> > +	void *q[CPU_MAP_BULK_SIZE];
> > +	unsigned int count;
> > +};  
>
> I realise it's a bit late to say this on a v7, but it might be better to
>  use a linked-list (list_heads) here instead of an array.  Then, the
>  struct xdp_pkt you store in the packet headroom could contain the
>  list_head, there's no arbitrary bulking limit, and the flush just has
>  to link the newly-created elements into the receiving CPU's list.
> Is there an obvious reason why this wouldn't work / can't perform as
>  well, or should I try it and benchmark it?

No, I've tried to explain this before.  I do want a bulking limit for
several reasons. (1) This is connected to how ptr_ring works. I do want
to have a full cache-line to transfer/enqueue into the ptr_ring.  The
ptr_ring is the key to making the transfer between CPUs work so
efficiently (I even reject my own alf_queue in favor of ptr_ring).
(2) Due to latency concerns, I don't want to "wait" for 64 packets before
the remote CPU get a chance to see these. I want to transfer/enqueue
packets to the remote CPU as soon as possible, and due to cacheline
constraints this is 8 packets.

The ptr_ring goes to great lengths to avoid cache-line bouncing. Like
fb9de9704775 ("ptr_ring: batch ring zeroing") which helps avoid cache
line bouncing when queue is full. When queue is almost empty,
cache-line bouncing still occurs.  Which is what I'm trying to minimize
here by transfering/enqueueing a full cacheline.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
