From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] virtio_net: fix refill related races
Date: Sun, 11 Dec 2011 16:44:29 +0200
Message-ID: <20111211144428.GB14381@redhat.com>
References: <20111207152120.GA23417@redhat.com>
	<8739cvisqe.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <8739cvisqe.fsf@rustcorp.com.au>
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

On Thu, Dec 08, 2011 at 03:07:29PM +1030, Rusty Russell wrote:
> On Wed, 7 Dec 2011 17:21:22 +0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> > Fix theoretical races related to refill work:
> > 1. After napi is disabled by ndo_stop, refill work
> >    can run and re-enable it.
> > 2. Refill can reschedule itself, if this happens
> >    it can run after cancel_delayed_work_sync,
> >    and will access device after it is destroyed.
> > 
> > As a solution, add flags to track napi state and
> > to disable refill, and toggle them on start, stop
> > and remove; check these flags on refill.
> 
> Why isn't a "dont-readd" flag sufficient?
> 
> Cheers,
> Rusty.

I started with that, but here's the problem I wanted to
address:

- we run out of descriptors and schedule refill work
- ndo_close runs
- refill work runs
- ndo_open runs


Now if we just disable refill, refill work will not add buffers and will
not reschedule.  Now we'll never get more buffers.
We can try starting refill work from ndo_open but overall
this seems to me more risky than just splitting flags.


-- 
MST
