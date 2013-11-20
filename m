From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] virtio-net: fix page refcnt leaking when fail to
	allocate frag skb
Date: Wed, 20 Nov 2013 11:17:13 +0800
Message-ID: <528C29B9.5000701@redhat.com>
References: <1384848307-7217-1-git-send-email-jasowang@redhat.com>
	<1384869828.8604.97.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119204909.GA15004@redhat.com>
	<1384896996.8604.120.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131119215312.GE15004@redhat.com>
	<1384898411.8604.127.camel@edumazet-glaptop2.roam.corp.google.com>
	<CANJ5vP+ZxtDf8OzREpyDpgh8JLnWGEjkUcS388hi+AOjdu0fZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>
To: Michael Dalton <mwdalton@google.com>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CANJ5vP+ZxtDf8OzREpyDpgh8JLnWGEjkUcS388hi+AOjdu0fZw@mail.gmail.com>
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

On 11/20/2013 09:34 AM, Michael Dalton wrote:
> Hi,
>
> After further reflection I think we're looking at two related issues:
> (a) a memory leak that Jason has identified that occurs when a memory
> allocation fails in receive_mergeable. Jasons commit solves this issue.
> (b) virtio-net does not dequeue all buffers for a packet in the
> case that an error occurs on receive and mergeable receive buffers is
> enabled.
>
> For (a), this bug is new and due to changes in 2613af0ed18a, and the
> net impact is memory leak on the physical page. However, I believe (b)
> has always been possible in some form because if page_to_skb() returns
> NULL (e.g., due to SKB allocation failure), receive_mergeable is never
> called. AFAICT this is also the behavior prior to 2613af0ed18a.
>
> The net impact of (b) would be that virtio-net would interpret a packet
> buffer that is in the middle of a mergeable packet as the start of a
> new packet, which is definitely also a bug (and the buffer contents
> could contain bytes that resembled a valid virtio-net header).
>
> A solution for (b) will require handling both the page_to_skb memory
> allocation failures and the memory allocation failures in
> receive_mergeable introduced by 2613af0ed18a.

Ture, so we first need a patch to solve page_to_skb() failure which
could be used for stable tree prior to 2613af0ed18a. Then another patch
to solve the issue introduced by 2613af0ed18a which could be only used
for 3.12 stable. Will draft patches for them.

Thanks
>
> Best,
>
> Mike
