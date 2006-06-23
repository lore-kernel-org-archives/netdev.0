From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: RE: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Fri, 23 Jun 2006 22:37:27 +1000
Message-ID: <1151066247.4217.254.camel@ras.pc.brisbane.lube>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>
	 <1150292693.5197.1.camel@jzny2>
	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>
	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
	 <1151000966.5392.34.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:35987 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1750760AbWFWMjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 08:39:09 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151000966.5392.34.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 14:29 -0400, jamal wrote: 
> Russell,
> 
> I did look at what you sent me and somewhere in those discussions i
> argue that the changes compensate to make the rate be a goodput
> instead of advertised throughput.

I did see that, but didn't realise you were responding to 
me.  A lot of discussion has gone on since and evidently 
quite a bit of which was addressed to me.  I will try to 
answer the some of the points.   Sorry for the digest 
like reply :(

On Wed, 2006-06-14 at 11:57 +0100, Alan Cox wrote:
> I'm 
> not sure if that matters but for modern processors I'm also sceptical
> that the clever computation is actually any faster than just doing the
> maths, especially if something cache intensive is also running.

Assuming you are referring to the rate tables - I hadn't
thought about it, but I guess I would agree.   However, this 
patch wasn't trying to radically re-engineer the traffic 
control engines rate calculation code.  Quite the reverse I -
was was trying to change it as little as possible.  The kernel 
part of the patch actually only introduced one small change - 
the optional addition of a constant the packet length.

On Thu, 2006-06-15 at 08:57 -0400, jamal wrote: 
> But i dont think it is ACKs perse that you or Russell are contending
> cause these issues. It's the presence of ATM . And all evidence seems to
> point to the fact that ISPs bill you for something other than your
> point of view, no?

I don't know about anywhere else, but certainly here in
Australia some ISP's creative in how they advertise their
link speeds.  Again that is not the issue we were trying 
to address with the patch.

On Thu, 2006-06-15 at 08:57 -0400, jamal wrote: 
> You are still speaking ATM (and the above may still be valid), but: 
> Could you for example look at the netdevice->type and from that figure
> out the link layer overhead and compensate for it.

As others have pointed out, this doesn't work for the ADSL 
user.  An ADSL modem is connected to the box using either 
ethernet, wireless or USB.

On Thu, 2006-06-15 at 09:03 -0400, jamal wrote: 
> It is probably doable by just looking at netdevice->type and figuring
> the link layer technology. Totally in user space and building the
> compensated for tables there before telling the kernel (advantage is no
> kernel changes and therefore it would work with older kernels as well).

Others have had this same thought, and have spent time trying
to come up with a user space only solution.  They failed because 
it isn't possible.  To understand why see this thread:

  http://mailman.ds9a.nl/pipermail/lartc/2006q1/018314.html

Also, the user space patch does improve the performance of 
older kernels (ie unpatched kernels).  Rather than getting 
the rate wrong 99.9% of the time, older kernels only get it 
wrong 14% of the time, on average.

On Tue, 2006-06-20 at 03:04 +0200, Patrick McHardy wrote: 
> What about qdiscs like SFQ (which uses the packet size in quantum
> calculations)? I guess it would make sense to use the wire-length
> there as well.

Being pedantic, SQF automatically assigns traffic to classes 
and gives each class an equal share of the available bandwidth.  
As I am sure you are aware SQF's trick is that it randomly 
changes its classification algorithm - every second in the Linux 
implementation.  If there are errors in rate calculation this 
randomisation will ensure they are distributed equally between 
the classes as time goes on.  So no, accurate packets sizes are 
not that important to SQF.

But they are important to many other qdiscs, and I am sure 
that was your point.  SQF just happened to be a bad example.

On Tue, 2006-06-20 at 10:06 -0400, jamal wrote:
> What this means is that Linux computes based on ethernet
> headers. Somewhere downstream ATM (refer to above) comes in and that
> causes mismatch in what Linux expects to be the bandwidth and what
> your service provider who doesnt account for the ATM overhead when
> they sell you "1.5Mbps".
> Reminds me of hard disk vendors who define 1K to be 1000 to show
> how large their drives are.
> Yes, Linux cant tell if your service provider is lying to you.

No, it can't.  But you can measure the bandwidth you are 
getting from your ISP and plug that into the tc command 
line.  The web page I sent to you describes how to do this
for ADSL lines.

On Tue, 2006-06-20 at 10:06 -0400, jamal wrote:
> > On Mon, 2006-19-06 at 21:31 +0200, Jesper Dangaard Brouer wrote:
> > The issue here is, that ATM does not have fixed overhead (due to alignment 
> > and padding).  This means that a fixed reduction of the bandwidth is not 
> > the solution.  We could reduce the bandwidth to the worst-case overhead, 
> > which is 62%, I do not think that is a good solution...
> > 
> 
> I dont see it as wrong to be honest with you. Your mileage may vary.

Jamal am I reading this correctly?  Did you just say that you 
don't see having to reduce your available bandwidth by 62% to 
take account of deficiencies in Linux traffic engine as wrong?  
Why on earth would you say that?

On Tue, 2006-06-20 at 10:06 -0400, jamal wrote:
> Dont have time to read your doc and dont get me wrong, there is a
> "quark" practical problem: As practical as the hard disk manufacturer
> who claims that they have 11G drive when it is 10G.

This reads like we don't see the same problem in the same way.
Your disk example is a 10% error that effects less savvy users.
The ATM problem we are trying to address effects a big chunk of 
all Linux's traffic control users.  (Big chunk as counted by
boxes, not bytes.)

Something like 60% of all broadband connections use ADSL.  Most 
of the remainder live in the US and use cable. Or at least so 
says this web page:
  http://tinyurl.com/pydnj
Extrapolating from that, I think it is safe to say fair chunk
of all people using the Linux Traffic Control engine use ADSL,
and thus may benefit from this patch.

Now it is true that right now these people may not see a great
benefit from the patch.  Those that will are divided into two
categories:

1.  Those that saturate their upstream bandwidth.  This isn't
    hard to do on ADSL, due to its first letter.  It effects
    people who use run web sites, email lists - which is bugger
    all, and those who play games or run P2P - which is most
    home users.

2.  Those that use Voip.  Again there aren't many people who do
    this right now, but that will change.  Its not hard to 
    envisage a future where real time streaming like this will
    come to dominate Internet traffic.  Voip effects the other
    major group of users out there - business.

Ergo I believe that in the long term the patch will benefit a
lot of people.  The next argument is how much it will benefit
them.

It turns out that the patch is only useful if you have some
small packets that MUST have priority on the ADSL link. 
Jesper's traffic was TCP ACK's (he was addressing problem 1) 
and mine was VOIP traffic.  This would seem a trivial problem 
to solve with Linux's traffic control engine.  I don't know 
what path Jesper took - but I tried using it in the obvious 
fashion and it didn't work.  A couple of large emails would 
take out an office's phone system.  It took me days of head 
scratching to figure out why.

The cause was ADSL using ATM as a carrier.  In my case I was 
using approx 110 byte packets.  Do the sums.  It takes 3 ATM 
cells to carry an 110 byte packets.  That is 159 bytes.  A
50% error.  That meant the ISP was doing the traffic control, 
and he wasn't prioritising VOIP traffic.  Sure, you can 
optimise the values  you pass to tc for 110 byte packets.  But 
then it fails miserably for a other packet sizes; such as 
a different VOIP codec, or TCP acks. The only solution is to 
understate your available bandwidth by at least a 1/3rd.  I 
hope you don't consider that acceptable.

The reason this patch wasn't thought of until now is that
large packets don't see much benefit.  For similar packet
sizes the maximum error is determined by the ATM cell size 
(you can be +/- one ATM cell) and that is 53 bytes.  This 
means on packets around MTU size the error is 53/1500 = 3.5%.  
Hardly worth worrying about.  For traditional Internet usage, 
ie the one ADSL was designed for, the upstream channel, ie 
the one carrying the TCP ACKS, was rarely saturated.  The 
speed was limited by the downstream channel - the one 
carrying MTU sized packets.

So in summary - no, Jamal, I see no correspondence between 
your 10/11Gb hard drives example and this patch.

On Tue, 2006-06-20 at 10:06 -0400, jamal wrote:
> It needs to be
> resolved - but not in an intrusive way in my opinion.

To be honest, I didn't think the patch was that intrusive.
It adds an optional constant to the skb->len.  Hardly earth
shattering.

On Tue, 2006-06-20 at 16:45 +0200, Patrick McHardy wrote: 
> Handling all qdiscs would mean adding a pointer to a mapping table
> to struct net_device and using something like "skb_wire_len(skb, dev)"
> instead of skb->len in the queueing layer. That of course doesn't
> mean that we can't still provide pre-adjusted ratetables for qdiscs
> that use them.

Yes, that would work well, and is probably how it should of
been done when the kernel stuff was originally written.  As 
it happens Jesper's original solution was closer to this.  The 
reason we choose not to go that way it is would change the 
kernel-userspace API.   The current patch solves the problem 
and works well as possible on all kernel versions - both 
patched and unpatched.

Now that I think about to change things the way you suggest
here does seem simple enough.  But it probably belongs in a 
different patch.  We wrote this patch to fix a specific problem 
with ATM links, and it should succeed or fail on the merits 
of doing that.  Cleaning up the kernel code to do what you 
suggest is a different issue.  Let whether it to should be 
done, or not, be based on its own merits.

On Tue, 2006-06-20 at 11:38 -0400, jamal wrote: 
> The issue is really is whether Linux should be interested in the
> throughput it is told about or the goodput (also known as effective
> throughput) the service provider offers. Two different issues by
> definition. 
<snip>
On Thu, 2006-06-22 at 14:29 -0400, jamal wrote:
> I did look at what you sent me and somewhere in those discussions i
> argue that the changes compensate to make the rate be a goodput
> instead of advertised throughput. Throughput is typically what 
> schedulers work with and is typically to what is on the wire.
> Goodput tends to be end-to-end; so somewhere down the road ATM
> "reduces" the goodput but not the throughput.
> I am actaully just fine with telling the scheduler you have less
> throughput than what your ISP is telling you. I am also
> not against a generic change as long as it is non-intrusive because i
> believe this is a practical issue and Patrick Mchardy says he can
> deliver such a patch.

I have read your throughput versus goodput thing a couple of
times, and I'm sorry - I don't understand.  What is it you
would like us to achieve?

As for the patch being invasive, it changes 37 lines of 
kernel code.  No other suggestion I have seen here will be 
that small.

If making the patch generic, ie allowing it to handle cell 
sizes other than ATM, then let me know I will make the
change on the weekend.  It is just a user space change.

One final point: if you are happy with an invasive patch that
changes the world, I have a suggestion.  Modularise the rate
calculation function.  We have qdisc modules, filter modules
and whatnot - so add another type.  Rate calculation.  The
current system can become the default rate calculation module
if none is specified.  Patrick can have his system, and Alan
can have his.  And we can add an ATM one.  If you wish, I can
(with Jespers help, I hope) re-do the patch in that style,
producing the default one and an ATM one.  My personal
preference though would be to put this patch in, and then
let this new idea stand or fall on its own merits.

