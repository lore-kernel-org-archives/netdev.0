From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next v2 3/4] virtio-net: auto-tune mergeable rx
	buffer size for improved performance
Date: Wed, 8 Jan 2014 21:16:23 +0200
Message-ID: <20140108191623.GA18312@redhat.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-3-git-send-email-mwdalton@google.com>
	<52CCEEF3.5070904@redhat.com>
	<CANJ5vP+btxgZg5kDq30KZTEXO7YBCL5TWoiRzjMqxnaA3Edkxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CANJ5vP+btxgZg5kDq30KZTEXO7YBCL5TWoiRzjMqxnaA3Edkxw@mail.gmail.com>
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

On Wed, Jan 08, 2014 at 10:28:09AM -0800, Michael Dalton wrote:
> Hi Jason,
> 
> On Tue, Jan 7, 2014 at 10:23 PM, Jason Wang <jasowang@redhat.com> wrote:
> > What's the reason that this extra space is not accounted for truesize?
> The initial rationale was that this extra space is due to
> internal fragmentation in the page frag allocator, but I agree with
> you -- this code should be changed and the extra space accounted for.
> Any internal fragmentation leading to a larger last packet allocated from
> the page should be reflected in the SKB truesize of the last packet.

I think this is what the original patchset did, but I don't really get
why this is a good idea.
Why should we select a frame at random and make it's truesize bigger?
All frames are to blame for the extra space.
Just ignoring it seems more symmetrical.


> I will do a followup patchset that accounts correctly for the extra
> space, which will also me to remove the two max statements you
> indicated. Thanks for finding this issue.
> 
> >> +     if (err < 0) {
> >> +             put_page(virt_to_head_page(ctx->buf));
> >> +             return err;
> > Should we also roll back the frag offset added above to avoid leaking frags?
> I believe the put_page here is sufficient for correctness. When we
> allocate a buffer using skb_page_frag_refill, we use get_page/put_page
> to allocate/free respectively. For example, if the virtqueue_add_inbuf
> succeeded, we would eventually call put_page either in virtio-net
> (e.g., page_to_skb for packets <= GOOD_COPY_LEN bytes) or later in
> __skb_frag_unref and other functions called during dev_kfree_skb.
> 
> However, an offset rollback does allow the space to be reused by the next
> allocation, which could be a good optimization. I can do the offset
> rollback (with a put_page) in the next patchset. What do you think?

If you intend to repost anyway (for the below wrinkle) then
you can do it right here just as well I guess. Seems a bit prettier.

> >> +     /* Do not attempt to add a buffer if the RX ring is full. */
> >> +     if (unlikely(!rq->vq->num_free))
> >> +             return true;
> > I haven't figured out why this is needed. It seems safe for
> > virtqueue_add_inbuf() just fail in add_recv_xx()?
> I think this is safe with one caveat -- we can't modify
> rq->mrg_buf_ctx until we know the ring isn't full (otherwise, we
> clobber an in-use entry). It is safe to modify rq->mrg_buf_ctx
> after we know that virtqueue_add_inbuf has succeeded.
> 
> I can remove the rq_num_free check from try_fill_recv, and then
> modify virtqueue_add_inbuf to use a local mergeable_receive_buf_ctx.
> Once virtqueue_add_inbuf succeeds, the contents of the local variable
> can be copied to rq->mrg_buf_ctx[rq->mrg_buf_ctx_head].
> 
> Best,
> 
> Mike


You don't have to fill in ctx before calling add_inbuf, do you?
Just fill it afterwards.

-- 
MST
