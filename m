From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V3 3/3] vhost_net: basic polling support
Date: Mon, 29 Feb 2016 13:17:15 +0800
Message-ID: <56D3D45B.3020600@redhat.com>
References: <1456476164-17242-1-git-send-email-jasowang@redhat.com>
	<1456476164-17242-4-git-send-email-jasowang@redhat.com>
	<56D36D25.6070903@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.zhang.wz@gmail.com, RAPOPORT@il.ibm.com
To: Christian Borntraeger <borntraeger@de.ibm.com>, kvm@vger.kernel.org,
	mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <56D36D25.6070903@de.ibm.com>
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



On 02/29/2016 05:56 AM, Christian Borntraeger wrote:
> On 02/26/2016 09:42 AM, Jason Wang wrote:
>> > This patch tries to poll for new added tx buffer or socket receive
>> > queue for a while at the end of tx/rx processing. The maximum time
>> > spent on polling were specified through a new kind of vring ioctl.
>> > 
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
>> > ---
>> >  drivers/vhost/net.c        | 79 +++++++++++++++++++++++++++++++++++++++++++---
>> >  drivers/vhost/vhost.c      | 14 ++++++++
>> >  drivers/vhost/vhost.h      |  1 +
>> >  include/uapi/linux/vhost.h |  6 ++++
>> >  4 files changed, 95 insertions(+), 5 deletions(-)
>> > 
>> > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>> > index 9eda69e..c91af93 100644
>> > --- a/drivers/vhost/net.c
>> > +++ b/drivers/vhost/net.c
>> > @@ -287,6 +287,44 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
>> >  	rcu_read_unlock_bh();
>> >  }
>> > 
>> > +static inline unsigned long busy_clock(void)
>> > +{
>> > +	return local_clock() >> 10;
>> > +}
>> > +
>> > +static bool vhost_can_busy_poll(struct vhost_dev *dev,
>> > +				unsigned long endtime)
>> > +{
>> > +	return likely(!need_resched()) &&
>> > +	       likely(!time_after(busy_clock(), endtime)) &&
>> > +	       likely(!signal_pending(current)) &&
>> > +	       !vhost_has_work(dev) &&
>> > +	       single_task_running();
>> > +}
>> > +
>> > +static int vhost_net_tx_get_vq_desc(struct vhost_net *net,
>> > +				    struct vhost_virtqueue *vq,
>> > +				    struct iovec iov[], unsigned int iov_size,
>> > +				    unsigned int *out_num, unsigned int *in_num)
>> > +{
>> > +	unsigned long uninitialized_var(endtime);
>> > +	int r = vhost_get_vq_desc(vq, vq->iov, ARRAY_SIZE(vq->iov),
>> > +				    out_num, in_num, NULL, NULL);
>> > +
>> > +	if (r == vq->num && vq->busyloop_timeout) {
>> > +		preempt_disable();
>> > +		endtime = busy_clock() + vq->busyloop_timeout;
>> > +		while (vhost_can_busy_poll(vq->dev, endtime) &&
>> > +		       vhost_vq_avail_empty(vq->dev, vq))
>> > +			cpu_relax();
> Can you use cpu_relax_lowlatency (which should be the same as cpu_relax for almost
> everybody but s390? cpu_relax (without low latency might give up the time slice
> when running under another hypervisor (like LPAR on s390), which might not be what
> we want here.

Ok, will do this in next version.
