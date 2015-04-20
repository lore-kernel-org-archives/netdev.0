From: Baolin Wang <baolin.wang@linaro.org>
Subject: Re: [PATCH 11/11] k_clock:Remove the 32bit methods with timespec type
Date: Mon, 20 Apr 2015 17:00:15 +0800
Message-ID: <CAMz4kuK48DS_7EuS0U_Hq7zb7ddKFqE46R=PMace5O8WFSvsWw@mail.gmail.com>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
 <1429509459-17068-12-git-send-email-baolin.wang@linaro.org>
 <20150420084229.GA4608@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============7057139860070527656=="
Cc: pang.xunlei@linaro.org, peterz@infradead.org, heiko.carstens@de.ibm.com,
 paulus@samba.org, cl@linux.com, heenasirwani@gmail.com,
 linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
 y2038 Mailman List <y2038@lists.linaro.org>, rafael.j.wysocki@intel.com,
 ahh@google.com, fweisbec@gmail.com, pjt@google.com, riel@redhat.com,
 Arnd Bergmann <arnd@arndb.de>, schwidefsky@de.ibm.com,
 John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>,
 rth@twiddle.net, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, tj@kernel.org, linux390@de.ibm.com,
 linuxppc-dev@lists.ozlabs.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20150420084229.GA4608@localhost.localdomain>
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

--===============7057139860070527656==
Content-Type: multipart/alternative; boundary=047d7bfd05fc93d64405142428f5

--047d7bfd05fc93d64405142428f5
Content-Type: text/plain; charset=UTF-8

On 20 April 2015 at 16:42, Richard Cochran <richardcochran@gmail.com> wrote:

> On Mon, Apr 20, 2015 at 01:57:39PM +0800, Baolin Wang wrote:
>
> > @@ -911,18 +907,14 @@ retry:
> >               return -EINVAL;
> >
> >       kc = clockid_to_kclock(timr->it_clock);
> > -     if (WARN_ON_ONCE(!kc || (!kc->timer_set && !kc->timer_set64))) {
> > +     if (WARN_ON_ONCE(!kc || !kc->timer_set64)) {
> >               error = -EINVAL;
> >       } else {
> > -             if (kc->timer_set64) {
> > -                     new_spec64 = itimerspec_to_itimerspec64(new_spec);
> > -                     error = kc->timer_set64(timr, flags, &new_spec64,
> > -                                             &old_spec64);
> > -                     if (old_setting)
> > -                             old_spec =
> itimerspec64_to_itimerspec(old_spec64);
> > -             } else {
> > -                     error = kc->timer_set(timr, flags, &new_spec, rtn);
> > -             }
> > +             new_spec64 = itimerspec_to_itimerspec64(new_spec);
> > +             error = kc->timer_set64(timr, flags, &new_spec64,
> > +                                     &old_spec64);
>
> This statement can fit on one line.
>
> > +             if (old_setting)
> > +                     old_spec = itimerspec64_to_itimerspec(old_spec64);
> >       }
> >
> >       unlock_timer(timr, flag);
>
> > @@ -1057,14 +1045,13 @@ SYSCALL_DEFINE2(clock_gettime, const clockid_t,
> which_clock,
> >       if (!kc)
> >               return -EINVAL;
> >
> > -     if (kc->clock_get64) {
> > -             error = kc->clock_get64(which_clock, &kernel_tp64);
> > -             kernel_tp = timespec64_to_timespec(kernel_tp64);
> > -     } else {
> > -             error = kc->clock_get(which_clock, &kernel_tp);
> > -     }
> > +     error = kc->clock_get64(which_clock, &kernel_tp64);
> > +     if (!error)
> > +             return error;
>
> Wrong test, should be: if (error) ...
>
> > +
> > +     kernel_tp = timespec64_to_timespec(kernel_tp64);
> >
> > -     if (!error && copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))
>
> The (!error && ...) was correct here!
>
> > +     if (copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))
> >               error = -EFAULT;
> >
> >       return error;
>
> You can simplify this like so:
>
>         return copy_to_user(tp, &kernel_tp, sizeof(kernel_tp)) ? -EFAULT :
> 0;
>
> > @@ -1104,14 +1091,13 @@ SYSCALL_DEFINE2(clock_getres, const clockid_t,
> which_clock,
> >       if (!kc)
> >               return -EINVAL;
> >
> > -     if (kc->clock_getres64) {
> > -             error = kc->clock_getres64(which_clock, &rtn_tp64);
> > -             rtn_tp = timespec64_to_timespec(rtn_tp64);
> > -     } else {
> > -             error = kc->clock_getres(which_clock, &rtn_tp);
> > -     }
> > +     error = kc->clock_getres64(which_clock, &rtn_tp64);
> > +     if (!error)
> > +             return error;
>
> Also wrong.
>
> > +
> > +     rtn_tp = timespec64_to_timespec(rtn_tp64);
> >
> > -     if (!error && tp && copy_to_user(tp, &rtn_tp, sizeof (rtn_tp)))
> > +     if (tp && copy_to_user(tp, &rtn_tp, sizeof (rtn_tp)))
> >               error = -EFAULT;
> >
> >       return error;
> > --
> > 1.7.9.5
> >
>
> Thanks,
> Richard
>

Thanks for your comments, i'll fix these mistakes in next patch series.



-- 
Baolin.wang
Best Regards

--047d7bfd05fc93d64405142428f5
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br></div><div class=3D"gmail_q=
uote">On 20 April 2015 at 16:42, Richard Cochran <span dir=3D"ltr">&lt;<a h=
ref=3D"mailto:richardcochran@gmail.com" target=3D"_blank">richardcochran@gm=
ail.com</a>&gt;</span> wrote:<br><blockquote style=3D"margin:0px 0px 0px 0.=
8ex;padding-left:1ex;border-left-color:rgb(204,204,204);border-left-width:1=
px;border-left-style:solid" class=3D"gmail_quote"><span>On Mon, Apr 20, 201=
5 at 01:57:39PM +0800, Baolin Wang wrote:<br>
<br>
&gt; @@ -911,18 +907,14 @@ retry:<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;<=
br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0kc =3D clockid_to_kclock(timr-&gt;it_clock);=
<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (WARN_ON_ONCE(!kc || (!kc-&gt;timer_set &amp;&=
amp; !kc-&gt;timer_set64))) {<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (WARN_ON_ONCE(!kc || !kc-&gt;timer_set64)) {<b=
r>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D -EINVA=
L;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0} else {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (kc-&gt;timer_set6=
4) {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0new_spec64 =3D itimerspec_to_itimerspec64(new_spec);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0error =3D kc-&gt;timer_set64(timr, flags, &amp;new_spec64,<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0&amp;old_spec64);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0if (old_setting)<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0old_spec =3D itimerspec64_to_itimerspec(=
old_spec64);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0error =3D kc-&gt;timer_set(timr, flags, &amp;new_spec, rtn);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0new_spec64 =3D itimer=
spec_to_itimerspec64(new_spec);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D kc-&gt;time=
r_set64(timr, flags, &amp;new_spec64,<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&amp;old_spe=
c64);<br>
<br>
</span>This statement can fit on one line.<br>
<span><br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (old_setting)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0old_spec =3D itimerspec64_to_itimerspec(old_spec64);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_timer(timr, flag);<br>
<br>
</span><span>&gt; @@ -1057,14 +1045,13 @@ SYSCALL_DEFINE2(clock_gettime, co=
nst clockid_t, which_clock,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!kc)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;<=
br>
&gt;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (kc-&gt;clock_get64) {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D kc-&gt;cloc=
k_get64(which_clock, &amp;kernel_tp64);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kernel_tp =3D timespe=
c64_to_timespec(kernel_tp64);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0} else {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D kc-&gt;cloc=
k_get(which_clock, &amp;kernel_tp);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0error =3D kc-&gt;clock_get64(which_clock, &amp;ke=
rnel_tp64);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!error)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return error;<br>
<br>
</span>Wrong test, should be: if (error) ...<br>
<span><br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0kernel_tp =3D timespec64_to_timespec(kernel_tp64)=
;<br>
&gt;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (!error &amp;&amp; copy_to_user(tp, &amp;kerne=
l_tp, sizeof (kernel_tp)))<br>
<br>
</span>The (!error &amp;&amp; ...) was correct here!<br>
<span><br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (copy_to_user(tp, &amp;kernel_tp, sizeof (kern=
el_tp)))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D -EFAUL=
T;<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0return error;<br>
<br>
</span>You can simplify this like so:<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 return copy_to_user(tp, &amp;kernel_tp, sizeof(=
kernel_tp)) ? -EFAULT : 0;<br>
<span><br>
&gt; @@ -1104,14 +1091,13 @@ SYSCALL_DEFINE2(clock_getres, const clockid_t,=
 which_clock,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (!kc)<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;<=
br>
&gt;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (kc-&gt;clock_getres64) {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D kc-&gt;cloc=
k_getres64(which_clock, &amp;rtn_tp64);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rtn_tp =3D timespec64=
_to_timespec(rtn_tp64);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0} else {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D kc-&gt;cloc=
k_getres(which_clock, &amp;rtn_tp);<br>
&gt; -=C2=A0 =C2=A0 =C2=A0}<br>
&gt; +=C2=A0 =C2=A0 =C2=A0error =3D kc-&gt;clock_getres64(which_clock, &amp=
;rtn_tp64);<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (!error)<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return error;<br>
<br>
</span>Also wrong.<br>
<span><br>
&gt; +<br>
&gt; +=C2=A0 =C2=A0 =C2=A0rtn_tp =3D timespec64_to_timespec(rtn_tp64);<br>
&gt;<br>
&gt; -=C2=A0 =C2=A0 =C2=A0if (!error &amp;&amp; tp &amp;&amp; copy_to_user(=
tp, &amp;rtn_tp, sizeof (rtn_tp)))<br>
&gt; +=C2=A0 =C2=A0 =C2=A0if (tp &amp;&amp; copy_to_user(tp, &amp;rtn_tp, s=
izeof (rtn_tp)))<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D -EFAUL=
T;<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0return error;<br>
&gt; --<br>
&gt; 1.7.9.5<br>
&gt;<br>
<br>
</span>Thanks,<br>
Richard<br>
</blockquote></div><p>=C2=A0</p><div>Thanks for your comments, i&#39;ll fix=
 these mistakes in next patch series.</div><div class=3D"gmail_extra"><br><=
br clear=3D"all"><br>-- <br></div><div class=3D"gmail_signature"><div dir=
=3D"ltr"><div>Baolin.wang<br></div>Best Regards<br></div></div><div class=
=3D"gmail_extra">
</div></div>

--047d7bfd05fc93d64405142428f5--

--===============7057139860070527656==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: inline

X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

--===============7057139860070527656==--
