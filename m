From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] 9p: disconnect channel when PCI device is removed
Date: Sun, 29 Apr 2012 05:21:27 +0200
Message-ID: <CA+1xoqekMH0yeGTu=2bsfJ8gcyARtX9MU3Z6A_q51q_dXxNbNw@mail.gmail.com>
References: <1334353716-19483-1-git-send-email-levinsasha928@gmail.com>
 <87iph118pd.fsf@skywalker.in.ibm.com> <CA+1xoqfgA6DJL7ztMOdfLZedV6YwzZPUfbovFykdSSZy0Aio6w@mail.gmail.com>
 <87ehrodjt6.fsf@skywalker.in.ibm.com> <CA+1xoqfQ0Cj5pibxN8ZTXbksezH4NqOERaiYav=D7BA+v86m3A@mail.gmail.com>
 <87d36rafid.fsf@skywalker.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ericvh@gmail.com, jvrao@linux.vnet.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d36rafid.fsf@skywalker.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 28, 2012 at 8:16 PM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> Sasha Levin <levinsasha928@gmail.com> writes:
>
>> On Mon, Apr 16, 2012 at 12:59 PM, Aneesh Kumar K.V
>> <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>> Sasha Levin <levinsasha928@gmail.com> writes:
>>>
>>>> On Sun, Apr 15, 2012 at 2:27 PM, Aneesh Kumar K.V
>>>> <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>>>> Sasha Levin <levinsasha928@gmail.com> writes:
>>>>>
>>>>>> When a virtio_9p pci device is being removed, we should close do=
wn any
>>>>>> active channels and free up resources, we're not supposed to BUG=
() if there's
>>>>>> still an open channel since it's a valid case when removing the =
PCI device.
>>>>>>
>>>>>> Otherwise, removing the PCI device with an open channel would ca=
use the
>>>>>> following BUG():
>>>>>>
>>>>> ...
>>>>>
>>>>>> diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
>>>>>> index 3d43206..5af18d1 100644
>>>>>> --- a/net/9p/trans_virtio.c
>>>>>> +++ b/net/9p/trans_virtio.c
>>>>>> @@ -615,7 +615,8 @@ static void p9_virtio_remove(struct virtio_d=
evice *vdev)
>>>>>> =A0{
>>>>>> =A0 =A0 =A0 struct virtio_chan *chan =3D vdev->priv;
>>>>>>
>>>>>> - =A0 =A0 BUG_ON(chan->inuse);
>>>>>> + =A0 =A0 if (chan->inuse)
>>>>>> + =A0 =A0 =A0 =A0 =A0 =A0 p9_virtio_close(chan->client);
>>>>>> =A0 =A0 =A0 vdev->config->del_vqs(vdev);
>>>>>>
>>>>>> =A0 =A0 =A0 mutex_lock(&virtio_9p_lock);
>>>>>
>>>>> But an umount should have resulted in p9_virtio_close ? How are y=
ou
>>>>> removing the device ? Are you removing the device with file syste=
m
>>>>> mounted =A0?. In that case may be we should return EBUSY ?
>>>>
>>>> I signal the underlying PCI device to remove (echo 1 >
>>>> /sys/devices/pci0000\:00/[...]/remove), we can't really prevent th=
at
>>>> thing so we must clean up ourselves.
>>>
>>> What does that mean for the mounted file system ? What would happen=
 to
>>> the pending fs operations in that case ?
>>
>> I'm guessing that all of them should be canceled.
>
> Pending operation we can cancel, but what about dirty pages in cached
> mode ? Also how does virtio-blk handle this ?

virtio-blk does pretty much the same thing:

sh-4.2# echo 1 > 0000\:00\:05.0/remove
sh-4.2# ls -al
[hang]

>> virtio-pci simulates
>> a PCI device, if the PCI device is unplugged there's not much to do
>> about the filesystem or pending requests.
>
> Ideal thing to do would be to make remove return -EBUSY; let the user
> umount. But looking at the code, I guess there is no easy way to retu=
rn
> error from remove callback ?

There's no way to return error, the removal callback is just a notifier=
=2E
