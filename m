From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next 4/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Sat, 16 Nov 2013 01:06:32 -0800
Message-ID: <CANJ5vPKaNsNkx9MLYFYBSxgfuhm_xnmJh_UYadAfv-_t6nPjbA@mail.gmail.com>
References: <1384294885-6444-1-git-send-email-mwdalton@google.com>
	<1384294885-6444-4-git-send-email-mwdalton@google.com>
	<528325DC.3050801@redhat.com> <20131113174245.GB31078@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20131113174245.GB31078@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi,

Apologies for the delay, I wanted to get answers together for all of the
open questions raised on this thread. The first patch in this patchset is
already merged, so after the merge window re-opens I'll send out new
patchsets covering the remaining 3 patches.

After reflecting on feedback from this thread, I think it makes sense to
separate out the per-receive queue page frag allocator patches from the
autotuning patch when the merge window re-opens. The per-receive queue
page frag allocator patches help deal with fragmentation (PAGE_SIZE does
not evenly divide MERGE_BUFFER_LEN), and provide benefits whether or not
auto-tuning is present. Auto-tuning can then be evaluated separately.

On Wed, 2013-11-13 at 15:10 +0800, Jason Wang wrote:
> There's one concern with EWMA. How well does it handle multiple streams
> each with different packet size? E.g there may be two flows, one with
> 256 bytes each packet another is 64K.  Looks like it can result we
> allocate PAGE_SIZE buffer for 256 (which is bad since the
> payload/truesize is low) bytes or 1500+ for 64K buffer (which is ok
> since we can do coalescing).

If multiple streams of very different packet sizes are arriving on the
same receive queue, no single buffer size is ideal(e.g., large buffers
will cause small packets to take up too much memory, but small buffers
may reduce throughput somewhat for large packets). We don't know a
priori which packet will be delivered to a given receive queue packet
buffer, so any size we choose will not be optimal for all cases if we
have significant variance in packet sizes.

> Do you have perf numbers that just without this patch? We need to know
> how much EWMA help exactly.

Great point, I should have included that in my initial benchmarking. I ran
a benchmark in the same environment as my initial results, this time with
the first 3 patches in this patchset applied but without the autotuning
patch.  The average performance over 5 runs of 30-second netperf was
13760.85Gb/s.

> Is there a chance that est_buffer_len was smaller than or equal with len?

Yes, that is possible if the average packet length decreases.

> Not sure this is accurate, since buflen may change and several frags may
> share a single page. So the est_buffer_len we get in receive_mergeable()
> may not be the correct value.

I agree it may not be 100% accurate but we can choose a weight that will
cause the average packet size to change slowly. Even with an order 3 page
there will not be too many packet buffers allocated from a single page.

On Wed, 2013-11-13 at 17:42 +0800, Michael S. Tsirkin wrote:
> I'm not sure it's useful - no one is likely to tune it in practice.
> But how about a comment explaining how was the number chosen?

That makes sense, I agree a comment is needed. The weight determines
how quickly we react to a change in packet size. As we attempt to fill
all free ring entries on refill (in try_fill_recv), I chose a large
weight so that a short burst of traffic with a different average packet
size will not substantially shift the packet buffer size for the entire
ring the next time try_fill_recv is called. I'll add a comment that
compares 64 to nearby values (32, 16).

Best,

Mike
