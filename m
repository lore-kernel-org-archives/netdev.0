From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: Device operative state notification against 2.5.7
Date: Sun, 31 Mar 2002 12:23:59 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CA6E3BF.8815AA4F@isg.de>
References: <Pine.GSO.4.30.0203302133110.7012-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
List-Id: netdev.vger.kernel.org

Hi Jamal,

> in the future can you please just post to netdev on networking
> related issues? I responded to lk, but feel free to remove it
> from the list.

ok. Do all netdev people already know the patch or shall I repost it to
this list?

> -I am not sure the idea of using a kernel thread is the best. Maybe
> move the checks to both the tx or rx softirqs instead of its own scheduling.
> -In particular, it would be a better idea not to just go walking all the
> devices; only walk devices that have raised an netif_carrier_.

Is it possible to send (netlink) messages from a softirq? Anyway, in the
tx/rx softirqs the check would be executed for nearly every packet, so
the tradeoff of having a kernel thread that polls the devices on request
(so may be never as long as the network is fine) seems better to me,
even if it has to walk through the complete list.

> -A shared devices bitmask across SMP should be enough (i.e no need for
> per-CPU state)

Neither dev->flags nor dev->state are per-CPU. Am I missing something?

> -Another thing might be to double check that the condition that raised
> the state change is still valid example -
> in between the moment you say a link is down due to some bad hardware
> fault to the moment some device timer recovers it;

The patch does that. After the thread wakes up, it iterates over the
device list and sends only messages if it sees differences between
IFF_RUNNING and LINK_STATE_NO_CARRIER.

> -Also IFF_RUNNING seems to have inconsistent semantics in a lot of
> drivers. It should really stand for "operational status" whereas
> IFF_UP should stand for "admin status" -- anyone wanna shed historical
> wisdom here?

Ultimately, that's what I want IFF_RUNNING to become in linux.

There are 14 files left below linux/drivers that still play with
IFF_RUNNING instead of using the netif_carrier_o* functions. I'm willing
to supply patches for them as they are broken anyway, but I won't be
able to do more than a test if the modifications compile.

Cheers, Stefan
