From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v2 3/4] virtio-net: auto-tune mergeable rx buffer
	size for improved performance
Date: Thu, 9 Jan 2014 01:02:41 -0800
Message-ID: <CANJ5vPJrE8gpUdxVjUXwCaTGcixt7xtp=qNBfcm4T4gm9-1APw@mail.gmail.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-3-git-send-email-mwdalton@google.com>
	<20140109014255.GA19321@redhat.com>
	<CANJ5vP+_aK0PMc6-hwbu6PduVNDe8jbWR19cN5C+k4mWQzdTGg@mail.gmail.com>
	<CANJ5vPLvDff5PMYNGvtt-dd=md8b46ZXAYLv-KnerNcfzDNHpw@mail.gmail.com>
	<20140109064807.GC19559@redhat.com>
	<CANJ5vPJp-AwvFDtY1R7SJg6L2dkEU6xPivgKcg4f0+05JCMEfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vPJp-AwvFDtY1R7SJg6L2dkEU6xPivgKcg4f0+05JCMEfw@mail.gmail.com>
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

If the prior code snippet looks good to you, I'll use something like
that as a baseline for a v3 patchset. I don't think we need a stricter
alignment than 64 to express values in the range (1536 ... 4096), as
the code snippet shows, which is great for x86 4KB pages.

On other architectures that have larger page sizes > 4KB with <= 64b
cachelines, we may want to increase the alignment so that the max buffer
size will be >= PAGE_SIZE (max size allowed by skb_page_frag_refill).

If we use a minimum alignment of 128, our maximum theoretical
packet buffer length is 1536 + 127 * 128 = 17792. With 256 byte
alignment, we can express a maximum packet buffer size > 65536.

Given the above, I think we want to select the min buffer alignment
based on the PAGE_SIZE:
        <= 4KB PAGE_SIZE: 64b min alignment
        <= 16KB PAGE_SIZE: 128b min alignment
        > 16KB PAGE_SIZE: 256b min alignment

So the prior code snippet would be relatively unchanged, except that
references to the previous minimum alignment of 64 would be replaced by
a #define'd constant derived from PAGE_SIZE as shown above.

This would guarantee that we use the minimum alignment necessary to
ensure that virtio-net can post a max size (PAGE_SIZE) buffer, and for
x86 this means we won't increase the alignment beyond the x86's current
L1_CACHE_BYTES value (64). Also, sorry I haven't had a chance to respond
yet to the debugfs feedback, I will get to that soon (just wanted to do
a further deep dive on some of the sysfs/debugfs tradeoffs).

Best,

Mike
