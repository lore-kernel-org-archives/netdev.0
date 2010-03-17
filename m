From: Laurent Chavey <chavey@google.com>
Subject: Re: [PATCH] vhost: fix error handling in vring ioctls
Date: Wed, 17 Mar 2010 11:40:23 -0700
Message-ID: <97949e3e1003171140j530ead98k40edd8eb647a0399@mail.gmail.com>
References: <20100317144249.GA3984@redhat.com> <97949e3e1003171054q3bee27d5yce0d92ae33e5b5ca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Slaby <jirislaby@gmail.com>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <97949e3e1003171054q3bee27d5yce0d92ae33e5b5ca@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Laurent Chavey <chavey@google.com>

On Wed, Mar 17, 2010 at 10:54 AM, Laurent Chavey <chavey@google.com> wr=
ote:
> Acked-by: chavey@google.com
>
>
> On Wed, Mar 17, 2010 at 7:42 AM, Michael S. Tsirkin <mst@redhat.com> =
wrote:
>> Stanse found a locking problem in vhost_set_vring:
>> several returns from VHOST_SET_VRING_KICK, VHOST_SET_VRING_CALL,
>> VHOST_SET_VRING_ERR with the vq->mutex held.
>> Fix these up.
>>
>> Reported-by: Jiri Slaby <jirislaby@gmail.com>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>> =A0drivers/vhost/vhost.c | =A0 18 ++++++++++++------
>> =A01 files changed, 12 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 7cd55e0..7bd7a1e 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -476,8 +476,10 @@ static long vhost_set_vring(struct vhost_dev *d=
, int ioctl, void __user *argp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (r < 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0eventfp =3D f.fd =3D=3D -1 ? NULL : e=
ventfd_fget(f.fd);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(eventfp))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(eventfp=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(eventfp)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 r =3D PTR_ERR(eventfp)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (eventfp !=3D vq->kick) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pollstop =3D filep =3D=
 vq->kick;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pollstart =3D vq->kic=
k =3D eventfp;
>> @@ -489,8 +491,10 @@ static long vhost_set_vring(struct vhost_dev *d=
, int ioctl, void __user *argp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (r < 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0eventfp =3D f.fd =3D=3D -1 ? NULL : e=
ventfd_fget(f.fd);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(eventfp))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(eventfp=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(eventfp)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 r =3D PTR_ERR(eventfp)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (eventfp !=3D vq->call) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0filep =3D vq->call;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ctx =3D vq->call_ctx;
>> @@ -505,8 +509,10 @@ static long vhost_set_vring(struct vhost_dev *d=
, int ioctl, void __user *argp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (r < 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0eventfp =3D f.fd =3D=3D -1 ? NULL : e=
ventfd_fget(f.fd);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(eventfp))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PTR_ERR(eventfp=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(eventfp)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 r =3D PTR_ERR(eventfp)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (eventfp !=3D vq->error) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0filep =3D vq->error;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vq->error =3D eventfp=
;
>> --
>> 1.7.0.18.g0d53a5
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>
