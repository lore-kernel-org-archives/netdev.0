From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH] Staging: dst: fix 'Client is not allowed' on sparc
Date: Wed, 16 Dec 2009 22:05:52 +0300
Message-ID: <a4423d670912161105s124adcdci3ad09c1cb7900ba1@mail.gmail.com>
References: <1260716147-1569-1-git-send-email-a.beregalov@gmail.com>
	 <20091216182433.GA28134@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sparclinux@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761349AbZLPTGL@vger.kernel.org>
In-Reply-To: <20091216182433.GA28134@ioremap.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/12/16 Evgeniy Polyakov <zbr@ioremap.net>:
> Hi Alexander.
>
> Sorry for late response.
> Your patch looks good, I will forward it to GregKH for inclusion.

But how does inet_getname() set sa_data_len to 0.
I can't imagine.
My patch is a workaround, not a fix.

Btw, it does not work on sparc anyway, it needs further digging.

> Thank you.
>
> On Sun, Dec 13, 2009 at 05:55:47PM +0300, Alexander Beregalov (a.bere=
galov@gmail.com) wrote:
>>
>> Not for applying, only describe the problem.
>>
>>
>> There is a warning on sparc
>> =C2=A0Kernel unaligned access at TPC[6c0dec] inet_getname+0x4c/0xc0
>> which goes from
>> =C2=A0 =C2=A0 =C2=A0 net/ipv4/af_inet.c:
>> =C2=A0 =C2=A0 =C2=A0 int inet_getname(
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ...
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *uaddr_len =3D size=
of(*sin);
>>
>> sizeof(*sin) is 16, but inet_getname sets sa_data_len to 0.
>> That is why client is denied to access the device.
>> inet_getname() does not read uaddr_len, only
>> writes, so move initialization of sa_data_len after it.
>> Make struct saddr aligned similar to
>> struct __kernel_sockaddr_storage. This fixes the warning.
>>
>> ---
>> =C2=A0drivers/staging/dst/export.c | =C2=A0 =C2=A02 +-
>> =C2=A0include/linux/dst.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0=
 =C2=A04 ++--
>> =C2=A02 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/staging/dst/export.c b/drivers/staging/dst/expo=
rt.c
>> index c324230..4644804 100644
>> --- a/drivers/staging/dst/export.c
>> +++ b/drivers/staging/dst/export.c
>> @@ -166,12 +166,12 @@ static struct dst_state *dst_accept_client(str=
uct dst_state *st)
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 new->socket =3D sock;
>>
>> - =C2=A0 =C2=A0 new->ctl.addr.sa_data_len =3D sizeof(struct sockaddr=
);
>> =C2=A0 =C2=A0 =C2=A0 err =3D kernel_getpeername(sock, (struct sockad=
dr *)&new->ctl.addr,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 (int *)&new->ctl.addr.sa_data_len);
>> =C2=A0 =C2=A0 =C2=A0 if (err)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto err_out_put;
>>
>> + =C2=A0 =C2=A0 new->ctl.addr.sa_data_len =3D sizeof(struct sockaddr=
);
>> =C2=A0 =C2=A0 =C2=A0 new->permissions =3D dst_check_permissions(st, =
new);
>> =C2=A0 =C2=A0 =C2=A0 if (new->permissions =3D=3D 0) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 err =3D -EPERM;
>> diff --git a/include/linux/dst.h b/include/linux/dst.h
>> index e26fed8..454b15a 100644
>> --- a/include/linux/dst.h
>> +++ b/include/linux/dst.h
>> @@ -74,10 +74,10 @@ struct saddr {
>> =C2=A0 =C2=A0 =C2=A0 /* address family, AF_xxx =C2=A0 =C2=A0 =C2=A0 =
*/
>> =C2=A0 =C2=A0 =C2=A0 unsigned short =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
sa_family;
>> =C2=A0 =C2=A0 =C2=A0 /* 14 bytes of protocol address */
>> - =C2=A0 =C2=A0 char =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0sa_data[SADDR_MAX_DATA];
>> + =C2=A0 =C2=A0 char =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0sa_data[SADDR_MAX_DATA - sizeof(unsigned short)];
>> =C2=A0 =C2=A0 =C2=A0 /* Number of bytes used in sa_data */
>> =C2=A0 =C2=A0 =C2=A0 unsigned short =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
sa_data_len;
>> -};
>> +} __attribute__((aligned(16))); =C2=A0 =C2=A0 =C2=A0/* sizeof(struc=
t sockaddr) */
>>
>> =C2=A0/* Address structure */
>> =C2=A0struct dst_network_ctl
>> --
>> 1.6.5.6
>
> --
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Evgeniy Polyakov
>
