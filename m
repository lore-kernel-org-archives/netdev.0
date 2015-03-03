From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv3 net-next 3/4] ipv4: shrink current mss for tcp PMTU
 blackhole detection
Date: Tue, 03 Mar 2015 17:18:19 +0800
Message-ID: <54F57C5B.3080709@gmail.com>
References: <1425093785-27380-1-git-send-email-fan.du@intel.com> <1425093785-27380-4-git-send-email-fan.du@intel.com> <CABrhC0m6nCwHy-CCLiFStYhSbMf78E1i6Lvh=DsPi6Pcg-GCOw@mail.gmail.com> <54F42D94.6070802@gmail.com> <CABrhC0nXCtWCgNm6Gz8UCXg=7Vt1pN0Q+aqO1TYZ74JK45Tq-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:40693 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754869AbbCCJXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 04:23:19 -0500
Received: by padfb1 with SMTP id fb1so13247100pad.7
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 01:23:19 -0800 (PST)
In-Reply-To: <CABrhC0nXCtWCgNm6Gz8UCXg=7Vt1pN0Q+aqO1TYZ74JK45Tq-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B403=E6=9C=8803=E6=97=A5 04:32, John Heffner =E5=86=
=99=E9=81=93:
> On Mon, Mar 2, 2015 at 4:29 AM, Fan Du<fengyuleidian0615@gmail.com>  =
wrote:
>> >Timeout indicates search_high should be set to the new mtu correspo=
nding to
>> >current_mss no
>> >matter how we change search_low. So the best shot here IMO would be=
 updating
>> >search_high
>> >with current_mss, which in return makes the search window*slide*  f=
rom right
>> >to left, and
>> >the probing will converge in good speed eventually.
>> >
>> >So my thoughts is:
>> >@@ -113,6 +113,7 @@ static void tcp_mtu_probing(struct inet_connect=
ion_sock
>> >*icsk, struct sock *sk)
>> >                         struct tcp_sock *tp =3D tcp_sk(sk);
>> >                         int mss;
>> >
>> >+                       icsk_mtup.search_high =3D tcp_mss_to_mtu(sk=
,
>> >tcp_current_mss(sk));
>> >                         mss =3D tcp_mtu_to_mss(sk, icsk->icsk_mtup=
=2Esearch_low)
>>>> >>>1;
>> >                         mss =3D min(net->ipv4.sysctl_tcp_base_mss,=
 mss);
>> >                         mss =3D max(mss, 68 - tp->tcp_header_len);
> Search_high should be adjusted downward only when you're quite certai=
n
> that you've gotten a negative signal.  There are many possible reason=
s
> for successive timeouts including intermittent disconnection, and the=
y
> should not have a persistent (or very long-term) effect on MTU.  Leav=
e
> search_high where it is until a working MTU can be established, then
> probe upward until probing can give you confidence you've found a new
> ceiling, or gotten back to the old one.
>
> If you think the current approach is broken, it would help to see a
> concrete demonstration of how it's deficient (a real packet trace is
> good!), and how a different approach work better.

 > With original approach(doubling mss), mss is not in between search_l=
ow and search_high,
 > it always equates search_low(subtract headers), the potential mss in=
 case of blackhole
 > is 256 and 128, after doubling, it will become 512 and 256 eventuall=
y no matter how
 > route changes, even mtu reduced from 1500 to 1100 in intermediate no=
de.

As for above statement, my test scenario is simple, using vxlan tunnel =
to connect two
docker instances on two hosts. All mtu default to 1500, run iperf betwe=
en docker instances.
After the connection is setup, adjust the iperf sender host physical et=
h0 mtu to
1100, and after a couple of seconds, mss will be set to 512.

And after using binary search, actually, search_high will be set to pro=
be_size trigger from
tcp_fastretrans_alert by my investigation. So the searching window does=
 slide to left, thus
I will drop this patch. Maybe this is because my test method is not pra=
ctical. And I believe
what you said about:
> There are many possible reasons for successive timeouts including int=
ermittent disconnection,
 > and they should not have a persistent (or very long-term) effect on =
MTU.

Never mind, no matter whether to adjust search_high, the reprobe timer =
will restore search_high
to maximum allowed, and once again, new mss will be available.

I will resend the rest of patches after incorporating your comments for=
 reviewing.
Thanks for your feedback.
