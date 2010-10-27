From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [Security] TIPC security issues
Date: Wed, 27 Oct 2010 14:27:13 -0400
Message-ID: <AANLkTi=jDDDk15KDhsC=qTnmgU5Urhc9LTrROkFOsY_Q@mail.gmail.com>
References: <AANLkTi=V93A660+YS8C2TvC13kGUcJpFgjPHUvONd_WW@mail.gmail.com>
	<20101027.102940.112580564.davem@davemloft.net>
	<AANLkTinHVXDJbgJ0zBVRnr8R4sx=NtZCaFgbFC+8DE+q@mail.gmail.com>
	<20101027.105047.183059900.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, drosenberg@vsecurity.com,
	jon.maloy@ericsson.com, allan.stephens@windriver.com,
	netdev@vger.kernel.org, security@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:53233 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754850Ab0J0S1O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:27:14 -0400
Received: by qwf7 with SMTP id 7so253868qwf.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 11:27:14 -0700 (PDT)
In-Reply-To: <20101027.105047.183059900.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 1:50 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Wed, 27 Oct 2010 10:37:46 -0700
>
>> If you _really_ care deeply, then some packet-oriented protocol can
>> just have its own private packet size limit (which would be way less
>> than 2GB), and then just look at the total size and say "oh, the tot=
al
>> size is bigger than my limit, so I'll just error out". Then, the fac=
t
>> that verify_iovec() may have truncated the message to 2GB-1 doesn't
>> matter at all.
>>
>> (Practically speaking, I bet all packet-oriented protocols already
>> have a limit that is enforced by simply allocation patterns, so I
>> don't think it's actually a problem even now)
>
> This is, as it turns out, effectively what the TIPC socket layer
> already does.
>
> Most of the send calls that propagate down to this code adding up the
> iov_len lengths gets passed a maximum packet size.
>
> Anyways, here is what I came up with to kill this specific bug in
> TIPC:
>
> From 39dc17049a5ed989bab8997945a048ffddf48387 Mon Sep 17 00:00:00 200=
1
> From: David S. Miller <davem@davemloft.net>
> Date: Wed, 27 Oct 2010 10:46:59 -0700
> Subject: [PATCH] tipc: Fix iov_len handling in message send path.
>
> Use size_t to add together iov_len's from the iovec, error
> out with -EMSGSIZE if total is greater than INT_MAX.
>
> Reported-by: Dan Rosenberg <drosenberg@vsecurity.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> =A0net/tipc/msg.c | =A0 13 ++++++++++---
> =A01 files changed, 10 insertions(+), 3 deletions(-)
>
> diff --git a/net/tipc/msg.c b/net/tipc/msg.c
> index ecb532f..b29eb8b 100644
> --- a/net/tipc/msg.c
> +++ b/net/tipc/msg.c
> @@ -76,11 +76,15 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, =
u32 type,
>
> =A0int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_=
sect)
> =A0{
> - =A0 =A0 =A0 int dsz =3D 0;
> + =A0 =A0 =A0 size_t dsz =3D 0;
> =A0 =A0 =A0 =A0int i;
>
> =A0 =A0 =A0 =A0for (i =3D 0; i < num_sect; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dsz +=3D msg_sect[i].iov_len;
> +
> + =A0 =A0 =A0 if (dsz > INT_MAX)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EMSGSIZE;
> +

I've got some patches from Al that I'm pre-reviewing/testing
before spamming everyone with them (will send within 24h, if
that is OK).   Anyway, in the above, does it make sense to
check for the overflow incrementally, i.e. something like this?

-       for (i =3D 0; i < num_sect; i++)
-               dsz +=3D msg_sect[i].iov_len;
+       for (i =3D 0; i < num_sect; i++) {
+               len =3D msg_sect[i].iov_len;
+               if (len > LONG_MAX - dsz)
+                       return LONG_MAX;
+               dsz +=3D len;
+       }

(where len and dsz are both size_t).

Thanks,
Paul.

> =A0 =A0 =A0 =A0return dsz;
> =A0}
>
> @@ -93,12 +97,15 @@ int tipc_msg_calc_data_size(struct iovec const *m=
sg_sect, u32 num_sect)
> =A0*/
>
> =A0int tipc_msg_build(struct tipc_msg *hdr,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct iovec co=
nst *msg_sect, u32 num_sect,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int max_size, i=
nt usrmem, struct sk_buff** buf)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct iovec const *msg_sec=
t, u32 num_sect,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int max_size, int usrmem, s=
truct sk_buff** buf)
> =A0{
> =A0 =A0 =A0 =A0int dsz, sz, hsz, pos, res, cnt;
>
> =A0 =A0 =A0 =A0dsz =3D tipc_msg_calc_data_size(msg_sect, num_sect);
> + =A0 =A0 =A0 if (dsz < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dsz;
> +
> =A0 =A0 =A0 =A0if (unlikely(dsz > TIPC_MAX_USER_MSG_SIZE)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*buf =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> --
> 1.7.3.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
