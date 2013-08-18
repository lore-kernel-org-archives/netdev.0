From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: NAT stops forwarding ACKs after PMTU discovery
Date: Sun, 18 Aug 2013 23:23:35 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1308182314050.25515@blackhole.kfki.hu>
References: <521061B4.1030508@fatooh.org> <1376839467.21329.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1376839467.21329.36.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 18 Aug 2013, Eric Dumazet wrote:

> On Sat, 2013-08-17 at 22:55 -0700, Corey Hickey wrote:
> > Hi,
> > 
> > If there is a better user-oriented list I should ask this question on,
> > please tell me; I've asked a couple similar questions on netdev before
> > and gotten some great help.
> > 
> > 
> > I'm having a problem wherein some NATted connections stop forwarding
> > packets. I've troubleshot the problem far enough to tell that it happens
> > when path MTU discovery happens--the ACK to the retransmitted packet
> > never gets forwarded back to my local client (and neither do the
> > retransmitted ACKs).
> > 
> > This is my setup:
> > ----------------------------------------------------------------------
> >        MTU 9100                  MTU 1355  MTU 1500
> > client      --> linux router          -->  vpn  --> work host
> > 198.18.0.3      198.18.0.1    (eth0)                10.15.24.13
> >                 192.168.61.54 (tun0)
> > ----------------------------------------------------------------------
> > 
> > I'm running openconnect on a Linux router to connect to a cisco VPN at
> > work. The Linux router does SNAT (MASQUERADE) over the virtual tun0
> > interface created by openconnect.
> > 
> > This is the best test I have so far:
> > 
> > $ sudo ip route flush cache ; ssh workhost.example.com exit
> > Read from socket failed: Connection reset by peer
> > 
> > Most of the time, this hangs for a few minutes before giving up;
> > sometimes it just works fine. tcpdumps indicate that when it works, all
> > packets transmitted are below the VPN's MTU; when it fails, MTU
> > discovery has happened:
> > 
> > 1. client sends large packet, for example 1832 bytes
> > 2. router sends ICMP fragmentation needed
> > 3. client retransmits with a smaller packet, for example 1303 bytes
> > 4. router forwards packet over VPN
> > 5. work host ACKs packet
> > 6. router receives ACK but does not forward it
> > 7. both endpoints retransmit, but ACKs never get forwarded
> > 
> > The NAT table maintains an entry throughout (and continues to SNAT
> > retransmits from the client), but the ACKs from the server never get
> > forwarded.
> > 
> > fire:~# netstat-nat -n -d 10.15.24.13
> > Proto NATed Address           Destination Address            State
> > tcp   198.18.0.3:51076        10.15.24.13:22                 ESTABLISHED
> > 
> > 
> > I put a LOG target on the INPUT chain, though, and apparently these
> > packets are bypassing the NAT; the kernel does not think they should be
> > forwarded (else they would be on the FORWARD chain).
> > 
> > [23335.509084] IN=tun0 OUT= MAC= SRC=10.15.24.13 DST=192.168.61.54
> > LEN=64 TOS=0x00 PREC=0x00 TTL=62 ID=28270 DF PROTO=TCP SPT=22 DPT=51076
> > WINDOW=134 RES=0x00 ACK FIN URGP=0
> > 
> > 
> > The kernel on the router is 3.10-2-amd64 (from Debian testing). I had
> > the same problem with 3.2.0-4-amd64 (from Debian stable), before I tried
> > to see if I could upgrade the problem away.
> > 
> > Any help would be much appreciated. I can send full tcpdumps if needed.
> 
> This looks like the bug we had to fix recently : 
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=356d7d88e088687b6578ca64601b0a2c9d145296
> 
> Could you try latest net tree ?

It's a PMTU related problem, so I'd suggest to check first the next ones:

Aren't the ICMP error messages (i.e. fragmentation-needed) filtered out?
If not, does adding an explicit TCPMSS rule to the mangle table help?
Isn't there SACK options involved? Maybe there's a "smart" sequence 
number "anonymizer" device in the path which forgets about the SEQ numbers 
in the SACK options and thus such packets are marked as INVALID.

So tcpdumps captured at both sides could really help to tell what goes wrong.

Best regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
