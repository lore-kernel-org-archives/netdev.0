From: jamal <hadi@cyberus.ca>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Sun, 31 Mar 2002 11:21:16 -0500 (EST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0203310941120.9704-100000@shell.cyberus.ca>
References: <3CA6E3BF.8815AA4F@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3CA6E3BF.8815AA4F@isg.de>
List-Id: netdev.vger.kernel.org



On Sun, 31 Mar 2002, Stefan Rompf wrote:

> Hi Jamal,
>
> > in the future can you please just post to netdev on networking
> > related issues? I responded to lk, but feel free to remove it
> > from the list.
>
> ok. Do all netdev people already know the patch or shall I repost it to
> this list?

For the uninitiated, here is where i saw it:
http://marc.theaimsgroup.com/?l=linux-net&m=101751062827998&w=1

(sorry, i am not subscribed to lk)

>
> > -I am not sure the idea of using a kernel thread is the best. Maybe
> > move the checks to both the tx or rx softirqs instead of its own scheduling.
> > -In particular, it would be a better idea not to just go walking all the
> > devices; only walk devices that have raised an netif_carrier_.
>
> Is it possible to send (netlink) messages from a softirq?

Why not?

> Anyway, in the
> tx/rx softirqs the check would be executed for nearly every packet, so
> the tradeoff of having a kernel thread that polls the devices on request
> (so may be never as long as the network is fine) seems better to me,
> even if it has to walk through the complete list.

Moving it to softirq gives it more privilege; however, you are right, the
tx/rx softirqs might not be the best place (i thought people will scream
at you if you went ahead and created a sofirq just for this). In any
case, this is a lesser concern for now, a few ms later is no biggie...

In regards to walking the whole dev list:
There is no point in polling when there is no work to be done (and
therefore no need for you to walk all the devices which have not shown
interest). A simple "registration" by devices raising or lowering carrier
would be the best way to do it (via netif_carrier_on/ff). The first
device on the list also wakes up the thread (or as you do right now
always wakes it up).
Keep rescheduling the thread until there are no more devices left (no
need for the timer) -- killing the thread might not be a bad idea either
since you would expect this not to happen that often.

>
> > -A shared devices bitmask across SMP should be enough (i.e no need for
> > per-CPU state)
>
> Neither dev->flags nor dev->state are per-CPU. Am I missing something?

I meant the structure that keeps track of changed carrier state ..
Example the simple linked list i mentioned above;

> > -Another thing might be to double check that the condition that raised
> > the state change is still valid example -
> > in between the moment you say a link is down due to some bad hardware
> > fault to the moment some device timer recovers it;
>
> The patch does that. After the thread wakes up, it iterates over the
> device list and sends only messages if it sees differences between
> IFF_RUNNING and LINK_STATE_NO_CARRIER.
>

I think you need to watch serialization issues with
netif_carrier_on/off between the driver and the top layer.
The difference between IFF_RUNNING and LINK_STATE_NO_CARRIER, IMO, is
insufficient check. This is because the semantics of IFF_RUNNING are not
well defined. Currently from scanning drivers i see IFF_RUNNING following
LINK_STATE_NO_CARRIER always i.e IFF_RUNNING is set when
LINK_STATE_NO_CARRIER is deasserted and vice-versa. Note this is not
always the case and it also does not say that we went from operational
down to up or vice-versa or whether we went on->off->on i.e looking at
those two flags alone is ambigous.
Note, you want to report both transitions and you also want to make
sure its not just simple noise.

> > -Also IFF_RUNNING seems to have inconsistent semantics in a lot of
> > drivers. It should really stand for "operational status" whereas
> > IFF_UP should stand for "admin status" -- anyone wanna shed historical
> > wisdom here?
>
> Ultimately, that's what I want IFF_RUNNING to become in linux.
>
> There are 14 files left below linux/drivers that still play with
> IFF_RUNNING instead of using the netif_carrier_o* functions. I'm willing
> to supply patches for them as they are broken anyway, but I won't be
> able to do more than a test if the modifications compile.
>

If we were to follow the BSD or CISCOish view of the world, then
removing a cable or death of allocated virtual circuit/tunnel would
mean !IFF_RUNNING. If i was to draw a truth table it would look like:

NO_CARRIER | IFF_RUNNING | meaning
-----------|-------------|------------------------------------
!set       | !set        | There is carrier, but no cable
           |             | no sense for ethernet; but may be useful
           |             | for PPP (for example line protocol is not up)
-----------|-------------|----------------------------------------
!set       | set         | operational up
           |             |
           |             |
-----------|-------------|--------------------------------------
set        | !set        | operational down
           |             |
           |             |
-----------|-------------|--------------------------------------
set        | set         | carrier off, cable on; not sure what this
           |             | means (may make sense for host scope)
           |             |
-----------|-------------|--------------------------------------

You still need to maintain state to catch the on->off->on. For example, no
point in reporting such state transition via netlink -- but you could call
that an optimization.
TB above is a little different from what you have in your code
(essentially you also add to the noise by mucking with IFF_RUNNING) which
in itself is philosophical in nature:
- Is it correct to get rid of the driver having a say in IFF_RUNNING?
For example is it correct that the core code sets IFF_RUNNING on the
device? Think of either a bonding, VLANs or extreme case where PPP
circuit is up for one protocol but not for another.
We need to disambiguate operational and admin status very clearly. Eg
should ifconfing-ing up a device mean it is also IFF_RUNNING (this is what
ifconfig does i think)

cheers,
jamal
