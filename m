From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 20 Sep 2004 09:44:45 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919234445.GC10124@gondor.apana.org.au>
References: <414D0CCD.90209@eurodev.net> <E1C8way-0000aH-00@gondolin.me.apana.org.au> <20040919120249.GA5963@gondor.apana.org.au> <20040919120730.GA6005@gondor.apana.org.au> <414DF111.3080409@eurodev.net> <20040919215328.GA9573@gondor.apana.org.au> <414E0CE6.107@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <414E0CE6.107@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 12:49:10AM +0200, Pablo Neira wrote:
> 
> Sorry, if i repeat things, I'm not willing to be annoying, just clarifying.

You're alright.  We're on the same side :)

> I'm always talking all the time about sending information from kernel 
> space to user space where I found the problem. There's no problem in 
> doing on the other way, in that case buffer never gets full.

Yes I understand.

> Two problems:
> 
> a) if you request information via nl sockets from user space and a 
> kernel module doesn't use the dontwait flag (I know, *nobody* is doing 
> this at the moment, so currently broadcast/unicast never wait as you 
> remarked).

And if anybody does that then they are buggy.  So let's not slow everybody
down for the sake of a non-existant buggy kernel implementation.

There is no point for the kernel to wait at all.  For unicast sockets
used for sending commands to the kernel, you should never get overruns
if you are reading your responses correctly and have set the queue size
correctly.
 
> b) A module needs to send a lot of information from kernel space to user 
> space, if buffer gets full quickly, buffer overruns and 
> netlink_unicast/broadcast never wait, so they drop packets.

I agree that this may be a problem for some, but I don't see how your
patch addresses it.  For the case of ip_queue the kernel simply cannot
wait since it just creates a queue through the backdoor.  You might as
well just increase your receive queue length.

And if your application can't keep up with the flow of packets, then
whatever we do in the kernel is not going to help.

Congestion control that Jamal talked about is certainly a good idea in
many situations.  But it can't be applied in the situation you're in
because ip_queue can't back off.

> Why someone could call netlink_unicast/broadcast from a module telling 
> them to wait if necessary? if that module want to care about a possible 
> message drop. This happens if you stress nl sockets. This way netlink 
> sockets behave well with an important workload without dropping 
> messages. So the user space part doesn't get that annoying -enobufs error.

I don't understand this paragraph.

> >Your original message mentioned a dead-lock, which is now obviously 
> >non-existant.
> 
> it exists if you use netlink_unicast/broadcast telling them to wait, so 
> it's not a real problem for current applications because they tell 
> netlink_unicast/broadcast not to wait.

s/applications/kernel implementation/

As I said above, if the kernel waits then it's a bug.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
