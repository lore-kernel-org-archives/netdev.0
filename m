From: Joel Cunningham <joel.cunningham@me.com>
Subject: Re: Understanding mutual exclusion between rtnl_lock and rcu_read_lock
Date: Fri, 03 Feb 2017 10:26:39 -0600
Message-ID: <DBF55E98-9737-47EA-8FB1-1FBA48D7CA1B@me.com>
References: <FEDE3C6F-2C5C-4BCE-829F-C8E177C2AA36@me.com>
 <CAKgT0Ufy1gii_tQ=puNnPfFeHiE=jti5ObFP3Js0U03ULPFyiQ@mail.gmail.com>
 <1486099283.21871.73.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pv38p43im-ztdg05071201.me.com ([17.133.183.8]:46284 "EHLO
        pv38p43im-ztdg05071201.me.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750937AbdBCQ0j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 11:26:39 -0500
Received: from process-dkim-sign-daemon.pv38p43im-ztdg05071201.me.com by
 pv38p43im-ztdg05071201.me.com
 (Oracle Communications Messaging Server 7.0.5.38.0 64bit (built Feb 26 2016))
 id <0OKT00900451ID00@pv38p43im-ztdg05071201.me.com> for
 netdev@vger.kernel.org; Fri, 03 Feb 2017 16:26:38 +0000 (GMT)
In-reply-to: <1486099283.21871.73.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 2, 2017, at 11:21 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>=20
> On Thu, 2017-02-02 at 15:52 -0800, Alexander Duyck wrote:
>> On Thu, Feb 2, 2017 at 3:47 PM, Joel Cunningham =
<joel.cunningham@me.com> wrote:
>>> Hi,
>>>=20
>>> I=E2=80=99m studying the synchronization used on different parts of =
struct net_device and I=E2=80=99m struggling to understand how structure =
member modifications in dev_ioctl are synchronized.  Getters in =
dev_ifsioc_locked() are only holding rcu_read_lock() while setters in =
dev_ifsioc() are holding rtnl_lock, but not using RCU APIs.  I was =
specifically looking at SIOCGIFHWADDR/SIOCSIFHWADDR.  What=E2=80=99s to =
prevent one CPU from executing a getter and another CPU from executing a =
setter resulting in possibly a torn read/write?  I didn=E2=80=99t see =
anything in rtnl_lock() that would wait for any rcu_reader_lock() =
critical sections (on other CPUs) to finish before acquiring the mutex.
>>>=20
>>> Is there something about dev_ioctl that prevents parallel execution? =
or maybe something I still don=E2=80=99t understand about the RCU =
implementation?
>>>=20
>>> Thanks,
>>>=20
>>> Joel
>>=20
>> My advice would be to spend more time familiarizing yourself with =
RCU.
>> The advantage of RCU is that it allows for updates while other =
threads
>> are accessing the data.  The rtnl_lock is just meant to prevent
>> multiple writers from updating the data simultaneously.  So between
>> writers the rtnl_lock is used to keep things synchronized, but =
between
>> writers and readers the mechanism that is meant to protect the data
>> and keep it sane is RCU.
>=20
> Note that sometimes we do not properly handle the case one field can =
be
> written by a writer holding RTNL (or socket lock or something else)
>=20
> We often believe compiler wont do something stupid, but it can
> sometimes.
>=20
> We definitely should scrutinize things a bit more, or maybe add __rcu
> like annotations to catch potential problems earlier.

This is my hunch from looking at dev_ioctl().  For some of the other =
fields, there is additional support to detect a write during the read, =
but not any of the ioctls handled in dev_ifsioc_locked().  For example, =
SIOCGIFNAME, dev_ifname() calls netdev_get_name() to copy dev->name, =
which uses devnet_rename_seq seqcount to detect if another thread called =
dev_change_name() and updated the name.

I found more examples of accessing net_device fields in net-sysfs.c and =
these instances are all acquire dev_base_lock/rtnl_lock before reading =
fields.  Maybe dev_ioctl should be implemented this way

>=20
> We recently found an issue in drivers/net/macvtap.c and
> drivers/net/tun.c using q->vnet_hdr_sz without proper annotation.
>=20
> macvtap patch would be :
>=20
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index =
4026185658381df004a7d641e2be7bcb9a45b509..d11a807565acf371f9bbb4afbfaca1aa=
cd000138 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -681,7 +681,7 @@ static ssize_t macvtap_get_user(struct =
macvtap_queue *q, struct msghdr *m,
> 	size_t linear;
>=20
> 	if (q->flags & IFF_VNET_HDR) {
> -		vnet_hdr_len =3D q->vnet_hdr_sz;
> +		vnet_hdr_len =3D READ_ONCE(q->vnet_hdr_sz);
>=20
> 		err =3D -EINVAL;
> 		if (len < vnet_hdr_len)
> @@ -820,7 +820,7 @@ static ssize_t macvtap_put_user(struct =
macvtap_queue *q,
>=20
> 	if (q->flags & IFF_VNET_HDR) {
> 		struct virtio_net_hdr vnet_hdr;
> -		vnet_hdr_len =3D q->vnet_hdr_sz;
> +		vnet_hdr_len =3D READ_ONCE(q->vnet_hdr_sz);
> 		if (iov_iter_count(iter) < vnet_hdr_len)
> 			return -EINVAL;
>=20
> @@ -1090,7 +1090,7 @@ static long macvtap_ioctl(struct file *file, =
unsigned int cmd,
> 		if (s < (int)sizeof(struct virtio_net_hdr))
> 			return -EINVAL;
>=20
> -		q->vnet_hdr_sz =3D s;
> +		WRITE_ONCE(q->vnet_hdr_sz, s);
> 		return 0;
>=20
> 	case TUNGETVNETLE:

Joel
