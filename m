From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 0/8] add TX timestamping via cmsg
Date: Thu, 31 Mar 2016 14:57:57 -0700
Message-ID: <20160331215207.GA10007@Shashi-FB-iPhone-6.DHCP.thefacebook.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
 <20160331003744.GA3300@kafai-mba.local>
 <CADAM+B1osNNwVpg1R_kAFW8m75mr15_usDa=gmqpBA+xwyA_fg@mail.gmail.com>
 <CAF=yD-Lpx2nBq1bL64-pzOqHh5E-a4Bbr2goDE59ApWvzFri_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:47045 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751933AbcCaV6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 17:58:34 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-Lpx2nBq1bL64-pzOqHh5E-a4Bbr2goDE59ApWvzFri_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 11:50:31PM -0400, Willem de Bruijn wrote:
> >> Nice patches!
>
> This does not yet solve the append issue that your MSG_EOR patch
> addresses, of course.
Yes.  I have been thinking about both approaches.

>
> The straightforward jump to new_segment that I proposed as
> simplification is more properly a "start-of-record" than
> "end-of-record" signal. It is probably preferable to indeed be able to
> pass EOR as signal that the last skb must not be appended to in
> subsequent calls.
I suspect we could do better than only checking MSG_EOR and jump.
Before entering the loop, we may be able to check if the
last-not-yet-written out skb has tskey set and the current
tcp_sendmsg may need to overwrite it before jumping.

Also, the 2nd sendmsg may not be called with MSG_EOR set but
the per-write-knob is turned on.  It could overwrite the
1st sendmsg with both per-write-knob on and MSG_EOR set.

Note that there is another collapse-case during tcp retrans
where the MSG_EOR bit is already loss.

Hence, having EOR passed as signal (as you mentioned) and stored
is needed.

I think another bit in the TCP_SKB_CB may help here.
The semantic of this bit could be 'no skb merge under some rare conditions'.
For now, it is limited to tskey.

[Another side note is, the split/fragment case should be fine as it is.
 When splitting a skb into two smaller skbs, the tskey should fall
 into either of them and no information loss.]

> I think that the record bounds issue is best solved independently from
> the interface for intermittent timestamps because
I understand that users may want to selectively do timestamping on a
particular sendmsg (per-write-knob), while do not care if the tskey
will be overwritten (no-tskey-overwritten) by the future
sendmsg/retrans.  Separating them gives the end-user a choice.

On the other hand, if the caller has specifically asked to do tstamp in
a particular tcp_sendmsg, it is a strong intention that the caller wants to
specifically track this message alone and not expecting this tstmap to
include anything else sent after it.  Beside, TLS user needs to make more
effort to pass the per-write-knob to tcp_sendmsg.  Hence, when per-write-knob
is used, I think the no-tskey-overwritten should be at least allowed (if
not the default).

> (a) changing the tcp
> bytestream packetization for timestamping introduces subtle
> differences between tracked and untracked data that are not always
> acceptable and (b) EOR can also be useful outside timestamps. A
> zerocopy sendmsg patchset that I sent for RFC last year encountered a
> similar requirement, to give one example: each skb with user data must
> point to a completion notification structure (ubuf_info), and can only
> point to one at a time. Appends that cause a conflict in skb->uarg
> pointers had to be blocked, at the cost of possibly different
> packetization compared to regular sends.
With no-tskey-overwritten turned on in production, we don't found the
end-user's performance has been impacted in meaningful way. I believe
it is the proper tradeoff as an opt-in feature to get measurement
data for existing tcp-socket users without adding a lot of burden
to the TCP stack which is a byte-oriented socket to begin with.
