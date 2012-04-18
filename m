From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [patch] Fix handling of overlength pathname in AF_UNIX sun_path
Date: Thu, 19 Apr 2012 10:50:40 +1200
Message-ID: <CAKgNAkh46EMDWpessyi0n-EyNoRid-iW1O1RfUpTtzKDv0mZFw@mail.gmail.com>
References: <4F8D497F.8060601@gmail.com> <20120417.223614.629911246108750471.davem@davemloft.net>
 <CADZpyix6DZ93f8MQf3Aa1NVV7HCFMAXVAdzRMFBY7xWHHQMPog@mail.gmail.com> <20120418.001650.1042781402985153056.davem@davemloft.net>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org, w@1wt.eu,
	alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120418.001650.1042781402985153056.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 18, 2012 at 4:16 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wro=
te:
> From: "Carlos O'Donell" <carlos-v2tUB8YBRSi3e3T8WW9gsA@public.gmane.org>
> Date: Wed, 18 Apr 2012 00:08:47 -0400
>
>> I don't clearly understand your position here, and perhaps that's my
>> own ignorance, but could you please clarify, with examples, exactly
>> why the change is not acceptable?
>
> My position is that since millions upon millions of Linux systems, in
> fact every single Linux system, exists right now with the current
> behavior we are not helping application writers at all by changing
> behavior now after it's been this way for nearly 20 years.
>
> Because if an application writer wants his code to work on systems
> that actually exist he has to accomodate the non-NULL termination
> situation if he wants to inspect or print out an AF_UNIX path.
>
> Because every system in existence right now allows the non-NULL
> terminated AF_UNIX paths, therefore it's possible on every system
> in existence right now.
>
> Catch my drift?
>
> The very thing the patch claims to help, it doesn't. =C2=A0We install=
 this
> kernel patch now and then tell application writers that they can just
> assume all AF_UNIX paths are NULL terminated when they want to print
> it out, because such code will not actually be guarenteed to work on
> all deployed Linux machines out there.

Hang on a moment. I did not suggest that we can just tell users they
can forget about the past. Obviously, users will need to program to
past kernel behavior here for a good long time yet. (As Alan says
elsewhere in the thread "they'll be defensively coding for
the existing API for another ten years for enterprise distros
anyway".) However, this is about longer-term improvement of the
quality of implementation; in X years (choose your X) time, a lot of
new application may not need to care about the old broken behavior.
See some related examples below.

And you skipped past my other two points. Even if my understanding
about POSIX mandates is correct, I can understand how we might ignore
that point. But the last one is still germane:

[[
3. Considering these two sets:

  (a) [applications that rely on the assumption that there
       is a null terminator inside sizeof(sun_path) bytes]
  (b) [applications that would break if the kernel behavior changed]

  I suspect that set (a) is rather larger than set (b)--or, more
  likely still, applications ensure they go for the lowest common
  denominator limit of 92 (HP-UX) or 104 (historical BSD limit)
  bytes, and so avoid this issue completely.
]]

There may well be potential breakages out there in set (a), and
improving the QOI would help them. (To put things in terms of Alan's
response: I suspect that there may well be existing applications that
are *not* defensively handling the existing API).

Taking the logic you've posed (my reading: "we shouldn't fix old
brokenness because applications will still need to code to the
brokenness") to the extreme, we'd *never* fix old pieces of
brokenness. However, we certainly have precedents for doing exactly
that:

After nearly 15 years of brokenness (stretching back to the first
kernels), commit 69be8f189653cd81aae5a74e26615b12871bb72e fixed this
(sigaction(2)):

   BUGS
       In kernels up to and including 2.6.13, specifying SA_NODEFER in
       sa_flags  prevents  not  only  the  delivered signal from being
       masked during execution of the handler, but  also  the  signals
       specified in sa_mask.  This bug was fixed in kernel 2.6.14.

Similarly, after brokenness that had run through the entire preceding
2.4.x kernel series, Linux 2.6.4 fixed this:

    BUGS
       In kernel 2.4 (and earlier) there is some  strangeness  in  the
       handling  of  X_OK  tests  for superuser.  If all categories of
       execute permission are disabled for a nondirectory  file,  then
       the  only  access() test that returns -1 is when mode is speci=E2=
=80=90
       fied as just X_OK; if R_OK or W_OK is also specified  in  mode,
       then  access() returns 0 for such files.  Early 2.6 kernels (up
       to and including 2.6.3) also behaved in the same way as  kernel
       2.4.

(A little background here:
http://thread.gmane.org/gmane.linux.kernel/158814, and the fix
eventually went in with
http://thread.gmane.org/gmane.linux.kernel/178719)

> You cannot just ignore 20 years of precedence and say "oh let's chang=
e
> this in the kernel now, and that way application writers don't have t=
o
> worry about that lack of NULL termination any more." =C2=A0It simply
> doesn't work like that.

As should be clear from the above, I agree. But still, I don't think
the logic "it's broken, and even if we fix it, users will still have
to code to the old brokenness" is a sufficient argument against
improving the QOI long-term.

> All of this talk about whether applications actually create non-NULL
> terminated AF_UNIX paths don't even factor into the conversation.
>
> So the value proposition for this patch simply does not exist.

Of course, it's your call in the end, but I don't think things are as
cut-and-dried as your response suggests.

Cheers,

Michael

--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
