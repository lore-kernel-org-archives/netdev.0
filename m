From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: IPv6 patch mysteriously breaks IPv4 VPN
Date: Thu, 21 Apr 2016 10:04:55 +0200
Message-ID: <874mav4cbc.fsf@nemi.mork.no>
References: <15023.1461205453@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <15023.1461205453@turing-police.cc.vt.edu> (Valdis Kletnieks's
	message of "Wed, 20 Apr 2016 22:24:13 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valdis Kletnieks <Valdis.Kletnieks@vt.edu> writes:

> I'll say up front - no, I do *not* have a clue why this commit causes=
 this
> problem - it makes exactly zero fsking sense.
>
> Scenario:  $WORK is blessed with a Juniper VPN system.  I've been
> seeing for a while now (since Dec-ish) an issue where at startup,
> the tun0 device will get wedged.  ifconfig reports this:
>
> tun0: flags=3D4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1400
>         inet 172.27.1.165  netmask 255.255.255.255  destination 172.2=
7.1.165
>         inet6 fe80::6802:d95c:f3f4:2a6f  prefixlen 64  scopeid 0x20<l=
ink>
>         unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txque=
uelen 500  (UNSPEC)
>         RX packets 0  bytes 0 (0.0 B)
>         RX errors 0  dropped 0  overruns 0  frame 0
>         TX packets 1  bytes 48 (48.0 B)
>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
>
> and no more packets cross - not even a ping.
>
> Yes, the tunnel is ipv4 only, and only ipv4 routes get set by the VPN=
 software.
>
> bisect results confirmed - linux-next 20160327 is bad, but 20160420 w=
ith this
> one conmmit reverted works.
>
> % git bisect bad                 =20
> cc9da6cc4f56e05cc9e591459fe0192727ff58b3 is the first bad commit
> commit cc9da6cc4f56e05cc9e591459fe0192727ff58b3
> Author: Bj=C3=83=C2=B8rn Mork <bjorn@mork.no>
> Date:   Wed Dec 16 16:44:38 2015 +0100
>                                =20
>     ipv6: addrconf: use stable address generator for ARPHRD_NONE

This is The Twilight Zone ;)

So, unless there is a bug I don't see here, the effect of that patch on
a tun interface is one thing only: a link local address is allocated by
default.  Which again will enable IPv6 autoconf on the interface,
causing us to send one or more router solicitations.

The only problem I can think of is if the userspace application stops
reading from the fd when it sees that RS.  Your counters shows one 48
bytes TX packet, which matches the expected size of the RS (no options
since there is no link layer address).

If this is correct, then I don't think reverting that patch will solve
the problem, only hide it.  The application will still fail if the
system is configured for stable privacy addresses, or set up in some
other way to configure a link local address.  I believe the stable
privacy use case must be considered, since it is a netns wide setting
and there isn't really any way to deconfigure it once configured. Any
system using stable privacy addressing will see this bug, with or
without that patch.

Lots of assumptions...  Let's try to verify some of them first.

 1) revert the patch (or run an older kernel) and configure stable
  privacy (feel free to use a more random secret than '::'):

     echo :: >/proc/sys/net/ipv6/conf/default/stable_secret

  Does that make the VPN tunnel fail too?


The remaining tests are interface specific. If you are are able to
configure settings for the tun interface then do that, otherwise you'll
have to change the defaults before letting the application create the
tun interface.

 2) run a kernel with the patch, but disable IPv6 on the tun interface:

   echo 1 >/proc/sys/net/ipv6/conf/tun0/disable_ipv6

   Does the VPN tunnel work now?=20
=20
 3) run a kernel with the patch and keep IPv6 enabled, but disable
   RS.  E.g. by:
=20
    echo 0 >/proc/sys/net/ipv6/conf/tun0/router_solicitations


 4) run a kernel with the patch, but explictly set the addrgen mode to
 none to prevent generating a link local address:

    ip link set tun0 addrgenmode none



If my assumptions are correct then the first test should make the VPN
software fail even without the patch, while the last 3 tests should all
make it work with the patch in place.

I still don't know how to deal with this, though.  I don't object to
reverting the patch if that is necessary, even if it is just to work
around a stupid userspace bug.  But I believe the stable privacy use
case is real, and if that causes the application to bug out anyway then
there isn't much point, is there?

The Linux kernel will send RS by default.  Depending on that not
happening on specific interface types, because there currently isn't an=
y
valid method to autogenerate addresses, is a little fragile.  New
address generation methods for different interface types have been adde=
d
over time. And will continue to be added.  There isn't really anything
special about tun interfaces in this regard.

If some application really cares, then it should explicitly disable the
RS and/or the address generation.  We do provide knobs for both.


Bj=C3=B8rn
