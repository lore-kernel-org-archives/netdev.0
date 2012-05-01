From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 3/4 v2 net-next] net: make GRO aware of skb->head_frag
Date: Mon, 30 Apr 2012 22:33:11 -0700
Message-ID: <CAKgT0UdeVvJe6k5OitkKgujSw3SQSOvtQ84KrPch8xdd=5ub1A@mail.gmail.com>
References: <1335523026.2775.236.camel@edumazet-glaptop>
	<1335809434.2296.9.camel@edumazet-glaptop>
	<4F9F21E2.3080407@intel.com>
	<1335835677.11396.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:51344 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035Ab2EAFdM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 01:33:12 -0400
Received: by dadz8 with SMTP id z8so4982145dad.10
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 22:33:11 -0700 (PDT)
In-Reply-To: <1335835677.11396.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 30, 2012 at 6:27 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> On Mon, 2012-04-30 at 16:36 -0700, Alexander Duyck wrote:
>> On 04/30/2012 11:10 AM, Eric Dumazet wrote:
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > GRO can check if skb to be merged has its skb->head mapped to a pa=
ge
>> > fragment, instead of a kmalloc() area.
>> >
>> > We 'upgrade' skb->head as a fragment in itself
>> >
>> > This avoids the frag_list fallback, and permits to build true GRO =
skb
>> > (one sk_buff and up to 16 fragments), using less memory.
>> >
>> > This reduces number of cache misses when user makes its copy, sinc=
e a
>> > single sk_buff is fetched.
>> >
>> > This is a followup of patch "net: allow skb->head to be a page fra=
gment"
>> >

[...]

>> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> > index effa75d..2ad1ee7 100644
>> > --- a/net/core/skbuff.c
>> > +++ b/net/core/skbuff.c
>> > @@ -69,7 +69,7 @@
>> > =A0#include <trace/events/skb.h>
>> > =A0#include <linux/highmem.h>
>> >
>> > -static struct kmem_cache *skbuff_head_cache __read_mostly;
>> > +struct kmem_cache *skbuff_head_cache __read_mostly;
>> > =A0static struct kmem_cache *skbuff_fclone_cache __read_mostly;
>> >
>> > =A0static void sock_pipe_buf_release(struct pipe_inode_info *pipe,
>> > @@ -2901,6 +2901,31 @@ int skb_gro_receive(struct sk_buff **head, =
struct sk_buff *skb)
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 NAPI_GRO_CB(skb)->free =3D 1;
>> > =A0 =A0 =A0 =A0 =A0 =A0 goto done;
>> > + =A0 } else if (skb->head_frag) {
>> > + =A0 =A0 =A0 =A0 =A0 int nr_frags =3D pinfo->nr_frags;
>> > + =A0 =A0 =A0 =A0 =A0 skb_frag_t *frag =3D pinfo->frags + nr_frags=
;
>> > + =A0 =A0 =A0 =A0 =A0 struct page *page =3D virt_to_head_page(skb-=
>head);
>> > + =A0 =A0 =A0 =A0 =A0 unsigned int first_size =3D headlen - offset=
;
>> > + =A0 =A0 =A0 =A0 =A0 unsigned int first_offset;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 if (nr_frags + 1 + skbinfo->nr_frags > MAX_S=
KB_FRAGS)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -E2BIG;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 first_offset =3D skb->data -
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(unsigned cha=
r *)page_address(page) +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0offset;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 pinfo->nr_frags =3D nr_frags + 1 + skbinfo->=
nr_frags;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 frag->page.p =A0 =A0 =A0=3D page;
>> > + =A0 =A0 =A0 =A0 =A0 frag->page_offset =3D first_offset;
>> > + =A0 =A0 =A0 =A0 =A0 skb_frag_size_set(frag, first_size);
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 memcpy(frag + 1, skbinfo->frags, sizeof(*fra=
g) * skbinfo->nr_frags);
>> > + =A0 =A0 =A0 =A0 =A0 /* We dont need to clear skbinfo->nr_frags h=
ere */
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 NAPI_GRO_CB(skb)->free =3D NAPI_GRO_FREE_STO=
LEN_HEAD;
>> > + =A0 =A0 =A0 =A0 =A0 goto done;
>> > =A0 =A0 } else if (skb_gro_len(p) !=3D pinfo->gso_size)
>> > =A0 =A0 =A0 =A0 =A0 =A0 return -E2BIG;
>> >
>> >
>> >
>> Maybe I missed something, but shouldn't you be checking skb->cloned,=
 and
>> skb_shinfo()->dataref before you can consider just dropping the
>> sk_buff? =A0It seems like if you are sharing the frag with a clone y=
ou
>> would have to retain the skb->head so that you can track the dataref=
=2E
>> Otherwise you will likely cause issues because the stack could end u=
p
>> freeing the sk_buff, or the GRO frame will be capable of calling
>> put_page and freeing the page out from under the clone.
>>
>
> Is it a general question, or specific to this patch ?
>
> If its a general problem, we already check dataref where appropriate.
> Fact that skb->head is a kmalloc() or frag doesnt matter.
>
> If specific to GRO, see my first answer. GRO owns each skb.
>
> adding a BUG() would make no sense here.

The question I had was more specific to GRO.  As long as we have
skb->users =3D=3D 1 and the skb isn't cloned we should be fine.   It ju=
st
hadn't occurred to me before that napi_gro_receive had the extra
requirement that the skb couldn't be cloned.

Thanks,

Alex
