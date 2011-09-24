From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: BUG_ON -> WARN_ON in tcp_fragment
Date: Fri, 23 Sep 2011 17:43:18 -0700
Message-ID: <CAB_+Fg7ATpMVRd-yRtATzdYKwzbCvBdOxD8UvTa=Pj74ErzgjA@mail.gmail.com>
References: <CAB_+Fg6jv7uqFo7+fjPT1j3TL01rftmxRM1v2oP40sbX8puwyQ@mail.gmail.com>
	<alpine.DEB.2.00.1109231032450.28649@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:56912 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab1IXAnV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 20:43:21 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p8O0hKDd010602
	for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 17:43:20 -0700
Received: from ywf9 (ywf9.prod.google.com [10.192.6.9])
	by wpaz29.hot.corp.google.com with ESMTP id p8O0hJjp003164
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 17:43:19 -0700
Received: by ywf9 with SMTP id 9so3709558ywf.36
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2011 17:43:19 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1109231032450.28649@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+netdev
Thanks, Ilpo.

On Fri, Sep 23, 2011 at 1:01 AM, Ilpo J=E4rvinen
<ilpo.jarvinen@helsinki.fi> wrote:
>
> On Thu, 22 Sep 2011, Nandita Dukkipati wrote:
>
> > I am observing several instances hitting the BUG_ON(len > skb->len)=
 in
> > tcp_fragment on older kernels.=A0The function passing incorrect arg=
uments is
> > tcp_mark_head_lost. I saw your patch changing BUG_ON to WARN_ON in =
this
> > patch. That's a good change, however I am trying to put in some amo=
unt of
> > debugging information to get to the root cause.
>
> Right, that change won't cure the cause. I was able to determine that=
 some
> invariant must be violated to trigger this. However, the lack of
> information about the state of variables in tcp_mark_head_lost preven=
ted
> me known exactly what is wrong (not to speak of from where the proble=
m
> originates, I certainly tried to read some other code too but so far
> I've not been able to figure it out). I never remembered to do the de=
bug
> patch while I would have had time (and I'm sitting at the computer).
>
> > Given that (packets - oldcnt) < tcp_skb_pcount, it should follow th=
at
> > (packets - oldcnt) * mss < skb->len.
> >
> > 1)=A0Is it possible that the skb has multiple small packets each sm=
aller than
> > mss, in which case we shouldn't expect the above relation to hold?
>
> It should not happen because we recalculate on each retransmission us=
ing
> effective MSS. SACK block combines skbs but should only do that for
> S-bit'ed skbs requiring reneging at minimum to get them flying again =
and
> still they're retransmitted through with the same eff MSS check being
> done. However, I've seen some indications that there could be some bu=
g in
> this as some drivers had to circumvent for the case of very small
> MSS'ed super skb (pcount > 1) because some hardware fails to handle t=
hat.
> I've no idea how such segments can be constructed atm but it certainl=
y
> seems that you might be on the right tracks.
>
> If you're seeing them it would be easy to do sanity checks in
> tcp_mark_head_lost instead of tcp_fragment and trigger printouts with=
 more
> verbose information. However, it might not solve the quest for the ca=
use
> as this might only be symptom but certainly is still a good initial s=
tep.
>
> > If not, then it appears to be one of the two cases -
> > 2) mss updated in the midst of recovery (path mtu discovery?), with=
out
> > corresponding updates of skb->gso_segs or skb-?gso_size?
>
> This is not relevant, as mss is stored into skb and we fetch it from
> there: mss =3D skb_shinfo(skb)->gso_size. All such mss changes only a=
ffect
> newly generated stuff.
>
> > 3) skb->len is inaccurately updated st some point.
>
> This is another possibility. But due to the other bug report I'm more
> inclined towards the first option. Also, I think this would lead to s=
ome
> noisy truesize inconsitency but I'm not the expert in those calculati=
ons
> :-D.
>
> > Your thoughts on which of these is a plausible scenario (or somethi=
ng other
> > than these!) would be great.
>
> Some pcount/cnt_hint misvalue might also explain something.
>
> --
> =A0i.
