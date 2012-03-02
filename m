From: Neal Cardwell <ncardwell@google.com>
Subject: Re: tcp: skb_shift() issues w.r.t. SACK processing
Date: Fri, 2 Mar 2012 16:57:30 -0500
Message-ID: <CADVnQym2VS1Ju=_jnGsR6q-PqKwkasfKjzO4=KLqxe00OA_eBw@mail.gmail.com>
References: <CAGK4HS-XSmQqhUz_eVSjnZPAxLJwrpB+u6GTL87j=S7+N9dyNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, ilpo.jarvinen@helsinki.fi
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:57718 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757322Ab2CBV5b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 16:57:31 -0500
Received: by qadc11 with SMTP id c11so44598qad.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 13:57:30 -0800 (PST)
In-Reply-To: <CAGK4HS-XSmQqhUz_eVSjnZPAxLJwrpB+u6GTL87j=S7+N9dyNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 1, 2012 at 4:36 PM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> Hi,
>
> I was looking at the skb_shift() function that is called by
> tcp_shift_skb_data() to shift bytes from a skb to the previous skb.
> This is used to collapse multiple
> SACK blocks into a single skb. I noticed the following two things.
>
> 1: skb_shift() has the following snippet.
> =A0if (!to ||
> =A0 =A0 =A0 =A0 =A0 =A0!skb_can_coalesce(tgt, to, skb_frag_page(fragf=
rom),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fragfrom->=
page_offset)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0merge =3D -1;
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0merge =3D to - 1;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0todo -=3D skb_frag_size(fragfrom);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (todo < 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb_prepare_for_sh=
ift(skb) ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_prepare_fo=
r_shift(tgt))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 0;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* All previous frag p=
ointers might be stale! */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fragfrom =3D &skb_shin=
fo(skb)->frags[from];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fragto =3D &skb_shinfo=
(tgt)->frags[merge];
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_frag_size_add(frag=
to, shiftlen);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_frag_size_sub(frag=
from, shiftlen);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fragfrom->page_offset =
+=3D shiftlen;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto onlymerged;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0from++;
> =A0 =A0 =A0 =A0}
>
> The (todo < 0) part is executed when we need to copy less than
> skb_frag_size(fragfrom). Essentially, after the bytes have been
> shifted, the frag in the original skb will still retain some data.
> However, unless I am reading this wrong, the bytes are actually never
> shifted. The frag offsets and size are updated and then we jump to
> label onlymerged which =A0updates other counters.
> It looks like the data will be lost since it is in neither skb. This
> may not matter in normal case since this data has been SACKed by
> receiver and will be discarded after cumulative ack.
> But in case of receiver SACK reneging, this data may potentially be
> resent. A similar case later in the function is treated correctly wit=
h
> the data actually getting copied.

I think skb_shift() is actually OK in this regard. The code in
question is guarded by a call to skb_can_coalesce(), which ensures
that the source and destination fragments are actually from the same
page, and are adjacent within the page. So in this case, the code
seems correct in its assumption that all we need to do is increment
the size of the destination fragment and decrement the size of the
source fragment.

neal

ps: I haven't looked into your second question.
