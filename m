From: Debabrata Banerjee <dbavatar@gmail.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
Date: Thu, 11 Jun 2015 17:25:49 -0400
Message-ID: <CAATkVEwBd=UXhaonUwW0OHh4Jo-6DMqvwhMqeZ-z9OHdZopbEw@mail.gmail.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
	<1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=f46d043c80eeab2780051844a2b7
Cc: Shaohua Li <shli@fb.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>, Kernel-team@fb.com,
	Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org,
	"Banerjee, Debabrata" <dbanerje@akamai.com>, Joshua Hunt <johunt@akamai.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

--f46d043c80eeab2780051844a2b7
Content-Type: text/plain; charset=UTF-8

It's somewhat an intractable problem to know if compaction will succeed
without trying it, and you can certainly end up in a state where memory is
heavily fragmented, even with compaction running. You can't compact kernel
pages for example, so you can end up in a state where compaction does
nothing through no fault of it's own.

In this case you waste time in compaction routines, then end up reclaiming
precious page cache pages or swapping out for whatever it is your machine
was doing trying to do to satisfy these order-3 allocations, after which
all those pages need to be restored from disk almost immediately. This is
not a happy server. Any mm fix may be years away. The only simple solution
I can think of is specifically caching these allocations, in any other case
under memory pressure they will be split by other smaller allocations.

We've been forcing these allocations to order-0 internally until we can
think of something else.

-Deb

On Thu, Jun 11, 2015 at 4:48 PM, Eric Dumazet <eric.dumazet@gmail.com>
wrote:

> On Thu, 2015-06-11 at 13:24 -0700, Shaohua Li wrote:
> > We saw excessive memory compaction triggered by skb_page_frag_refill.
> > This causes performance issues. Commit 5640f7685831e0 introduces the
> > order-3 allocation to improve performance. But memory compaction has
> > high overhead. The benefit of order-3 allocation can't compensate the
> > overhead of memory compaction.
> >
> > This patch makes the order-3 page allocation atomic. If there is no
> > memory pressure and memory isn't fragmented, the alloction will still
> > success, so we don't sacrifice the order-3 benefit here. If the atomic
> > allocation fails, compaction will not be triggered and we will fallback
> > to order-0 immediately.
> >
> > The mellanox driver does similar thing, if this is accepted, we must fix
> > the driver too.
> >
> > Cc: Eric Dumazet <edumazet@google.com>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > ---
> >  net/core/sock.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 292f422..e9855a4 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct
> page_frag *pfrag, gfp_t gfp)
> >
> >       pfrag->offset = 0;
> >       if (SKB_FRAG_PAGE_ORDER) {
> > -             pfrag->page = alloc_pages(gfp | __GFP_COMP |
> > +             pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP
> |
> >                                         __GFP_NOWARN | __GFP_NORETRY,
> >                                         SKB_FRAG_PAGE_ORDER);
> >               if (likely(pfrag->page)) {
>
> This is not a specific networking issue, but mm one.
>
> You really need to start a discussion with mm experts.
>
> Your changelog does not exactly explains what _is_ the problem.
>
> If the problem lies in mm layer, it might be time to fix it, instead of
> work around the bug by never triggering it from this particular point,
> which is a safe point where a process is willing to wait a bit.
>
> Memory compaction is either working as intending, or not.
>
> If we enabled it but never run it because it hurts, what is the point
> enabling it ?
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--f46d043c80eeab2780051844a2b7
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">It&#39;s somewhat an intractable problem to know if compac=
tion will succeed without trying it, and you can certainly end up in a stat=
e where memory is heavily fragmented, even with compaction running. You can=
&#39;t compact kernel pages for example, so you can end up in a state where=
 compaction does nothing through no fault of it&#39;s own.<div><br></div><d=
iv>In this case you waste time in compaction routines, then end up reclaimi=
ng precious page cache pages or swapping out for whatever it is your machin=
e was doing trying to do to satisfy these order-3 allocations, after which =
all those pages need to be restored from disk almost immediately. This is n=
ot a happy server. Any mm fix may be years away. The only simple solution I=
 can think of is specifically caching these allocations, in any other case =
under memory pressure they will be split by other smaller allocations.<div>=
<br></div><div>We&#39;ve been forcing these allocations to order-0 internal=
ly until we can think of something else.</div><div><br></div><div>-Deb<br><=
div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Thu, Jun 11, 20=
15 at 4:48 PM, Eric Dumazet <span dir=3D"ltr">&lt;<a href=3D"mailto:eric.du=
mazet@gmail.com" target=3D"_blank">eric.dumazet@gmail.com</a>&gt;</span> wr=
ote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"=
h5">On Thu, 2015-06-11 at 13:24 -0700, Shaohua Li wrote:<br>
&gt; We saw excessive memory compaction triggered by skb_page_frag_refill.<=
br>
&gt; This causes performance issues. Commit 5640f7685831e0 introduces the<b=
r>
&gt; order-3 allocation to improve performance. But memory compaction has<b=
r>
&gt; high overhead. The benefit of order-3 allocation can&#39;t compensate =
the<br>
&gt; overhead of memory compaction.<br>
&gt;<br>
&gt; This patch makes the order-3 page allocation atomic. If there is no<br=
>
&gt; memory pressure and memory isn&#39;t fragmented, the alloction will st=
ill<br>
&gt; success, so we don&#39;t sacrifice the order-3 benefit here. If the at=
omic<br>
&gt; allocation fails, compaction will not be triggered and we will fallbac=
k<br>
&gt; to order-0 immediately.<br>
&gt;<br>
&gt; The mellanox driver does similar thing, if this is accepted, we must f=
ix<br>
&gt; the driver too.<br>
&gt;<br>
&gt; Cc: Eric Dumazet &lt;<a href=3D"mailto:edumazet@google.com">edumazet@g=
oogle.com</a>&gt;<br>
&gt; Signed-off-by: Shaohua Li &lt;<a href=3D"mailto:shli@fb.com">shli@fb.c=
om</a>&gt;<br>
&gt; ---<br>
&gt;=C2=A0 net/core/sock.c | 2 +-<br>
&gt;=C2=A0 1 file changed, 1 insertion(+), 1 deletion(-)<br>
&gt;<br>
&gt; diff --git a/net/core/sock.c b/net/core/sock.c<br>
&gt; index 292f422..e9855a4 100644<br>
&gt; --- a/net/core/sock.c<br>
&gt; +++ b/net/core/sock.c<br>
&gt; @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struc=
t page_frag *pfrag, gfp_t gfp)<br>
&gt;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0pfrag-&gt;offset =3D 0;<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0if (SKB_FRAG_PAGE_ORDER) {<br>
&gt; -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pfrag-&gt;page =3D al=
loc_pages(gfp | __GFP_COMP |<br>
&gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pfrag-&gt;page =3D al=
loc_pages((gfp &amp; ~__GFP_WAIT) | __GFP_COMP |<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0__GFP_NOWARN | __GFP_NORETRY,<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0SKB_FRAG_PAGE_ORDER);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(pfrag=
-&gt;page)) {<br>
<br>
</div></div>This is not a specific networking issue, but mm one.<br>
<br>
You really need to start a discussion with mm experts.<br>
<br>
Your changelog does not exactly explains what _is_ the problem.<br>
<br>
If the problem lies in mm layer, it might be time to fix it, instead of<br>
work around the bug by never triggering it from this particular point,<br>
which is a safe point where a process is willing to wait a bit.<br>
<br>
Memory compaction is either working as intending, or not.<br>
<br>
If we enabled it but never run it because it hurts, what is the point<br>
enabling it ?<br>
<br>
<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</blockquote></div><br></div></div></div></div>

--f46d043c80eeab2780051844a2b7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
