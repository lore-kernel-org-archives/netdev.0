From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 0/8] add TX timestamping via cmsg
Date: Sun, 3 Apr 2016 18:45:56 -0400
Message-ID: <CAF=yD-K9RGiqPJHjgyGx8DVM1mPRATq3-WMZhCBzeeaOwYNPYw@mail.gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
 <20160331003744.GA3300@kafai-mba.local> <CADAM+B1osNNwVpg1R_kAFW8m75mr15_usDa=gmqpBA+xwyA_fg@mail.gmail.com>
 <CAF=yD-Lpx2nBq1bL64-pzOqHh5E-a4Bbr2goDE59ApWvzFri_Q@mail.gmail.com> <20160331215207.GA10007@Shashi-FB-iPhone-6.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	Network Development <netdev@vger.kernel.org>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:33523 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbcDCWqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 18:46:37 -0400
Received: by mail-lb0-f194.google.com with SMTP id bc4so18818195lbc.0
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 15:46:36 -0700 (PDT)
In-Reply-To: <20160331215207.GA10007@Shashi-FB-iPhone-6.DHCP.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> This does not yet solve the append issue that your MSG_EOR patch
>> addresses, of course.
> Yes.  I have been thinking about both approaches.
>
>>
>> The straightforward jump to new_segment that I proposed as
>> simplification is more properly a "start-of-record" than
>> "end-of-record" signal. It is probably preferable to indeed be able to
>> pass EOR as signal that the last skb must not be appended to in
>> subsequent calls.
> I suspect we could do better than only checking MSG_EOR and jump.
> Before entering the loop, we may be able to check if the
> last-not-yet-written out skb has tskey set and the current
> tcp_sendmsg may need to overwrite it before jumping.

Yes, that would be better, if it is conditional on the tskey having
been set by a sendmsg call that also had MSG_EOR.

> Also, the 2nd sendmsg may not be called with MSG_EOR set but
> the per-write-knob is turned on.  It could overwrite the
> 1st sendmsg with both per-write-knob on and MSG_EOR set.
>
> Note that there is another collapse-case during tcp retrans
> where the MSG_EOR bit is already loss.
>
> Hence, having EOR passed as signal (as you mentioned) and stored
> is needed.
>
> I think another bit in the TCP_SKB_CB may help here.
> The semantic of this bit could be 'no skb merge under some rare conditions'.
> For now, it is limited to tskey.

Agreed.

> [Another side note is, the split/fragment case should be fine as it is.
>  When splitting a skb into two smaller skbs, the tskey should fall
>  into either of them and no information loss.]
>
>> I think that the record bounds issue is best solved independently from
>> the interface for intermittent timestamps because
> I understand that users may want to selectively do timestamping on a
> particular sendmsg (per-write-knob), while do not care if the tskey
> will be overwritten (no-tskey-overwritten) by the future
> sendmsg/retrans.  Separating them gives the end-user a choice.
>
> On the other hand, if the caller has specifically asked to do tstamp in
> a particular tcp_sendmsg, it is a strong intention that the caller wants to
> specifically track this message alone and not expecting this tstmap to
> include anything else sent after it.
>
> Beside, TLS user needs to make more
> effort to pass the per-write-knob to tcp_sendmsg.  Hence, when per-write-knob
> is used, I think the no-tskey-overwritten should be at least allowed

Absolutely.
