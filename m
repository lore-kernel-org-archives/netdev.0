From: Liu ping fan <kernelfans@gmail.com>
Subject: Re: vhost-net: is there a race for sock in handle_tx/rx?
Date: Thu, 3 May 2012 17:08:04 +0800
Message-ID: <CAFgQCTuUmwWF3vumXLZ=BZKLToypaYE_sL44-iFrXp5Qtwze2Q@mail.gmail.com>
References: <CAFgQCTtKWR6F3D_mPcGe69HvZbYmmAdXreSWLZQrdi+0T3i2ag@mail.gmail.com>
	<20120503084115.GM8266@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120503084115.GM8266@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Oh, got it. It is a very interesting implement.

Thanks and regards,
pingfan

On Thu, May 3, 2012 at 4:41 PM, Michael S. Tsirkin <mst@redhat.com> wro=
te:
> On Thu, May 03, 2012 at 04:33:55PM +0800, Liu ping fan wrote:
>> Hi,
>>
>> During reading the vhost-net code, I find the following,
>>
>> static void handle_tx(struct vhost_net *net)
>> {
>> =C2=A0 =C2=A0 =C2=A0 struct vhost_virtqueue *vq =3D &net->dev.vqs[VH=
OST_NET_VQ_TX];
>> =C2=A0 =C2=A0 =C2=A0 unsigned out, in, s;
>> =C2=A0 =C2=A0 =C2=A0 int head;
>> =C2=A0 =C2=A0 =C2=A0 struct msghdr msg =3D {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .msg_name =3D NULL,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .msg_namelen =3D 0,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .msg_control =3D NU=
LL,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .msg_controllen =3D=
 0,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .msg_iov =3D vq->io=
v,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .msg_flags =3D MSG_=
DONTWAIT,
>> =C2=A0 =C2=A0 =C2=A0 };
>> =C2=A0 =C2=A0 =C2=A0 size_t len, total_len =3D 0;
>> =C2=A0 =C2=A0 =C2=A0 int err, wmem;
>> =C2=A0 =C2=A0 =C2=A0 size_t hdr_size;
>> =C2=A0 =C2=A0 =C2=A0 struct socket *sock;
>> =C2=A0 =C2=A0 =C2=A0 struct vhost_ubuf_ref *uninitialized_var(ubufs)=
;
>> =C2=A0 =C2=A0 =C2=A0 bool zcopy;
>>
>> =C2=A0 =C2=A0 =C2=A0 /* TODO: check that we are running from vhost_w=
orker? */
>> =C2=A0 =C2=A0 =C2=A0 sock =3D rcu_dereference_check(vq->private_data=
, 1);
>> =C2=A0 =C2=A0 =C2=A0 if (!sock)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0---------------------------=
-----> Qemu calls
>> vhost_net_set_backend() to set a new backend fd, and close
>> @oldsock->file. And =C2=A0sock->file refcnt=3D=3D0.
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 Can vhost_worker prevent
>> itself from such situation? And how?
>>
>> =C2=A0 =C2=A0 =C2=A0 wmem =3D atomic_read(&sock->sk->sk_wmem_alloc);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0.........................................=
=2E...............................
>>
>> Is it a race?
>>
>> Thanks and regards,
>> pingfan
>
> See comment before void __rcu *private_data in vhost.h
>
>
