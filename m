From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/13] net: add paged frag destructor to skb_fill_page_desc()
Date: Fri, 22 Jul 2011 23:44:05 +0200
Message-ID: <CAHXqBF+TJrBvEo+fd4tfXxDucEx5QaCgfBWPQ2B5UPjYQUAUgg@mail.gmail.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
 <1311340653-19336-10-git-send-email-ian.campbell@citrix.com>
 <CAHXqBFLQFKqK=ORpDQx6s2ud8mWkx=YC_AT60GVS+4XK0H61pw@mail.gmail.com> <1311368872.4027.76.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Alexey Kuznetsov <kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org>,
	"Pekka Savola (ipv6)" <pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org>,
	James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	Hideaki YOSHIFUJI <yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devel-s9riP+hp16TNLxjTenLetw@public.gmane.org" <devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
To: Ian Campbell <Ian.Campbell-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1311368872.4027.76.camel-ztPmHsLffjjnO4AKDKe2m+kiAK3p4hvP@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

W dniu 22 lipca 2011 23:07 u=BFytkownik Ian Campbell
<Ian.Campbell-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org> napisa=B3:
> On Fri, 2011-07-22 at 20:58 +0100, Micha=B3 Miros=B3aw wrote:
>> 2011/7/22 Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>:
>> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> > index 9818fe2..faee8d3 100644
>> > --- a/include/linux/skbuff.h
>> > +++ b/include/linux/skbuff.h
>> > @@ -1134,12 +1134,14 @@ static inline int skb_pagelen(const struct=
 sk_buff *skb)
>> > =A0* Does not take any additional reference on the fragment.
>> > =A0*/
>> > =A0static inline void __skb_fill_page_desc(struct sk_buff *skb, in=
t i,
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct page *page, int off, int size)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct page *page,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct skb_frag_destructor *destroy,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 int off, int size)
>> > =A0{
>> > =A0 =A0 =A0 =A0skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
>> >
>> > =A0 =A0 =A0 =A0frag->page.p =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D page;
>> > - =A0 =A0 =A0 frag->page.destructor =A0 =A0 =3D NULL;
>> > + =A0 =A0 =A0 frag->page.destructor =A0 =A0 =3D destroy;
>> > =A0 =A0 =A0 =A0frag->page_offset =A0 =A0 =A0 =A0 =3D off;
>> > =A0 =A0 =A0 =A0frag->size =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D size;
>> > =A0}
>>
>> You could just rename this function to e.g.
>> __skb_fill_fragile_page_desc() (or whatever name) add an inline
>> wrapper calling it with destroy =3D=3D NULL. This will avoid touchin=
g all
>> those drivers which won't ever need this functionality.
>
> I could call this variant __skb_frag_init (which I think better fits
> into the pattern of the new functions) and leave the existing
> __skb_fill_page_desc as a compat wrapper if that's preferred but I wa=
s
> trying to avoid duplicating up constructors just for different sets o=
f
> defaults.

It's just Huffman coding: since most users need destroy =3D NULL, it's
good to have a wrapper for this case as it will then take less time to
write and understand the code (you won't need to think what is this
NULL for in all those places).

Best Regards,
Micha=B3 Miros=B3aw
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
