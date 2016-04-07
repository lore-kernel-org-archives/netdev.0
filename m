From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Thu, 7 Apr 2016 16:17:15 +0200
Message-ID: <20160407161715.52635cac@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
        James Bottomley
 <James.Bottomley@HansenPartnership.com>,
        "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei
 Starovoitov <alexei.starovoitov@gmail.com>,
        Brenden Blanco
 <bblanco@plumgrid.com>,
        lsf-pc@lists.linux-foundation.org
To: lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1460034425.20949.7.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

(Topic proposal for MM-summit)

Network Interface Cards (NIC) drivers, and increasing speeds stress
the page-allocator (and DMA APIs).  A number of driver specific
open-coded approaches exists that work-around these bottlenecks in the
page allocator and DMA APIs. E.g. open-coded recycle mechanisms, and
allocating larger pages and handing-out page "fragments".

I'm proposing a generic page-pool recycle facility, that can cover the
driver use-cases, increase performance and open up for zero-copy RX.


The basic performance problem is that pages (containing packets at RX)
are cycled through the page allocator (freed at TX DMA completion
time).  While a system in a steady state, could avoid calling the page
allocator, when having a pool of pages equal to the size of the RX
ring plus the number of outstanding frames in the TX ring (waiting for
DMA completion).

The motivation for quick page recycling came primarily for performance
reasons.  But returning pages to the same pool also benefit other
use-cases.  If a NIC HW RX ring is strictly bound (e.g. to a process
or guest/KVM) then pages can be shared/mmap'ed (RX zero-copy) as
information leaking does not occur.  (Obviously for this use-case,
when adding pages into the pool these need to zero'ed out).


The motivation behind implemeting this (extremely fast page-pool) is
because we need it as a building block in the network stack, but
hopefully other areas could also benefit from this.


[Resources/Links]: It is specifically related to:

What Facebook calls XDP (eXpress Data Path)
 * https://github.com/iovisor/bpf-docs/blob/master/Express_Data_Path.pdf
 * RFC patchset thread: http://thread.gmane.org/gmane.linux.network/406288

And what I call the "packet-page" level:
 * BoF on kernel network performance: http://lwn.net/Articles/676806/
 * http://people.netfilter.org/hawk/presentations/NetDev1.1_2016/links.html


See you soon at LFS/MM-summit :-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
