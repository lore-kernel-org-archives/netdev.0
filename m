From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH net-next 2/3] ipv4: Use binary search to choose tcp PMTU
 probe_size
Date: Mon, 16 Feb 2015 13:27:00 +0800
Message-ID: <54E17FA4.1000104@gmail.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com> <1423815405-32644-3-git-send-email-fan.du@intel.com> <CABrhC0mPhY1u5rb=KsaF96fLqw_QYLUGm_D9_Yhn655JxLN1Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:39048 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbbBPFbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 00:31:36 -0500
Received: by pdjy10 with SMTP id y10so32830691pdj.6
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 21:31:35 -0800 (PST)
In-Reply-To: <CABrhC0mPhY1u5rb=KsaF96fLqw_QYLUGm_D9_Yhn655JxLN1Xw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B402=E6=9C=8814=E6=97=A5 01:52, John Heffner =E5=86=
=99=E9=81=93:
> On Fri, Feb 13, 2015 at 3:16 AM, Fan Du <fan.du@intel.com> wrote:
>> Current probe_size is chosen by doubling mss_cache,
>> the initial mss base is 512 Bytes, as a result the
>> converged probe_size will only be 1024 Bytes, there
>> is still big gap between 1024 and common 1500 bytes
>> of mtu.
>>
>> Use binary search to choose probe_size in a fine
>> granularity manner, an optimal mss will be found
>> to boost performance as its maxmium.
>>
>> Test env:
>> Docker instance with vxlan encapuslation(82599EB)
>> iperf -c 10.0.0.24  -t 60
>>
>> before this patch:
>> 1.26 Gbits/sec
>>
>> After this patch: increase 26%
>> 1.59 Gbits/sec
>>
>> Signed-off-by: Fan Du <fan.du@intel.com>
>
> Thanks for looking into making mtu probing better.  Improving the
> search strategy is commendable.  One high level comment though is tha=
t
> there's some cost associated with probing and diminishing returns the
> smaller the interval (search_high - search_low), so there should be
> some threshold below which further probing is deemed no longer useful=
=2E
>
> Aside from that, some things in this patch don't look right to me.
> Comments inline below.
>
>
>> ---
>>   include/net/inet_connection_sock.h |    3 +++
>>   net/ipv4/tcp_input.c               |    5 ++++-
>>   net/ipv4/tcp_output.c              |   12 +++++++++---
>>   net/ipv4/tcp_timer.c               |    2 +-
>>   4 files changed, 17 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_c=
onnection_sock.h
>> index 5976bde..3d0932e 100644
>> --- a/include/net/inet_connection_sock.h
>> +++ b/include/net/inet_connection_sock.h
>> @@ -124,6 +124,9 @@ struct inet_connection_sock {
>>                  int               search_high;
>>                  int               search_low;
>>
>> +               int               search_high_sav;
>> +               int               search_low_sav;
>> +
>>                  /* Information on the current probe. */
>>                  int               probe_size;
>>          } icsk_mtup;
>
>
> What are these for?  They're assigned but not used.

It's used by the probe timer to restore original search range.
See patch3/3.

>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 8fdd27b..20b28e9 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -2613,7 +2613,10 @@ static void tcp_mtup_probe_success(struct soc=
k *sk)
>>          tp->snd_cwnd_stamp =3D tcp_time_stamp;
>>          tp->snd_ssthresh =3D tcp_current_ssthresh(sk);
>>
>> -       icsk->icsk_mtup.search_low =3D icsk->icsk_mtup.probe_size;
>> +       if (icsk->icsk_mtup.search_low =3D=3D icsk->icsk_mtup.probe_=
size)
>> +               icsk->icsk_mtup.search_low =3D icsk->icsk_mtup.searc=
h_high;
>> +       else
>> +               icsk->icsk_mtup.search_low =3D icsk->icsk_mtup.probe=
_size;
>>          icsk->icsk_mtup.probe_size =3D 0;
>>          tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
>>   }
>
> It would be cleaner to handle this in tcp_mtu_probe, in deciding
> whether to issue a probe, than to change the semantics of search_high
> and search_low.  Issuing a probe where probe_size =3D=3D search_low s=
eems
> like the wrong thing to do.
That's my original thoughts, the seconds thoughts is every BYTE in data=
center
cost money, so why not to get optimal performance by using every possib=
le byte
available.

Anyway, a sysctl threshold will also do the job, will incorporate this =
in next version.

>
>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> index a2a796c..0a60deb 100644
>> --- a/net/ipv4/tcp_output.c
>> +++ b/net/ipv4/tcp_output.c
>> @@ -1349,10 +1349,13 @@ void tcp_mtup_init(struct sock *sk)
>>          struct inet_connection_sock *icsk =3D inet_csk(sk);
>>          struct net *net =3D sock_net(sk);
>>
>> -       icsk->icsk_mtup.enabled =3D net->ipv4.sysctl_tcp_mtu_probing=
 > 1;
>> +       icsk->icsk_mtup.enabled =3D net->ipv4.sysctl_tcp_mtu_probing=
;
>>          icsk->icsk_mtup.search_high =3D tp->rx_opt.mss_clamp + size=
of(struct tcphdr) +
>>                                 icsk->icsk_af_ops->net_header_len;
>>          icsk->icsk_mtup.search_low =3D tcp_mss_to_mtu(sk, net->ipv4=
=2Esysctl_tcp_base_mss);
>> +
>> +       icsk->icsk_mtup.search_high_sav =3D icsk->icsk_mtup.search_h=
igh;
>> +       icsk->icsk_mtup.search_low_sav =3D icsk->icsk_mtup.search_lo=
w;
>>          icsk->icsk_mtup.probe_size =3D 0;
>>   }
>>   EXPORT_SYMBOL(tcp_mtup_init);
>
> You're changing the meaning of sysctl_tcp_mtu_probing.  I don't think
> that's what you want.  From Documentation/networking/ip-sysctl.txt:
>
> tcp_mtu_probing - INTEGER
> Controls TCP Packetization-Layer Path MTU Discovery.  Takes three
> values:
>   0 - Disabled
>   1 - Disabled by default, enabled when an ICMP black hole detected
>   2 - Always enabled, use initial MSS of tcp_base_mss.
yes, will honor the original enable theme.

>
>> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
>> index 0732b78..9d1cfe0 100644
>> --- a/net/ipv4/tcp_timer.c
>> +++ b/net/ipv4/tcp_timer.c
>> @@ -113,7 +113,7 @@ static void tcp_mtu_probing(struct inet_connecti=
on_sock *icsk, struct sock *sk)
>>                          struct tcp_sock *tp =3D tcp_sk(sk);
>>                          int mss;
>>
>> -                       mss =3D tcp_mtu_to_mss(sk, icsk->icsk_mtup.s=
earch_low) >> 1;
>> +                       mss =3D tcp_mtu_to_mss(sk, icsk->icsk_mtup.s=
earch_low);
>>                          mss =3D min(net->ipv4.sysctl_tcp_base_mss, =
mss);
>>                          mss =3D max(mss, 68 - tp->tcp_header_len);
>>                          icsk->icsk_mtup.search_low =3D tcp_mss_to_m=
tu(sk, mss);
>
> Why did you change this?  I think this breaks black hole detection.
hmm, I misunderstood this part.
In case of pure black hole detection, lowering the current tcp mss inst=
ead of search_low,
will make more sense, as current tcp mss still got lost.

-                       mss =3D tcp_mtu_to_mss(sk, icsk->icsk_mtup.sear=
ch_low) >> 1;
+                       /* try mss smaller than current mss */
+                       mss =3D tcp_current_mss(sk) >> 1;

Black hole seems more like a misconfiguration in administrative level o=
n intermediate node,
rather than a stack issue, why keep shrinking mss to get packet through=
 with poor performance?


> Thanks,
>    -John
>
