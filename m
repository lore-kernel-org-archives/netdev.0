From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Thu, 17 Nov 2011 21:22:12 +0100
Message-ID: <CAHXqBFL5m2J=XRBY1jEO3wWPyy-y1AKwuVTd_dVrtFNbtJ76JQ@mail.gmail.com>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
 <1320860984.3916.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1321541121.3664.270.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:59306 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab1KQUWh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 15:22:37 -0500
Received: by iage36 with SMTP id e36so2637433iag.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 12:22:37 -0800 (PST)
In-Reply-To: <1321541121.3664.270.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/17 Ian Campbell <Ian.Campbell@citrix.com>:
> On Wed, 2011-11-09 at 17:49 +0000, Eric Dumazet wrote:
>> struct skb_frag_page_desc {
>> =C2=A0 =C2=A0 =C2=A0 struct page *p;
>> =C2=A0 =C2=A0 =C2=A0 atomic_t ref;
>> =C2=A0 =C2=A0 =C2=A0 int (*destroy)(void *data);
>> /* =C2=A0 =C2=A0void *data; */ /* no need, see container_of() */
>
> It turns out that container_of is not so useful here as the users
> typically has a list of pages not a single page and hence has a list =
of
> destructors too. What you actually need is the container of the point=
er
> to that list, IYSWIM, which you can't get at given only a pointer to =
an
> element of the list. So you end up doing
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct subsys_page_desc {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct subsys_=
container *container;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct sbk_fra=
g_page_desc;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> *container here is basically the same as the void * so you might as w=
ell
> include it in the base datastructure.

If you reverse the order fields in subsys_page_desc then
container_of() compiles to no-op, and you don't have to impose this
extra field for all users, even if they don't need it.

If you see it useful, then there could be base skb_frag_page_desc and
then, skb_frag_page_desc_with_data (or othre) extending it. Core code
only ever needs the base structure.

BTW, destroy() prototype should be:

void destroy(struct skb_frag_page_desc *desc);

Because: 1. you know the parameter's type, 2. whatever would be
returned is not going to be useful.

Best Regards,
Micha=C5=82 Miros=C5=82aw
