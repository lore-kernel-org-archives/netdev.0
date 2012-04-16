From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] 9p: disconnect channel when PCI device is removed
Date: Mon, 16 Apr 2012 16:29:01 +0530
Message-ID: <87ehrodjt6.fsf@skywalker.in.ibm.com>
References: <1334353716-19483-1-git-send-email-levinsasha928@gmail.com> <87iph118pd.fsf@skywalker.in.ibm.com> <CA+1xoqfgA6DJL7ztMOdfLZedV6YwzZPUfbovFykdSSZy0Aio6w@mail.gmail.com>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ericvh@gmail.com, jvrao@linux.vnet.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:51705 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753078Ab2DPK7L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 06:59:11 -0400
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 16 Apr 2012 16:29:05 +0530
In-Reply-To: <CA+1xoqfgA6DJL7ztMOdfLZedV6YwzZPUfbovFykdSSZy0Aio6w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sasha Levin <levinsasha928@gmail.com> writes:

> On Sun, Apr 15, 2012 at 2:27 PM, Aneesh Kumar K.V
> <aneesh.kumar@linux.vnet.ibm.com> wrote:
>> Sasha Levin <levinsasha928@gmail.com> writes:
>>
>>> When a virtio_9p pci device is being removed, we should close down =
any
>>> active channels and free up resources, we're not supposed to BUG() =
if there's
>>> still an open channel since it's a valid case when removing the PCI=
 device.
>>>
>>> Otherwise, removing the PCI device with an open channel would cause=
 the
>>> following BUG():
>>>
>> ...
>>
>>> diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
>>> index 3d43206..5af18d1 100644
>>> --- a/net/9p/trans_virtio.c
>>> +++ b/net/9p/trans_virtio.c
>>> @@ -615,7 +615,8 @@ static void p9_virtio_remove(struct virtio_devi=
ce *vdev)
>>> =C2=A0{
>>> =C2=A0 =C2=A0 =C2=A0 struct virtio_chan *chan =3D vdev->priv;
>>>
>>> - =C2=A0 =C2=A0 BUG_ON(chan->inuse);
>>> + =C2=A0 =C2=A0 if (chan->inuse)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 p9_virtio_close(chan->c=
lient);
>>> =C2=A0 =C2=A0 =C2=A0 vdev->config->del_vqs(vdev);
>>>
>>> =C2=A0 =C2=A0 =C2=A0 mutex_lock(&virtio_9p_lock);
>>
>> But an umount should have resulted in p9_virtio_close ? How are you
>> removing the device ? Are you removing the device with file system
>> mounted =C2=A0?. In that case may be we should return EBUSY ?
>
> I signal the underlying PCI device to remove (echo 1 >
> /sys/devices/pci0000\:00/[...]/remove), we can't really prevent that
> thing so we must clean up ourselves.

What does that mean for the mounted file system ? What would happen to
the pending fs operations in that case ?

-aneesh
