From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate packet scheduling	for	ATM/ADSL
 (kernel)
Date: Mon, 23 Oct 2006 14:39:29 +0200
Message-ID: <453CB801.4010902@trash.net>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>	 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net> <1161602527.5502.155.camel@ras.pc.stuart.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:20363 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751937AbWJWMjc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Oct 2006 08:39:32 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1161602527.5502.155.camel@ras.pc.stuart.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Russell Stuart wrote:
> On Thu, 2006-10-19 at 16:38 +0200, Patrick McHardy wrote:
> 
>>I still think this patch shouldn't go in. There's no point in doing the
>>same thing twice, and I haven't heard a compelling argument why it has
>>to be done in a way that only helps qdiscs using rtabs while ignoring
>>statistics and estimators (I even provided a patch to show how to do
>>it without these limitations).
> 
> 
> As far as I can see one patch changes the way the 
> kernel calculates packet lengths, and the other modifies 
> RTAB.  I can not see the significant overlap between the 
> patches that you talk about.

The implementation may be different, but the intention and the
result is the same. I probably would mind less if it wouldn't
affect userspace compatibility, but we need to carry this stuff
for ever even if we add another implementation that covers all
qdiscs.

> As for why haven't got a new patch from me that addresses 
> the "doing the same thing twice" issue - it is because I
> can see no such issue.  I have asked you repeatedly to
> explain it further, but you have not done so.

What do I need to explain further? As I stated several times,
I would like to see a patch that handles all qdiscs. And it
should probably not have hardcoded ATM values, there is other
media that behaves similar.

> As for "providing a patch" - I believe at the time you
> called it something you were working on.  As far as I
> know you still are working on it.  Besides, even if you
> did intend me to take it further, I am not particularly 
> interested in the packet length issue as it does not 
> effect the real world performance of any of the qdiscs 
> I use.

No, I'm not working on it currently, it was more meant for
demonstration purposes. If you're not interested in taking
the opinion of people working on the code into account thats
your problem.

>>Besides that:
>>
>>+static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, int pktlen)
>>+{
>>+	int slot = pktlen + rtab->rate.cell_align;
>>+	if (slot < 0)
>>+	  	slot = 0;
>>
>>Why would it go negative? A negative cell_align doesn't make sense I
>>guess.
> 
> 
> A negative cell align is possible, and in fact is typical.
> If slot ended up being less than 0 then the configuration
> parameters passed to "tc" would of been wrong - they could
> not of matched the actual traffic.  The error can't be 
> detected in "tc", but it can't be allowed to cause the
> kernel to index off the end of an array either.

I'm not sure I understand what you're saying here. The transmission
time gets _smaller_ by transmitting over ATM? Does this have anything
to do with the off-by-one during rate table calculation you or
Jesper noticed?

>>+	slot >>= rtab->rate.cell_log;
>>+	if (slot > 255)
>>+		return rtab->data[255] + 1;
>>
>>Whats the point of this? Is it just to keep htb giant statistics
>>working?
> 
> 
> Yes.

TBF and policers already make sure this can never happen, this is
what HTB should do as well. If it is also needed for CBQ it is
a bugfix and should be done seperately.

