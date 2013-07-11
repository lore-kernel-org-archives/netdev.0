From: Annie <annie.li@oracle.com>
Subject: Re: [PATCH v2 1/1] xen/netback: correctly calculate
	required slots of skb.
Date: Thu, 11 Jul 2013 18:46:53 +0800
Message-ID: <4A59CC63-9B57-49FA-A2FD-6903C86E110E@oracle.com>
References: <1373447711-31303-1-git-send-email-annie.li@oracle.com>
	<1373530274.5453.148.camel@hastur.hellion.org.uk>
	<51DE6DFD.9080007@oracle.com>
	<1373536078.5453.159.camel@hastur.hellion.org.uk>
Mime-Version: 1.0 (1.0)
Content-Type: multipart/mixed; boundary="===============4421383046443079146=="
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"msw@amazon.com" <msw@amazon.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1373536078.5453.159.camel@hastur.hellion.org.uk>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org


--===============4421383046443079146==
Content-Type: multipart/alternative;
	boundary=Apple-Mail-F39F69E0-45FD-4ABF-A6CF-28CEA7F26F9C
Content-Transfer-Encoding: 7bit


--Apple-Mail-F39F69E0-45FD-4ABF-A6CF-28CEA7F26F9C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=GB2312



=B7=A2=D7=D4=CE=D2=B5=C4 iPhone

=D4=DA 2013-7-11=A3=AC=CF=C2=CE=E75:47=A3=ACIan Campbell <ian.campbell@citri=
x.com> =D0=B4=B5=C0=A3=BA

> On Thu, 2013-07-11 at 16:34 +0800, annie li wrote:
>> On 2013-7-11 16:11, Ian Campbell wrote:
>>> On Wed, 2013-07-10 at 17:15 +0800, Annie Li wrote:
>>>> +static int netbk_count_slots(struct xenvif *vif, struct sk_buff *skb,
>>>> +                int *copy_off, unsigned long size,
>>>> +                unsigned long offset, int *head)
>>>>  {
>>>> -    unsigned int count;
>>>> -    int i, copy_off;
>>>> +    unsigned long bytes;
>>>> +    int count =3D 0;
>>>>=20
>>>> -    count =3D DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);
>>>> +    offset &=3D ~PAGE_MASK;
>>>>=20
>>>> -    copy_off =3D skb_headlen(skb) % PAGE_SIZE;
>>>> +    while (size > 0) {
>>>> +        BUG_ON(offset >=3D PAGE_SIZE);
>>>> +        BUG_ON(*copy_off > MAX_BUFFER_OFFSET);
>>>>=20
>>>> -    if (skb_shinfo(skb)->gso_size)
>>>> -        count++;
>>>> +        bytes =3D PAGE_SIZE - offset;
>>>>=20
>>>> -    for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
>>>> -        unsigned long size =3D skb_frag_size(&skb_shinfo(skb)->frags[i=
]);
>>>> -        unsigned long offset =3D skb_shinfo(skb)->frags[i].page_offset=
;
>>>> -        unsigned long bytes;
>>>> +        if (bytes > size)
>>>> +            bytes =3D size;
>>>>=20
>>>> -        offset &=3D ~PAGE_MASK;
>>>> +        if (start_new_rx_buffer(*copy_off, bytes, *head)) {
>>>> +            count++;
>>>> +            *copy_off =3D 0;
>>>> +        }
>>>>=20
>>>> -        while (size > 0) {
>>>> -            BUG_ON(offset >=3D PAGE_SIZE);
>>>> -            BUG_ON(copy_off > MAX_BUFFER_OFFSET);
>>>> +        if (*copy_off + bytes > MAX_BUFFER_OFFSET)
>>>> +            bytes =3D MAX_BUFFER_OFFSET - *copy_off;
>>>>=20
>>>> -            bytes =3D PAGE_SIZE - offset;
>>>> +        *copy_off +=3D bytes;
>>>>=20
>>>> -            if (bytes > size)
>>>> -                bytes =3D size;
>>>> +        offset +=3D bytes;
>>>> +        size -=3D bytes;
>>>>=20
>>>> -            if (start_new_rx_buffer(copy_off, bytes, 0)) {
>>>> -                count++;
>>>> -                copy_off =3D 0;
>>>> -            }
>>>> +        /* Next frame */
>>>> +        if (offset =3D=3D PAGE_SIZE && size)
>>>> +            offset =3D 0;
>>>> +
>>>> +        if (*head)
>>>> +            count++;
>>> This little bit corresponds to the "/* Leave a gap for the GSO
>>> descriptor. */" in gop_frag_copy?
>>=20
>> No, it does not correspond to this in gop_frag_copy.
>=20
> So what does it correspond to?

It corresponds to following code in gop_frag_copy,
req =3D RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);

>=20
>> The code here only=20
>> increase count for the first time. I thought to initialize the count in=20=

>> xen_netbk_count_skb_slots with 1 to avoid this. But thinking of the=20
>> extreme case when the header size is zero(not sure whether this case=20
>> could be true), I increase the count here to keep safe in case header=20
>> size is zero.
>=20
> netfront requires that the first slot always contains some data,
> gop_frag_copy will BUG if that's not the case.
>=20
>>=20
>> There is code correspond to that in gop_frag_copy in=20
>> xen_netbk_count_skb_slots, see following,
>>=20
>> +    if (skb_shinfo(skb)->gso_size && !vif->gso_prefix)
>> +        count++;
>> (The original code does not have gso_prefix, I added it in this patch
>> too based on Wei's suggestion)
>=20
> OK.
>=20
> It's be nice if the count and copy variants of this logic could be as
> similar as possible but they already differ quite a bit. I have
> considered whether we could combine the two by adding "dry-run"
> functionality to gop_frag_copy but that seems like it would just ugly up
> both versions.
>=20
> Ian.
>=20
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel


--Apple-Mail-F39F69E0-45FD-4ABF-A6CF-28CEA7F26F9C
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=utf-8

<html><head></head><body bgcolor=3D"#FFFFFF"><div><div><br><br>=E5=8F=91=E8=87=
=AA=E6=88=91=E7=9A=84 iPhone</div><div><br>=E5=9C=A8 2013-7-11=EF=BC=8C=E4=B8=
=8B=E5=8D=885:47=EF=BC=8CIan Campbell &lt;<a href=3D"mailto:ian.campbell@cit=
rix.com">ian.campbell@citrix.com</a>&gt; =E5=86=99=E9=81=93=EF=BC=9A<br><br>=
</div><div></div><blockquote type=3D"cite"><div><span>On Thu, 2013-07-11 at 1=
6:34 +0800, annie li wrote:</span><br><blockquote type=3D"cite"><span>On 201=
3-7-11 16:11, Ian Campbell wrote:</span><br></blockquote><blockquote type=3D=
"cite"><blockquote type=3D"cite"><span>On Wed, 2013-07-10 at 17:15 +0800, An=
nie Li wrote:</span><br></blockquote></blockquote><blockquote type=3D"cite">=
<blockquote type=3D"cite"><blockquote type=3D"cite"><span>+static int netbk_=
count_slots(struct xenvif *vif, struct sk_buff *skb,</span><br></blockquote>=
</blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite=
"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp=
; &nbsp;&nbsp;&nbsp;int *copy_off, unsigned long size,</span><br></blockquot=
e></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"ci=
te"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp; &nbsp;&nbsp;&nbsp;unsigned long offset, int *head)</span><br></blockquot=
e></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"ci=
te"><blockquote type=3D"cite"><span> &nbsp;{</span><br></blockquote></blockq=
uote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><block=
quote type=3D"cite"><span>- &nbsp; &nbsp;unsigned int count;</span><br></blo=
ckquote></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=
=3D"cite"><blockquote type=3D"cite"><span>- &nbsp; &nbsp;int i, copy_off;</s=
pan><br></blockquote></blockquote></blockquote><blockquote type=3D"cite"><bl=
ockquote type=3D"cite"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp;unsign=
ed long bytes;</span><br></blockquote></blockquote></blockquote><blockquote t=
ype=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span>+ &nb=
sp; &nbsp;int count =3D 0;</span><br></blockquote></blockquote></blockquote>=
<blockquote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite=
"><span></span><br></blockquote></blockquote></blockquote><blockquote type=3D=
"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span>- &nbsp; &n=
bsp;count =3D DIV_ROUND_UP(skb_headlen(skb), PAGE_SIZE);</span><br></blockqu=
ote></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"=
cite"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp;offset &amp;=3D ~PAGE_M=
ASK;</span><br></blockquote></blockquote></blockquote><blockquote type=3D"ci=
te"><blockquote type=3D"cite"><blockquote type=3D"cite"><span></span><br></b=
lockquote></blockquote></blockquote><blockquote type=3D"cite"><blockquote ty=
pe=3D"cite"><blockquote type=3D"cite"><span>- &nbsp; &nbsp;copy_off =3D skb_=
headlen(skb) % PAGE_SIZE;</span><br></blockquote></blockquote></blockquote><=
blockquote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"=
><span>+ &nbsp; &nbsp;while (size &gt; 0) {</span><br></blockquote></blockqu=
ote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><blockq=
uote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp;BUG_ON(offset &gt;=3D P=
AGE_SIZE);</span><br></blockquote></blockquote></blockquote><blockquote type=
=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span>+ &nbsp;=
 &nbsp; &nbsp; &nbsp;BUG_ON(*copy_off &gt; MAX_BUFFER_OFFSET);</span><br></b=
lockquote></blockquote></blockquote><blockquote type=3D"cite"><blockquote ty=
pe=3D"cite"><blockquote type=3D"cite"><span></span><br></blockquote></blockq=
uote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><block=
quote type=3D"cite"><span>- &nbsp; &nbsp;if (skb_shinfo(skb)-&gt;gso_size)</=
span><br></blockquote></blockquote></blockquote><blockquote type=3D"cite"><b=
lockquote type=3D"cite"><blockquote type=3D"cite"><span>- &nbsp; &nbsp; &nbs=
p; &nbsp;count++;</span><br></blockquote></blockquote></blockquote><blockquo=
te type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span>+=
 &nbsp; &nbsp; &nbsp; &nbsp;bytes =3D PAGE_SIZE - offset;</span><br></blockq=
uote></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D=
"cite"><blockquote type=3D"cite"><span></span><br></blockquote></blockquote>=
</blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><blockquote=
 type=3D"cite"><span>- &nbsp; &nbsp;for (i =3D 0; i &lt; skb_shinfo(skb)-&gt=
;nr_frags; i++) {</span><br></blockquote></blockquote></blockquote><blockquo=
te type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span>-=
 &nbsp; &nbsp; &nbsp; &nbsp;unsigned long size =3D skb_frag_size(&amp;skb_sh=
info(skb)-&gt;frags[i]);</span><br></blockquote></blockquote></blockquote><b=
lockquote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite">=
<span>- &nbsp; &nbsp; &nbsp; &nbsp;unsigned long offset =3D skb_shinfo(skb)-=
&gt;frags[i].page_offset;</span><br></blockquote></blockquote></blockquote><=
blockquote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"=
><span>- &nbsp; &nbsp; &nbsp; &nbsp;unsigned long bytes;</span><br></blockqu=
ote></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"=
cite"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp;if (bytes=
 &gt; size)</span><br></blockquote></blockquote></blockquote><blockquote typ=
e=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span>+ &nbsp=
; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;bytes =3D size;</span><br></blockquote><=
/blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"=
><blockquote type=3D"cite"><span></span><br></blockquote></blockquote></bloc=
kquote><blockquote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D=
"cite"><span>- &nbsp; &nbsp; &nbsp; &nbsp;offset &amp;=3D ~PAGE_MASK;</span>=
<br></blockquote></blockquote></blockquote><blockquote type=3D"cite"><blockq=
uote type=3D"cite"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &n=
bsp;if (start_new_rx_buffer(*copy_off, bytes, *head)) {</span><br></blockquo=
te></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"c=
ite"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &n=
bsp;count++;</span><br></blockquote></blockquote></blockquote><blockquote ty=
pe=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span>+ &nbs=
p; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*copy_off =3D 0;</span><br></blockquote=
></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cit=
e"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp;}</span><br>=
</blockquote></blockquote></blockquote><blockquote type=3D"cite"><blockquote=
 type=3D"cite"><blockquote type=3D"cite"><span></span><br></blockquote></blo=
ckquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><bl=
ockquote type=3D"cite"><span>- &nbsp; &nbsp; &nbsp; &nbsp;while (size &gt; 0=
) {</span><br></blockquote></blockquote></blockquote><blockquote type=3D"cit=
e"><blockquote type=3D"cite"><blockquote type=3D"cite"><span>- &nbsp; &nbsp;=
 &nbsp; &nbsp; &nbsp; &nbsp;BUG_ON(offset &gt;=3D PAGE_SIZE);</span><br></bl=
ockquote></blockquote></blockquote><blockquote type=3D"cite"><blockquote typ=
e=3D"cite"><blockquote type=3D"cite"><span>- &nbsp; &nbsp; &nbsp; &nbsp; &nb=
sp; &nbsp;BUG_ON(copy_off &gt; MAX_BUFFER_OFFSET);</span><br></blockquote></=
blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite">=
<blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp;if (*copy_off +=
 bytes &gt; MAX_BUFFER_OFFSET)</span><br></blockquote></blockquote></blockqu=
ote><blockquote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"=
cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;bytes =3D MAX_BUFFER_=
OFFSET - *copy_off;</span><br></blockquote></blockquote></blockquote><blockq=
uote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span=
></span><br></blockquote></blockquote></blockquote><blockquote type=3D"cite"=
><blockquote type=3D"cite"><blockquote type=3D"cite"><span>- &nbsp; &nbsp; &=
nbsp; &nbsp; &nbsp; &nbsp;bytes =3D PAGE_SIZE - offset;</span><br></blockquo=
te></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"c=
ite"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp;*copy_off +=
=3D bytes;</span><br></blockquote></blockquote></blockquote><blockquote type=
=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span></span><=
br></blockquote></blockquote></blockquote><blockquote type=3D"cite"><blockqu=
ote type=3D"cite"><blockquote type=3D"cite"><span>- &nbsp; &nbsp; &nbsp; &nb=
sp; &nbsp; &nbsp;if (bytes &gt; size)</span><br></blockquote></blockquote></=
blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><blockquote t=
ype=3D"cite"><span>- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
bytes =3D size;</span><br></blockquote></blockquote></blockquote><blockquote=
 type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span>+ &=
nbsp; &nbsp; &nbsp; &nbsp;offset +=3D bytes;</span><br></blockquote></blockq=
uote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><block=
quote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp;size -=3D bytes;</spa=
n><br></blockquote></blockquote></blockquote><blockquote type=3D"cite"><bloc=
kquote type=3D"cite"><blockquote type=3D"cite"><span></span><br></blockquote=
></blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cit=
e"><blockquote type=3D"cite"><span>- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbs=
p;if (start_new_rx_buffer(copy_off, bytes, 0)) {</span><br></blockquote></bl=
ockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><b=
lockquote type=3D"cite"><span>- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &n=
bsp; &nbsp;count++;</span><br></blockquote></blockquote></blockquote><blockq=
uote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><span=
>- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;copy_off =3D 0;</s=
pan><br></blockquote></blockquote></blockquote><blockquote type=3D"cite"><bl=
ockquote type=3D"cite"><blockquote type=3D"cite"><span>- &nbsp; &nbsp; &nbsp=
; &nbsp; &nbsp; &nbsp;}</span><br></blockquote></blockquote></blockquote><bl=
ockquote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cite"><=
span>+ &nbsp; &nbsp; &nbsp; &nbsp;/* Next frame */</span><br></blockquote></=
blockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite">=
<blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp;if (offset =3D=3D=
 PAGE_SIZE &amp;&amp; size)</span><br></blockquote></blockquote></blockquote=
><blockquote type=3D"cite"><blockquote type=3D"cite"><blockquote type=3D"cit=
e"><span>+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;offset =3D 0;</span><br>=
</blockquote></blockquote></blockquote><blockquote type=3D"cite"><blockquote=
 type=3D"cite"><blockquote type=3D"cite"><span>+</span><br></blockquote></bl=
ockquote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><b=
lockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &nbsp;if (*head)</span>=
<br></blockquote></blockquote></blockquote><blockquote type=3D"cite"><blockq=
uote type=3D"cite"><blockquote type=3D"cite"><span>+ &nbsp; &nbsp; &nbsp; &n=
bsp; &nbsp; &nbsp;count++;</span><br></blockquote></blockquote></blockquote>=
<blockquote type=3D"cite"><blockquote type=3D"cite"><span>This little bit co=
rresponds to the "/* Leave a gap for the GSO</span><br></blockquote></blockq=
uote><blockquote type=3D"cite"><blockquote type=3D"cite"><span>descriptor. *=
/" in gop_frag_copy?</span><br></blockquote></blockquote><blockquote type=3D=
"cite"><span></span><br></blockquote><blockquote type=3D"cite"><span>No, it d=
oes not correspond to this in gop_frag_copy.</span><br></blockquote><span></=
span><br><span>So what does it correspond to?</span><br></div></blockquote><=
div><br></div><div>It corresponds to following code in&nbsp;gop_frag_copy,</=
div><div>req =3D RING_GET_REQUEST(&amp;vif-&gt;rx, vif-&gt;rx.req_cons++);</=
div><div><br></div><blockquote type=3D"cite"><div><span></span><br><blockquo=
te type=3D"cite"><span> The code here only </span><br></blockquote><blockquo=
te type=3D"cite"><span>increase count for the first time. I thought to initi=
alize the count in </span><br></blockquote><blockquote type=3D"cite"><span>x=
en_netbk_count_skb_slots with 1 to avoid this. But thinking of the </span><b=
r></blockquote><blockquote type=3D"cite"><span>extreme case when the header s=
ize is zero(not sure whether this case </span><br></blockquote><blockquote t=
ype=3D"cite"><span>could be true), I increase the count here to keep safe in=
 case header </span><br></blockquote><blockquote type=3D"cite"><span>size is=
 zero.</span><br></blockquote><span></span><br><span>netfront requires that t=
he first slot always contains some data,</span><br><span>gop_frag_copy will B=
UG if that's not the case.</span><br><span></span><br><blockquote type=3D"ci=
te"><span></span><br></blockquote><blockquote type=3D"cite"><span>There is c=
ode correspond to that in gop_frag_copy in </span><br></blockquote><blockquo=
te type=3D"cite"><span>xen_netbk_count_skb_slots, see following,</span><br><=
/blockquote><blockquote type=3D"cite"><span></span><br></blockquote><blockqu=
ote type=3D"cite"><span>+ &nbsp; &nbsp;if (skb_shinfo(skb)-&gt;gso_size &amp=
;&amp; !vif-&gt;gso_prefix)</span><br></blockquote><blockquote type=3D"cite"=
><span>+ &nbsp; &nbsp; &nbsp; &nbsp;count++;</span><br></blockquote><blockqu=
ote type=3D"cite"><span>(The original code does not have gso_prefix, I added=
 it in this patch</span><br></blockquote><blockquote type=3D"cite"><span>too=
 based on Wei's suggestion)</span><br></blockquote><span></span><br><span>OK=
.</span><br><span></span><br><span>It's be nice if the count and copy varian=
ts of this logic could be as</span><br><span>similar as possible but they al=
ready differ quite a bit. I have</span><br><span>considered whether we could=
 combine the two by adding "dry-run"</span><br><span>functionality to gop_fr=
ag_copy but that seems like it would just ugly up</span><br><span>both versi=
ons.</span><br><span></span><br><span>Ian.</span><br><span></span><br><span>=
</span><br><span>_______________________________________________</span><br><=
span>Xen-devel mailing list</span><br><span><a href=3D"mailto:Xen-devel@list=
s.xen.org">Xen-devel@lists.xen.org</a></span><br><span><a href=3D"http://lis=
ts.xen.org/xen-devel">http://lists.xen.org/xen-devel</a></span><br></div></b=
lockquote></div><div><span></span></div></body></html>=

--Apple-Mail-F39F69E0-45FD-4ABF-A6CF-28CEA7F26F9C--


--===============4421383046443079146==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Xen-devel mailing list
Xen-devel@lists.xen.org
http://lists.xen.org/xen-devel

--===============4421383046443079146==--
