From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [net-next RFC PATCH 5/5] virtio-net: flow director support
Date: Tue, 6 Dec 2011 09:18:48 +0000
Message-ID: <CAJSP0QX5dDkpX+cRcQut2mb6K91zeqGLRrZBGAWT_r2p685gaQ@mail.gmail.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
	<20111205085925.6116.94352.stgit@dhcp-8-146.nay.redhat.com>
	<CAJSP0QXfHC8j2Kk9x6wyBMubo2=YvpaLAShJtwMWA2mtro6UhA@mail.gmail.com>
	<4EDDB71F.9080908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com,
	bhutchings@solarflare.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4EDDB71F.9080908@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 6, 2011 at 6:33 AM, Jason Wang <jasowang@redhat.com> wrote:
> On 12/05/2011 06:55 PM, Stefan Hajnoczi wrote:
>>
>> On Mon, Dec 5, 2011 at 8:59 AM, Jason Wang<jasowang@redhat.com> =A0w=
rote:
>>>
>>> +static int virtnet_set_fd(struct net_device *dev, u32 pfn)
>>> +{
>>> + =A0 =A0 =A0 struct virtnet_info *vi =3D netdev_priv(dev);
>>> + =A0 =A0 =A0 struct virtio_device *vdev =3D vi->vdev;
>>> +
>>> + =A0 =A0 =A0 if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_FD)) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 vdev->config->set(vdev,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 o=
ffsetof(struct virtio_net_config_fd,
>>> addr),
>>> +&pfn, sizeof(u32));
>>
>> Please use the virtio model (i.e. virtqueues) instead of shared
>> memory. =A0Mapping a page breaks the virtio abstraction.
>
>
> Using control virtqueue is more suitable but there's are also some pr=
oblems:
>
> One problem is the interface, =A0if we use control virtqueue, we need=
 a
> interface between the backend and tap/macvtap to change the flow mapp=
ing.
> But qemu and vhost_net only know about the file descriptor, more
> informations or interfaces need to be exposed in order to let ethtool=
 or
> ioctl work.

QEMU could provide map a shared page with tap/macvtap.  The difference
would be that the guest<->host interface is still virtio and QEMU
pokes values into the shared page on behalf of the guest.

> Another problem is the delay introduced by ctrl vq, as the ctrl vq wo=
uld be
> used in the critical path in guest and it use busy wait to get the re=
sponse,
> the delay is not neglectable.

Then you need to find a better way of doing this.  Can the host
automatically associate the flow from the tx virtqueue packets are
transmitted on?  Does it make sense to add a virtio_net_hdr field that
updates the queue mapping?

The vcpus are just threads and may not be bound to physical CPUs, so
what is the big picture here?  Is the guest even in the position to
set the best queue mappings today?

Stefan
