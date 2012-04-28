From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] 9p: disconnect channel when PCI device is removed
Date: Sat, 28 Apr 2012 10:55:26 +0200
Message-ID: <CA+1xoqfQ0Cj5pibxN8ZTXbksezH4NqOERaiYav=D7BA+v86m3A@mail.gmail.com>
References: <1334353716-19483-1-git-send-email-levinsasha928@gmail.com>
 <87iph118pd.fsf@skywalker.in.ibm.com> <CA+1xoqfgA6DJL7ztMOdfLZedV6YwzZPUfbovFykdSSZy0Aio6w@mail.gmail.com>
 <87ehrodjt6.fsf@skywalker.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ericvh@gmail.com, jvrao@linux.vnet.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42387 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab2D1Izs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 04:55:48 -0400
In-Reply-To: <87ehrodjt6.fsf@skywalker.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 16, 2012 at 12:59 PM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> Sasha Levin <levinsasha928@gmail.com> writes:
>
>> On Sun, Apr 15, 2012 at 2:27 PM, Aneesh Kumar K.V
>> <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>> Sasha Levin <levinsasha928@gmail.com> writes:
>>>
>>>> When a virtio_9p pci device is being removed, we should close down=
 any
>>>> active channels and free up resources, we're not supposed to BUG()=
 if there's
>>>> still an open channel since it's a valid case when removing the PC=
I device.
>>>>
>>>> Otherwise, removing the PCI device with an open channel would caus=
e the
>>>> following BUG():
>>>>
>>> ...
>>>
>>>> diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
>>>> index 3d43206..5af18d1 100644
>>>> --- a/net/9p/trans_virtio.c
>>>> +++ b/net/9p/trans_virtio.c
>>>> @@ -615,7 +615,8 @@ static void p9_virtio_remove(struct virtio_dev=
ice *vdev)
>>>> =A0{
>>>> =A0 =A0 =A0 struct virtio_chan *chan =3D vdev->priv;
>>>>
>>>> - =A0 =A0 BUG_ON(chan->inuse);
>>>> + =A0 =A0 if (chan->inuse)
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 p9_virtio_close(chan->client);
>>>> =A0 =A0 =A0 vdev->config->del_vqs(vdev);
>>>>
>>>> =A0 =A0 =A0 mutex_lock(&virtio_9p_lock);
>>>
>>> But an umount should have resulted in p9_virtio_close ? How are you
>>> removing the device ? Are you removing the device with file system
>>> mounted =A0?. In that case may be we should return EBUSY ?
>>
>> I signal the underlying PCI device to remove (echo 1 >
>> /sys/devices/pci0000\:00/[...]/remove), we can't really prevent that
>> thing so we must clean up ourselves.
>
> What does that mean for the mounted file system ? What would happen t=
o
> the pending fs operations in that case ?

I'm guessing that all of them should be canceled. virtio-pci simulates
a PCI device, if the PCI device is unplugged there's not much to do
about the filesystem or pending requests.
