From: "=?gb2312?B?zsDH5Q==?=" <weiqing@zw.com.cn>
Subject: A question on "Scheduling in interrupt".
Date: Sat, 15 Jun 2002 22:33:09 +0800
Sender: owner-netdev@oss.sgi.com
Message-ID: <002301c21479$92ce7f00$c9001eac@public>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_NextPart_000_0020_01C214BC.A0B63CA0"
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------=_NextPart_000_0020_01C214BC.A0B63CA0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

Dear Networking Teak,

I am a system engineer in a Chinese software development company, and =
currently I am implementing IPSec on Linux version 2.2.16. Generally =
speaking, what I am doing is adding internet key exchange and IPsec =
processing functions into the Linux ip_queue_xmit, ip_build_xmit and =
ip_local_deliver procedures. After I have built up a new sk_buff =
variable, I send it off using my own function send_skbuff(), this is =
where the problem occurs. Following is the complete copy of the culprit:

void send_skbuff(struct sk_buff *skb)
{
  struct rtable *rt;
  struct iphdr *iph;

  iph =3D skb->nh.iph;
  if(ip_route_output(&rt, iph->daddr, iph->saddr,
 IPTOS_LOWDELAY, 0))
    goto drop;
  skb->dst =3D dst_clone(&rt->u.dst);
  skb->priority =3D TC_PRIO_FILLER;
  if (skb_cloned(skb))
    skb =3D skb_copy(skb, GFP_ATOMIC);
  else
    skb =3D skb_clone(skb, GFP_ATOMIC);
  if (skb->len > rt->u.dst.pmtu)
    goto fragment;
  skb->dst->output(skb);
  return;
fragment:
  ip_fragment(skb, skb->dst->output);
  return;
drop:
  kfree_skb(skb);=20
}

All functions within the above procedure are kernel supplied and =
irrelevant to the problem, so I will skip its explanation.
I use the kgdb to debug my codes. Everything worked fine until I had =
crossed the skb->dst->output(skb) statement and hit upon return. Then, =
when I typed =A1=B0next=A1=B1 on host machine, the system crashed with =
=A1=B0Scheduling in interrupt!=A1=B1 appearing on target machine and the =
following message on my host machine:

Program received signal SIGSEGV, Segmentation fault.
Schedule () at sched.c: 875
875 *(int *)0 =3D 0

Leery of some low level codes within the =
=A1=B0skb->dst->output(skb)=A1=B1 provoked the crash, I step into that =
statement which points to function ip_output. Alas, the system crashed =
with the same reason upon the first statement of procedure ip_output, =
and that statement does simple book keeping!
The problem is patent: scheduling while within the interrupt processing, =
the myth is how could it ever be scheduling within interrupt since I am =
not doing anything within the interrupt context!? It is a well known =
fact that within Linux there are three places to evoke scheduling, =
either it is educed explicitly by the procedure itself, which won=A1=AFt =
be within interrupt context as long as the caller is not within it; or =
it can be elicited when the current process=A1=AFs time quantum is =
exhausted or when a newly awakened process has a higher priority than =
the current one, during these two situations, the system will mark the =
need_resched flag, and the actual scheduling is performed when the =
system returns from a interrupt, again within the context of the process =
that is to be scheduled away. Therefore normally there is no chance to =
be scheduling in interrupt. Where is the hole? The problem must be =
caused by my codes, shouldn=A1=AFt it?
By the way, I implemented the send_skbuff months ago, and together with =
other codes they had been working fine. This scheduling in interrupt =
problem only recently popped up when I was debugging error processing =
for IPsec and the place it occurred is irrelevant to the error =
processing.
Any comments will be greatly appreciated.

Regards,

Lee Tong


------=_NextPart_000_0020_01C214BC.A0B63CA0
Content-Type: text/html;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD W3 HTML//EN">
<HTML>
<HEAD>

<META content=3Dtext/html;charset=3Dgb2312 http-equiv=3DContent-Type>
<META content=3D'"MSHTML 4.72.2106.11"' name=3DGENERATOR>
</HEAD>
<BODY bgColor=3D#ffffff>
<DIV><FONT color=3D#000000 size=3D2>Dear Networking Teak,</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 size=3D2>I am a system engineer in a Chinese =
software=20
development company, and currently I am implementing IPSec on Linux =
version=20
2.2.16. Generally speaking, what I am doing is adding internet key =
exchange and=20
IPsec processing functions into the Linux ip_queue_xmit, ip_build_xmit =
and=20
ip_local_deliver procedures. After I have built up a new sk_buff =
variable, I=20
send it off using my own function send_skbuff(), this is where the =
problem=20
occurs. Following is the complete copy of the culprit:</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 size=3D2>void send_skbuff(struct sk_buff=20
*skb)<BR>{<BR>&nbsp; struct rtable *rt;<BR>&nbsp; struct iphdr=20
*iph;</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 size=3D2>&nbsp; iph =3D =
skb-&gt;nh.iph;<BR>&nbsp;=20
if(ip_route_output(&amp;rt, iph-&gt;daddr,=20
iph-&gt;saddr,<BR>&nbsp;IPTOS_LOWDELAY, 0))<BR>&nbsp;&nbsp;&nbsp; goto=20
drop;<BR>&nbsp; skb-&gt;dst =3D dst_clone(&amp;rt-&gt;u.dst);<BR>&nbsp;=20
skb-&gt;priority =3D TC_PRIO_FILLER;<BR>&nbsp; if=20
(skb_cloned(skb))<BR>&nbsp;&nbsp;&nbsp; skb =3D skb_copy(skb,=20
GFP_ATOMIC);<BR>&nbsp; else<BR>&nbsp;&nbsp;&nbsp; skb =3D skb_clone(skb, =

GFP_ATOMIC);<BR>&nbsp; if (skb-&gt;len &gt;=20
rt-&gt;u.dst.pmtu)<BR>&nbsp;&nbsp;&nbsp; goto fragment;<BR>&nbsp;=20
skb-&gt;dst-&gt;output(skb);<BR>&nbsp; return;<BR>fragment:<BR>&nbsp;=20
ip_fragment(skb, skb-&gt;dst-&gt;output);<BR>&nbsp; =
return;<BR>drop:<BR>&nbsp;=20
kfree_skb(skb); <BR>}</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 size=3D2>All functions within the above =
procedure are=20
kernel supplied and irrelevant to the problem, so I will skip its=20
explanation.<BR>I use the kgdb to debug my codes. Everything worked fine =
until I=20
had crossed the skb-&gt;dst-&gt;output(skb) statement and hit upon =
return. Then,=20
when I typed &ldquo;next&rdquo; on host machine, the system crashed with =

&ldquo;Scheduling in interrupt!&rdquo; appearing on target machine and =
the=20
following message on my host machine:</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 size=3D2>Program received signal SIGSEGV, =
Segmentation=20
fault.<BR>Schedule () at sched.c: 875<BR>875 *(int *)0 =3D =
0</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 size=3D2>Leery of some low level codes within =
the=20
&ldquo;skb-&gt;dst-&gt;output(skb)&rdquo; provoked the crash, I step =
into that=20
statement which points to function ip_output. Alas, the system crashed =
with the=20
same reason upon the first statement of procedure ip_output, and that =
statement=20
does simple book keeping!<BR>The problem is patent: scheduling while =
within the=20
interrupt processing, the myth is how could it ever be scheduling within =

interrupt since I am not doing anything within the interrupt context!? =
It is a=20
well known fact that within Linux there are three places to evoke =
scheduling,=20
either it is educed explicitly by the procedure itself, which =
won&rsquo;t be=20
within interrupt context as long as the caller is not within it; or it =
can be=20
elicited when the current process&rsquo;s time quantum is exhausted or =
when a=20
newly awakened process has a higher priority than the current one, =
during these=20
two situations, the system will mark the need_resched flag, and the =
actual=20
scheduling is performed when the system returns from a interrupt, again =
within=20
the context of the process that is to be scheduled away. Therefore =
normally=20
there is no chance to be scheduling in interrupt. Where is the hole? The =
problem=20
must be caused by my codes, shouldn&rsquo;t it?<BR>By the way, I =
implemented the=20
send_skbuff months ago, and together with other codes they had been =
working=20
fine. This scheduling in interrupt problem only recently popped up when =
I was=20
debugging error processing for IPsec and the place it occurred is =
irrelevant to=20
the error processing.<BR>Any comments will be greatly =
appreciated.</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 size=3D2>Regards,</FONT></DIV>
<DIV><FONT color=3D#000000 size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000 size=3D2>Lee =
Tong<BR></FONT></DIV></BODY></HTML>

------=_NextPart_000_0020_01C214BC.A0B63CA0--
