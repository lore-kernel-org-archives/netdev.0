From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add c/r support for connected INET sockets
Date: Tue, 13 Oct 2009 15:00:49 -0400
Message-ID: <4AD4CE61.30503@librato.com>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>	<1254932945-12578-3-git-send-email-danms@us.ibm.com>	<4AD3A52B.6050101@librato.com>
	<87ws2zcjhe.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        John Dykstra <jdykstra72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ws2zcjhe.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


Dan Smith wrote:
> OL> * Did you test this with UDP too ?
> 
> Not sendmail of course, but I have a little test program that
> maintains a DGRAM connection to the echo service on a remote node,
> yeah.
> 
> OL> * What happens if the the clock on the target machine differs from
> OL> the clock on the origin machine ?  (TCP timestamps)
> 
> I guess maybe we should canonicalize the timeout values to something
> like "milliseconds after checkpoint start"?  This would allow the
> remote system to reset the timers to something reasonable.  It would
> also cause non-migration restarts to restore the timers appropriately
> for a coordinated restart of multiple machines.

IIRC, the TCP stack takes the timestamp for each packet directly from
jiffies. So you need to teach TCP to add a per-container (or you can
make it per-socket) delta to that timestamp.

> 
> OL> * How confident are we that "bad" input in one or more fields,
> OL> that you don't currently sanitize, cannot create "bad" behavior ?
> OL> (bad can be kernel crash, unauthorized behavior, DoS etc)
> 
> I'm going to say 0.052.

Ah ... sure ...
To avoid confusion, can you state the units :p

> 
> I haven't evaluated much of it, no :)

I guess my point is that we want to ask the networking people this
question in an explicit way.

> 
> OL> * How much does TCP rely on the validity of the info in the
> OL> protocol control block, and what sorts of bads can happen if it
> OL> isn't ?  Would TCP be still happy if the URG point is bogus, would
> OL> it allow the user to sent packets otherwise disallowed (to that
> OL> user?), or maybe it could crash the kernel ?
> 
> Good question, I'll have to look.

Ditto.

So I'm thinking, for both, do (1) put a big fat comment in the code
saying that sanity-tests are needed, and what for, and (2) send a
separate mail to the networking people with these two scenarios and
request comments ?

> 
> OL> * Can you please document (brief description) how the restart
> OL> logic works (listening parent socket etc) ?
> 
> Sure.
> 
> OL> * Do you intend to checkpoint (and collect) lingering sockets,
> OL> that is they are closed by the application so not references by
> OL> any task, but still sending data from their buffers ?
> 
> Yeah, I expect that will be important :)

Cool. How about a TODO comment somewhere to convince everyone ( = me)
that you have it in your plans :)

> 
> OL> * I'd like to also preserve the "older" behavior - so the user can
> OL> choose to restart and reset all previous connections, keep
> OL> listening sockets (e.g. RESTART_DISCONNET).
> 
> Sure, sounds good to me.
> 
>>> +	printk("Doing post-restart hash\n");
> 
> (oops, looks like I left some debug messages in place)
> 
> OL> I wonder if a user can use this to convince TCP to send some nasty
> OL> packets to some arbitrary destination, with specific seq-number or
> OL> what not ?
> 
> I'm not sure what you mean.  The sk->num value comes from the sport
> which should have been refused during the bind() if it's in use or not
> permitted, no?

I think Serge already pointed in his review that this should not permit
a user to bind inconsistent or restricted ports.

I actually meant the contrary: suppose a malicious user on your machine
wants to attack a target machine/connection. can that user provide such
destination-address data and protocol parameters to build a connection
that locally seems valid, but is malicious ?

For example, now, if a user wants to send a TCP packet with arbitrary
protocol parameters, he needs to use raw IP sockets, which require
privilege. Would restarting a connection with the desired parameters
become a way to bypass that restriction ?  (e.g. assume the user
restarts while using the host's network namespace).

Oren.
