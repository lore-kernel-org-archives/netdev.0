From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Patch for man unix(7)
Date: Mon, 16 Apr 2012 10:40:09 +1200
Message-ID: <CAKgNAki82=5=SkYkfXuF08YMMZ4dpYvORmWQ5OSkQx6Uhahqdw@mail.gmail.com>
References: <AANLkTimtTazMmDvQFgASsVGa=AYvPZqUaUmyg5p7VVY1@mail.gmail.com>
 <201010171428.DDC17187.FFFJSLtOOHOMQV@I-love.SAKURA.ne.jp>
 <201010262115.FEH09326.OMFJHSVOFLQFOt@I-love.SAKURA.ne.jp>
 <201011232159.DFE78143.tSHMFQOLFVFJOO@I-love.SAKURA.ne.jp> <CAKgNAkgNRbdcWwo0nhsbCxtnagEucxm6d76ugGAAUAd+ukBLCQ@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgNAkgNRbdcWwo0nhsbCxtnagEucxm6d76ugGAAUAd+ukBLCQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 16, 2012 at 9:42 AM, Michael Kerrisk (man-pages)
<mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hello Tetsuao Handa
>
> [Thanks for the text program that you sent more recently]
>
> On Wed, Nov 24, 2010 at 1:59 AM, Tetsuo Handa
> <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org> wrote:
>> =A0From f388eedbdc0b099bb9f36ab007f9370432abb300 Mon Sep 17 00:00:00=
 2001
>> =A0From: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
>> Date: Tue, 23 Nov 2010 21:34:25 +0900
>> Subject: [PATCH] unix.7: Fix description of "pathname" sockets
>>
>> Since unix_mkname() in net/unix/af_unix.c does
>>
>> =A0((char *)sunaddr)[len] =3D 0;
>>
>> rather than
>>
>> =A0((char *)sunaddr)[len - 1] =3D 0;
>>
>> , sunaddr->sun_path may not be terminated with a null byte if
>> len =3D=3D sizeof(*sunaddr).
>>
>> Therefore, the caller of getsockname(), getpeername(), accept() must=
 not assume
>> that sunaddr->sun_path contains a null-terminated pathname even if t=
he returned
>> addrlen is greater than sizeof(sa_family_t) and sun_path[0] !=3D '\0=
'.
>
> Thanks. I see what you mean. However, I'm wondering, is the kernel
> behavior simply a bug that should be fixed, so that a null terminator
> is always placed in sun_path?
>
> I realize that's an ABI change, but:
> a) I suspect most sane applications would never create a sun_path tha=
t
> didn't contain a null terminator within sizeof(sun_path) bytes.
> b) Considering these two sets:
> =A0 1. [applications that would break if the assumption that there
> =A0 =A0 =A0 =A0 is no null terminator inside sizeof(sun_path) bytes d=
oesn't

Sorry! Small thinko in previous line:

"is no null terminator" =3D=3D> "is a null terminator"

Thanks,

Michael

> =A0 =A0 =A0 =A0 hold true]
> =A0 2. [applications that would break if the kernel behavior changed]
> =A0 I suspect that set 1 is much larger than set 2.
>
> Your thoughts?
>
> Thanks,
>
> Michael
>
>> Signed-off-by: Tetsuo Handa <penguin-kernel-JPay3/Yim36HaxMnTkn67Xf5DAMn2ifp@public.gmane.org>
>> ---
>> =A0man7/unix.7 | =A0 19 ++++++++++++++++---
>> =A01 files changed, 16 insertions(+), 3 deletions(-)
>>
>> diff --git a/man7/unix.7 b/man7/unix.7
>> index b53328b..7b0b47c 100644
>> --- a/man7/unix.7
>> +++ b/man7/unix.7
>> @@ -80,10 +80,23 @@ When the address of the socket is returned by
>> =A0and
>> =A0.BR accept (2),
>> =A0its length is
>> -.IR "offsetof(struct sockaddr_un, sun_path) + strlen(sun_path) + 1"=
 ,
>> +.IR "offsetof(struct sockaddr_un, sun_path) + strlen(sun_path) + 1"=
=2E
>> +Note that this length can be one byte larger than
>> +.IR "sizeof(struct sockaddr_un)"
>> +because
>> +.BR bind (2)
>> +accepts
>> +.IR sun_path
>> +which is not terminated with a null byte ('\\0').
>> +Therefore, you must not use string manipulation functions (e.g. str=
len(),
>> +printf("%s")) against
>> +.IR sun_path
>> +because
>> +.BR getsockname (2),
>> +.BR getpeername (2),
>> =A0and
>> -.I sun_path
>> -contains the null-terminated pathname.
>> +.BR accept (2)
>> +may not have stored a null-terminated string.
>> =A0.IP *
>> =A0.IR unnamed :
>> =A0A stream socket that has not been bound to a pathname using
>> --
>> 1.6.1
>
>
>
> --
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Author of "The Linux Programming Interface"; http://man7.org/tlpi/



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
