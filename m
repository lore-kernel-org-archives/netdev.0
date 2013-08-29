From: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [-next] openvswitch BUILD_BUG_ON failed
Date: Thu, 29 Aug 2013 14:40:16 -0700
Message-ID: <CACzMAJKLADE2oZc5NZNQa0g=pentd1EfqukwMdeGBaMvcwN4aQ@mail.gmail.com>
References: <CAMuHMdVG9FmZNayrf7HMz4kC4X5QELeXUFjjzpAM80ND_QOm8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0952524099=="
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-Next <linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAMuHMdVG9FmZNayrf7HMz4kC4X5QELeXUFjjzpAM80ND_QOm8A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0952524099==
Content-Type: multipart/alternative; boundary=089e0149ce5ca1a89e04e51cf3f9

--089e0149ce5ca1a89e04e51cf3f9
Content-Type: text/plain; charset=ISO-8859-1

Yes, fengguan.Wu has reported the issue. Just sent out a patch for review.
You are welcome to review it.

http://openvswitch.org/pipermail/dev/2013-August/031247.html


On Thu, Aug 29, 2013 at 2:21 PM, Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>wrote:

> On m68k, where the alignment of 32-bit words is 2 bytes:
>
> net/openvswitch/flow.c:1984:2: error: call to
> '__compiletime_assert_1984' declared with attribute error:
> BUILD_BUG_ON failed: sizeof(struct sw_flow_key) % sizeof(long)
>
> (http://kisskb.ellerman.id.au/kisskb/buildresult/9422860/)
>
> This was introduced by commit 5828cd9a68873df1340b420371c02c47647878fb
> Author: Andy Zhou <azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Date:   Tue Aug 27 13:02:21 2013 -0700
>
>     openvswitch: optimize flow compare and mask functions
>
>     Make sure the sw_flow_key structure and valid mask boundaries are
> always
>     machine word aligned. Optimize the flow compare and mask operations
>     using machine word size operations. This patch improves throughput on
>     average by 15% when CPU is the bottleneck of forwarding packets.
>
>     This patch is inspired by ideas and code from a patch submitted by
> Peter
>     Klausler titled "replace memcmp() with specialized comparator".
>     However, The original patch only optimizes for architectures
>     support unaligned machine word access. This patch optimizes for all
>     architectures.
>
> A quick fix to satisfy the build check is to make the padding explicit
> (gmail-whitespace-damaged diff):
>
> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index b65f885..15f08d9 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -78,6 +78,7 @@ struct sw_flow_key {
>                 u32     priority;       /* Packet QoS priority. */
>                 u32     skb_mark;       /* SKB mark. */
>                 u16     in_port;        /* Input switch port (or
> DP_MAX_PORTS).
> +               u16     pad;
>         } phy;
>         struct {
>                 u8     src[ETH_ALEN];   /* Ethernet source address. */
>
> However, I have some doubts about other alignment "enforcements":
>
> "__aligned(__alignof__(long))" makes the whole struct aligned to the
> alignment rule for "long":
>    1. This is only 2 bytes on m68k, i.e. != sizeof(long).
>    2. This is 4 bytes on many 32-bit platforms, which may be less than the
>       default alignment for "__be64" (cfr. some members of struct
>       ovs_key_ipv4_tunnel), so this may make those 64-bit members
> unaligned.
> I guess you want (at least) 4 byte alignment on 32-bit, and prefer 8 byte
> alignment on 64-bit?
> Not specifying any alignment constraint will give you most of that (except
> on 64-bit platforms where 64-bit words must be only 4-byte aligned).
>
> There's another build check "BUILD_BUG_ON(sizeof(long) % sizeof(u32))".
> Isn't this always true on Linux, as "long" is never smaller than 4 bytes?
>

Gr{oetje,eeting}s,
>
>                         Geert
>
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 --
> geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org
>
> In personal conversations with technical people, I call myself a hacker.
> But
> when I'm talking to journalists I just say "programmer" or something like
> that.
>                                 -- Linus Torvalds
>

--089e0149ce5ca1a89e04e51cf3f9
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Yes, fengguan.Wu has reported the issue. Just sent out a p=
atch for review. You are welcome to review it. <br><br><a href=3D"http://op=
envswitch.org/pipermail/dev/2013-August/031247.html">http://openvswitch.org=
/pipermail/dev/2013-August/031247.html</a><br>
<div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote">On Thu, Aug 2=
9, 2013 at 2:21 PM, Geert Uytterhoeven <span dir=3D"ltr">&lt;<a href=3D"mai=
lto:geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org" target=3D"_blank">geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org</a>&gt;</s=
pan> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">On m68k, where the alignment of 32-bit words=
 is 2 bytes:<br>
<br>
net/openvswitch/flow.c:1984:2: error: call to<br>
&#39;__compiletime_assert_1984&#39; declared with attribute error:<br>
BUILD_BUG_ON failed: sizeof(struct sw_flow_key) % sizeof(long)<br>
<br>
(<a href=3D"http://kisskb.ellerman.id.au/kisskb/buildresult/9422860/" targe=
t=3D"_blank">http://kisskb.ellerman.id.au/kisskb/buildresult/9422860/</a>)<=
br>
<br>
This was introduced by commit 5828cd9a68873df1340b420371c02c47647878fb<br>
Author: Andy Zhou &lt;<a href=3D"mailto:azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org">azhou-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org<=
/a>&gt;<br>
Date: =A0 Tue Aug 27 13:02:21 2013 -0700<br>
<br>
=A0 =A0 openvswitch: optimize flow compare and mask functions<br>
<br>
=A0 =A0 Make sure the sw_flow_key structure and valid mask boundaries are a=
lways<br>
=A0 =A0 machine word aligned. Optimize the flow compare and mask operations=
<br>
=A0 =A0 using machine word size operations. This patch improves throughput =
on<br>
=A0 =A0 average by 15% when CPU is the bottleneck of forwarding packets.<br=
>
<br>
=A0 =A0 This patch is inspired by ideas and code from a patch submitted by =
Peter<br>
=A0 =A0 Klausler titled &quot;replace memcmp() with specialized comparator&=
quot;.<br>
=A0 =A0 However, The original patch only optimizes for architectures<br>
=A0 =A0 support unaligned machine word access. This patch optimizes for all=
<br>
=A0 =A0 architectures.<br>
<br>
A quick fix to satisfy the build check is to make the padding explicit<br>
(gmail-whitespace-damaged diff):<br>
<br>
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h<br>
index b65f885..15f08d9 100644<br>
--- a/net/openvswitch/flow.h<br>
+++ b/net/openvswitch/flow.h<br>
@@ -78,6 +78,7 @@ struct sw_flow_key {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 =A0 =A0 priority; =A0 =A0 =A0 /* Packet=
 QoS priority. */<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 =A0 =A0 skb_mark; =A0 =A0 =A0 /* SKB ma=
rk. */<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 =A0 =A0 in_port; =A0 =A0 =A0 =A0/* Inpu=
t switch port (or DP_MAX_PORTS).<br>
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 =A0 =A0 pad;<br>
=A0 =A0 =A0 =A0 } phy;<br>
=A0 =A0 =A0 =A0 struct {<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 =A0 =A0 src[ETH_ALEN]; =A0 /* Ethernet s=
ource address. */<br>
<br>
However, I have some doubts about other alignment &quot;enforcements&quot;:=
<br>
<br>
&quot;__aligned(__alignof__(long))&quot; makes the whole struct aligned to =
the<br>
alignment rule for &quot;long&quot;:<br>
=A0 =A01. This is only 2 bytes on m68k, i.e. !=3D sizeof(long).<br>
=A0 =A02. This is 4 bytes on many 32-bit platforms, which may be less than =
the<br>
=A0 =A0 =A0 default alignment for &quot;__be64&quot; (cfr. some members of =
struct<br>
=A0 =A0 =A0 ovs_key_ipv4_tunnel), so this may make those 64-bit members una=
ligned.<br>
I guess you want (at least) 4 byte alignment on 32-bit, and prefer 8 byte<b=
r>
alignment on 64-bit?<br>
Not specifying any alignment constraint will give you most of that (except<=
br>
on 64-bit platforms where 64-bit words must be only 4-byte aligned).<br>
<br>
There&#39;s another build check &quot;BUILD_BUG_ON(sizeof(long) % sizeof(u3=
2))&quot;.<br>
Isn&#39;t this always true on Linux, as &quot;long&quot; is never smaller t=
han 4 bytes?=A0<br></blockquote><br><blockquote class=3D"gmail_quote" style=
=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
Gr{oetje,eeting}s,<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Geert<br>
<br>
--<br>
Geert Uytterhoeven -- There&#39;s lots of Linux beyond ia32 -- <a href=3D"m=
ailto:geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org">geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org</a><br>
<br>
In personal conversations with technical people, I call myself a hacker. Bu=
t<br>
when I&#39;m talking to journalists I just say &quot;programmer&quot; or so=
mething like that.<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 -- Linus To=
rvalds<br>
</blockquote></div><br></div></div>

--089e0149ce5ca1a89e04e51cf3f9--

--===============0952524099==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0952524099==--
