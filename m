From: Baolin Wang <baolin.wang@linaro.org>
Subject: Re: [PATCH 05/11] time/posix-timers:Convert to the 64bit methods for
 k_clock callback functions
Date: Tue, 21 Apr 2015 16:36:13 +0800
Message-ID: <CAMz4kuKF2sU4tMD7UtDobu2kVDMp7cfHNERSPQ9Yyzs80tOzYg@mail.gmail.com>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
 <1429509459-17068-6-git-send-email-baolin.wang@linaro.org>
 <alpine.DEB.2.11.1504202243070.13914@nanos>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5371854255723363967=="
Cc: Xunlei Pang <pang.xunlei@linaro.org>, peterz@infradead.org,
 heiko.carstens@de.ibm.com, paulus@samba.org, cl@linux.com,
 Heena Sirwani <heenasirwani@gmail.com>, linux-arch@vger.kernel.org,
 linux-s390@vger.kernel.org, y2038 Mailman List <y2038@lists.linaro.org>,
 rafael.j.wysocki@intel.com, Andrew Hunter <ahh@google.com>,
 =?UTF-8?B?RnLDqWTDqXJpYyBXZWlzYmVja2Vy?= <fweisbec@gmail.com>,
 Paul Turner <pjt@google.com>, riel@redhat.com, Arnd Bergmann <arnd@arndb.de>,
 Richard Cochran <richardcochran@gmail.com>, schwidefsky@de.ibm.com,
 John Stultz <john.stultz@linaro.org>, rth@twiddle.net,
 gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, tj@kernel.org, linux390@de.ibm.com,
 linuxppc-dev@lists.ozlabs.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <alpine.DEB.2.11.1504202243070.13914@nanos>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

--===============5371854255723363967==
Content-Type: multipart/alternative; boundary=089e0122f07478b051051437f06d

--089e0122f07478b051051437f06d
Content-Type: text/plain; charset=UTF-8

On 21 April 2015 at 04:48, Thomas Gleixner <tglx@linutronix.de> wrote:

> On Mon, 20 Apr 2015, Baolin Wang wrote:
> >  /* Set clock_realtime */
> >  static int posix_clock_realtime_set(const clockid_t which_clock,
> > -                                 const struct timespec *tp)
> > +                                 const struct timespec64 *tp)
> >  {
> > -     return do_sys_settimeofday(tp, NULL);
> > +     struct timespec ts = timespec64_to_timespec(*tp);
> > +
> > +     return do_sys_settimeofday(&ts, NULL);
>
> Sigh. No. We first provide a proper function for this, which takes a
> timespec64, i.e. do_sys_settimeofday64() instead of having this
> wrapper mess all over the place.
>

Thanks for your comments,but if use do_sys_settimeofday64() here that
will  introduce
a security bug: do_sys_settimeofday contains a capability
check that normally prevents non-root users from setting the time.

With your change, any user can set the system time.

>
> >       /* SIGEV_NONE timers are not queued ! See common_timer_get */
> >       if (((timr->it_sigev_notify & ~SIGEV_THREAD_ID) == SIGEV_NONE)) {
> > diff --git a/kernel/time/timekeeping.h b/kernel/time/timekeeping.h
> > index 1d91416..144af14 100644
> > --- a/kernel/time/timekeeping.h
> > +++ b/kernel/time/timekeeping.h
> > @@ -15,7 +15,7 @@ extern u64 timekeeping_max_deferment(void);
> >  extern int timekeeping_inject_offset(struct timespec *ts);
> >  extern s32 timekeeping_get_tai_offset(void);
> >  extern void timekeeping_set_tai_offset(s32 tai_offset);
> > -extern void timekeeping_clocktai(struct timespec *ts);
> > +extern void timekeeping_clocktai(struct timespec64 *ts);
>
> # git grep timekeeping_clocktai() is your friend.
>
> Thanks,
>
>         tglx
>



-- 
Baolin.wang
Best Regards

--089e0122f07478b051051437f06d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On 21 April 2015 at 04:48, Thomas Gleixner <span dir=3D"ltr">&lt;<a hre=
f=3D"mailto:tglx@linutronix.de" target=3D"_blank">tglx@linutronix.de</a>&gt=
;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin-top:0p=
x;margin-right:0px;margin-bottom:0px;margin-left:0.8ex;border-left-width:1p=
x;border-left-color:rgb(204,204,204);border-left-style:solid;padding-left:1=
ex"><span class=3D"">On Mon, 20 Apr 2015, Baolin Wang wrote:<br>
&gt;=C2=A0 /* Set clock_realtime */<br>
&gt;=C2=A0 static int posix_clock_realtime_set(const clockid_t which_clock,=
<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct timespec *tp)=
<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const struct timespec64 *t=
p)<br>
&gt;=C2=A0 {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0return do_sys_settimeofday(tp, NULL);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0struct timespec ts =3D timespec64_to_timespec(*tp=
);<br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0return do_sys_settimeofday(&amp;ts, NULL);<br>
<br>
</span>Sigh. No. We first provide a proper function for this, which takes a=
<br>
timespec64, i.e. do_sys_settimeofday64() instead of having this<br>
wrapper mess all over the place.<br></blockquote><div><br></div><span style=
=3D"font-size:13px">Thanks for your comments,but if use=C2=A0</span>do_sys_=
settimeofday64() here that will=C2=A0<span style=3D"font-size:13px">=C2=A0i=
ntroduce a security bug: do_sys_settimeofday contains a capability</span></=
div><div class=3D"gmail_quote"><span style=3D"font-size:13px">check that no=
rmally prevents non-root users from setting the time.</span><br style=3D"fo=
nt-size:13px"><br style=3D"font-size:13px"><div><span style=3D"font-size:13=
px">With your change, any user can set the system time.</span>=C2=A0</div><=
blockquote class=3D"gmail_quote" style=3D"margin-top:0px;margin-right:0px;m=
argin-bottom:0px;margin-left:0.8ex;border-left-width:1px;border-left-color:=
rgb(204,204,204);border-left-style:solid;padding-left:1ex">
<span class=3D""><br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0/* SIGEV_NONE timers are not queued ! See co=
mmon_timer_get */<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (((timr-&gt;it_sigev_notify &amp; ~SIGEV_=
THREAD_ID) =3D=3D SIGEV_NONE)) {<br>
&gt; diff --git a/kernel/time/timekeeping.h b/kernel/time/timekeeping.h<br>
&gt; index 1d91416..144af14 100644<br>
&gt; --- a/kernel/time/timekeeping.h<br>
&gt; +++ b/kernel/time/timekeeping.h<br>
&gt; @@ -15,7 +15,7 @@ extern u64 timekeeping_max_deferment(void);<br>
&gt;=C2=A0 extern int timekeeping_inject_offset(struct timespec *ts);<br>
&gt;=C2=A0 extern s32 timekeeping_get_tai_offset(void);<br>
&gt;=C2=A0 extern void timekeeping_set_tai_offset(s32 tai_offset);<br>
&gt; -extern void timekeeping_clocktai(struct timespec *ts);<br>
&gt; +extern void timekeeping_clocktai(struct timespec64 *ts);<br>
<br>
</span># git grep timekeeping_clocktai() is your friend.<br>
<br>
Thanks,<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 tglx<br>
</blockquote></div><br><br clear=3D"all"><div><br></div>-- <br><div class=
=3D"gmail_signature"><div dir=3D"ltr"><div>Baolin.wang<br></div>Best Regard=
s<br></div></div>
</div></div>

--089e0122f07478b051051437f06d--

--===============5371854255723363967==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============5371854255723363967==--
