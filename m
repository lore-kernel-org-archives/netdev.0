From: jamal <hadi@cyberus.ca>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: 11 Feb 2004 08:11:51 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076505110.2267.207.camel@jzny.localdomain>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
	 <1076338874.1026.36.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402100008580.1251@u.domain.uli>
	 <1076367038.1037.15.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402100114020.1251@u.domain.uli>
	 <1076376094.1039.102.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402101028400.1158@u.domain.uli>
	 <1076410090.1039.578.camel@jzny.localdomain>
	 <Pine.LNX.4.58.0402110349260.1325@u.domain.uli>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402110349260.1325@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Tue, 2004-02-10 at 20:52, Julian Anastasov wrote: 
> 	Hello,
> 
> On Tue, 10 Feb 2004, jamal wrote:
> 
> > I believe it would work even if there is no neighbor resolved yet.
> > i.e it depends only on a route being resolvable not necessarily
> > having the next hop existing already in arp cache. Try get on some host
> 
> 	Yes, I tried it on empty system, just ip route get -> NUD_NONE.

It doesnt seem to show up at all in the neigh cache display although
you are correct that it does go to NUD_NONE given the transition
when you attempt a ping right after. 

is NUD_NONE never displayed by ip n ls?

> > that doesnt exist in cache yet - try on some fake address on a directly
> > connected subnet (make sure you pick a host that doesnt exist and
> > therefore will never be reached).
> 
> 	I did it during my initial tests and now I tested it
> again, looks as expected.

I am not %100 sure if such an entry should be route cached if the nh
is not resolvable. What are your thoughts on this?

> > > 	Yes, requestor can be in PROBE state sending unicasts
> > > but for us the target can be already unreachable.
> >
> > This is true; what i am saying is for this to happen more than likely
> > something odd must have happened ex: the cable towards the target may
> > have been pulled.i.e the chances of this happening just because the
> > arp cache expired are low. The arp cache would exist because the
> > initial states would have created it.
> 
> 	Yes, target can exist in the cache in NUD_FAILED without
> timer. But it is possible if we send probe to receive answer.

NUD_FAILED is dead meat waiting to be garbage collected.

> So, before calling neigh_event_send we can see that the target entry
> is in one of these states:
> 
> a) NUD_NONE - just created, nobody uses it, will go to NUD_INCOMPLETE
> 	with timer on neigh_event_send
> b) NUD_INCOMPLETE - we are probing it with broadcasts, timer is running,
> 	will continue with the probes
> c) NUD_FAILED - no timer pending, will go to NUD_INCOMPLETE to refresh
> 	the state
> d) NUD_VALID - stale/probed/delayed/reachable (probably start delay+probe
> process). STALE looks like valid state but can be outdated - the
> routing cache can keep it for minutes. We can only hope that the
> user has all timeouts configured properly and this period is short.
> 
> 	So, if the entry is not valid we can check if ->probes
> ensures at least "2 brd probes sent" (probes >= ucast_probes+2).
> This means "we have no answer for the 1st probe" and allows us
> to stop queueing requests. So, we need to queue requests
> only if probes < ucast_probes+2 (cases a, c and sometimes b).
> Of course, if the entry is valid we will queue the brd requests.
> Do you like such checks instead of adding new flag? Or the wishes
> are already too many to continue with this patch?

I think if any cache entry is NUD_VALID you should respond immediately.
anything else you should enqueue request and initiate a discovery to
target.

> 	If you prefer you can take the 20 lines of code from
> http://www.ssi.bg/~ja/tmp/arp_proxy-2.6.2-1.diff and to write
> a pseudo-C example how you feel the handling should be.
> 

Ok, I looked at this and i am wondering if all logic you have is needed.
I apologize in advance because i feel i missed something you said
earlier, but what is wrong with just saying along the following lines:

 if (skb->stamp.tv_sec == 0 ||
    skb->pkt_type == PACKET_HOST ||
    in_dev->arp_parms->proxy_delay == 0) {
         if ((in_dev->arp_parms->proxy_validate) &&
              n && !neigh_is_valid(n)) {
                              /* probably issue arp to tip here */
                              goto q_it;                           
	                                                             
	}                                     
	arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
 } else {
q_it:
         if (fwd_proxy)
              neigh_event_send(n, NULL);
         pneigh_enqueue(&arp_tbl, in_dev->arp_parms, skb);
         in_dev_put(in_dev);
         return 0;
 }
 goto out;

--	


Let me cut your email in two here because it is getting too long


cheers,
jamal
