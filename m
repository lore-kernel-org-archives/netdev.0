From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Sat, 18 Oct 2008 07:02:14 +0200
Message-ID: <48F96DD6.5060904@cosmosbay.com>
References: <1224253423.17450.211.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.150]:48727 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858AbYJRFC3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2008 01:02:29 -0400
In-Reply-To: <1224253423.17450.211.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Ohly a =E9crit :
> Hello folks!
>=20
> It's been a while, I hope you are still interested in the topic. It w=
as
> previously discussed under the subject "[RFC][PATCH 1/1] net: support
> for hardware timestamping". I would like to revive the discussion (an=
d
> eventually the implementation), therefore I'm starting a new thread. =
I
> also have two questions about oddities (?) in the current code.
>=20
> Octavian posted a patch which modified the sk_buff::tstamp field so t=
hat
> it can store both system time and hardware time stamps (which may be
> unrelated to system time!). A single bit distinguishes the two. Ingo
> suggested to drop that distinction. Before going into details of what
> might have to be changed, let me take stock of what is currently done
> with sk_buff::tstamp.
>=20
> There seem to be at least three usages:=20
>       * the netfilter code uses it to trigger timing related filter
>         rules (net/netfilter/xt_time.c)

This netfilter code could be changed to use current system time=20
(low second resolution : xtime), and not skb time. When no sniffer is r=
unning,
we get timestamp at the time netfilter code is running anyway, not
at time packet is received by NIC driver.


>       * keep track of the time stamp of the last packet received via =
a
>         socket (SOCK_TIMESTAMP, net/sock/core.c), used for
>         SIOCGSTAMP[NS]=20
>       * deliver receive time together with packet to user space
>         (SOCK_RCVTSTAMP[NS], net/sock/sock.c)
>=20
> Currently time stamping is enabled via sock_enable_timestamp(), which
> itself uses the lower level net_enable_timestamp(). At that level, a
> counter keeps track of how many users need time stamping.
>=20
> Based on how sk_buff::tstamp is used, one can conclude that it needs =
to
> be reasonably close to system time (for the netfilter code) but not
> absolutely the same. Ingo also said that it should be monotonically
> increasing. However, I doubt that this is currently guaranteed: the
> value is created with ktime_get_real(), which in contrast to ktime_ge=
t()
> is not monotonic (if I read the comments right).
>=20
> While looking at the code I ran into a few oddities which I don't qui=
te
> understand. Could be me, of course ;-}
>=20
> First, in net/ipv[46]/netfilter/ip*_queue.c, the call to
> net_enable_timestamp() is in an else branch of __ipq_rcv_skb(). The
> net_disable_timestamp() is unconditionally in __ipq_reset(). Shouldn'=
t
> the code take care that enable/disable calls always match exactly?
> Perhaps I'm missing something, but at least at first glance that does=
n't
> seem to be the case. Also, is it possible that net_enable_timestamp()=
 in
> __ipq_rcv_skb() is called repeatedly?=20
>=20
> Second, sock_recv_timestamp() in include/net/sock.h only copies
> sk_buff::tstamp into sock::sk_tstamp if SOCK_RCVTSTAMP[NS] is not set=
=2E
> If this is set (note that SOCK_RCVTSTAMPNS also sets SOCK_RCVTSTAMP),
> then __sock_recv_timestamp() copies the value into cmsgs instead. Is
> that really the intended semantic? My expectation is that all of the
> usages above are possible at the same time.
>=20
> Let's move on to the changes necessary for hardware time stamping.
>=20
> With regards to hardware time stamps we identified the following
> additional usages of sk_buff::tstamp (assuming that we recycle it
> instead of adding a new field):=20
>       * Transport the original hardware timestamps to user space:
>         Octavian is doing that with custom patches at the moment that=
 he
>         would like to replace with an upstream solution. These hardwa=
re
>         time stamps are *not* synchronized with system time, only
>         between cards. Transforming them to system time decreases the=
ir
>         accuracy and therefore is not desirable.=20
>       * Use hardware timestamps as replacement for the currently rath=
er
>         inaccurate, software-only time stamps, both for incoming and =
for
>         outgoing packets: this improves the accuracy of system time
>         synchronization with PTP [1]. For this use case, the time sta=
mp
>         delivered to the user space PTPd should be consistently
>         generated either by hardware or in software. Alternating betw=
een
>         the two methods introduces jumps, which decreases the accurac=
y
>         of the clock synchronization.
>=20
> The first use case is problematic if the hardware time diverges from
> system time *and* net time stamping is enabled (implying that one of =
the
> existing usages of tstamp is active). Would it be acceptable to let t=
he
> user of the Linux kernel avoid this conflict or does the kernel itsel=
f
> need to detect the conflict?
>=20
> The second additional use case has no such conflict. Ensuring that th=
e
> user space daemon just gets the kind of time stamps he wants is harde=
r.
> In the previous discussion we ended with the proposal to add socket
> flags which determine what kind of time stamps are to be generated (T=
X
> or RX, hardware or software). After looking at this again I believe t=
hat
> deciding that at the socket level is too late: suppose the daemon has
> initialized the hardware time stamping successfully and then requests=
 to
> get only hardware time stamps. A packet is received but couldn't be t=
ime
> stamped (can happen due to hardware limitations). The IP filter needs=
 a
> time stamp and therefore generates one in software, which is stored i=
n
> sk_buff::tstamp. Now the socket code cannot tell whether this is a ti=
me
> stamp that it can report to the daemon.
>=20
> The only solution that I see is to use one bit as flag to distinguish
> between hardware and software time stamps, as Octavian originally
> suggested. In contrast to his proposal, the rest of the bits are to b=
e
> interpreted as system time, i.e., there would be no delayed conversio=
n
> of hardware time stamps to system time stamps. In my opinion, such a
> conversion would be tricky, for example because it would have to be d=
one
> by the hardware driver which generated the time stamp, but there is n=
o
> link back to it from sk_buff.
>=20
> If that flag bit is not acceptable for Linux upstream, then PTPd woul=
d
> still work, albeit with lower accuracy.
>=20
> That's all for now - the mail is long enough as it is...
> Comments?
>=20
> [1] http://www.linuxclustersinstitute.org/conferences/archive/2008/PD=
=46/Ohly_92221.pdf
>=20

Interesting stuff :)

1) You want hardware TX stamping on all frames sent behalf a given sock=
et
  Mark a WANT_HARDWARE_TX_STAMP flag at socket level
   Copy this flag when generating skb for this socket.
     When transmitting WANT_HARDWARE_TX_STAMP tagged frame to device,
     dont feed it to dev_queue_xmit_nit() in dev_hard_start_xmit()
     In NIC driver tx completion, test skb WANT_HARDWARE_TX_STAMP flag.
     If set, get tstamp from hardware and copy it to skb tstamp,=20
     and call dev_queue_xmit_nit() (we might avoid cloning skb there, s=
ince
     nic driver doesnt need it anymore)

  This flag could also be set at device level, for all sent frames. (tc=
pdump new option)

2) You want hardware RX stamping on a particular device, yet being able=
 to
   deliver system time to legacy apps, unaware of hardware tstamps.

   Set a global flag on device, telling linux stack this device feeds h=
ardware stamp.
   In driver RX completion, set skb tstamp with hardware stamps.

   Mark a WANT_HARDWARE_RX_STAMP flag at socket level, for PTP applicat=
ions.

   In recv(), if current socket is not marked WANT_HARDWARE_RX_STAMP an=
d device has
   the global flag set, copy system time in tstamp, overrinding hardwar=
e tstamp.





