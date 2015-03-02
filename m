From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCHv3 net-next 3/4] ipv4: shrink current mss for tcp PMTU
 blackhole detection
Date: Mon, 02 Mar 2015 17:29:56 +0800
Message-ID: <54F42D94.6070802@gmail.com>
References: <1425093785-27380-1-git-send-email-fan.du@intel.com> <1425093785-27380-4-git-send-email-fan.du@intel.com> <CABrhC0m6nCwHy-CCLiFStYhSbMf78E1i6Lvh=DsPi6Pcg-GCOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, edumazet@google.com,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34987 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbbCBJew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 04:34:52 -0500
Received: by pdbft15 with SMTP id ft15so12447132pdb.2
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 01:34:51 -0800 (PST)
In-Reply-To: <CABrhC0m6nCwHy-CCLiFStYhSbMf78E1i6Lvh=DsPi6Pcg-GCOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B403=E6=9C=8801=E6=97=A5 07:39, John Heffner =E5=86=
=99=E9=81=93:
> On Fri, Feb 27, 2015 at 10:23 PM, Fan Du<fan.du@intel.com>  wrote:
>> >Reducing current tcp mss instead of search_low will make
>> >more sense, as current tcp mss still got lost.
>> >@@ -113,7 +114,8 @@ static void tcp_mtu_probing(struct inet_connect=
ion_sock *icsk, struct sock *sk)
>> >                         struct tcp_sock *tp =3D tcp_sk(sk);
>> >                         int mss;
>> >
>> >-                       mss =3D tcp_mtu_to_mss(sk, icsk->icsk_mtup.=
search_low) >> 1;
>> >+                       /* try mss smaller than current mss */
>> >+                       mss =3D tcp_current_mss(sk) >> 1;
>> >                         mss =3D min(net->ipv4.sysctl_tcp_base_mss,=
 mss);
>> >                         mss =3D max(mss, 68 - tp->tcp_header_len);
>> >                         icsk->icsk_mtup.search_low =3D tcp_mss_to_=
mtu(sk, mss);
>> >@@ -176,7 +178,7 @@ static int tcp_write_timeout(struct sock *sk)
> I don't believe there's a problem with the code as written.  Modulo
> headers, search_low <=3D mss =3D< search_high.  This code, on success=
ive
> timeouts, widens the search range by adjusting search_low (and mss)
> downward.
With original approach(doubling mss), mss is not in between search_low =
and search_high,
it always equates search_low(subtract headers), the potential mss in ca=
se of blackhole
is 256 and 128, after doubling, it will become 512 and 256 eventually n=
o matter how
route changes, even mtu reduced from 1500 to 1100 in intermediate node.

After using binary search, halve search_low will make search window lef=
t boundary expending
in a slower manner, as a result the limit of mss is search_high/2, beca=
use search_high does
not change.

Timeout indicates search_high should be set to the new mtu correspondin=
g to current_mss no
matter how we change search_low. So the best shot here IMO would be upd=
ating search_high
with current_mss, which in return makes the search window *slide* from =
right to left, and
the probing will converge in good speed eventually.

So my thoughts is:
@@ -113,6 +113,7 @@ static void tcp_mtu_probing(struct inet_connection_=
sock *icsk, struct sock *sk)
                         struct tcp_sock *tp =3D tcp_sk(sk);
                         int mss;

+                       icsk_mtup.search_high =3D tcp_mss_to_mtu(sk, tc=
p_current_mss(sk));
                         mss =3D tcp_mtu_to_mss(sk, icsk->icsk_mtup.sea=
rch_low) >> 1;
                         mss =3D min(net->ipv4.sysctl_tcp_base_mss, mss=
);
                         mss =3D max(mss, 68 - tp->tcp_header_len);
