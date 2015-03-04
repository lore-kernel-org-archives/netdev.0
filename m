From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv4 net-next 3/3] ipv4: Create probe timer for tcp PMTU
 as per RFC4821
Date: Wed, 04 Mar 2015 10:11:10 +0800
Message-ID: <54F669BE.7060706@gmail.com>
References: <1425374361-21047-1-git-send-email-fan.du@intel.com> <1425374361-21047-4-git-send-email-fan.du@intel.com> <CABrhC0nQcFSkAcMmnJ+fw0nhOGKiebEDnU4P9=nRsn=u16Lotw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35940 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412AbbCDCQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 21:16:10 -0500
Received: by pdbnh10 with SMTP id nh10so29688249pdb.3
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 18:16:09 -0800 (PST)
In-Reply-To: <CABrhC0nQcFSkAcMmnJ+fw0nhOGKiebEDnU4P9=nRsn=u16Lotw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B403=E6=9C=8804=E6=97=A5 00:39, John Heffner =E5=86=
=99=E9=81=93:
> On Tue, Mar 3, 2015 at 4:19 AM, Fan Du <fan.du@intel.com> wrote:
>> As per RFC4821 7.3.  Selecting Probe Size, a probe timer should
>> be armed once probing has converged. Once this timer expired,
>> probing again to take advantage of any path PMTU change. The
>> recommended probing interval is 10 minutes per RFC1981. Probing
>> interval could be sysctled by sysctl_tcp_probe_interval.
>>
>> Eric Dumazet suggested to implement pseudo timer based on 32bits
>> jiffies tcp_time_stamp instead of using classic timer for such
>> rare event.
>>
>> Signed-off-by: Fan Du <fan.du@intel.com>
>
>> @@ -1823,6 +1825,31 @@ send_now:
>>          return false;
>>   }
>>
>> +static inline void tcp_mtu_check_reprobe(struct sock *sk)
>> +{
>> +       struct inet_connection_sock *icsk =3D inet_csk(sk);
>> +       struct tcp_sock *tp =3D tcp_sk(sk);
>> +       struct net *net =3D sock_net(sk);
>> +       u32 interval;
>> +       s32 delta;
>> +
>> +       interval =3D net->ipv4.sysctl_tcp_probe_interval;
>> +       delta =3D tcp_time_stamp - icsk->icsk_mtup.probe_timestamp;
>> +       if (unlikely(delta >=3D interval * HZ)) {
>> +               int mss =3D tcp_current_mss(sk);
>> +
>> +               /* Update current search range */
>> +               icsk->icsk_mtup.search_high =3D tp->rx_opt.mss_clamp=
 +
>> +                       sizeof(struct tcphdr) +
>> +                       icsk->icsk_af_ops->net_header_len;
>> +               icsk->icsk_mtup.search_low =3D tcp_mss_to_mtu(sk, ms=
s);
>> +               icsk->icsk_mtup.probe_size =3D 0;
>> +
>> +               /* Update probe time stamp */
>> +               icsk->icsk_mtup.probe_timestamp =3D tcp_time_stamp;
>> +       }
>> +}
>> +
>>   /* Create a new MTU probe if we are ready.
>>    * MTU probe is regularly attempting to increase the path MTU by
>>    * deliberately sending larger packets.  This discovers routing
>
> I think the only update to the search range required here is
> potentially moving search_high upward.  Touching search_low seems
> unnecessary,
No.

If you restoring search_low to its original, the first probe will proba=
bly
be no better than using current mss, because current mss is working goo=
d,
there may be better mss between mtu(current mss) and search_high. Repro=
bing
from search_low to search_high is definitely not worth the effort.

> and probe_size better be zero when executing this anyway.
> (We don't want to be changing the state while a probe is in flight.)
Good point.
probe size should be set to zero frist, then update search range to kee=
p
state consistent.
>
>
>> @@ -1866,8 +1893,11 @@ static int tcp_mtu_probe(struct sock *sk)
>>          size_needed =3D probe_size + (tp->reordering + 1) * tp->mss=
_cache;
>>          interval =3D icsk->icsk_mtup.search_high - icsk->icsk_mtup.=
search_low;
>>          if (probe_size > tcp_mtu_to_mss(sk, icsk->icsk_mtup.search_=
high) ||
>> -           interval < max(1, net->ipv4.sysctl_tcp_probe_threshold))=
 {
>> -               /* TODO: set timer for probe_converge_event */
>> +               interval < net->ipv4.sysctl_tcp_probe_threshold) {
>> +               /* Check whether enough time has elaplased for
>> +                * another round of probing.
>> +                */
>> +               tcp_mtu_check_reprobe(sk);
>>                  return -1;
>>          }
>
> The way this check works, I think putting it here may not be exactly
> what we want.  The comment was to set a timer here, but that's not
> exactly what tcp_mtu_check_reprobe does.  Since it may update the
> search range, I think it would be better to call prior to comparing
> the candidate probe_size to search_high.
Semantically speaking, reprobe checking should be placed inside where
a decision to not probe has been made, reprobing from a stable state ;)
If we moving the reporobe checking outside, current probing may be lega=
l,
but the reprobe check will rule it out.

So I don't see any compelling reason to move the reprobe checking outsi=
de.

> Thanks,
>    -John
>
