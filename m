From: David Lamparter <equinox@diac24.net>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect failed
Date: Fri, 12 Nov 2010 22:16:27 +0100
Message-ID: <20101112211627.GC122902@jupiter.n2.diac24.net>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
 <00c201cb81eb$84e18160$8ea48420$@com>
 <1289578108.3083.95.camel@localhost.localdomain>
 <1289578532.3185.265.camel@edumazet-laptop>
 <20101112163543.GB122902@jupiter.n2.diac24.net>
 <4CDD7145.8070606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Paris <eparis@redhat.com>, Hua Zhong <hzhong@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, paul.moore@hp.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CDD7145.8070606@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 12, 2010 at 05:54:29PM +0100, Patrick McHardy wrote:
> Am 12.11.2010 17:35, schrieb David Lamparter:
> > On Fri, Nov 12, 2010 at 05:15:32PM +0100, Eric Dumazet wrote:
> >> Le vendredi 12 novembre 2010 =C3=A0 11:08 -0500, Eric Paris a =C3=A9=
crit :
> >>
> >>> 2) What should the generic TCP code (tcp_connect()) do if the skb=
 failed
> >>> to send.  Should it return error codes back up the stack somehow =
or
> >>> should they continue to be ignored?  Obviously continuing to just=
 ignore
> >>> information we have doesn't make me happy (otherwise I wouldn't h=
ave
> >>> started scratching this itch).  But the point about ENOBUFS is we=
ll
> >>> taken.  Maybe I should make tcp_connect(), or the caller to
> >>> tcp_connect() more intelligent about specific error codes?
> >>>
> >>> I'm looking for a path forward.  If SELinux is rejecting the SYN =
packets
> >>> on connect() I want to pass that info to userspace rather than ju=
st
> >>> hanging.  What's the best way to accomplish that?
> >>>
> >>
> >> Eric, if you can differentiate a permanent reject, instead of a
> >> temporary one (congestion, or rate limiting, or ENOBUF, or ...), t=
hen
> >> yes, you could make tcp_connect() report to user the permanent err=
or,
> >> and ignore the temporary one.
>=20
> Indeed. We could even make the NF_DROP return value configurable
> by encoding it in the verdict.

> There is no NF_REJECT.
Ah, sorry, not at home in netfilter, coming from an user perspective he=
re.

> Returning NF_DROP results in -EPERM getting reported back. As Eric
> noticed, this is ignored for SYN packets.

Hrm. But how do you silently drop packets? This seems counterintuitive
or even buggy to me; or at least the netfilter DROP target shouldn't us=
e
this kind of error-reporting drop.

As food for thought I'd like to pose the following rule:
iptables -A OUTPUT -m statistic --mode nth --every 5 -j DROP
which should, to my understanding, still allow the connect to complete,
even if the first SYN got (silently!...) dropped.

Also, i'm *very* sure i was able to trigger a "permission denied" from
either firewall or route rules; weirdly enough i can't get that on my
2.6.35.7 router... (poking older boxes to reproduce it right now)

Just for reference some test results: (heavily cropped)
TL;DR: only tcp-reset and route prohibit work immediately.


+ telnet 74.125.43.105 80
Connected to 74.125.43.105.
+ iptables -I OUTPUT -p tcp -d 74.125.43.105 --dport 80 -j REJECT
  # default w/o reject-with is icmp-port-unreachable
+ telnet 74.125.43.105 80
telnet: connect to address 74.125.43.105: Connection refused
real    0m3.014s
+ iptables -I OUTPUT -p tcp -d 74.125.43.105 --dport 80 -j REJECT --rej=
ect-with tcp-reset
+ telnet 74.125.43.105 80
telnet: connect to address 74.125.43.105: Connection refused
real    0m0.007s
+ iptables -I OUTPUT -p tcp -d 74.125.43.105 --dport 80 -j REJECT --rej=
ect-with host-prohib
+ telnet 74.125.43.105 80
telnet: connect to address 74.125.43.105: No route to host
real    0m3.010s
+ iptables -I OUTPUT -p tcp -d 74.125.43.105 --dport 80 -j REJECT --rej=
ect-with admin-prohib
+ telnet 74.125.43.105 80
telnet: connect to address 74.125.43.105: No route to host
real    0m3.009s
+ iptables -I OUTPUT -p tcp -d 74.125.43.105 --dport 80 -j REJECT --rej=
ect-with net-prohib
+ telnet 74.125.43.105 80
telnet: connect to address 74.125.43.105: Network is unreachable
real    0m3.011s
+ iptables -F OUTPUT
+ ip route add prohibit 74.125.43.105
+ ip route flush cache
+ telnet 74.125.43.105 80
telnet: connect to address 74.125.43.105: Network is unreachable
real    0m0.007s


-David
