From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH] xen/netfront: handle compound page
 fragments on transmit
Date: Tue, 20 Nov 2012 08:14:17 -0800
Message-ID: <CANn89iJiugvBQgKvWrpg-BvpBi6SEwuDpkLEd0DTcRMyfvzsJQ@mail.gmail.com>
References: <1353403286.18229.159.camel@zakaz.uk.xensource.com>
	<1353411606-15940-1-git-send-email-ian.campbell@citrix.com>
	<50AB856D02000078000A9EFD@nat28.tlf.novell.com>
	<1353418516.13542.38.camel@zakaz.uk.xensource.com>
	<50AB990602000078000A9F5B@nat28.tlf.novell.com>
	<1353420865.13542.44.camel@zakaz.uk.xensource.com>
	<50ABA29902000078000A9FB1@nat28.tlf.novell.com>
	<1353424014.13542.49.camel@zakaz.uk.xensource.com>
	<50ABB38202000078000AA0FD@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2251798557072754796=="
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	KonradRzeszutekWilk <konrad@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stefan Bader <stefan.bader@canonical.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Sander Eikelenboom <linux@eikelenboom.it>, ANNIE LI <annie.li@oracle.com>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <50ABB38202000078000AA0FD@nat28.tlf.novell.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

--===============2251798557072754796==
Content-Type: multipart/alternative; boundary=e89a8f3ba0db992cdc04ceef8630

--e89a8f3ba0db992cdc04ceef8630
Content-Type: text/plain; charset=ISO-8859-1

At least TCP skbs are limited to 65536 bytes in tcp_sendmsg()
(around 45 1460-bytes MSS segments)

Thats probably because IPv4  stack only copes with this limit.

This probably could be relaxed for TCP friends, but this kind of skbs
should not hit a driver.




On Tue, Nov 20, 2012 at 7:44 AM, Jan Beulich <JBeulich@suse.com> wrote:

> >>> On 20.11.12 at 16:06, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > On Tue, 2012-11-20 at 14:32 +0000, Jan Beulich wrote:
> >> > @@ -517,15 +540,16 @@ static int xennet_start_xmit(struct sk_buff
> *skb,
> >> > struct net_device *dev)
> >> >    grant_ref_t ref;
> >> >    unsigned long mfn;
> >> >    int notify;
> >> > -  int frags = skb_shinfo(skb)->nr_frags;
> >> > +  int slots;
> >> >    unsigned int offset = offset_in_page(data);
> >> >    unsigned int len = skb_headlen(skb);
> >> >    unsigned long flags;
> >> >
> >> > -  frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
> >> > -  if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
> >> > -          printk(KERN_ALERT "xennet: skb rides the rocket: %d
> frags\n",
> >> > -                 frags);
> >> > +  slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
> >> > +          xennet_count_skb_frag_slots(skb);
> >> > +  if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> >>
> >> But still - isn't this wrong now (i.e. can't it now validly exceed the
> >> boundary checked for)?
> >
> > In practice no because of the property that the number of pages backing
> > the frags is <= MAX_SKB_FRAGS even if you are using compound pages as
> > the frags.
>
> So are you saying that there is something in the system
> preventing up to MAX_SKB_FRAGS * SKB_FRAG_PAGE_ORDER
> (or NETDEV_FRAG_PAGE_MAX_ORDER) skb-s to be created? I
> didn't find any. I do notice that __netdev_alloc_frag() currently
> never gets called with a size larger than PAGE_SIZE, but
> considering that the function just recently got made capable of
> that, I'm sure respective users will show up rather sooner than
> later.
>
> Jan
>
>

--e89a8f3ba0db992cdc04ceef8630
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div style=3D"font-family: arial, helvetica, sans-serif; font-size: 10pt">A=
t least TCP skbs are limited to 65536 bytes in tcp_sendmsg()<div>(around 45=
 1460-bytes MSS segments)<br><div><br></div><div>Thats probably because IPv=
4 =A0stack only copes with this limit.</div>
<div><br></div><div>This probably could be relaxed for TCP friends, but thi=
s kind of skbs should not hit a driver.</div><div><br></div><div><br></div>=
</div><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote">On Tue,=
 Nov 20, 2012 at 7:44 AM, Jan Beulich <span dir=3D"ltr">&lt;<a href=3D"mail=
to:JBeulich@suse.com" target=3D"_blank">JBeulich@suse.com</a>&gt;</span> wr=
ote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">&gt;=
&gt;&gt; On 20.11.12 at 16:06, Ian Campbell &lt;<a href=3D"mailto:Ian.Campb=
ell@citrix.com">Ian.Campbell@citrix.com</a>&gt; wrote:<br>

&gt; On Tue, 2012-11-20 at 14:32 +0000, Jan Beulich wrote:<br>
&gt;&gt; &gt; @@ -517,15 +540,16 @@ static int xennet_start_xmit(struct sk_=
buff *skb,<br>
&gt;&gt; &gt; struct net_device *dev)<br>
&gt;&gt; &gt; =A0 =A0grant_ref_t ref;<br>
&gt;&gt; &gt; =A0 =A0unsigned long mfn;<br>
&gt;&gt; &gt; =A0 =A0int notify;<br>
&gt;&gt; &gt; - =A0int frags =3D skb_shinfo(skb)-&gt;nr_frags;<br>
&gt;&gt; &gt; + =A0int slots;<br>
&gt;&gt; &gt; =A0 =A0unsigned int offset =3D offset_in_page(data);<br>
&gt;&gt; &gt; =A0 =A0unsigned int len =3D skb_headlen(skb);<br>
&gt;&gt; &gt; =A0 =A0unsigned long flags;<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt; - =A0frags +=3D DIV_ROUND_UP(offset + len, PAGE_SIZE);<br>
&gt;&gt; &gt; - =A0if (unlikely(frags &gt; MAX_SKB_FRAGS + 1)) {<br>
&gt;&gt; &gt; - =A0 =A0 =A0 =A0 =A0printk(KERN_ALERT &quot;xennet: skb ride=
s the rocket: %d frags\n&quot;,<br>
&gt;&gt; &gt; - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frags);<br>
&gt;&gt; &gt; + =A0slots =3D DIV_ROUND_UP(offset + len, PAGE_SIZE) +<br>
&gt;&gt; &gt; + =A0 =A0 =A0 =A0 =A0xennet_count_skb_frag_slots(skb);<br>
&gt;&gt; &gt; + =A0if (unlikely(slots &gt; MAX_SKB_FRAGS + 1)) {<br>
&gt;&gt;<br>
&gt;&gt; But still - isn&#39;t this wrong now (i.e. can&#39;t it now validl=
y exceed the<br>
&gt;&gt; boundary checked for)?<br>
&gt;<br>
&gt; In practice no because of the property that the number of pages backin=
g<br>
&gt; the frags is &lt;=3D MAX_SKB_FRAGS even if you are using compound page=
s as<br>
&gt; the frags.<br>
<br>
</div></div>So are you saying that there is something in the system<br>
preventing up to MAX_SKB_FRAGS * SKB_FRAG_PAGE_ORDER<br>
(or NETDEV_FRAG_PAGE_MAX_ORDER) skb-s to be created? I<br>
didn&#39;t find any. I do notice that __netdev_alloc_frag() currently<br>
never gets called with a size larger than PAGE_SIZE, but<br>
considering that the function just recently got made capable of<br>
that, I&#39;m sure respective users will show up rather sooner than<br>
later.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
Jan<br>
<br>
</font></span></blockquote></div><br></div></div>

--e89a8f3ba0db992cdc04ceef8630--


--===============2251798557072754796==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============2251798557072754796==--
