From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 29 Sep 2004 06:50:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096455046.1044.189.camel@jzny.localdomain>
References: <20040928024614.GA9911@gondor.apana.org.au>
	 <1096340772.8659.51.camel@jzny.localdomain>
	 <20040928032321.GB10116@gondor.apana.org.au>
	 <1096343125.8661.96.camel@jzny.localdomain>
	 <20040928035921.GA10675@gondor.apana.org.au>
	 <1096367787.8662.146.camel@jzny.localdomain>
	 <20040928111159.GA18421@gondor.apana.org.au>
	 <1096374736.8663.217.camel@jzny.localdomain>
	 <20040929001327.GB25293@gondor.apana.org.au>
	 <1096426324.1044.129.camel@jzny.localdomain>
	 <20040929032724.GA26959@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040929032724.GA26959@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-28 at 23:27, Herbert Xu wrote:
> On Tue, Sep 28, 2004 at 10:52:05PM -0400, jamal wrote:
> >
> > > You're right.  rtmsg_info() is using GOODISZE unnecessarily.  I'll
> > > write up a patch.
> > 
> > But why? ;->
> 
> So that the alloc_skb() is slightly less likely to fail. 

[..]
Ok, You fell into my trap. I just had to say that ;-> We are even.

> > Well, if you are gonna overrun the socket anyways, is there a point
> > in delivering all that incomplete info?
> >
> > If you go ahead and deliver it anyways, you will be crossing
> > kernel->userspace. Its a worthy cause to do so.
> 
> Hang on a second, if we're going to overrun anyway, then we *can't*
> deliver it to user-space.  If we could deliver then we wouldn't be
> having an overrun.

Assume you are delivering a huge atomic multi message; lets say it
constitutes 50 pkts.
--> You deliver up to 15 and then overrun.
--> The 15 pkts are a waste, really. User will have to poll
for the info for all details to be sure i.e you dont know what was lost
for sure if you get an overrun. In otherwise the transaction was not
delivered to its completion.

> > > Can you please elaborate on "crossing into user space"? I don't think
> > > I understand where these cycles are being wasted.
> > 
> > delivering messages which get obsoleted by an overun from kernel to user
> > space for uses up unnecessary cycles.
> 
> You'll have to spell it out for me I'm afraid :)

See above.

> If we're overrunning then we can't deliver the message at hand.  If you
> are referring to the messages afterwards then the only way we can deliver
> them is if the appliation lets us by clearing the queue.  If you are
> referring to the messages that are already on the queue then we've done
> the work already so why shouldn't they stay?

I was refering to above scenario. To continue that example:
--> 15 pkst made it
--> some gap then lost skbs (maybe due to allocation issues etc)
--> If you recover and have the last 10 out of 50, then they are
obsolete. If you already did the work of collecting them, then reduce
the mess by not having the user copy them. 
I dont think 10 are a big deal but multiply by some factor and the cost
is clear to quantify.

[..]
> we extend the dump paradigm to cover get as well.  However, to design the
> interface, we need to look at potential users of this.  So please give
> me an example :)

extending get to do the dumplike approach is not a bad idea.

I said dont ask me for an example ;-> You provide the mechanism, you be
ready for the consequences - people will use it. Thats a good enough
reason;->
If you insist however, heres one i can visualize thats a legit get from
a semantic view:
A get of a table entry which itself happens to be a table (and if you
want to be funnier maybe three level deep table). You do a get on a
table entry, you get a _whole table_ back. 

> > > Not quite.  Overrun errors are reported immediately.  
> > 
> > Yes, except they get reported sooner (by virtue of queue getting filled
> > sooner) if you have a 4K sock buffer vs 1M if you are registered for the
> > same events. I Know its a digression - just making a point.
> 
> The one with the 1M buffer may not overrun at all if it can process the
> events fast enough.

Ok, i will agree to that but the assumption in the example is both will
be overrun by the same set of messages. To argue (for the sake of
arguing) say the 4K buffer user was faster;-> Lets drop this bit.

> > congestion - especially in a local scenario. Of course such queues have 
> > finite buffers - you just engineer it so the queue doesnt overflow and
> > head of line blocking is tolerable. Either of those concerns not
> > addressed, shit will hit the fan.
> 
> I don't see how you can engineer it so that it doesn't overflow. 

Sorry, you cant. I meant you have to get the two to work together.


cheers,
jamal
