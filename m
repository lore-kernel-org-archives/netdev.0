From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Wed, 11 Feb 2004 03:52:05 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402110349260.1325@u.domain.uli>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
 <1076338874.1026.36.camel@jzny.localdomain>  <Pine.LNX.4.58.0402100008580.1251@u.domain.uli>
  <1076367038.1037.15.camel@jzny.localdomain>  <Pine.LNX.4.58.0402100114020.1251@u.domain.uli>
  <1076376094.1039.102.camel@jzny.localdomain>  <Pine.LNX.4.58.0402101028400.1158@u.domain.uli>
 <1076410090.1039.578.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1076410090.1039.578.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 10 Feb 2004, jamal wrote:

> I believe it would work even if there is no neighbor resolved yet.
> i.e it depends only on a route being resolvable not necessarily
> having the next hop existing already in arp cache. Try get on some host

	Yes, I tried it on empty system, just ip route get -> NUD_NONE.

> that doesnt exist in cache yet - try on some fake address on a directly
> connected subnet (make sure you pick a host that doesnt exist and
> therefore will never be reached).

	I did it during my initial tests and now I tested it
again, looks as expected.

> > 	Yes, requestor can be in PROBE state sending unicasts
> > but for us the target can be already unreachable.
>
> This is true; what i am saying is for this to happen more than likely
> something odd must have happened ex: the cable towards the target may
> have been pulled.i.e the chances of this happening just because the
> arp cache expired are low. The arp cache would exist because the
> initial states would have created it.

	Yes, target can exist in the cache in NUD_FAILED without
timer. But it is possible if we send probe to receive answer.
So, before calling neigh_event_send we can see that the target entry
is in one of these states:

a) NUD_NONE - just created, nobody uses it, will go to NUD_INCOMPLETE
	with timer on neigh_event_send
b) NUD_INCOMPLETE - we are probing it with broadcasts, timer is running,
	will continue with the probes
c) NUD_FAILED - no timer pending, will go to NUD_INCOMPLETE to refresh
	the state
d) NUD_VALID - stale/probed/delayed/reachable (probably start delay+probe
process). STALE looks like valid state but can be outdated - the
routing cache can keep it for minutes. We can only hope that the
user has all timeouts configured properly and this period is short.

	So, if the entry is not valid we can check if ->probes
ensures at least "2 brd probes sent" (probes >= ucast_probes+2).
This means "we have no answer for the 1st probe" and allows us
to stop queueing requests. So, we need to queue requests
only if probes < ucast_probes+2 (cases a, c and sometimes b).
Of course, if the entry is valid we will queue the brd requests.
Do you like such checks instead of adding new flag? Or the wishes
are already too many to continue with this patch?

	If you prefer you can take the 20 lines of code from
http://www.ssi.bg/~ja/tmp/arp_proxy-2.6.2-1.diff and to write
a pseudo-C example how you feel the handling should be.

	For now I'm adding this:

out_delay:
	/*
	 * Do not enqueue requests after sending the 2nd brd probe,
	 * assume the target will be down for long time
	 */
	if (delay && atomic_read(&n->probes) < n->parms->ucast_probes + 2) {
		pneigh_enqueue(&arp_tbl, in_dev->arp_parms, skb);
		skb = NULL;
	}
	goto out;

> > 2. we lie and send false answers to unicast probes, for long time
> > after target becomes unreachable
>
> This is current behavior; i wouldnt say we lie rather we send educated
> response back.

	To clear this issue, do you mean this case 2 is for entry in
STALE state? And because we are not probing it its state in our cache is
outdated. You prefer in this case to send answer, right? Because I
do not see a good reason to send answer for FAILED/INCOMPLETE/NONE.
And because STALE is part of VALID we always will send answer,
no matter brd/uni. I do not see where we need to send ARP reply
for !NUD_VALID.

> > I can agree with you (for case 2) only if the requestor is
> > not going to send unicast probes forever.
>
> Thats why i asked if you are trying to catch insane implementation.
> In my case everything is Linux. Ok, theres some pollution with
> a CISCO upstream, but that seems to have a sane arp too.
> Leave #2 with a flag to ask for for neigh_event_send() to be used
> when needed.

	I only worry if you want to send replies to unicast
probes in FAILED/INCOMPLETE/NONE state. If we have valid neighbour,
even STALE one, we can send reply no matter the uni/brd type.
brd/uni are differently treated only for the delay but we should
ignore both uni and brd requests if the entry is !VALID.

	I think, it is not enough the flag to control whether
neigh_event_send is used, if the flag is 0 you want also to
send replies in !VALID state (as before) because nobody will
send us IP traffic without receiving answer from us - only
IP traffic can originate resolution in such case. For now, I
see that the flag can be only in this way (on output interface?):

- 0: (default, as before): send answers in !VALID, do not use
neigh_event_send. The problem with the old behaviour is that
we always send answer, even in !VALID.

- 1: (new): do not send answers in !VALID, use neigh_event_send

	do you mean the same?

> I dont question the validity of this portion of your patch.
> i.e it is an improvement in certain cases - the cost is only an extra
> neigh_event_send(). But because it is not needed 100% of the time given

	And I do not see any cost in using neigh_event_send,
you are always going to fire the resolution process, now with ARP
probes or later with IP traffic in the default mode. The ARP
traffic to/from target will be equal in both cases.

> the educated assumption being made right now, i think the behavior
> should be configurable. For me #2 breaks only if the target dissapeares
> (cable gone or target removed).

	I hope you can clarify your idea with pseudo-C example :)

> > > Exactly my setup. So in this case i think this feature should stay.
> >
> > 	So, how are we going to support it? Additional flag?
> > If we do not support it we are going to drop the first request
> > and to answer the next one. Or may be we can introduce delay?
>
> We should support it. It should just be turned off by default.
> It seems to me it should be per device flag with ability to turn it off
> for all devices too, no?

	Yes, the flag can be (all/flag || iface/flag), no problem with
that :)

> cheers,
> jamal

Regards

--
Julian Anastasov <ja@ssi.bg>
