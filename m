From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 6/6] vhost_net: remove the max pending check
Date: Sun, 25 Aug 2013 14:53:44 +0300
Message-ID: <20130825115344.GB1829@redhat.com>
References: <1376630190-5912-1-git-send-email-jasowang@redhat.com>
	<1376630190-5912-7-git-send-email-jasowang@redhat.com>
	<20130816100225.GD21821@redhat.com> <5212D8F2.10307@redhat.com>
	<52172395.9000400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <52172395.9000400@redhat.com>
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

On Fri, Aug 23, 2013 at 04:55:49PM +0800, Jason Wang wrote:
> On 08/20/2013 10:48 AM, Jason Wang wrote:
> > On 08/16/2013 06:02 PM, Michael S. Tsirkin wrote:
> >> > On Fri, Aug 16, 2013 at 01:16:30PM +0800, Jason Wang wrote:
> >>> >> We used to limit the max pending DMAs to prevent guest from pinning too many
> >>> >> pages. But this could be removed since:
> >>> >>
> >>> >> - We have the sk_wmem_alloc check in both tun/macvtap to do the same work
> >>> >> - This max pending check were almost useless since it was one done when there's
> >>> >>   no new buffers coming from guest. Guest can easily exceeds the limitation.
> >>> >> - We've already check upend_idx != done_idx and switch to non zerocopy then. So
> >>> >>   even if all vq->heads were used, we can still does the packet transmission.
> >> > We can but performance will suffer.
> > The check were in fact only done when no new buffers submitted from
> > guest. So if guest keep sending, the check won't be done.
> >
> > If we really want to do this, we should do it unconditionally. Anyway, I
> > will do test to see the result.
> 
> There's a bug in PATCH 5/6, the check:
> 
> nvq->upend_idx != nvq->done_idx
> 
> makes the zerocopy always been disabled since we initialize both
> upend_idx and done_idx to zero. So I change it to:
> 
> (nvq->upend_idx + 1) % UIO_MAXIOV != nvq->done_idx.

But what I would really like to try is limit ubuf_info to VHOST_MAX_PEND.
I think this has a chance to improve performance since
we'll be using less cache.
Of course this means we must fix the code to really never submit
more than VHOST_MAX_PEND requests.

Want to try?
> 
> With this change on top, I didn't see performance difference w/ and w/o
> this patch.

Did you try small message sizes btw (like 1K)? Or just netperf
default of 64K?

-- 
MST
