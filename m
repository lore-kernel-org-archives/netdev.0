From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] netlink: align attributes on 64-bits
Date: Tue, 18 Dec 2012 09:19:04 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70F2@saturn3.aculab.com>
References: <1355500160.2626.9.camel@bwh-desktop.uk.solarflarecom.com> <1355762980-4285-1-git-send-email-nicolas.dichtel@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70F1@saturn3.aculab.com> <50CF57DC.5050804@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <bhutchings@solarflare.com>, <tgraf@suug.ch>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
To: <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33857 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754160Ab2LRJVk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 04:21:40 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28855-08 for <netdev@vger.kernel.org>;
 Tue, 18 Dec 2012 09:21:35 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <50CF57DC.5050804@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Le 17/12/2012 18:06, David Laight a =E9crit :
> >>   int nla_put(struct sk_buff *skb, int attrtype, int attrlen, cons=
t void *data)
> >>   {
> >> -	if (unlikely(skb_tailroom(skb) < nla_total_size(attrlen)))
> >> +	int align =3D IS_ALIGNED((unsigned long)skb_tail_pointer(skb), 8=
) ? 0 : 4;
> >
> > I've just realised where you are adding this!
> > You only want to add pad if the attribute is a single 64bit item,
> > not whenever the destination is misaligned.
> As said in the commit log, I want to align all attributes. An attribu=
te can be
> like this:
>=20
> struct foo {
> 	__u32 bar1;
> 	__u32 bar2;
> 	__u64 bar3;
> }
>=20
> nla_put() don't know what is contained in the attribute.

Put there is no need to 8-byte align something whose size isn't a
multiple of 8 bytes.

> > ...
> >> +	if (align) {
> >> +		/* Goal is to add an attribute with size 4. We know that
> >> +		 * NLA_HDRLEN is 4, hence payload is 0.
> >> +		 */
> >> +		__nla_reserve(skb, 0, 0);
> >
> > One of those zeros should be 'align - 4', then the comment
> > can be more descriptive.

> I thought if you were to research why we use 0, you would know that t=
he first 0
> is the type and the second is the payload size...

I can tell that one is the type and the other the size, you've
implied that the 'type+size' actually total 4 bytes.
I don't need to find out which is which!
Now you've told me I'd have written:
	_nla_reserve(skb, 0, align - NLA_HDRLEN);

The compiler could well have tracked the value - so know it is 4.
OTOH you might want to generate the size of 'align' without
using a conditional.

	David
