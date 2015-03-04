From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCHv4 net-next 3/3] ipv4: Create probe timer for tcp PMTU as
 per RFC4821
Date: Wed, 4 Mar 2015 08:26:52 -0500
Message-ID: <CABrhC0nO3E_kPGDGc1Rxe8d5nXQ0-EcX_DLRcZk4NOTqqZ7BPw@mail.gmail.com>
References: <1425374361-21047-1-git-send-email-fan.du@intel.com>
	<1425374361-21047-4-git-send-email-fan.du@intel.com>
	<CABrhC0nQcFSkAcMmnJ+fw0nhOGKiebEDnU4P9=nRsn=u16Lotw@mail.gmail.com>
	<54F669BE.7060706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:36860 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926AbbCDN0y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 08:26:54 -0500
Received: by lbiz11 with SMTP id z11so18193202lbi.3
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 05:26:52 -0800 (PST)
In-Reply-To: <54F669BE.7060706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 3, 2015 at 9:11 PM, Fan Du <fengyuleidian0615@gmail.com> wr=
ote:
> =E4=BA=8E 2015=E5=B9=B403=E6=9C=8804=E6=97=A5 00:39, John Heffner =E5=
=86=99=E9=81=93:
>
>> On Tue, Mar 3, 2015 at 4:19 AM, Fan Du <fan.du@intel.com> wrote:
>>>
>>> As per RFC4821 7.3.  Selecting Probe Size, a probe timer should
>>> be armed once probing has converged. Once this timer expired,
>>> probing again to take advantage of any path PMTU change. The
>>> recommended probing interval is 10 minutes per RFC1981. Probing
>>> interval could be sysctled by sysctl_tcp_probe_interval.
>>>
>>> Eric Dumazet suggested to implement pseudo timer based on 32bits
>>> jiffies tcp_time_stamp instead of using classic timer for such
>>> rare event.
>>>
>>> Signed-off-by: Fan Du <fan.du@intel.com>
>>
>>
>>> @@ -1823,6 +1825,31 @@ send_now:
>>>          return false;
>>>   }
>>>
>>> +static inline void tcp_mtu_check_reprobe(struct sock *sk)
>>> +{
>>> +       struct inet_connection_sock *icsk =3D inet_csk(sk);
>>> +       struct tcp_sock *tp =3D tcp_sk(sk);
>>> +       struct net *net =3D sock_net(sk);
>>> +       u32 interval;
>>> +       s32 delta;
>>> +
>>> +       interval =3D net->ipv4.sysctl_tcp_probe_interval;
>>> +       delta =3D tcp_time_stamp - icsk->icsk_mtup.probe_timestamp;
>>> +       if (unlikely(delta >=3D interval * HZ)) {
>>> +               int mss =3D tcp_current_mss(sk);
>>> +
>>> +               /* Update current search range */
>>> +               icsk->icsk_mtup.search_high =3D tp->rx_opt.mss_clam=
p +
>>> +                       sizeof(struct tcphdr) +
>>> +                       icsk->icsk_af_ops->net_header_len;
>>> +               icsk->icsk_mtup.search_low =3D tcp_mss_to_mtu(sk, m=
ss);
>>> +               icsk->icsk_mtup.probe_size =3D 0;
>>> +
>>> +               /* Update probe time stamp */
>>> +               icsk->icsk_mtup.probe_timestamp =3D tcp_time_stamp;
>>> +       }
>>> +}
>>> +
>>>   /* Create a new MTU probe if we are ready.
>>>    * MTU probe is regularly attempting to increase the path MTU by
>>>    * deliberately sending larger packets.  This discovers routing
>>
>>
>> I think the only update to the search range required here is
>> potentially moving search_high upward.  Touching search_low seems
>> unnecessary,
>
> No.
>
> If you restoring search_low to its original, the first probe will pro=
bably
> be no better than using current mss, because current mss is working g=
ood,
> there may be better mss between mtu(current mss) and search_high. Rep=
robing
> from search_low to search_high is definitely not worth the effort.

Set search_high to the maximal MSS.  The next probe will be halfway
between search_low and MSS.  There's no reason to reduce search_low
when the current MSS =3D=3D search_low.


>>> @@ -1866,8 +1893,11 @@ static int tcp_mtu_probe(struct sock *sk)
>>>          size_needed =3D probe_size + (tp->reordering + 1) * tp->ms=
s_cache;
>>>          interval =3D icsk->icsk_mtup.search_high -
>>> icsk->icsk_mtup.search_low;
>>>          if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search=
_high)
>>> ||
>>> -           interval < max(1, net->ipv4.sysctl_tcp_probe_threshold)=
) {
>>> -               /* TODO: set timer for probe_converge_event */
>>> +               interval < net->ipv4.sysctl_tcp_probe_threshold) {
>>> +               /* Check whether enough time has elaplased for
>>> +                * another round of probing.
>>> +                */
>>> +               tcp_mtu_check_reprobe(sk);
>>>                  return -1;
>>>          }
>>
>>
>> The way this check works, I think putting it here may not be exactly
>> what we want.  The comment was to set a timer here, but that's not
>> exactly what tcp_mtu_check_reprobe does.  Since it may update the
>> search range, I think it would be better to call prior to comparing
>> the candidate probe_size to search_high.
>
> Semantically speaking, reprobe checking should be placed inside where
> a decision to not probe has been made, reprobing from a stable state =
;)
> If we moving the reporobe checking outside, current probing may be le=
gal,
> but the reprobe check will rule it out.
>
> So I don't see any compelling reason to move the reprobe checking out=
side.

The reprobe check should happen when you know you don't already have a
pending probe, not when a decision has already been made not to probe.
The impact is relatively minor because practically you're just
extending the duration of a long timer a bit more, but there's not a
good reason to do so.

Thanks,
  -John
