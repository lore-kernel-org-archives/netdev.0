From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V3 3/3] vhost_net: basic polling support
Date: Mon, 29 Feb 2016 11:03:54 +0200
Message-ID: <20160229105517-mutt-send-email-mst@redhat.com>
References: <1456476164-17242-1-git-send-email-jasowang@redhat.com>
	<1456476164-17242-4-git-send-email-jasowang@redhat.com>
	<20160228140937.GA8855@redhat.com> <56D3D404.6080600@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.zhang.wz@gmail.com, RAPOPORT@il.ibm.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <56D3D404.6080600@redhat.com>
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

On Mon, Feb 29, 2016 at 01:15:48PM +0800, Jason Wang wrote:
> 
> 
> On 02/28/2016 10:09 PM, Michael S. Tsirkin wrote:
> > On Fri, Feb 26, 2016 at 04:42:44PM +0800, Jason Wang wrote:
> >> > This patch tries to poll for new added tx buffer or socket receive
> >> > queue for a while at the end of tx/rx processing. The maximum time
> >> > spent on polling were specified through a new kind of vring ioctl.
> >> > 
> >> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > Looks good overall, but I still see one problem.
> >
> >> > ---
> >> >  drivers/vhost/net.c        | 79 +++++++++++++++++++++++++++++++++++++++++++---
> >> >  drivers/vhost/vhost.c      | 14 ++++++++
> >> >  drivers/vhost/vhost.h      |  1 +
> >> >  include/uapi/linux/vhost.h |  6 ++++
> >> >  4 files changed, 95 insertions(+), 5 deletions(-)
> >> > 
> >> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> >> > index 9eda69e..c91af93 100644
> >> > --- a/drivers/vhost/net.c
> >> > +++ b/drivers/vhost/net.c
> >> > @@ -287,6 +287,44 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
> >> >  	rcu_read_unlock_bh();
> >> >  }
> >> >  
> >> > +static inline unsigned long busy_clock(void)
> >> > +{
> >> > +	return local_clock() >> 10;
> >> > +}
> >> > +
> >> > +static bool vhost_can_busy_poll(struct vhost_dev *dev,
> >> > +				unsigned long endtime)
> >> > +{
> >> > +	return likely(!need_resched()) &&
> >> > +	       likely(!time_after(busy_clock(), endtime)) &&
> >> > +	       likely(!signal_pending(current)) &&
> >> > +	       !vhost_has_work(dev) &&
> >> > +	       single_task_running();
> > So I find it quite unfortunate that this still uses single_task_running.
> > This means that for example a SCHED_IDLE task will prevent polling from
> > becoming active, and that seems like a bug, or at least
> > an undocumented feature :).
> 
> Yes, it may need more thoughts.
> 
> >
> > Unfortunately this logic affects the behaviour as observed
> > by userspace, so we can't merge it like this and tune
> > afterwards, since otherwise mangement tools will start
> > depending on this logic.
> >
> >
> 
> How about remove single_task_running() first here and optimize on top?
> We probably need something like this to handle overcommitment.

Sounds good.

-- 
MST
