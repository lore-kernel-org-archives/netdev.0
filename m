From: jamal <hadi@cyberus.ca>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: 11 Feb 2004 08:40:46 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1076506090.2268.252.camel@jzny.localdomain>
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

On Tue, 2004-02-10 at 20:52, Julian Anastasov wrote:

> > > 2. we lie and send false answers to unicast probes, for long time
> > > after target becomes unreachable
> >
> > This is current behavior; i wouldnt say we lie rather we send educated
> > response back.
> 
> 	To clear this issue, do you mean this case 2 is for entry in
> STALE state? And because we are not probing it its state in our cache is
> outdated. You prefer in this case to send answer, right? Because I
> do not see a good reason to send answer for FAILED/INCOMPLETE/NONE.
> And because STALE is part of VALID we always will send answer,
> no matter brd/uni. I do not see where we need to send ARP reply
> for !NUD_VALID.

I agree with you. We may be saying the same thing. What i mean is [**]:
further below.

> > > I can agree with you (for case 2) only if the requestor is
> > > not going to send unicast probes forever.
> >
> > Thats why i asked if you are trying to catch insane implementation.
> > In my case everything is Linux. Ok, theres some pollution with
> > a CISCO upstream, but that seems to have a sane arp too.
> > Leave #2 with a flag to ask for for neigh_event_send() to be used
> > when needed.
> 
> 	I only worry if you want to send replies to unicast
> probes in FAILED/INCOMPLETE/NONE state. If we have valid neighbour,
> even STALE one, we can send reply no matter the uni/brd type.
> brd/uni are differently treated only for the delay but we should
> ignore both uni and brd requests if the entry is !VALID.

Thats what i was also trying to say with a small caveat
in [**].

> 	I think, it is not enough the flag to control whether
> neigh_event_send is used, if the flag is 0 you want also to
> send replies in !VALID state (as before) because nobody will
> send us IP traffic without receiving answer from us - only
> IP traffic can originate resolution in such case. For now, I
> see that the flag can be only in this way (on output interface?):

Look at that sample code i sent earlier - thats what ive been meaning to 
say all along ;-> Gives meaning to code speaks louder ;->
 
> - 0: (default, as before): send answers in !VALID, do not use
> neigh_event_send. The problem with the old behaviour is that
> we always send answer, even in !VALID.
> 

yes.

> - 1: (new): do not send answers in !VALID, use neigh_event_send
> 
> 	do you mean the same?
> 

I think so.

> > I dont question the validity of this portion of your patch.
> > i.e it is an improvement in certain cases - the cost is only an extra
> > neigh_event_send(). But because it is not needed 100% of the time given
> 
> 	And I do not see any cost in using neigh_event_send,
> you are always going to fire the resolution process, now with ARP
> probes or later with IP traffic in the default mode. The ARP
> traffic to/from target will be equal in both cases.

Ok, so you agree with what i say in [**] but you are just trying to
ensure it happens all the time i think. 

> > the educated assumption being made right now, i think the behavior
> > should be configurable. For me #2 breaks only if the target dissapeares
> > (cable gone or target removed).
> 
> 	I hope you can clarify your idea with pseudo-C example :)

The previous sample i sent + [**] below.
Note that in the sample code i sent case of proxy_delay being zero even 
bcasts are treated the same way.

[..]

[**] If a linux machine (which is sane ARP implementation) sent a unicast 
probe to us, theres high likelihood that the target is in VALID state. 
This is what i refered to as an educated guess.

cheers,
jamal
