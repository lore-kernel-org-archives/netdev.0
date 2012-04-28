From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] 9p: disconnect channel when PCI device is removed
Date: Sat, 28 Apr 2012 23:46:26 +0530
Message-ID: <87d36rafid.fsf@skywalker.in.ibm.com>
References: <1334353716-19483-1-git-send-email-levinsasha928@gmail.com> <87iph118pd.fsf@skywalker.in.ibm.com> <CA+1xoqfgA6DJL7ztMOdfLZedV6YwzZPUfbovFykdSSZy0Aio6w@mail.gmail.com> <87ehrodjt6.fsf@skywalker.in.ibm.com> <CA+1xoqfQ0Cj5pibxN8ZTXbksezH4NqOERaiYav=D7BA+v86m3A@mail.gmail.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ericvh@gmail.com, jvrao@linux.vnet.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+1xoqfQ0Cj5pibxN8ZTXbksezH4NqOERaiYav=D7BA+v86m3A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sasha Levin <levinsasha928@gmail.com> writes:

> On Mon, Apr 16, 2012 at 12:59 PM, Aneesh Kumar K.V
> <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> Sasha Levin <levinsasha928@gmail.com> writes:
>>
>>> On Sun, Apr 15, 2012 at 2:27 PM, Aneesh Kumar K.V
>>> <aneesh.kumar@linux.vnet.ibm.com> wrote:
>>>> Sasha Levin <levinsasha928@gmail.com> writes:
>>>>
>>>>> When a virtio_9p pci device is being removed, we should close dow=
n any
>>>>> active channels and free up resources, we're not supposed to BUG(=
) if there's
>>>>> still an open channel since it's a valid case when removing the P=
CI device.
>>>>>
>>>>> Otherwise, removing the PCI device with an open channel would cau=
se the
>>>>> following BUG():
>>>>>
>>>> ...
>>>>
>>>>> diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
>>>>> index 3d43206..5af18d1 100644
>>>>> --- a/net/9p/trans_virtio.c
>>>>> +++ b/net/9p/trans_virtio.c
>>>>> @@ -615,7 +615,8 @@ static void p9_virtio_remove(struct virtio_de=
vice *vdev)
>>>>> =C2=A0{
>>>>> =C2=A0 =C2=A0 =C2=A0 struct virtio_chan *chan =3D vdev->priv;
>>>>>
>>>>> - =C2=A0 =C2=A0 BUG_ON(chan->inuse);
>>>>> + =C2=A0 =C2=A0 if (chan->inuse)
>>>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 p9_virtio_close(chan-=
>client);
>>>>> =C2=A0 =C2=A0 =C2=A0 vdev->config->del_vqs(vdev);
>>>>>
>>>>> =C2=A0 =C2=A0 =C2=A0 mutex_lock(&virtio_9p_lock);
>>>>
>>>> But an umount should have resulted in p9_virtio_close ? How are yo=
u
>>>> removing the device ? Are you removing the device with file system
>>>> mounted =C2=A0?. In that case may be we should return EBUSY ?
>>>
>>> I signal the underlying PCI device to remove (echo 1 >
>>> /sys/devices/pci0000\:00/[...]/remove), we can't really prevent tha=
t
>>> thing so we must clean up ourselves.
>>
>> What does that mean for the mounted file system ? What would happen =
to
>> the pending fs operations in that case ?
>
> I'm guessing that all of them should be canceled.

Pending operation we can cancel, but what about dirty pages in cached
mode ? Also how does virtio-blk handle this ?=20

> virtio-pci simulates
> a PCI device, if the PCI device is unplugged there's not much to do
> about the filesystem or pending requests.

Ideal thing to do would be to make remove return -EBUSY; let the user
umount. But looking at the code, I guess there is no easy way to return
error from remove callback ?

-aneesh
