From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 3/3] net: auto-tune mergeable rx buffer size for
	improved performance
Date: Thu, 26 Dec 2013 22:24:13 +0200
Message-ID: <20131226202413.GA10215@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<1387239389-13216-3-git-send-email-mwdalton@google.com>
	<52BBDBAD.8030609@redhat.com>
	<CANJ5vPJX1yTKJXpFe+PO7u89-tYRjNPdJwrBLjAop3veye1pDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Michael Dalton <mwdalton@google.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <CANJ5vPJX1yTKJXpFe+PO7u89-tYRjNPdJwrBLjAop3veye1pDg@mail.gmail.com>
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

On Thu, Dec 26, 2013 at 12:06:23PM -0800, Michael Dalton wrote:
> On Mon, Dec 23, 2013 at 4:51 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > OK so a high level benchmark shows it's worth it,
> > but how well does the logic work?
> > I think we should make the buffer size accessible in sysfs
> > or debugfs, and look at it, otherwise we don't really know.
> >
> Exporting the size sounds good to me, it is definitely an
> important metric and would give more visibility to the admin.
> 
> Do you have a preference for implementation strategy? I was
> thinking just add a DEVICE_ATTR to create a read-only sysfs file,
> 'mergeable_rx_buffer_size', and return a space-separated list of the
> current buffer size (computed from the average packet size) for each
> receive queue. -EINVAL or a similar error could be returned if the
> netdev was not configured for mergeable rx buffers.

Not too important really. Maybe an attribute per queue? Might be
easier to parse and does not need tricky formatting.

> > I don't get the real motivation for this.
> >
> > We have skbs A,B,C sharing a page, with chunk D being unused.
> > This randomly charges chunk D to an skb that ended up last
> > in the page.
> > Correct?
> > Why does this make sense?
> 
> The intent of this code is to adjust the SKB true size for
> the packet. We should completely use each packet buffer except
> for the last buffer. For all buffers except the last buffer, it
> should be the case that 'len' (bytes received) = buffer size. For
> the last buffer, this code adjusts the truesize by comparing the
> approximated buffer size with the bytes received into the buffer,
> and adding the difference to the SKB truesize if the buffer size
> is greater than the number of bytes received.
> 
> We approximate the buffer size by using the last packet buffer size
> from that same page, which as you have correctly noted may be a buffer
> that belongs to a different packet on the same virtio-net device. This
> buffer size should be very close to the actual buffer size because our
> EWMA estimator uses a high weight (so the packet buffer size changes very
> slowly) and there are only a handful packets on a page (even order-3).

I'll need to ponder it, don't understand it exactly.

> > Why head_skb only? Why not full buffer size that comes from host?
> > This is simply len.
> 
> Sorry, I believe this code fragment should be clearer. Basically, we
> have a corner case in that for packets with size <= GOOD_COPY_LEN, there
> are no frags because page_to_skb() already unref'd the page and the entire
> packet contents are copied to skb->data. In this case, the SKB truesize
> is already accurate and should not be updated (and it would be unsafe to
> access page->private as page is already unref'd).
> 
> I'll look at the above code again and cleanup (please let me know if you
> have a preference) and/or add a comment to clarify.
> 
> Best,
> 
> Mike
