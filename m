From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v2 3/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Thu, 9 Jan 2014 00:28:50 -0800
Message-ID: <CANJ5vPJp-AwvFDtY1R7SJg6L2dkEU6xPivgKcg4f0+05JCMEfw@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-3-git-send-email-mwdalton@google.com>
	<20140109014255.GA19321@redhat.com>
	<CANJ5vP+_aK0PMc6-hwbu6PduVNDe8jbWR19cN5C+k4mWQzdTGg@mail.gmail.com>
	<CANJ5vPLvDff5PMYNGvtt-dd=md8b46ZXAYLv-KnerNcfzDNHpw@mail.gmail.com>
	<20140109064807.GC19559@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20140109064807.GC19559@redhat.com>
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

Here's a quick sketch of some code that enforces a minimum buffer
alignment of only 64, and has a maximum theoretical buffer size of
aligned GOOD_PACKET_LEN + (BUF_ALIGN - 1) * BUF_ALIGN, which is at least
1536 + 63 * 64 = 5568. On x86, we already use a 64 byte alignment, and
this code supports all current buffer sizes, from 1536 to PAGE_SIZE.

#if L1_CACHE_BYTES < 64
#define MERGEABLE_BUFFER_ALIGN 64
#define MERGEABLE_BUFFER_SHIFT 6
#else
#define MERGEABLE_BUFFER_ALIGN L1_CACHE_BYTES
#define MERGEABLE_BUFFER_SHIFT L1_CACHE_SHIFT
#endif
#define MERGEABLE_BUFFER_MIN ALIGN(GOOD_PACKET_LEN +
                                   sizeof(virtio_net_hdr_mrg_rbuf),
                                   MERGEABLE_BUFFER_ALIGN)
#define MERGEABLE_BUFFER_MAX min(MERGEABLE_BUFFER_MIN +
                                 (MERGEABLE_BUFFER_ALIGN - 1) *
                                 MERGEABLE_BUFFER_ALIGN, PAGE_SIZE)
/* Extract buffer length from a mergeable buffer context. */
static u16 get_mergeable_buf_ctx_len(void *ctx) {
        u16 len = (uintptr_t)ctx & (MERGEABLE_BUFFER_ALIGN - 1);
        return MERGEABLE_BUFFER_MIN + (len << MERGEABLE_BUFFER_SHIFT);
}
/* Extract buffer base address from a mergeable buffer context. */
static void *get_mergeable_buf_ctx_base(void *ctx) {
        return (void *) ((uintptr)ctx & -MERGEABLE_BUFFER_ALIGN);
}
/* Convert a base address and length to a mergeable buffer context. */
static void *to_mergeable_buf_ctx(void *base, u16 len) {
        len -= MERGEABLE_BUFFER_MIN;
        return (void *) ((uintptr)base | (len >> MERGEABLE_BUFFER_SHIFT));
}
/* Compute the packet buffer length for a receive queue. */
static u16 get_mergeable_buffer_len(struct receive_queue *rq) {
        u16 len = clamp_t(u16, MERGEABLE_BUFFER_MIN,
                          ewma_read(&rq->avg_pkt_len),
                          MERGEABLE_BUFFER_MAX);
        return ALIGN(len, MERGEABLE_BUFFER_ALIGN);
}

Best,

Mike
