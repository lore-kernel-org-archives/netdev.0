From: Kevin Dwyer <kevin@pheared.net>
Subject: Re: Resend:  SIOCGIFBRDADDR?
Date: Thu, 15 Aug 2002 15:11:48 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208151441350.9904-100000@kaneda.isrd.lan>
References: <200208151635.UAA27112@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: alanr@unix.sh, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200208151635.UAA27112@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

On Thu, 15 Aug 2002, kuznet@ms2.inr.ac.ru grunted something like:

Thanks for the response...

> > crazy.  So my question: Does anyone know if there's an ip route command to
> > make the Bcast field show up as the correct value,
>
> Yes, that one which is described in manual (and equivalent to corresponding
> ifconfig)
>
> ifconfig eth0:tra-ta-ta 10.x.y.z etc.

Perhaps I should clarify a bit further.
When we are starting heartbeat, the interface is setup thusly:
(I've simplified this to make it easier to read)

ifconfig eth0 10.5.5.8 broadcast 10.5.5.255 netmask 255.255.255.0
ip -f inet addr add 10.5.5.1 dev eth0 scope link
ip -f inet addr add 10.5.5.2 dev eth0 scope link

After executing those commands, we see the following:

ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:C0:95:E1:BC:64
          inet addr:10.5.5.1  Bcast:0.0.0.0  Mask:255.255.255.255
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
<snip>

(Note: the inet addr, Bcast, and Mask fields are all incorrectly reporting
       ifconfig's initial settings, which is why heartbeat is also
       confused.)

2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:c0:95:e1:bc:64 brd ff:ff:ff:ff:ff:ff
    inet 10.5.5.1/32 scope link eth0
    inet 10.5.5.2/32 scope link eth0
    inet 10.5.5.8/24 brd 10.5.5.255 scope global eth0


So we have eth0 setup as 10.5.5.8, and two aliases setup with iproute at
10.5.5.1 and 10.5.5.2.  They are not however aliases like eth0:1, eth0:2,
etc.  But, iproute has setup the kernel to reply to ARPs for those IPs.

So, heartbeat needs to know which interface to use for sending broadcast
packets to another node.  I've defined eth0 as said interface, and it uses
eth0 as the ifreq for the ioctl call.  However, the ioctl call returns
0.0.0.0, when in fact I need 10.5.5.255.


> >				      or is there a better
> > way for heartbeat to get the broadcast address?
>
> Well, yes. Initialize ifreq with right address, for instance.
> Probably, your program has the same problem, which is in net-tools package.

See above.. the problem is that using eth0 is the right address.

> Or this:
>
> > That command gives me the correct broadcast address in the brd field.

The only problem I see with emulating iproute's commands is that you'll
need netlink (is this correct?) so it won't work for everyone until
everyone starts adding that to their kernel config.  (A possibly
reasonable request, if this is indeed the best way to attack the problem.
This is partially why we're asking for commentary/help.)


-[ kevin@pheared.net                 devel.pheared.net ]-
-[ Rather be forgotten, than remembered for giving in. ]-
-[ ZZ = g ^ (xb * xa) mod p      g = h^{(p-1)/q} mod p ]-
