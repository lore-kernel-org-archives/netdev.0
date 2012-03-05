From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp: skb_shift() issues w.r.t. SACK processing
Date: Mon, 5 Mar 2012 12:42:37 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1203051136150.2966@wel-95.cs.helsinki.fi>
References: <CAGK4HS-XSmQqhUz_eVSjnZPAxLJwrpB+u6GTL87j=S7+N9dyNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1341356009-1330941126=:2966"
Cc: netdev <netdev@vger.kernel.org>, ncardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42530 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756472Ab2CEKmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 05:42:39 -0500
In-Reply-To: <CAGK4HS-XSmQqhUz_eVSjnZPAxLJwrpB+u6GTL87j=S7+N9dyNg@mail.gmail.com>
Content-ID: <alpine.DEB.2.00.1203051203530.2966@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1341356009-1330941126=:2966
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1203051152381.2966@wel-95.cs.helsinki.fi>

On Thu, 1 Mar 2012, Vijay Subramanian wrote:

> [...snip...]
> 
> The (todo < 0) part is executed when we need to copy less than
> skb_frag_size(fragfrom). Essentially, after the bytes have been
> shifted, the frag in the original skb will still retain some data.
> However, unless I am reading this wrong, the bytes are actually never
> shifted. The frag offsets and size are updated and then we jump to
> label onlymerged which  updates other counters.
> It looks like the data will be lost since it is in neither skb. This
> may not matter in normal case since this data has been SACKed by
> receiver and will be discarded after cumulative ack.
> But in case of receiver SACK reneging, this data may potentially be
> resent. A similar case later in the function is treated correctly with
> the data actually getting copied.

Like Neal already mentioned, the data is moved before goto. Thanks anyway 
for staring at it for a while and bringing up your suspicions.

> 2: The reason I  was looking at skb_shift() was to understand why some
> SACKed skbs were not getting collapsed into the previous skbs by
> tcp_shift_skb_data(). This function has the following check.
> if (!skb_can_shift(skb))
>                goto fallback;
> which fails if skb has data in linear part.
> 
> Currently skb_shift() does not shift bytes if there is data in linear
> part. From skb_shift()
> BUG_ON(skb_headlen(skb));       /* Would corrupt stream */
> 
> commit f07d960df3 (tcp: avoid frag allocation for small frames) made
> it possible for skb to have data in linear part. Such skbs will not be
> collapsed into the previous skb. This is not a bug but this behavior
> prevents some savings by not allowing collapse of SACKed skbs. Can
> anyone clarify why shifting bytes from linear part would corrupt the
> stream in current code?

Linear to linear part is legal only if tgt has no frags, back then frags 
were basically always there when GSO was enabled. The current skb_shift 
only deals (linear+)frags+frags copying, whereas linear+frags+linear+frags 
is unrepresentable afaict with the current skbuff structures. ...The 
corruption would happen if frags would be moved past a linear part.

> Does it make sense to remove this constraint after commit f07d960df3?

Pure linear to linear is probably not going to gain much as two of them 
won't fit anyway to (2048 - MAX_TCP_HEADER - x) with the default mss. And 
if one would be sending smaller than mss, imho that's where the problem 
lies, not in the recombining logic :-). But of course it would be 
technically possible to include also combining for pure linear to linear 
if there's enough linear space in the tgt but I doubt that the benefits 
are large enough to be worth the effort. Or do you have some particular 
case with measurable %?

I suppose the select_size logic could somehow depend on the size sendmsg 
is going to process though.

I've added Eric as Cc if he has some insights on this, it seems like 
trade-off here.


-- 
 i.
--8323329-1341356009-1330941126=:2966--
