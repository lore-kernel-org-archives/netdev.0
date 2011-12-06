From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Tue, 06 Dec 2011 18:21:29 +0800
Message-ID: <4EDDECA9.8060808@redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
	<CAJSP0QXfHC8j2Kk9x6wyBMubo2=YvpaLAShJtwMWA2mtro6UhA@mail.gmail.com>
	<4EDDB71F.9080908@redhat.com>
	<CAJSP0QX5dDkpX+cRcQut2mb6K91zeqGLRrZBGAWT_r2p685gaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, bhutchings@solarflare.com
To: Stefan Hajnoczi <stefanha@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAJSP0QX5dDkpX+cRcQut2mb6K91zeqGLRrZBGAWT_r2p685gaQ@mail.gmail.com>
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

On 12/06/2011 05:18 PM, Stefan Hajnoczi wrote:
> On Tue, Dec 6, 2011 at 6:33 AM, Jason Wang<jasowang@redhat.com>  wrote:
>> On 12/05/2011 06:55 PM, Stefan Hajnoczi wrote:
>>> On Mon, Dec 5, 2011 at 8:59 AM, Jason Wang<jasowang@redhat.com>    wrote:
>>>> +static int virtnet_set_fd(struct net_device *dev, u32 pfn)
>>>> +{
>>>> +       struct virtnet_info *vi = netdev_priv(dev);
>>>> +       struct virtio_device *vdev = vi->vdev;
>>>> +
>>>> +       if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_FD)) {
>>>> +               vdev->config->set(vdev,
>>>> +                                 offsetof(struct virtio_net_config_fd,
>>>> addr),
>>>> +&pfn, sizeof(u32));
>>> Please use the virtio model (i.e. virtqueues) instead of shared
>>> memory.  Mapping a page breaks the virtio abstraction.
>>
>> Using control virtqueue is more suitable but there's are also some problems:
>>
>> One problem is the interface,  if we use control virtqueue, we need a
>> interface between the backend and tap/macvtap to change the flow mapping.
>> But qemu and vhost_net only know about the file descriptor, more
>> informations or interfaces need to be exposed in order to let ethtool or
>> ioctl work.
> QEMU could provide map a shared page with tap/macvtap.  The difference
> would be that the guest<->host interface is still virtio and QEMU
> pokes values into the shared page on behalf of the guest.

This makes sense.

>> Another problem is the delay introduced by ctrl vq, as the ctrl vq would be
>> used in the critical path in guest and it use busy wait to get the response,
>> the delay is not neglectable.
> Then you need to find a better way of doing this.  Can the host
> automatically associate the flow from the tx virtqueue packets are
> transmitted on?  Does it make sense to add a virtio_net_hdr field that
> updates the queue mapping?

It can but it can not properly handling the the packet re-ordering 
caused by the moving of guest applications among guest cpus. One more 
problem for virtio_net_hdr is we need to build a empty packet when there 
no other packet to send.

One solution is to introduce unblock cmd for ctrl vq.
> The vcpus are just threads and may not be bound to physical CPUs, so
> what is the big picture here?  Is the guest even in the position to
> set the best queue mappings today?

Not sure it could publish the best mapping but the idea is to make sure 
the packets of a flow were handled by the same guest vcpu and may be the 
same vhost thread in order to eliminate the packet reordering and lock 
contention. But this assumption does not take the bouncing of vhost or 
vcpu threads which would also affect the result.

Anyway, the mapping from guest was an important reference.
> Stefan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
