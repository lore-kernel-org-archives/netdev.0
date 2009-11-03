From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv7 3/3] vhost_net: a kernel-level virtio server
Date: Tue, 03 Nov 2009 19:51:35 +0100
Message-ID: <4AF07BB7.1020802@gmail.com>
References: <cover.1257267892.git.mst@redhat.com> <20091103172422.GD5591@redhat.com> <4AF0708B.4020406@gmail.com> <4AF07199.2020601@gmail.com> <4AF072EE.9020202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
        virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
        linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org,
        akpm@linux-foundation.org, hpa@zytor.com,
        Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4AF072EE.9020202@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Gregory Haskins a =E9crit :
> Gregory Haskins wrote:
>> Eric Dumazet wrote:
>>> Michael S. Tsirkin a =E9crit :
>>>> +static void handle_tx(struct vhost_net *net)
>>>> +{
>>>> +	struct vhost_virtqueue *vq =3D &net->dev.vqs[VHOST_NET_VQ_TX];
>>>> +	unsigned head, out, in, s;
>>>> +	struct msghdr msg =3D {
>>>> +		.msg_name =3D NULL,
>>>> +		.msg_namelen =3D 0,
>>>> +		.msg_control =3D NULL,
>>>> +		.msg_controllen =3D 0,
>>>> +		.msg_iov =3D vq->iov,
>>>> +		.msg_flags =3D MSG_DONTWAIT,
>>>> +	};
>>>> +	size_t len, total_len =3D 0;
>>>> +	int err, wmem;
>>>> +	size_t hdr_size;
>>>> +	struct socket *sock =3D rcu_dereference(vq->private_data);
>>>> +	if (!sock)
>>>> +		return;
>>>> +
>>>> +	wmem =3D atomic_read(&sock->sk->sk_wmem_alloc);
>>>> +	if (wmem >=3D sock->sk->sk_sndbuf)
>>>> +		return;
>>>> +
>>>> +	use_mm(net->dev.mm);
>>>> +	mutex_lock(&vq->mutex);
>>>> +	vhost_no_notify(vq);
>>>> +
>>> using rcu_dereference() and mutex_lock() at the same time seems wrong=
, I suspect
>>> that your use of RCU is not correct.
>>>
>>> 1) rcu_dereference() should be done inside a read_rcu_lock() section,=
 and
>>>    we are not allowed to sleep in such a section.
>>>    (Quoting Documentation/RCU/whatisRCU.txt :
>>>      It is illegal to block while in an RCU read-side critical sectio=
n, )
>>>
>>> 2) mutex_lock() can sleep (ie block)
>>>
>>
>> Michael,
>>   I warned you that this needed better documentation ;)
>>
>> Eric,
>>   I think I flagged this once before, but Michael convinced me that it
>> was indeed "ok", if but perhaps a bit unconventional.  I will try to
>> find the thread.
>>
>> Kind Regards,
>> -Greg
>>
>=20
> Here it is:
>=20
> http://lkml.org/lkml/2009/8/12/173
>=20

Yes, this doesnt convince me at all, and could be a precedent for a wrong=
 RCU use.
People wanting to use RCU do a grep on kernel sources to find how to corr=
ectly
use RCU.

Michael, please use existing locking/barrier mechanisms, and not pretend =
to use RCU.

Some automatic tools might barf later.

For example, we could add a debugging facility to check that rcu_derefere=
nce() is used
in an appropriate context, ie conflict with existing mutex_lock() debuggi=
ng facility.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
