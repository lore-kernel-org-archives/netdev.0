From: Marc Herbert <marc.herbert@free.fr>
Subject: RE: TxDescriptors -> 1024 default. Please not for every NIC!
Date: Wed, 2 Jun 2004 21:14:24 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0406022102360.1474@fcat>
References: <C925F8B43D79CC49ACD0601FB68FF50CDB13D3@orsmsx408>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50CDB13D3@orsmsx408>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 26 May 2004, Brandeburg, Jesse wrote:

> I'm not sure that you could actually get the problem to occur on 100
> or 10Mb/s hardware however because of TCP window size limitation and
> such. What I'm getting at is that even if you have a device that can
> queue lots of packets, it probably won't unless you're using an
> unreliable protocol like UDP.  Theoretically it's a problem, but I'm
> not convinced that in real world scenarios it actually creates any
> issues.  Do you have a test that demonstrates the problem?

OK, let's go for it.

The following message details a simple experiment demonstrating how a
too big (1000-packet) txqueuelen creates a dreaded latency at the IP
level inside the sender for under-gigabit Ethernet interfaces, and so
finally advocates a default 1000-packet txqueuelen defined _only_
by/for the _GigE_ drivers, leaving the previous (before sep 2003 in
2.4) 100-packet default untouched for slower interfaces. The
experiment should be very quick and easy to reproduce in your lab,
even in your home.

Sorry, this message is way too long because it's... detailed, and
tries to anticipate questions, hopefully avoiding the need to come
back on this issue.  The counter-part is that it's not dense and thus
hopefully quick to read for anyone in the field. And please pardon my
english mistakes.


Detailed Experiment
-------------------

You need at least 2 hosts, but ideally 3. The sender "S", the
receiver "R1", and some witness host "R2". R1 and R2=A0can probably
be collapsed together if you don't have enough hosts but I am
afraid of unknown nasty side effects in this case.

Host S is using a simple TCP connection to upload an infinite file to
host R. The bottleneck is S's own 100Mb/s (or worst, 10Mb/s) network
interface. This is very important: no packet drop must occur elsewhere
between S=A0and R, else TCP congestion avoidance algorithm will
interpret this as a congestion sign and throttle down, and the txqueue
will stay empty. If your TCP connection is under-performing your
sending wire for any reason, you will obviously never fill your
txqueue. The ACK-clocking property of TCP has for consequence that
only the queue of the bottleneck of the path may fill up (except in
very dynamic environnements where the bottleneck may be fast-changing,
but let's stay simple).

Actually almost everything below is still true when the bottleneck is
elsewhere in some router further on the path instead of local in the
sender. It's still true, just... elsewhere. For instance if you use a
linux box as a router, and if it happens to be the bottleneck, I
suspect this latency issue will appear more or less the same.  But
again, let's stay simple for the moment, forget those further routers
and get back to this _local_ IP bottleneck and its too big
txqueuelen. By the way, forcing your GigE interface to 100 or 10=A0is
ok.

I used iperf <http://dast.nlanr.net/Projects/Iperf/> to upload the
infinite file, but any equivalent tool should do it.

Since your TCP connection will suffer this artificial txqueue latency,
you also need to increase SND_BUF and RCV_BUF, else the number of TCP
packets sent (and thus the txqueue filling) will be capped (wait below
for more about this).


- So just run:

host_R $ iperf --server --interval 1 --window 1M
host_S $ iperf --client R --time 1000 --window 1M

Check that you get a full 94.1Mb/s (resp. 9.4Mb/s) wire-rate. If not,
investigate why and don't bother going on.


- Now just watch the latency between S some other host "R2". For
instance using mtr:

S$ mtr -l R2

As the txqueue fills up, you will see perceived latency increasing
every round-trip time, up to 120ms (worst with 10Mb/s: up to
1.2s!). When the txqueue is full, TCP detects it and enters congestion
window reduction, providing some temporary relief. Then the artificial la=
tency
quickly ramps up again.

- You can also try to start another simultaneous upload to R2:

host_R2 $ iperf -s -i 1
host_S  $  iperf -c R2 -t 1000

... and watch how the artificial latency harms the start of the other
TCP connection, which need ages to ramp up it's throughput.

I also heard from here: "A Map of the Networking Code in Linux Kernel
 2.4.20", Technical Report DataTAG-2004-1, section 4.4
 http://datatag.web.cern.ch/datatag/publications.html
that you can get interesting qdisc stats using such commands:

# tc qdisc add dev eth1 root pfifo limit 100
#=A0tc -s -d qdisc show dev eth1

But I did not tried them.


Warning: the interface tx_ring size has to be added to the qdisc's
txqueuelen to get the total sender's queue length perceived by TCP.
Some drivers may also set it big.



Solution
--------

Now reduce the txqueuelen to the previous value:

		ifconfig eth1 txqueuelen 100

for 10Mb/s you can even try:

		ifconfig eth1 txqueuelen 10


Now your latency is now back to a sensible value (12ms max), and
everything works fine. It's a simple as that. Throughput is not harmed
at all, you still get the full 94.1 Mb/s wire-rate. If this (previous)
setting was harmful to throughput for 100Mb/s interfaces, people would
have complained since long.



The more complex truth
-----------------------

If there is a real-world, distance-caused latency between S and R,
then having some equivalent amount of buffering in txqueuelen helps
average performance, because the interface has then a backlog of
packets to send while TCP takes time to ramp up its congestion window
again a decrease, the former compensating the latter. (This may be
what the e1000 guys observed in the first place, motivating the
increase to 1000=A0? After all, 1.2ms of buffering was small) The
txqueue may smooth the sawtooth evolution of TCP congestion window,
minimizing the interface idle time.  But increased perceived latency
is the price to pay for this nice damper. There is a tradeoff between
latency and TCP=A0throughput _on wide area_ routes to tune here, but
pushing it as far as storing in txqueuelen _multiple_ times any
real-world latency (did I say "1.2s" already?) brings no benefit at
all for throughput; it's just terribly harmful for perceived latency.
No IP router does so much buffering. Besides linux :-> I don't think
IP queues should be sized to cope with moon-earth latency by default.



Conclusion
----------
(aka: let's harass the maintainers)

Of course I just demonstrated here the worst case. In many other
cases, TCP will throttle down for some reason (packet losses, too
small socket buffers,...), it will not fill the pipe nor the txqueue,
and this dreaded latency will not appear. You could argue that my test
case is very seldom in the real world/not representative (and
I would _not_ agree), so the txqueue will never be full in practice,
since there will always be some other reason making TCP
under-performing the sending wire. OK. Even then, why defining it
uselessly so high=A0for every NIC? Why take this risk? Just as a small
convenience for e1000 users? Mmmmm...

So now every interface has this 1000-packet queue (and soon 10,000
because of these upcoming 10Gb/s interfaces). To ensure no one ever
falls in this too big txqueue trap, I suggest the following user
documentation:

  "if you have a 100Mb/s interface, be warned that your txqueuelen is
  too high (it was tuned for real, gigabit men). So please reduce
  it using ifconfig. Alternatively, if you are not root,
  please tune your socket buffers finely. Too small, you will under-perfo=
rm.
  Too big, you will fill up your txqueue and create artificial
  latency. Good luck. Of course, you can forget all the above when
  your interface is not the bottleneck"

On the other hand, having a default max txqueuelen defined in
_milliseconds_ (just like most other routers do) is quite easy to
implement and covers correctly all=A0cases, without complex tuning
instructions for the end user. The ideal implementation is that every
driver defines txqueuelen by itself, depending on the actual link
speed. It is unrealistic in the short-term, but the incremental
implementation path is very easy: define a "sensible, generic default"
of=A0100-packet, perfect for the 100Mb/s masses, not too bad for 10Mb/s
masses, and let the (only few until now, let's hurry up) gigabit
drivers override/optimize this to 1000, or whatever else even more
finely tuned, for the cheap price of a few lines of code per driver.


Thanks in advance for agreeing OR proving that I am wrong.
I mean: thanks in advance for anything besides remaining silent.

And thanks for reading all this gossiping, an impressive effort indeed.
