From: Willy Tarreau <willy@w.ods.org>
Subject: Deadlock problem with dev->refcnt somewhere in netlink/multicast...
Date: Wed, 28 Jan 2004 12:34:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128113441.GA12118@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, davem@redhat.com, Alexandre.Cassen@wanadoo.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello,

as previously discussed in private with Jeff and David, I encounter a deadlock
problem somewhere in netlink in 2.4 kernels since at least 2.4.21 to
2.4.25-pre7. At first I thought it was related to the TG3 driver that I was
using, but after many steps in the wrong direction, I could finally find an
easy way to reproduce it on other NICs (e1000 & 3c59x). I have added lots of
traces in the kernel to track the dev->refcnt changes, but I now need help to
understand what I gathered. For this, you need an application which binds to
a multicast address. Since I've been noticing the problem on keepalived at
first, I'm sticking to it for this example, but I just could reproduce the
same problem with ntpd a few minutes ago.

The problem is the following :

1/ configure an interface up with an address
2/ start keepalived. Keepalived registers itself to receive netlink
   broadcasts (link and address groups), and sets a multicast address
   for VRRP on the interfaces.
3/ now flush all addresses on this interface
4/ then put the link down
5/ then stop keepalived
6/ now rmmod => it hangs in unregister_netdevice() with dev->refcnt=2

now simply change the order of operations between 3 and 4 (addr vs link) :

1/ configure an interface up with an address
2/ start keepalived.
3/ then put the link down
4/ now flush all addresses on this interface
5/ then stop keepalived
6/ now rmmod => no problem at all

Stopping keepalived after the ip link down or ip addr flush is OK too.
I have tried suggestions by Alexandre Cassen to disable either link
or address group registration in keepalived, but it did not change
anything at all. I even set the group to zero, but the problem persists,
which led me to try ntp to confirm that this was a multicast problem in
fact. Anyway, "ip monitor" does not cause this trouble. So I'm now certain
that just listening to netlink broadcasts does not causes this problem.
BTW, If I manually delete the addresses by hand instead of flushing them,
it does not work either. Oh, and I noticed that when I flush all IP addresses
on an interface, the interface disappears from "ip maddr", so I suspect that
someone in the address deletion code does something nasty with the mcast
addresses, but I cannot find what.

So I put lots of printk's in the kernel to track dev->refcnt at several
places, and I now have the following traces, with all printk(refcnt), not
displayed here, and along with diffs between them. The end of the name
tells the order of removal : A=addr, L=link, K=keepalived. So "trace.kal"
describes the following operations, where keepalived was stopped, then
the address was flushed, then the link was set down :

root: ##### TRACE ##### modprobe e1000
root: ##### TRACE ##### ip addr
root: ##### TRACE ##### ip addr add 1.2.3.0/24 dev eth2
root: ##### TRACE ##### ip addr
root: ##### TRACE ##### ip link set eth2 up
root: ##### TRACE ##### keepalived --vrrp -f /var/state/vrrp.conf
root: ##### TRACE ##### ip addr
root: ##### TRACE ##### ip addr flush dev eth2
root: ##### TRACE ##### ip link set eth2 down
root: ##### TRACE ##### killall keepalived
root: ##### TRACE ##### ip addr
root: ##### TRACE ##### rmmod e1000

Since there are important differences between logs, and it's been several
days I spent on the problem, I think that there is something obvious in
front of me that I cannot see. I have uploaded the traces and the side-by-side
diffs on this site (not posted because they're about 10kB each) :

    http://w.ods.org/debug/pb-mcast/

I really hope that someone with better knowledge will be able either to
point to the problem, or to narrow the problem so that I have some clues
where to add traces or what to try, because I'm really out of ideas now.

Thanks in advance,
Willy
