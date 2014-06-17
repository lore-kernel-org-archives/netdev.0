From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on
 retransmit window
Date: Mon, 16 Jun 2014 17:25:30 -0700
Message-ID: <CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com>
 <20140616211954.6E12BA3A89@unicorn.suse.cz> <CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com>
 <CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michal Kubecek <mkubecek@suse.cz>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:47859 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbaFQA0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 20:26:11 -0400
Received: by mail-ie0-f169.google.com with SMTP id at1so5771585iec.0
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 17:26:10 -0700 (PDT)
In-Reply-To: <CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 4:42 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Mon, Jun 16, 2014 at 6:39 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> On Mon, Jun 16, 2014 at 2:19 PM, Michal Kubecek <mkubecek@suse.cz> wrote:
>>> RFC 5681 says that ssthresh reduction in response to RTO should
>>> be done only once and should not be repeated until all packets
>>> from the first loss are retransmitted. RFC 6582 (as well as its
>>> predecessor RFC 3782) is even more specific and says that when
>>> loss is detected, one should mark current SND.NXT and ssthresh
>>> shouldn't be reduced again due to a loss until SND.UNA reaches
>>> this remembered value.
>>>
>>> In Linux implementation, this is done in tcp_enter_loss() but an
>>> additional condition
>>>
>>>   (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)
>>>
>>> allows to further reduce ssthresh before snd_una reaches the
>>> high_seq (the snd_nxt value at the previous loss) as
>>> icsk_retransmits is reset as soon as snd_una moves forward. As a
>>> result, if a retransmit timeout ouccurs early in the retransmit
>>> phase, we can adjust snd_ssthresh based on very low value of
>>> cwnd. This can be especially harmful for reno congestion control
>>> with slow linear cwnd growth in congestion avoidance phase.
>>>
>>> The patch removes the condition above so that snd_ssthresh is
>>> not reduced again until snd_una reaches high_seq as described in
>>> RFC 5681 and 6582.
>>>
>>> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
>
> AFAICT this commit description is arguing from a mis-reading of the
> RFCs.
>
> RFC 6582 and RFC 3782 are only about Fast Recovery, and not relevant
> to the timeout recovery we're dealing with in tcp_enter_loss().
>
> RFC 5681, Section 4.3 says:
>
>    Loss in two successive windows of data, or the loss of a
>    retransmission, should be taken as two indications of congestion and,
>    therefore, cwnd (and ssthresh) MUST be lowered twice in this case.
>
> So if we're in TCP_CA_Loss snd_una advances (FLAG_DATA_ACKED is set
> and icsk_retransmits is zero), but snd_una does not advance above
> high_seq, then if we subsequently suffer an RTO (and call
> tcp_enter_loss()) then that indicates a retransmission is lost, which
> this passage from sec 4.3 indicates should be taken as a second
> indication of congestion.
That's right. I should have checked the RFC more thoroughly. Sorry
please ignore my Acked-by.

However Linux is inconsistent on the loss of a retransmission. It
reduces ssthresh (and cwnd) if this happens on a timeout, but not in
fast recovery (tcp_mark_lost_retrans). We should fix that and that
should help dealing with traffic policers.


>
>> - (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
>
> AFAICT this existing code is a faithful implementation of, RFC 5681,
> Section 7:
>
>    The treatment of ssthresh on retransmission timeout was clarified.
>    In particular, ssthresh must be set to half the FlightSize on the
>    first retransmission of a given segment and then is held constant on
>    subsequent retransmissions of the same segment.
>
> That is, if snd_una advances (FLAG_DATA_ACKED is set and
> icsk_retransmits is zero), if we subsequently suffer an RTO and call
> tcp_enter_loss() then we will be sending a "first retransmission" at
> the segment pointed to by the new/higher snd_una. So this is the first
> retransmission of that new segment, so we should reduce ssthresh.
>
> And from first principles, the current Linux code and RFCs seem
> sensible on this matter, AFAICT. Suppose we suffer an RTO, and then
> over the following RTTs in TCP_CA_Loss we grow cwnd exponentially
> again. If we suffer another RTO in this cwnd growth process, then it
> seems like a good idea to remember the reduced ssthresh inferred from
> this smaller cwnd at which we suffered a loss.
>
> So AFAICT the existing code is sensible and complies with the RFC.
>
> Now, I agree the linear growth of Reno in such situations is
> problematic, but I think it's a somewhat separate issue. Or at least
> if we're going to change the behavior here then we should justify it
> by using data, and not by reference to RFCs. :-)
>
> neal
