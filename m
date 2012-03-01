From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: tcp: skb_shift() issues w.r.t. SACK processing
Date: Thu, 1 Mar 2012 13:36:20 -0800
Message-ID: <CAGK4HS-XSmQqhUz_eVSjnZPAxLJwrpB+u6GTL87j=S7+N9dyNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, ncardwell <ncardwell@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41057 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516Ab2CAVgV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2012 16:36:21 -0500
Received: by vbbff1 with SMTP id ff1so917363vbb.19
        for <netdev@vger.kernel.org>; Thu, 01 Mar 2012 13:36:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was looking at the skb_shift() function that is called by
tcp_shift_skb_data() to shift bytes from a skb to the previous skb.
This is used to collapse multiple
SACK blocks into a single skb. I noticed the following two things.

1: skb_shift() has the following snippet.
=A0if (!to ||
=A0 =A0 =A0 =A0 =A0 =A0!skb_can_coalesce(tgt, to, skb_frag_page(fragfro=
m),
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fragfrom->pa=
ge_offset)) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0merge =3D -1;
=A0 =A0 =A0 =A0} else {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0merge =3D to - 1;

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0todo -=3D skb_frag_size(fragfrom);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (todo < 0) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (skb_prepare_for_shif=
t(skb) ||
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_prepare_for_=
shift(tgt))
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0=
;

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* All previous frag poi=
nters might be stale! */
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fragfrom =3D &skb_shinfo=
(skb)->frags[from];
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fragto =3D &skb_shinfo(t=
gt)->frags[merge];

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_frag_size_add(fragto=
, shiftlen);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_frag_size_sub(fragfr=
om, shiftlen);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fragfrom->page_offset +=3D=
 shiftlen;

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto onlymerged;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0from++;
=A0 =A0 =A0 =A0}

The (todo < 0) part is executed when we need to copy less than
skb_frag_size(fragfrom). Essentially, after the bytes have been
shifted, the frag in the original skb will still retain some data.
However, unless I am reading this wrong, the bytes are actually never
shifted. The frag offsets and size are updated and then we jump to
label onlymerged which =A0updates other counters.
It looks like the data will be lost since it is in neither skb. This
may not matter in normal case since this data has been SACKed by
receiver and will be discarded after cumulative ack.
But in case of receiver SACK reneging, this data may potentially be
resent. A similar case later in the function is treated correctly with
the data actually getting copied.


2: The reason I =A0was looking at skb_shift() was to understand why som=
e
SACKed skbs were not getting collapsed into the previous skbs by
tcp_shift_skb_data(). This function has the following check.
if (!skb_can_shift(skb))
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto fallback;
which fails if skb has data in linear part.

Currently skb_shift() does not shift bytes if there is data in linear
part. From skb_shift()
BUG_ON(skb_headlen(skb)); =A0 =A0 =A0 /* Would corrupt stream */

commit f07d960df3 (tcp: avoid frag allocation for small frames) made
it possible for skb to have data in linear part. Such skbs will not be
collapsed into the previous skb. This is not a bug but this behavior
prevents some savings by not allowing collapse of SACKed skbs. Can
anyone clarify why shifting bytes from linear part would corrupt the
stream in current code? Does it make sense to remove this constraint
after
commit f07d960df3?

Thanks,
Vijay
