From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Looping in EAGAIN
Date: Thu, 26 Mar 2015 19:55:28 -0700
Message-ID: <CAA93jw5mKR5hdZjSw+j3TJ1r2ARiYK5DAqW_jmk+9hp2nZehOA@mail.gmail.com>
References: <CAA93jw7Ch2B4nw-5obw7VfTUYU1kjJ9=6BkqFf4B96uWqZvPOw@mail.gmail.com>
 <87egu9f5u5.wl-jch@pps.univ-paris-diderot.fr>
 <877g01f3pl.wl-jch@pps.univ-paris-diderot.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1256271650995626590=="
Cc: dnsmasq-discuss <Dnsmasq-discuss@lists.thekelleys.org.uk>,
 Simon Kelley <simon@thekelleys.org.uk>,
 "babel-users@lists.alioth.debian.org" <babel-users@lists.alioth.debian.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Juliusz Chroboczek <jch@pps.univ-paris-diderot.fr>
Return-path: <babel-users-bounces+gnbu-babel-users=m.gmane.org@lists.alioth.debian.org>
In-Reply-To: <877g01f3pl.wl-jch@pps.univ-paris-diderot.fr>
List-Unsubscribe: <http://lists.alioth.debian.org/cgi-bin/mailman/options/babel-users>,
 <mailto:babel-users-request@lists.alioth.debian.org?subject=unsubscribe>
List-Archive: <http://lists.alioth.debian.org/pipermail/babel-users/>
List-Post: <mailto:babel-users@lists.alioth.debian.org>
List-Help: <mailto:babel-users-request@lists.alioth.debian.org?subject=help>
List-Subscribe: <http://lists.alioth.debian.org/cgi-bin/mailman/listinfo/babel-users>,
 <mailto:babel-users-request@lists.alioth.debian.org?subject=subscribe>
Errors-To: babel-users-bounces+gnbu-babel-users=m.gmane.org@lists.alioth.debian.org
Sender: "Babel-users"
 <babel-users-bounces+gnbu-babel-users=m.gmane.org@lists.alioth.debian.org>
List-Id: netdev.vger.kernel.org

--===============1256271650995626590==
Content-Type: multipart/alternative; boundary=001a113ba080cbb12b05123c4380

--001a113ba080cbb12b05123c4380
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I see this patch for EAGAIN on an interface going away did not make the
babel-ss-merge branch apparently.  (for those new to this bug, see:
http://lists.alioth.debian.org/pipermail/babel-users/2014-October/001777.ht=
ml
for more details. )

No, I haven't had time to test this patch, nor have I come up with a better
idea.

I am curious if there could be some other *more robust* means of detecting
when an interface has gone away, and/or how dnsmasq was coping with this
situation nowadays.

(I'd mentioned this problem on the endless homenet thread

http://www.ietf.org/mail-archive/web/homenet/current/msg05156.html

and, thought I'd check to see if it was mainlined!)

I certainly hate any possibility anywhere in routing code where a
possibility for infinite loop existed. are there any checkers for such
loops in the world?

On Wed, Oct 15, 2014 at 2:00 PM, Juliusz Chroboczek <
jch@pps.univ-paris-diderot.fr> wrote:
> Dave,
>
> I'm not going to have time to test this for a while.  In the meantime,
> here's a proposed patch, please let me know if you find the time to test
> it.
>have
> -- Juliusz
>
> diff --git a/net.c b/net.c
> index 6f9728f..9b0b738 100644
> --- a/net.c
> +++ b/net.c
> @@ -141,7 +141,7 @@ babel_send(int s,
>  {
>      struct iovec iovec[2];
>      struct msghdr msg;
> -    int rc;
> +    int rc, count =3D 0;
>
>      iovec[0].iov_base =3D (void*)buf1;
>      iovec[0].iov_len =3D buflen1;
> @@ -156,13 +156,18 @@ babel_send(int s,
>   again:
>      rc =3D sendmsg(s, &msg, 0);
>      if(rc < 0) {
> -        if(errno =3D=3D EINTR)
> -            goto again;
> -        else if(errno =3D=3D EAGAIN) {
> +        if(errno =3D=3D EINTR) {
> +            count++;
> +            if(count < 1000)
> +                goto again;
> +        } else if(errno =3D=3D EAGAIN) {
>              int rc2;
>              rc2 =3D wait_for_fd(1, s, 5);
> -            if(rc2 > 0)
> -                goto again;
> +            if(rc2 > 0) {
> +                count++;
> +                if(count < 1000)
> +                    goto again;
> +            }
>              errno =3D EAGAIN;
>          }
>      }



--=20
Dave T=C3=A4ht
Let's make wifi fast, less jittery and reliable again!

https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb

--001a113ba080cbb12b05123c4380
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I see this patch for EAGAIN on an interface going away did=
 not make the babel-ss-merge branch apparently. =C2=A0(for those new to thi=
s bug, see: <a href=3D"http://lists.alioth.debian.org/pipermail/babel-users=
/2014-October/001777.html">http://lists.alioth.debian.org/pipermail/babel-u=
sers/2014-October/001777.html</a> for more details. )<br><br>No, I haven&#3=
9;t had time to test this patch, nor have I come up with a better idea.<br>=
<br>I am curious if there could be some other *more robust* means of detect=
ing when an interface has gone away, and/or how dnsmasq was coping with thi=
s situation nowadays.<br><br>(I&#39;d mentioned this problem on the endless=
 homenet thread<br><br><a href=3D"http://www.ietf.org/mail-archive/web/home=
net/current/msg05156.html">http://www.ietf.org/mail-archive/web/homenet/cur=
rent/msg05156.html</a><br><br>and, thought I&#39;d check to see if it was m=
ainlined!)<br><br>I certainly hate any possibility anywhere in routing code=
 where a possibility for infinite loop existed. are there any checkers for =
such loops in the world?<br><br>On Wed, Oct 15, 2014 at 2:00 PM, Juliusz Ch=
roboczek &lt;<a href=3D"mailto:jch@pps.univ-paris-diderot.fr">jch@pps.univ-=
paris-diderot.fr</a>&gt; wrote:<br>&gt; Dave,<br>&gt;<br>&gt; I&#39;m not g=
oing to have time to test this for a while.=C2=A0 In the meantime,<br>&gt; =
here&#39;s a proposed patch, please let me know if you find the time to tes=
t<br>&gt; it.<br>&gt;have<br>&gt; -- Juliusz<br>&gt;<br>&gt; diff --git a/n=
et.c b/net.c<br>&gt; index 6f9728f..9b0b738 100644<br>&gt; --- a/net.c<br>&=
gt; +++ b/net.c<br>&gt; @@ -141,7 +141,7 @@ babel_send(int s,<br>&gt; =C2=
=A0{<br>&gt; =C2=A0 =C2=A0 =C2=A0struct iovec iovec[2];<br>&gt; =C2=A0 =C2=
=A0 =C2=A0struct msghdr msg;<br>&gt; - =C2=A0 =C2=A0int rc;<br>&gt; + =C2=
=A0 =C2=A0int rc, count =3D 0;<br>&gt;<br>&gt; =C2=A0 =C2=A0 =C2=A0iovec[0]=
.iov_base =3D (void*)buf1;<br>&gt; =C2=A0 =C2=A0 =C2=A0iovec[0].iov_len =3D=
 buflen1;<br>&gt; @@ -156,13 +156,18 @@ babel_send(int s,<br>&gt; =C2=A0 ag=
ain:<br>&gt; =C2=A0 =C2=A0 =C2=A0rc =3D sendmsg(s, &amp;msg, 0);<br>&gt; =
=C2=A0 =C2=A0 =C2=A0if(rc &lt; 0) {<br>&gt; - =C2=A0 =C2=A0 =C2=A0 =C2=A0if=
(errno =3D=3D EINTR)<br>&gt; - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0got=
o again;<br>&gt; - =C2=A0 =C2=A0 =C2=A0 =C2=A0else if(errno =3D=3D EAGAIN) =
{<br>&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0if(errno =3D=3D EINTR) {<br>&gt; + =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count++;<br>&gt; + =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0if(count &lt; 1000)<br>&gt; + =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto again;<br>&gt; + =C2=A0 =C2=A0 =
=C2=A0 =C2=A0} else if(errno =3D=3D EAGAIN) {<br>&gt; =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0int rc2;<br>&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0rc2 =3D wait_for_fd(1, s, 5);<br>&gt; - =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0if(rc2 &gt; 0)<br>&gt; - =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto again;<br>&gt; + =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0if(rc2 &gt; 0) {<br>&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0count++;<br>&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0if(count &lt; 1000)<br>&gt; + =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto again;<br>&gt; + =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>&gt; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0errno =3D EAGAIN;<br>&gt; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0}<br>&gt; =C2=A0 =C2=A0 =C2=A0}<br><br><br><br>-- <br>Dave T=C3=
=A4ht<br>Let&#39;s make wifi fast, less jittery and reliable again!<br><br>=
<a href=3D"https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84j=
jmb">https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb</a=
></div>

--001a113ba080cbb12b05123c4380--


--===============1256271650995626590==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1256271650995626590==--
