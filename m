From: jamal <hadi@cyberus.ca>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: 11 Feb 2004 23:48:47 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076561326.1032.62.camel@jzny.localdomain>
References: <Pine.LNX.4.44.0402111534310.2809-100000@l>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0402111534310.2809-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-02-11 at 09:32, Julian Anastasov wrote:

> > > 	I did it during my initial tests and now I tested it
> > > again, looks as expected.
> >
> > I am not %100 sure if such an entry should be route cached if the nh
> > is not resolvable. What are your thoughts on this?
> 
> 	It looks bad to call route_slow for every one request,
> I have to think more about it.

If you make another get it goes via fast path.
The disappointing part is this feature has a lot of potential
if it works "correctly" (imagine being able to populate route cache
before packet arrives and not needing for packet to go via slow path).

>> I think if any cache entry is NUD_VALID you should respond
>>immediately.

>        No, we should delay the broadcasts if such delay is
> configured. For unicasts we respond immediately.

Ok, extend that to say "if we have to respond immediately we may check
if the target is valid"

> anything else you should enqueue request and initiate a discovery to
> target.
> 	By checking ->probes we queue !VALID entries only
> when switching from FAILED to INCOMPLETE. For example:
> 
> - we have 3 brd probes configured to send
> 
> - request comes
> 
> - we send 1st brd probe for target and enqueue this incoming request
> and all requests coming before we send the 2nd probe
> 
> - we send 2nd probe (still no answer for the 1st)
> 
> - at this point we know that target is really dead and we do not
> need to queue more incoming requests (even brd ones) until target
> responds (the queue has limit)
> 
> - this cycle repeats on each 3 seconds which means that for 1
> second we queue requests and for 2 seconds we just drop

I am indifferent about the above (and it may be complicating things). 

> 	There is possible loop in this example (as DaveM warned)
> when ((tv_sec=0 or delay=0) and !valid) but it can be fixed 

Correct
Note the point i was trying to make in that snippet is: the
valuable piece is in checking that for cases where we respond 
immediately we at least validate the state of the target.
To me thats all you need to do ;->

> (then
> you will have code in similar size :)). 
>
> The problem is that I
> wanted to avoid creating new flag if there is no need to support
> the old behavior in the real life. Also, we have choice to apply
> delay according to the proxy type (DNAT/fwd/pneigh) and the
> probes sent.
> 

Ok, remove the flag. That one piece is safe. I didnt understand
why you have to speacial case for "NAT/fwd/pneigh" 

> 	Also, you do not call neigh_event_send when
> request with tv_sec!=0 comes. 

I think we have been this whole issue severely (i.e you understand my
view and i understand yours) - lets get a closure. Heres where i stand:
- checking validity in fast response is fair game and doesnt need a flag
- loops must be avoided

Some of your features are fine except they may be a little extreme.
Note, this code has been to work well for years, the minimalist
approach to features would be the best approach.

cheers,
jamal
