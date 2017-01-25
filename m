From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small buffer
 XDP receive
Date: Wed, 25 Jan 2017 07:52:23 -0800
Message-ID: <5888C9B7.8040603@gmail.com>
References: <CAADnVQ+O1tNuktnPgkL7JHZFBaQbWfxq0rjxPn86rsbRcteRyg@mail.gmail.com>
 <20170125164844-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>,
        David Miller <davem@davemloft.net>,
        John Fastabend <john.r.fastabend@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35672 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdAYPwh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 10:52:37 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so20027202pge.2
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 07:52:37 -0800 (PST)
In-Reply-To: <20170125164844-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-25 06:52 AM, Michael S. Tsirkin wrote:
> On Tue, Jan 24, 2017 at 11:33:56PM -0800, Alexei Starovoitov wrote:
>> On Tue, Jan 24, 2017 at 8:02 PM, John Fastabend
>> <john.fastabend@gmail.com> wrote:
>>>
>>> Finally just to point out here are the drivers with XDP support on latest
>>> net tree,
>>>
>>>         mlx/mlx5
>>>         mlx/mlx4
>>>         qlogic/qede
>>>         netronome/nfp
>>>         virtio_net
>>>
>>> And here is the list of adjust header support,
>>>
>>>         mlx/mlx4
>>>
>>
>> in net-next it's actually:
>> yes: mlx4, mlx5
>> no: qede, nfp, virtio
>> while nfp and virtio are working on it.
>>
>> xdp_adjust_head() is must have for load balancer,
> 
> What amount of head space does it need? 70 bytes
> to do vxlan kind of thing?
> 
>> so the sooner it lands for virtio the easier it will be
>> to develop xdp programs. Initially I expected
>> e1k+xdp to be the base line for debugging and
>> development of xdp programs, but since not everyone
>> agreed on e1k the virtio+xdp filled in the gap.
>> So without adjust_head in virtio I see very little use for it
>> in our environment.
>> It is a must have feature regardless of timing.
>> I will backport whatever is necessary, but distros
>> will stick with official releases and imo it's not great
>> from xdp adoption point of view to have
>> virtio driver lacking key features.
> 
> If everyone can agree it's net-next material then I'm happy.
> 

Considering that the only support for adjust_head in net branch
is in mlx4 and most drivers are aborting when programs get loaded
with adjust_head support I am OK with applying the patch below to
net and this series to net-next.

https://patchwork.ozlabs.org/patch/707118/

 diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
 index 08327e005ccc..db761f37783e 100644
 --- a/drivers/net/virtio_net.c
 +++ b/drivers/net/virtio_net.c
 @@ -1677,6 +1677,11 @@  static int virtnet_xdp_set(struct net_device *dev,
struct bpf_prog *prog)
  	u16 xdp_qp = 0, curr_qp;
  	int i, err;

 +	if (prog && prog->xdp_adjust_head) {
 +		netdev_warn(dev, "Does not support bpf_xdp_adjust_head()\n");
 +		return -EOPNOTSUPP;
 +	}
 +
  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO4) ||
  	    virtio_has_feature(vi->vdev, VIRTIO_NET_F_GUEST_TSO6)) {
  		netdev_warn(dev, "can't set XDP while host is implementing LRO, disable LRO
first\n");


Thanks,
John
