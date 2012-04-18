From: "Carlos O'Donell" <carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Wed, 18 Apr 2012 00:08:47 -0400
Message-ID: <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com>
References: <4F8D497F.8060601@gmail.com>
	<20120417.223614.629911246108750471.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, w@1wt.eu,
	alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120417.223614.629911246108750471.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 10:36 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wr=
ote:
> From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 17 Apr 2012 22:44:15 +1200
>
>> 1. Changing the kernel behavior prevents userspace having
>> =A0 =A0to go through the sort of contortions described above
>> =A0 =A0in order to handle the 108-non-NUL-bytes-in-sun_path case.
>
> The problem with this logic is that it ignores every single Linux
> system that exists right now.
>
> You need to code this logic into your application unless you don't
> want it to run properly on every Linux system that actually exists.
>
> Sorry, we're not making this change.

Dave,

I don't clearly understand your position here, and perhaps that's my
own ignorance, but could you please clarify, with examples, exactly
why the change is not acceptable? I can see several valid arguments
against the change, but I don't know which argument your position
asserts.

One might assert that careless userspace applications exist that pass
`sizeof(struct sockaddr_un)' (or worse) as the 3rd argument to bind
instead of SUN_LEN(my_sock). The logic in the patch doesn't account
for this, and can't really, and would therefore unacceptably break
existing applications by trying to assert the location of a \0 where
one doesn't exist. The kernel must therefore continue to
null-terminate at the specified length, possibly the 109th character,
and use strlen to capture the true length of the path. The kernel
knows that in the worst case a non-null terminated path might contain
some garbage, but that's the users fault, and the logic to prevent
this must exist in the application not the kernel.

The counter argument to all of this is that it's a QoI issue, and that
the kernel shouldn't accept accidentally non-null terminated paths,
and should instead return EINVAL for them. Not to mention that it's
difficult for userspace to easily catch this error in glibc which
would need to inspect the sockaddr, duplicating kernel code.

Why is it valid for the user path to have no null terminator?

Why not have:

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index d510353..f9f77a7 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -216,6 +216,9 @@ static int unix_mkname(struct sockaddr_un
*sunaddr, int len, unsigned *hashp)
                 */
                ((char *)sunaddr)[len] =3D 0;
                len =3D strlen(sunaddr->sun_path)+1+sizeof(short);
+               /* No null terminator was found in the path. */
+               if (len > sizeof(*sunaddr))
+                       return -EINVAL;
                return len;
        }

---

Does that make sense?

Cheers,
Carlos.
