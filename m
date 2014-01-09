From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v2 3/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Wed, 8 Jan 2014 19:16:18 -0800
Message-ID: <CANJ5vP+_aK0PMc6-hwbu6PduVNDe8jbWR19cN5C+k4mWQzdTGg@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-3-git-send-email-mwdalton@google.com>
	<20140109014255.GA19321@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140109014255.GA19321@redhat.com>
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

Hi Michael,

On Wed, Jan 8, 2014 at 5:42 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> Sorry that I didn't notice early, but there seems to be a bug here.
> See below.
Yes, that is definitely a bug. Virtio spec permits OOO completions,
but current code assumes in-order completion. Thanks for catching this.

> Don't need full int really, it's up to 4K/cache line size,
> 1 byte would be enough, maximum 2 ...
> So if all we want is extra 1-2 bytes per buffer, we don't really
> need this extra level of indirection I think.
> We can just allocate them before the header together with an skb.
I'm not sure if I'm parsing the above correctly, but do you mean using a
few bytes at the beginning of the packet buffer to store truesize? I
think that will break Jason's virtio-net RX frag coalescing
code. To coalesce consecutive RX packet buffers, our packet buffers must
be physically adjacent, and any extra bytes before the start of the
buffer would break that.

We could allocate an SKB per packet buffer, but if we have multi-buffer
packets often(e.g., netperf benefiting from GSO/GRO), we would be
allocating 1 SKB per packet buffer instead of 1 SKB per MAX_SKB_FRAGS
buffers. How do you feel about any of the below alternatives:

(1) Modify the existing mrg_buf_ctx to chain together free entries
We can use the 'buf' pointer in mergeable_receive_buf_ctx to chain
together free entries so that we can support OOO completions. This would
be similar to how virtio-queue manages free sg entries.

(2) Combine the buffer pointer and truesize into a single void* value
Your point about there only being a byte needed to encode truesize is
spot on, and I think we could leverage this to eliminate the out-of-band
metadata ring entirely. If we were willing to change the packet buffer
alignment from L1_CACHE_BYTES to 256 (or min (256, L1_CACHE_SIZE)), we
could encode the truesize in the least significant 8 bits of the buffer
address (encoded as truesize >> 8 as we know all sizes are a multiple
of 256). This would allow packet buffers up to 64KB in length.

Is there another approach you would prefer to any of these? If the
cleanliness issues and larger alignment aren't too bad, I think (2)
sounds promising and allow us to eliminate the metadata ring
entirely while still permitting RX frag coalescing.

Best,

Mike
