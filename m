From: jamal <hadi@cyberus.ca>
Subject: Re: [Ipsec-tools-devel] Re: IPSEC: on behavior of acquire
Date: 04 Apr 2005 08:33:27 -0400
Message-ID: <1112618007.1096.465.camel@jzny.localdomain>
References: <1112405303.1096.37.camel@jzny.localdomain>
	 <424E454D.4090402@gmc.lt> <1112477326.1088.321.camel@jzny.localdomain>
	 <424FA946.70809@gmc.lt> <1112538566.1096.391.camel@jzny.localdomain>
	 <425067D9.9050603@gmc.lt>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
In-Reply-To: <425067D9.9050603@gmc.lt>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-04-03 at 18:02, Aidas Kasparas wrote:
> jamal wrote:
[..]
> > As an example, if the first pfkey user was just doing "setkey -x" and
> > the second was infact pluto, then pluto will never see the 
> > acquire. This is what got me looking at it to begin with. Look at the
> > earlier postings on the subject.
> 
> While I agree that code before your patch would not allow to cooperate 
> tools using different ways to manage SAD/SPD (pfkey vs netlink), I have 
> one setup in production where two instances of racoon runs 
> simultaneously and both gets required pfkey-messages.
> 

yes, multiple instances of the same socket type would work. Try running 
"ip xfrm mon" and your two racoon instances and see what happens;->
Anyways this will be fixed in upcoming kernels.

> > So in other words, just killing the ike server as you propose would mean
> > the kernel has no open sockets and will therefore never bother to send
> > an acquire.
> 
> I proposed to stop KE server, not to kill it.
> 

The goal is: An acquire that the kernel thinks it sent successfuly in
order to update a SA larval state never made it. 
To simulate this, it doesnt matter whether it happened in kernel-user
space boundary or afterwards.
The simple observation to make is: the kernel thinks the desired
objective has been reached when it was not and from the little
investigation conclude the kernel did not try to reliably deliver the
message. 
> > 
> > Still all this is moot and is distracting us from the main discussion.
> > Lets define "lost"  simply as the case where an acquire never got to the
> > server (which may be sitting elsewhere on the network). 
> 
> ACQUIREs _never_ _leaves_ _the box_ they are generated. It is allways 
> kernel-to-userspace_process communication. It could be made reliable. 
> And present situation IS sufficiently reliable.
> 

I think i have made a bad case of explaining.
Yes, I know where acquires terminate. However this is not about where
acquires terminate. It is insufficient to assume that a succesful
acquire to user space equates to successful interaction to the KE server
which will do an update.
Does that make more sense?

If you issue an acquire from the kernel it will result in a domino
effect in the blocks to the right of xfrm in your diagram and the end
result is the larval SA gets an update (as a result of the acquire).
So ignore where/how the acquire gets there and imagine that kernel sent
an acquire so you could get an SA update then it will become clear.

> OK, let's talk about architecture xfrm <-> blackbox. In this 
> architecture communication between these two elements (I do not speak 
> about any comms in the blackbox) can be of two types:
> 1) reliable (messages always reach blackbox or error is reported);
> 2) unreliable (messages may fail even to reach blackbox).
> 
> With good blackboxes good ipsec system can be built using any of comm 
> types. But:
> a) (1) will be more reliable;
> b) (1) will be more simple (at least xfrm side, as it will not require 
> retransmisions);
> c) (1) is implemented now (as a function call).
> 
> What I want to say is xfrm-to-blackbox interface is good as it is. The 
> problem may only be in how good the blackbox is. And here we have to 
> look inside blackbox and start talk about particular implementations of 
> that blackbox. Retransmitions, if they needed, needs to be inside that 
> blackbox.
> 

I am not sure i followed what you are actually trying to say above.
Lets discuss basics of how reliability is achieved. If you want to have
something reliably delivered after you transmit
you do several basic things:
a) you wait for an end acknowledgement, in this case an update to the
acquire 
b) you timeout within reasonable time (30 seconds seems to be the
default in acquire) and 
c) you retransmit upto a maximum number of times. This is the part that
is missing

> > 
> > The solution being proposed for Linux to treat that xfrm piece in the
> > same fashion as ARP is correct. Read the email from Alexey. Imagine if
> > ARP was only issued once(as does pfkey) or forever(as does netlink).
> > 
> 
> I have read email from Alexey. I think that xfrm_lookup() function 
> implements functionality very similar to functionality which Alexey 
> described.

Absolutely not. But this is a good sign - i.e you see the desire to do
this, you just think its already there.

> And I think that direct comparison of ARP messages and pfkey messages is 
> not fair, because pfkey acquire messages goes over reliable traffic and 
> are used only to _initiate_ the process of SA negotiation. ARP has to 
> receive information from other boxes which send it only as a direct 
> responce to some packet. More, ARP is designed to be used [amogst 
> others] on networks which loose some traffic by design.
> 

Please refer to my above statements as to what is missing to complete
the equation.

> > I believe this is an issue with ipsec architecture itself - someone
> > needs to write an IETF draft on it.
> > 
> 
> I still do not see the topic for such draft.
> 

Read again what i said above.

cheers,
jamal
