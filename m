From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on
 postrouting hook
Date: Sun, 15 Feb 2004 08:03:54 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0402150801310.12126-100000@thoron.boston.redhat.com>
References: <402F3D1E.2020005@kolumbus.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@redhat.com>, Harald Welte <laforge@netfilter.org>,
        <netdev@oss.sgi.com>, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <402F3D1E.2020005@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Feb 2004, Mika Penttil=E4 wrote:

> James Morris wrote:
>=20
> >On Sat, 14 Feb 2004, Mika Penttil=E4 wrote:
> >>>
> >>This is unneeded overhead for the common case. The right fix is to ma=
ke=20
> >>sure the modifier (netfilter etc) makes the copy if needed. Actually,=
=20
> >>this is what skb_ip_make_writable() is doing.
> >>   =20
> >>
> >
> >The common case here will be only for locally generated multicast and=20
> >broadcast packets.
> >
> >If the netfilter core code is modified instead, we will end up adding
> >skb_ip_make_writable() to nf_hook_slow() which will be called for ever=
y=20
> >packet with an output device which uses hardware checksums.
> >
> >Not sure which is worse, but here's a proposed patch which does this.
> >
> >
> >- James
> >
>=20
> I don't see the context here. Where is the packet mangled? Why isn't=20
> that instance doing skb_ip_make_writable()? selinux? Not everyone=20
> generating locally multicast/broadcast packets is using selinux...
>=20

[my previous post didn't seem to make it to the list, newer patch is=20
attached below again]

The packet is mangled in skb_checksum_help(), which is called by the=20
Netfilter core code.  It is not being mangled by SELinux.


- James
--=20
James Morris
<jmorris@redhat.com>


diff -urN -X dontdiff linux-2.6.3-rc2-mm1.o/include/linux/netfilter.h lin=
ux-2.6.3-rc2-mm1.w2/include/linux/netfilter.h
--- linux-2.6.3-rc2-mm1.o/include/linux/netfilter.h	2004-02-03 22:43:48.0=
00000000 -0500
+++ linux-2.6.3-rc2-mm1.w2/include/linux/netfilter.h	2004-02-15 00:16:30.=
000000000 -0500
@@ -162,6 +162,12 @@
 /* FIXME: Before cache is ever used, this must be implemented for real. =
*/
 extern void nf_invalidate_cache(int pf);
=20
+/* Call this before modifying an existing IP packet: ensures it is
+   modifiable and linear to the point you care about (writable_len).
+   Returns true or false. */
+extern int skb_ip_make_writable(struct sk_buff **pskb,
+				unsigned int writable_len);
+
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 #endif /*CONFIG_NETFILTER*/
diff -urN -X dontdiff linux-2.6.3-rc2-mm1.o/include/linux/netfilter_ipv4.=
h linux-2.6.3-rc2-mm1.w2/include/linux/netfilter_ipv4.h
--- linux-2.6.3-rc2-mm1.o/include/linux/netfilter_ipv4.h	2004-02-03 22:44=
:26.000000000 -0500
+++ linux-2.6.3-rc2-mm1.w2/include/linux/netfilter_ipv4.h	2004-02-15 00:1=
6:13.000000000 -0500
@@ -78,11 +78,6 @@
=20
 extern int ip_route_me_harder(struct sk_buff **pskb);
=20
-/* Call this before modifying an existing IP packet: ensures it is
-   modifiable and linear to the point you care about (writable_len).
-   Returns true or false. */
-extern int skb_ip_make_writable(struct sk_buff **pskb,
-				unsigned int writable_len);
 #endif /*__KERNEL__*/
=20
 #endif /*__LINUX_IP_NETFILTER_H*/
diff -urN -X dontdiff linux-2.6.3-rc2-mm1.o/net/core/netfilter.c linux-2.=
6.3-rc2-mm1.w2/net/core/netfilter.c
--- linux-2.6.3-rc2-mm1.o/net/core/netfilter.c	2004-02-03 22:43:46.000000=
000 -0500
+++ linux-2.6.3-rc2-mm1.w2/net/core/netfilter.c	2004-02-15 00:57:05.00000=
0000 -0500
@@ -509,6 +509,13 @@
 		if (outdev =3D=3D NULL) {
 			skb->ip_summed =3D CHECKSUM_NONE;
 		} else {
+			int wlen =3D skb->h.raw - skb->data + skb->csum;
+		=09
+			/* packet is about to be modified */
+			if (!skb_ip_make_writable(&skb, wlen)) {
+				kfree(skb);
+				return -ENOMEM;
+			}
 			skb_checksum_help(skb);
 		}
 	}
