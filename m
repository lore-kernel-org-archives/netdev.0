From: Amos Kong <akong@redhat.com>
Subject: Re: [PATCH] virtio_net: return error when there is no virtqueue or
	MQ isn't support
Date: Tue, 22 Apr 2014 12:14:35 +0800
Message-ID: <20140422041435.GB2543@amosk.info>
References: <1398093061-13444-1-git-send-email-akong@redhat.com>
	<5355DDF6.7050509@redhat.com> <20140422032351.GA2543@amosk.info>
	<5355E7BE.10506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <5355E7BE.10506@redhat.com>
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

On Tue, Apr 22, 2014 at 11:53:34AM +0800, Jason Wang wrote:
> On 04/22/2014 11:23 AM, Amos Kong wrote:
> > On Tue, Apr 22, 2014 at 11:11:50AM +0800, Jason Wang wrote:
> >> On 04/21/2014 11:11 PM, Amos Kong wrote:
> >>> Currently ethtool returns zero if there is no virtqueue or MQ isn't
> >>> support, we should return -ENOTSUPP to notice user.
> >>>
> >>> Signed-off-by: Amos Kong <akong@redhat.com>

NAK this patch.

> >>> ---
> >>>  drivers/net/virtio_net.c | 2 +-
> >>>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>>
> >>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> >>> index 8a852b5..eaf8266 100644
> >>> --- a/drivers/net/virtio_net.c
> >>> +++ b/drivers/net/virtio_net.c
> >>> @@ -1053,7 +1053,7 @@ static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
> >>>  	struct net_device *dev = vi->dev;
> >>>  
> >>>  	if (!vi->has_cvq || !virtio_has_feature(vi->vdev, VIRTIO_NET_F_MQ))
> >>> -		return 0;
> >>> +		return -ENOTSUPP;
> >>>  
> >>>  	s.virtqueue_pairs = queue_pairs;
> >>>  	sg_init_one(&sg, &s, sizeof(s));
> >> How about check the return value of virtnet_set_queues() in
> >> virtnet_restore() also?
> > If we migrate a guest from MQ supported side to MQ non-supported side,
> > virtnet_restore() will not return error right now.
> >
> > If we return error when no vq or no mq support, and check return value
> > of virtnet_set_queues() in virtnet_restore(), migration will fail. 
> > Is it expected?
> >
> >
> 
> I think what you mean is restore not migration here. The point is not to
> execute VIRTIO_NET_CTRL_MQ when multiqueue is not supported, so it's the
> caller responsibility to pass a valid queue_pairs to
> virtnet_set_queues(). This patch is not necessary, your last patch is
> fine enough to solve the issue. Do you agree?
 
Yes.

If mq is supported,
  - change queue to 0: virtnet_send_command() will return error
  - change queue to >= 1: success

If mq isn't support, current queue is 1.
  - change queue to 1: return 0 at mq checking point, nothing is
                       changed, expected.
  * change queue to 0:   we should return -INVAL
    (my first patch checked this in virtnet_set_channels())
  * change queue to > 1: we should return -INVAL
    (we already checked 'queue_pairs > vi->max_queue_pairs' in virtnet_set_channels())

The * items are lack in current virtnet_send_command(), but can
already checked it in virtnet_set_channels(), it's enough.

So we can just apply my first patch [1].

[1] http://www.spinics.net/lists/netdev/msg279631.html

> Thanks

Thanks.

BTW, -ENOTSUPP isn't an invalid ERROR for virtio-net.

/* Defined for the NFSv3 protocol */
#define ENOTSUPP        524     /* Operation is not supported */

-- 
			Amos.
