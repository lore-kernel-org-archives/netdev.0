From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 28 Dec 2004 10:55:39 -0500
Message-ID: <1104249339.1090.134.camel@jzny.localdomain>
References: <200412270715.iBR7Fffe026855@hera.kernel.org>
	 <20041227121658.GI7884@postel.suug.ch>
	 <1104240053.1100.53.camel@jzny.localdomain>
	 <20041228134022.GA32419@postel.suug.ch>
	 <1104242397.1090.94.camel@jzny.localdomain>
	 <20041228145033.GB32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041228145033.GB32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-28 at 09:50, Thomas Graf wrote:
> * jamal <1104242397.1090.94.camel@jzny.localdomain> 2004-12-28 08:59
 
> > If you implement the mothership match changes we discussed then it
> > should go as a match (as opposed to action). As an action its yet
> > another deferal for later cleanup.
> 
> I'm getting more and more careful because we already suffer from
> various limitations by design of underlying layers. I agree that the
> best way would be to make it a generic match but we will end up
> implementing logic expressions code for every layer over and over.

Thats the point of this discussion ;-> We need to figure a way to do it
with minimal damage ;-> I actually dont think its such a bad idea to
change all classifiers this once as long as the backward compat applies.

> I have to think a little more about it, here's an up-to-date brain dump:
> Classifier extensions should no longer be configured over classifier
> specific TLV types but rather be part of a nested TLV. The extesions
> should be changeable directly without going through the classifier
> changing code, i.e. RTM_NEWFEXT/RTM_DELFEXT or something alike. 

Sensible. Also enforce that it gets configured when configuring the
filter - this way binding can happen at installation and not lookup
time.
Now we need to find a clever way to do little coding .. I will give it
some thinking in the background. 
Clearly this has to be interleaved with filtering as opposed to be at
the end of filtering as actions are.

> It
> should be possible to create logic relations between extensions like
> match indev = "eth0" or (nfmark gt 10 or nfmark lt 4).
> 

Ok, so several things from your text in requirements/desires department:
- Reusing existing classifiers is very valuable at that extension level.
We actually could do it today with continue/reclassify except it will be
faster if you could just point to the next classifier rule from the
current classification. Not sure if this makes sense..
- The idea of continue/reclassify is also valuable for match extensions.
- match extensions desire minimalist API. Need to write one page of code
approach ..
- I like the logical relationships you have.


> Doesn't sound too bad but we're actually just implementing things
> on top of classifiers that should actually be on the same level.
> 

Not in the case of the 2 page of code for extra match.

> > So my preference is to get the changes we discussed then this meta
> > match.
> > I could whip out meta action for setting values if you are gonna work
> > on the match piece.
> 
> I was thinking of combining these by simply introducing an ASSIGN
> operator so we don't have redundant code. 

That is still a hack. 

> We could make a generic
> metadata api so netfilter could make use of it.
> 

I can see tc using netfilter but not the other way round without
a lot of complexity.

> > Sounds reasonable at the high level. I am not sure i got the stats part.
> 
> Simple hit/success counters per match to be returned as separate TLV.
> 

Yes, but how do you use them to match?

> > Can you write out the BNF. Heres what i was thinking for meta action:
> 
> tc <OPERATION> meta [NOT] VALUE OPERATOR VALUE

hopefully within a filter since these are not really standalone.
as in filter ... extmatch meta ...

> VALUE ::= { METAVARS | number | pattern }
> OPERATOR ::= { = | > | < | assign }
> 
> where: typeof(METAVAR) for every value pair must be equal

so how would tcindex fit here?

cheers,
jamal
