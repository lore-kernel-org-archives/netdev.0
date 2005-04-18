From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] QoS: frg queue (was [RFC] QoS: new per flow queue)
Date: Mon, 18 Apr 2005 09:14:23 -0400
Message-ID: <1113830063.26757.15.camel@localhost.localdomain>
References: <20050407203631.02CF.LARK@linux.net.cn>
	 <1112964208.1088.226.camel@jzny.localdomain>
	 <20050413131916.030F.LARK@linux.net.cn>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
In-Reply-To: <20050413131916.030F.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Wang Jian,

On Wed, 2005-13-04 at 13:45 +0800, Wang Jian wrote: 
> Hi jamal,
> 
> Sorry for the late reply. I am occupied by other things and just have
> time back to this topic.
> 

Well, apologies from here as well - i missed responding on time.

> On 08 Apr 2005 08:43:28 -0400, jamal <hadi@cyberus.ca> wrote:
> 
> 

> > The reclassification or #1 will best be left to the user. This is not
> > hard to do.
> 
> I scan through other code and find no easy way to redirect non-handled
> traffic to another class. Can you give me some hint on that?
> 

There are two constructs at the classifier level: the first one is
"reclassify" which basically asks the classification activity to
restart. Another one is the " continue"  construct which basically asks
for the classification to continue where the last one ended.
Does this explanation help?

> > 
> > Ok, stop calling it per-flow-queue then ;-> You should call it
> > per-flow-rate-guarantee.
> 
> I have renamed it to frg (flow rate guarantee) per your suggestion.
> After the above reclassification is done, I will post new patch here.
> 
> I will extend the concept of flow to include GRE, so pptp VPN can be
> supported. There are other 'flows' to consider.
> 

I think you should start by decoupling the classification away from your
qdisc.


> > Sharing is not a big challenge -  and should be policy driven.
> > HTB and CBQ both support it. I am not sure about HFSC.
> > 
> 
> Still, I am not clear if you understand me. How it works for this
> purpose:
> 
> guarantee and only guarantee rate * n when there are n flows?
> 
> When there only 1 flow, guarantee only rate * 1
> When there only 2 flows, guarantee only rate * 2
> ...
> and so on
> 

sure and at some point you exceed available bandwidth. You can
over-provision of course.

> If always guarantee rate * limit, then the excessive guaranteed rate can
> be abused.
> 

I didnt follow this.

> But if always guarantee only rate * 1, then it is not enough.
> 

I also didnt follow this. 

Lets say you have 8 flows; each to be guaranteed 100Kbps. Lets say your
wire rate is only 1Mbps. 

Then you create policies so that each gets 100Kbps. If they all use
their quota you still have 200Kbps to play with. You could then say that
out of that 200Kps, 100kbps is to be shared amongst the 8 flows if they
exceed their allocated 100Kbps(sharing) and the other 100kbps is for
best effort traffic. 
In this case, each flow is _guaranteed_ 100Kbps and upto 100Kbps from
shared quota if no-one else is using that shared quota. 
If multi flows are using the shared 100Kbps then, its given out on first
come basis. "Guaranteed" in this case means it is _reserved_ i.e if flow
#3 is not using its allocation, flow #2 cant use it.

Ok, so now tell me where you and i are differing on semantics?
Is the above what you are also saying? 

> > So it seems you want by all means to avoid entering something that
> > will take forever to list. Did i understand this correctly?
> 
> Yes. It is special purpose but general enough. I think it's worthy of
> adding a new qdisc for it to avoid the dirty long listing part.
> 

I am not sure about the "general enough" part. You need to know what is
happening at any instance in time if this is to be useful. So that
information for listing should be available - you may wish not to
display it unless someone asks for verbose output.

> > 
> > We can probably avoid insisting on dynamically creating classes maybe.
> > You can rate control before you enqueue and we can use fwmark perhaps.
> > Earlier i also asked whether policing will suffice. Heres an example
> > (maybe dated syntax, but concept still valid) that shows sharing using
> > policers:
> > http://www.cyberus.ca/~hadi/patches/action/README
> 
> I will look at it later.
> 

Please do so we can have a synchronized discussion.


> If we can do it with one thing, we should avoid creating 1000 things.
> The policy way works but is dirty.

yes, but that hiding can be hidden at user space for example. 
There are several levels of verbosity if you insist:
- See nothing
- just see info which says "at the moment we have 234 classes
dynamically created" 
- get a full listing for each of 234 classes and their attributes.
- get a full listing for each 234 class and their attributes as well as
stats. 

> > I would think the number 1000 should be related to hash of flow header,
> > no? In which case there should be no collision unless the hash of ftp
> > and http are 1000.
> > 
> 
> To save netfilter rule matching work, if the CONNMARK is set, then it
> will be used to set nfmark.
> 
> If a CONNMARK is already set on this http stream, it will be kept. Then
> if you redefine 1:1000 as another meaning, then this http carrying
> 1:1000 will be mis-classified.
> 

your policy management/scripts are then responsible to make sure
everything is synchronized between iptables and tc. Once we have the
tracker action, this would only need to be doen via tc.

cheers,
jamal
