From: jamal <hadi@cyberus.ca>
Subject: Re: IPSEC: on behavior of acquire
Date: 03 Apr 2005 10:29:27 -0400
Message-ID: <1112538566.1096.391.camel@jzny.localdomain>
References: <1112405303.1096.37.camel@jzny.localdomain>
	 <424E454D.4090402@gmc.lt> <1112477326.1088.321.camel@jzny.localdomain>
	 <424FA946.70809@gmc.lt>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
In-Reply-To: <424FA946.70809@gmc.lt>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-04-03 at 04:28, Aidas Kasparas wrote:
> jamal wrote:

> > Exactly what i was trying to emulate - lost messages. 
> 
> Your emulation was not correct. More correct would have been to start KE 
> daemon, let it fully initialize (open pfkey socket, inform kernel that 
> it is interested in acquire messages), then stop it (via debugger or 
> kill -STOP) and only then send pings or other traffic and see what will 
> happen. This is because there are different paths in xfrm+pfkey for 
> cases 1) when there is no KE daemon and 2) when daemon is, but for some 
> reason it does not establish a SA and therefore reaction to traffic is 
> different.
> 

I dont think that would work.
To summarize what happens in the kernel: everything leads to km_query()
as you have indicated in your text. 
If the kernel finds someone/thing has either a pfkey or netlink socket
open it sends a acquire to them. In the code you are probably looking at
(before i created the patch) - the first user/daemon the kernel sees
(either pfkey or netlink based) that has a socket open
will receive an acquire and the kernel will give up after that.

As an example, if the first pfkey user was just doing "setkey -x" and
the second was infact pluto, then pluto will never see the 
acquire. This is what got me looking at it to begin with. Look at the
earlier postings on the subject.
So in other words, just killing the ike server as you propose would mean
the kernel has no open sockets and will therefore never bother to send
an acquire.

Still all this is moot and is distracting us from the main discussion.
Lets define "lost"  simply as the case where an acquire never got to the
server (which may be sitting elsewhere on the network). In that case
what i did is sufficient. i.e. The methods to create this are not the
issue. The issue at stake is the behavior of the kernel in generating
the acquires.

[..]

> On the other hand, analysis above shows that return code is choosen by 
> xfrm framework, therefore if error code has to be changed, it should be 
> changed in xfrm, not in pfkey or netlink code.

The control for both is under generic code. The end return code - you
are right, thats user behavior and should match.

> > One could look at the acquire as part of the "connection" setup
> > (for lack of better description). Without the acquire succeeding, theres
> > no connection..(assuming that to be a policy).
> > Therefore if acquire is not supposed to be delivered with some certainty
> > (read: retries) then theres some resiliciency issues IMO.
> 
> OK, To avoid speaking about apples and oranges let's first find out 
> where you see the problem. In the ipsec framework there are the 
> following players (I'm speaking about pfkey case; netlink may be little 
> different):
> 
> xfrm <-> pfkey <-> KE daemon <-> remote peer
> 
> xfrm-pfkey communication is based on function calls. For them to fail 
> something really weird has to happen with your kernel.
> 
> KE deamon - remote peer communications are done on UDP/500, UDP/4500 
> according to internet standards. Packet retransmissions are implemented 
> the way standards require, therefore it is not a fatal condition if some 
> packet will be lost on the way.

Please refer to my earlier definition of what "lost" means. It doesnt
matter where the breakage happens really.
Think of everything to the right of "xfrm" in your diagram as a black
box (i.e that second thing could be pfkey or netlink - thats not the
issue). 
Think of some message that is supposed to reach the KE daemon
(make it interesting and say it is remote KE) then think of that message
never making it because something in the blackbox swallowed it.
If that packet is the first one and it needs to do so for the sake of 
setup for subsequent packets - then the desire to have it reach its
destination is very imprtant. There is no progress for it or subsequent
packets if it doesnt make it.

The solution being proposed for Linux to treat that xfrm piece in the
same fashion as ARP is correct. Read the email from Alexey. Imagine if
ARP was only issued once(as does pfkey) or forever(as does netlink).

I believe this is an issue with ipsec architecture itself - someone
needs to write an IETF draft on it.

> 
> >  
> > Note: Sometimes theres no app. Example a packet coming into a gateway.
> > 
> 
> What do you have in mind?
> 
> If it is ISAKMP negotiation from remote peer, then it comes over UDP/500 
> or UDP/4500 over IP socket and not via acquire message via pfkey socket.
> 
> If it is ESP/AH packet with unknown SPI, then kernel simply drops it and 
> do not send any acquire messages.
> 

I was thinking more of this second scenario with incoming from clear
text domain and gateway encrypting assuming proper policy setup. 
I would have to go and reread the "opportunistic" encryption draft 
closely to make sense.

> > Havent tried that - the reason i said restart was the right signal was
> > mainly that an app could translate that to mean "try again".
> > In other words even in the case of ping -c1 the ping app could have 
> > reattempted.
> 
> If there is security policy which is not satisfied and there is nobody 
> which could make it satisfied, then why should we give application false 
> hope that on retry things will change?
> 

In the case of knowing it is the policy that is not satisfied i think it
would make sense to not to tell the app to retry. 

> > 
> > What about ERESTART the way netlink does it right now?
> 
> I suspect that ERESTART is generated not by netlink, but by 
> xfrm_lookup() function when signal_pending(current) is true. Why that 
> function returns true in netlink case but not in pfkey case I don't 
> know. IMHO, xfrm_lookup() returns correct error codes in that case.
> 

yes, you are correct.

> > ECONNREFUSED is probably not a bad idea.
> > ping was clearly dumb and didnt do anything with the info.
> > Overall, I think the errors are unfortunately not descriptive at all.
> 
> I don't like ECONNREFUSED in this place. As a user if I would receive 
> ECONNREFUSED message then I would address application server admin or 
> remote host admin to resolve the problem. But the problem is in network 
> setup and therefore person responsible for networks should be contacted. 
> Therefore, I would like more ENETUNREACH or EHOSTUNREACH.
> 

Agreed to this as well. I think this is what would happen in the case of
ARP failure as well.
ECONNREFUSED would make sense in the case where the policy rejected
progress.

cheers,
jamal
