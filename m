From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: Re: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection close
 threshold as a time value.
Date: Wed, 06 Jun 2012 22:35:58 +0200
Message-ID: <1339014958.4294.2.camel@nexus>
References: <4A950B82.1070807@tvk.rwth-aachen.de>
 <CAFbMe2Mu46N8kRrYkGzYRLuntEd2J9aO_d0Jw_y0gsQA4q-qHw@mail.gmail.com>
 <CAPshTCiFDUb3CVm-joJW_DRVS+C+_BjFO-Mt3uAwrCzVw8MsVg@mail.gmail.com>
 <1338832247.5299.4.camel@nexus>
 <CAPshTChwnEaMTOsofFDP0ZY8U3VCP2ZrtXjdhKG03rRsx7kryA@mail.gmail.com>
 <CAPshTCg8W0QxubvO_dWBsSOqvCEdBSWLKv3cNOvn=VbyqHA1zg@mail.gmail.com>
 <1338921588.17263.6.camel@nexus>
 <CAPshTCjEkyLg+BdYvA3vW4C92rAyfuC_mVEDgrbRz4NDyGh9Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.rwth-aachen.de ([134.130.7.73]:37434 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758179Ab2FFUgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 16:36:04 -0400
Received: from mx-out-1.rwth-aachen.de ([134.130.5.186])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0M5700ASGQJZSEI0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 06 Jun 2012 22:35:59 +0200 (CEST)
Received: from [192.168.0.131] ([unknown] [178.203.192.189])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0M57000LGQJY1V00@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Wed, 06 Jun 2012 22:35:59 +0200 (CEST)
In-reply-to: <CAPshTCjEkyLg+BdYvA3vW4C92rAyfuC_mVEDgrbRz4NDyGh9Ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, den 05.06.2012, 14:22 -0700 schrieb Jerry Chu:
> On Tue, Jun 5, 2012 at 11:39 AM, Damian Lukowski
> <damian@tvk.rwth-aachen.de> wrote:
> > Am Dienstag, den 05.06.2012, 10:42 -0700 schrieb Jerry Chu:
> >> On Mon, Jun 4, 2012 at 4:50 PM, Jerry Chu <hkchu@google.com> wrote:
> >> > Hi Damian,
> >> >
> >> > On Mon, Jun 4, 2012 at 10:50 AM, Damian Lukowski
> >> > <damian@tvk.rwth-aachen.de> wrote:
> >> >> Hi Jerry,
> >> >>
> >> >> please verify, I understood you correctly.
> >> >>
> >> >> You have set TCP_RTO_MIN to a lower value, e.g. 0.002 seconds to improve
> >> >> your internal low-latency traffic. Because of the improvement, R1
> >> >> timeouts are triggered too fast for external high-RTT traffic. Is that
> >> >> correct?
> >> >
> >> > Correct.
> >> >
> >> >> If so, may I suggest to set tcp_retries1 to a higher value? For
> >> >> TCP_RTO_MIN == 0.002 and tcp_retries1 ==  10, R1 will be calculated to
> >> >> approximately 4 seconds.
> >> >
> >> > I think hacking tcp_retries1 is the wrong solution. E.g., 10 retries may be too
> >> > generous for those short RTT flows.
> >> >
> >> > I think the fundamental problem is - the ideal fix for your original RTO revert
> >> > problem should've used the per-flow RTO to compute R1 & R2. But that
> >> > computation may be too expensive so you used TCP_RTO_MIN as an
> >> > approximation - not a good idea IMHO!
> >>
> >> Just realized the correct fix of using the original, non-backoff per flow RTO is
> >> not any more expensive than the current code through ilog2(). What's needed
> >> is a new field "base_rto" to record the original RTO before backoff. I'm leaning
> >> toward this more accurate fix now without any fudge because fudging almost
> >> always causes bugs.
> >
> >
> > The current version of retransmits_timed_out() uses such a field
> > already. I suppose, we can do a combination like the following?
> >
> > -       unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
> > +       unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : __tcp_set_rto(tcp_sk(sk));
> 
> Yes that could work and we probably don't need a new field for the original RTO.
> 
> But I started wondering what the problem you tried to solve initially. The old
> counter (icsk_retransmits) based code was really easy to understand, debug, and
> matched well with the API (sysctl_tcp_retries1, sysctl_tcp_retries2,
> TCP_SYNCNT,...), which are all counter based. Moreover, my simple brain has
> a strong prejudice against complex code unless the complexity is justified.
> 
> Could you point out where backoff revert might happen? (tcp_v4_err() when
> handing ICMP errors?) And for those cases is it possible to either not increment
> icsk_retransmits (as long as it won't get us into infinite
> retransmissions), or invent
> a separate field for the sole purpose of timeout check? Won't that be
> much simpler than your current fix?

Hi,

backoffs are reverted when an RTO retransmission triggers an ICMP
destination unreachable along the path towards the target.
Consider A --- R --- B, where A and B are TCP endpoints, and R is some
router in between. When the link between R and B breaks for a longer
time, A will perform RTO retransmissions if there are outstanding ACKs.
Those packets which arrive at R will hopefully trigger an ICMP response
back towards A, as R has no more route towards B. The ICMP packet is an
indication for A, that the retransmission has not been lost because of
congestion but because of a link outage, and the backoff will be
reverted for the corresponding TCP session. In the best case, every RTO
retransmission triggers an ICMP response, so every backoff is reverted,
and the time between retransmissions remains at the original value.
If icsk_retransmits is decremented at this point within the original
code's logic, the connection might never time out. And we cannot take
tcp_retriesX literally here, as the above scenario would time out after
tcp_retries2 x base_rto, where the base_rto might be as small as 0.2
seconds.

I am not sure, how an additional counter variable should help. You still
cannot take tcp_retriesX literally. Besides, I think that changing the
socket structure is too heavy machinery, isn't it?

Regards
 Damian

> 
> Best,
> 
> Jerry
> 
> > +       rto_base = rto_base ? : TCP_RTO_MIN;
> >
> > -       if (!inet_csk(sk)->icsk_retransmits)
> > +       if (inet_csk(sk)->icsk_retransmits < boundary)
> >
> >
> > Regards
> >  Damian
> >
> >>
> >> Any comment is welcome. I'm not sure in the existing code if it makes sense
> >> to apply the exponential backoff based computation to thin stream but it's a
> >> separate question so I won't touch it.
> >>
> >> Jerry
> >>
> >> >
> >> > The easiest solution I can see so far is to replace the check
> >> >
> >> > if (!inet_csk(sk)->icsk_retransmits)
> >> >                return false;
> >> >
> >> > at the beginning of retransmits_timed_out() with
> >> >
> >> > if (inet_csk(sk)->icsk_retransmits < boundary)
> >> >                return false;
> >> >
> >> > Best,
> >> >
> >> > Jerry
> >> >
> >> >>
> >> >> Is that ok?
> >> >>
> >> >> Best regards
> >> >>  Damian
> >> >>
> >> >> Am Freitag, den 01.06.2012, 15:58 -0700 schrieb Jerry Chu:
> >> >>> > From: Damian Lukowski <damian@tvk.rwth-aachen.de>
> >> >>> > Date: Wed, Aug 26, 2009 at 3:16 AM
> >> >>> > Subject: [PATCH 3/3] Revert Backoff [v3]: Calculate TCP's connection close
> >> >>> > threshold as a time value.
> >> >>> > To: Netdev <netdev@vger.kernel.org>
> >> >>> >
> >> >>> >
> >> >>> > RFC 1122 specifies two threshold values R1 and R2 for connection timeouts,
> >> >>> > which may represent a number of allowed retransmissions or a timeout value.
> >> >>> > Currently linux uses sysctl_tcp_retries{1,2} to specify the thresholds
> >> >>> > in number of allowed retransmissions.
> >> >>> >
> >> >>> > For any desired threshold R2 (by means of time) one can specify tcp_retries2
> >> >>> > (by means of number of retransmissions) such that TCP will not time out
> >> >>> > earlier than R2. This is the case, because the RTO schedule follows a fixed
> >> >>> > pattern, namely exponential backoff.
> >> >>> >
> >> >>> > However, the RTO behaviour is not predictable any more if RTO backoffs can
> >> >>> > be
> >> >>> > reverted, as it is the case in the draft
> >> >>> > "Make TCP more Robust to Long Connectivity Disruptions"
> >> >>> > (http://tools.ietf.org/html/draft-zimmermann-tcp-lcd).
> >> >>> >
> >> >>> > In the worst case TCP would time out a connection after 3.2 seconds, if the
> >> >>> > initial RTO equaled MIN_RTO and each backoff has been reverted.
> >> >>> >
> >> >>> > This patch introduces a function retransmits_timed_out(N),
> >> >>> > which calculates the timeout of a TCP connection, assuming an initial
> >> >>> > RTO of MIN_RTO and N unsuccessful, exponentially backed-off retransmissions.
> >> >>> >
> >> >>> > Whenever timeout decisions are made by comparing the retransmission counter
> >> >>> > to some value N, this function can be used, instead.
> >> >>> >
> >> >>> > The meaning of tcp_retries2 will be changed, as many more RTO
> >> >>> > retransmissions
> >> >>> > can occur than the value indicates. However, it yields a timeout which is
> >> >>> > similar to the one of an unpatched, exponentially backing off TCP in the
> >> >>> > same
> >> >>> > scenario. As no application could rely on an RTO greater than MIN_RTO, there
> >> >>> > should be no risk of a regression.
> >> >>>
> >> >>> This looks like a typical "fix one problem, introducing a few more" patch :(.
> >> >>> What do you mean by "no application could rely on an RTO greater than
> >> >>> MIN_RTO..."
> >> >>> above? How can you make the assumption that RTO is not too far off
> >> >>> from TCP_RTO_MIN?
> >> >>>
> >> >>> While you tried to address a problem where the retransmission count
> >> >>> was high but the actual
> >> >>> timeout duration was too short, have you considered the other case
> >> >>> around, i.e., the timeout
> >> >>> duration is long but the retransmission count is too short? This is
> >> >>> exactly what's happening
> >> >>> to us with your patch. We've much reduced TCP_RTO_MIN for our internal
> >> >>> traffic, but not
> >> >>> noticing your change has severely shortened the R1 & R2 recommended by
> >> >>> RFC1122 for our
> >> >>> long haul traffic until now. In many cases R1 threshold was met upon
> >> >>> the first retrans timeout.
> >> >>>
> >> >>> I think retransmits_timed_out() should check against both time
> >> >>> duration and retrans count
> >> >>> (icsk_retransmits).
> >> >>>
> >> >>> Thought?
> >> >>>
> >> >>> Jerry
> >> >>>
> >> >>> >
> >> >>> > Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> >> >>> > ---
> >> >>> >  include/net/tcp.h    |   18 ++++++++++++++++++
> >> >>> >  net/ipv4/tcp_timer.c |   11 +++++++----
> >> >>> >  2 files changed, 25 insertions(+), 4 deletions(-)
> >> >>> >
> >> >>> > diff --git a/include/net/tcp.h b/include/net/tcp.h
> >> >>> > index c35b329..17d1a88 100644
> >> >>> > --- a/include/net/tcp.h
> >> >>> > +++ b/include/net/tcp.h
> >> >>> > @@ -1247,6 +1247,24 @@ static inline struct sk_buff
> >> >>> > *tcp_write_queue_prev(struct sock *sk, struct sk_bu
> >> >>> >  #define tcp_for_write_queue_from_safe(skb, tmp, sk)                    \
> >> >>> >        skb_queue_walk_from_safe(&(sk)->sk_write_queue, skb, tmp)
> >> >>> >
> >> >>> > +static inline bool retransmits_timed_out(const struct sock *sk,
> >> >>> > +                                        unsigned int boundary)
> >> >>> > +{
> >> >>> > +       int limit, K;
> >> >>> > +       if (!inet_csk(sk)->icsk_retransmits)
> >> >>> > +               return false;
> >> >>> > +
> >> >>> > +       K = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
> >> >>> > +
> >> >>> > +       if (boundary <= K)
> >> >>> > +               limit = ((2 << boundary) - 1) * TCP_RTO_MIN;
> >> >>> > +       else
> >> >>> > +               limit = ((2 << K) - 1) * TCP_RTO_MIN +
> >> >>> > +                       (boundary - K) * TCP_RTO_MAX;
> >> >>> > +
> >> >>> > +       return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= limit;
> >> >>> > +}
> >> >>> > +
> >> >>> >  static inline struct sk_buff *tcp_send_head(struct sock *sk)
> >> >>> >  {
> >> >>> >        return sk->sk_send_head;
> >> >>> > diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> >> >>> > index a3ba494..2972d7b 100644
> >> >>> > --- a/net/ipv4/tcp_timer.c
> >> >>> > +++ b/net/ipv4/tcp_timer.c
> >> >>> > @@ -137,13 +137,14 @@ static int tcp_write_timeout(struct sock *sk)
> >> >>> >  {
> >> >>> >        struct inet_connection_sock *icsk = inet_csk(sk);
> >> >>> >        int retry_until;
> >> >>> > +       bool do_reset;
> >> >>> >
> >> >>> >        if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
> >> >>> >                if (icsk->icsk_retransmits)
> >> >>> >                        dst_negative_advice(&sk->sk_dst_cache);
> >> >>> >                retry_until = icsk->icsk_syn_retries ? :
> >> >>> > sysctl_tcp_syn_retries;
> >> >>> >        } else {
> >> >>> > -               if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
> >> >>> > +               if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
> >> >>> >                        /* Black hole detection */
> >> >>> >                        tcp_mtu_probing(icsk, sk);
> >> >>> >
> >> >>> > @@ -155,13 +156,15 @@ static int tcp_write_timeout(struct sock *sk)
> >> >>> >                        const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
> >> >>> >
> >> >>> >                        retry_until = tcp_orphan_retries(sk, alive);
> >> >>> > +                       do_reset = alive ||
> >> >>> > +                                  !retransmits_timed_out(sk, retry_until);
> >> >>> >
> >> >>> > -                       if (tcp_out_of_resources(sk, alive ||
> >> >>> > icsk->icsk_retransmits < retry_until))
> >> >>> > +                       if (tcp_out_of_resources(sk, do_reset))
> >> >>> >                                return 1;
> >> >>> >                }
> >> >>> >        }
> >> >>> >
> >> >>> > -       if (icsk->icsk_retransmits >= retry_until) {
> >> >>> > +       if (retransmits_timed_out(sk, retry_until)) {
> >> >>> >                /* Has it gone just too far? */
> >> >>> >                tcp_write_err(sk);
> >> >>> >                return 1;
> >> >>> > @@ -385,7 +388,7 @@ void tcp_retransmit_timer(struct sock *sk)
> >> >>> >  out_reset_timer:
> >> >>> >        icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
> >> >>> >        inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto,
> >> >>> > TCP_RTO_MAX);
> >> >>> > -       if (icsk->icsk_retransmits > sysctl_tcp_retries1)
> >> >>> > +       if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
> >> >>> >                __sk_dst_reset(sk);
> >> >>> >
> >> >>> >  out:;
> >> >>> > --
> >> >>> > 1.6.3.3
> >> >>> >
> >> >>> > --
> >> >>> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> >>> > the body of a message to majordomo@vger.kernel.org
> >> >>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> >>> >
> >> >>
> >> >>
> >
> >
