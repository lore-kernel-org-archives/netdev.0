From: Aidas Kasparas <a.kasparas@gmc.lt>
Subject: Re: IPSEC: on behavior of acquire
Date: Mon, 04 Apr 2005 01:02:01 +0300
Message-ID: <425067D9.9050603@gmc.lt>
References: <1112405303.1096.37.camel@jzny.localdomain>
 <424E454D.4090402@gmc.lt> <1112477326.1088.321.camel@jzny.localdomain>
 <424FA946.70809@gmc.lt> <1112538566.1096.391.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <1112538566.1096.391.camel@jzny.localdomain>
To: hadi@cyberus.ca
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



jamal wrote:
> On Sun, 2005-04-03 at 04:28, Aidas Kasparas wrote:
> 
>>jamal wrote:
> 
> 
>>>Exactly what i was trying to emulate - lost messages. 
>>
>>Your emulation was not correct. More correct would have been to start KE 
>>daemon, let it fully initialize (open pfkey socket, inform kernel that 
>>it is interested in acquire messages), then stop it (via debugger or 
>>kill -STOP) and only then send pings or other traffic and see what will 
>>happen. This is because there are different paths in xfrm+pfkey for 
>>cases 1) when there is no KE daemon and 2) when daemon is, but for some 
>>reason it does not establish a SA and therefore reaction to traffic is 
>>different.
>>
> 
> 
> I dont think that would work.
> To summarize what happens in the kernel: everything leads to km_query()
> as you have indicated in your text. 
> If the kernel finds someone/thing has either a pfkey or netlink socket
> open it sends a acquire to them. In the code you are probably looking at
> (before i created the patch) - the first user/daemon the kernel sees
> (either pfkey or netlink based) that has a socket open
> will receive an acquire and the kernel will give up after that.
> 
> As an example, if the first pfkey user was just doing "setkey -x" and
> the second was infact pluto, then pluto will never see the 
> acquire. This is what got me looking at it to begin with. Look at the
> earlier postings on the subject.

While I agree that code before your patch would not allow to cooperate 
tools using different ways to manage SAD/SPD (pfkey vs netlink), I have 
one setup in production where two instances of racoon runs 
simultaneously and both gets required pfkey-messages.

> So in other words, just killing the ike server as you propose would mean
> the kernel has no open sockets and will therefore never bother to send
> an acquire.

I proposed to stop KE server, not to kill it.

> 
> Still all this is moot and is distracting us from the main discussion.
> Lets define "lost"  simply as the case where an acquire never got to the
> server (which may be sitting elsewhere on the network). 

ACQUIREs _never_ _leaves_ _the box_ they are generated. It is allways 
kernel-to-userspace_process communication. It could be made reliable. 
And present situation IS sufficiently reliable.

In that case
> what i did is sufficient. i.e. The methods to create this are not the
> issue. The issue at stake is the behavior of the kernel in generating
> the acquires.
> 

See below.

> 
> Please refer to my earlier definition of what "lost" means. It doesnt
> matter where the breakage happens really.
> Think of everything to the right of "xfrm" in your diagram as a black
> box (i.e that second thing could be pfkey or netlink - thats not the
> issue). 
> Think of some message that is supposed to reach the KE daemon
> (make it interesting and say it is remote KE) then think of that message
> never making it because something in the blackbox swallowed it.
> If that packet is the first one and it needs to do so for the sake of 
> setup for subsequent packets - then the desire to have it reach its
> destination is very imprtant. There is no progress for it or subsequent
> packets if it doesnt make it.

OK, let's talk about architecture xfrm <-> blackbox. In this 
architecture communication between these two elements (I do not speak 
about any comms in the blackbox) can be of two types:
1) reliable (messages always reach blackbox or error is reported);
2) unreliable (messages may fail even to reach blackbox).

With good blackboxes good ipsec system can be built using any of comm 
types. But:
a) (1) will be more reliable;
b) (1) will be more simple (at least xfrm side, as it will not require 
retransmisions);
c) (1) is implemented now (as a function call).

What I want to say is xfrm-to-blackbox interface is good as it is. The 
problem may only be in how good the blackbox is. And here we have to 
look inside blackbox and start talk about particular implementations of 
that blackbox. Retransmitions, if they needed, needs to be inside that 
blackbox.

> 
> The solution being proposed for Linux to treat that xfrm piece in the
> same fashion as ARP is correct. Read the email from Alexey. Imagine if
> ARP was only issued once(as does pfkey) or forever(as does netlink).
> 

I have read email from Alexey. I think that xfrm_lookup() function 
implements functionality very similar to functionality which Alexey 
described.

And I think that direct comparison of ARP messages and pfkey messages is 
not fair, because pfkey acquire messages goes over reliable traffic and 
are used only to _initiate_ the process of SA negotiation. ARP has to 
receive information from other boxes which send it only as a direct 
responce to some packet. More, ARP is designed to be used [amogst 
others] on networks which loose some traffic by design.

> I believe this is an issue with ipsec architecture itself - someone
> needs to write an IETF draft on it.
> 

I still do not see the topic for such draft.

> 
>>> 
>>>Note: Sometimes theres no app. Example a packet coming into a gateway.
>>>
>>
>>What do you have in mind?
>>
>>If it is ISAKMP negotiation from remote peer, then it comes over UDP/500 
>>or UDP/4500 over IP socket and not via acquire message via pfkey socket.
>>
>>If it is ESP/AH packet with unknown SPI, then kernel simply drops it and 
>>do not send any acquire messages.
>>
> 
> 
> I was thinking more of this second scenario with incoming from clear
> text domain and gateway encrypting assuming proper policy setup. 

If you're talking about network behind security gateway communicating to 
host or network for which there is security policy configured on 
gateway, then acquire message will be generated on that security 
gateway, when that packet will be considered for forwarding. Again, that 
acquire messages never will leave security gateway.

> I would have to go and reread the "opportunistic" encryption draft 
> closely to make sense.
> 

Speaking of "opportunistic" encryption. I never understood it. 
Ipsec-tools do not implement it. And in the year or so when I'm involved 
with it, I don't remember anybody even asking or mentioning about this 
feature. Therefore, I don't care about it -- users do not need it.


-- 
Aidas Kasparas
IT administrator
GM Consult Group, UAB
