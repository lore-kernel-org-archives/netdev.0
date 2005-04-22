From: Wang Jian <lark@linux.net.cn>
Subject: Re: [RFC] QoS: frg queue (was [RFC] QoS: new per flow queue)
Date: Fri, 22 Apr 2005 12:11:44 +0800
Message-ID: <20050422115230.03E0.LARK@linux.net.cn>
References: <20050419012147.038F.LARK@linux.net.cn> <20050418184029.GV4114@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050418184029.GV4114@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas Graf,

Due to some reason, I was removed from this list and I wait for sometime
to make sure this.

On Mon, 18 Apr 2005 20:40:29 +0200, Thomas Graf <tgraf@suug.ch> wrote:

> * Wang Jian <20050419012147.038F.LARK@linux.net.cn> 2005-04-19 02:01
> > In your big piture,
> > 
> > 1. the dynamic allocated classids prepresent streams (I avoid using flow
> > here ntentionally)
> > 2. the dynamic created TBFs are mapped 1:1 to classids, to provide rate
> > control
> > 
> > Let's simplify it to
> > 
> > 1. namespace represent streams
> > 2. rate controls for every name in the namespace (1:1 map)
> 
> This is only true for use 1 where the allocator creates indepdendent
> qdiscs. Look at use case 2 where a major classid of 11: and 12: create
> htb class siblings, this even allows to divided one big flow
> namespaces into various group but still respecting global policies.
> 

Yes, the use case 2 you refer to is not in my original design.

> 
> I understand all of your arguments but I would like to, if possible,
> avoid to add yet another quite specific qdisc which could have been
> implemented in a generic way for everyone to use. Your FRG basically
> does what the alloctor + classifier + action + qdiscs can do but it
> is orientied at one specific use case.

Agree. I will maintain my code out of kernel tree, in case someone feels
my frg is usefull for his/her special case.

> 
> Let's analyze your enqueue()
> 
> 1) perflow_is_valid() // BTW, I think you have a typo in there, 2 times TCP ;->
>    Should be done in the classifier with ematches:
>    ... ematch meta(PROTOCOL eq IP) AND
>               (cmp(ip_proto eq TCP) OR cmp(ip_proto eq UDP) ..)
> 
> 2) perflow_(fill|find|new)_tuple()
>    Should be done in the classifier as an action
> 
> 3) qsch->q.qlen >= q->qlen
>    Must be done in the qdisc after classification so this would
>    go into the allocator.
> 
> 4) flow->timer
>    Must be handled by the alloctor
> 
> 5) rate limiting
>    IMHO: Should be done in separate qdiscs
> 
> Advantages?
>  - What happens if you want to allow yet another protocol
>    in your flow? You have to change sources etc.
>  - Protocol specific flow hashing? No problem, replace the action.
>  - ...
> 
> The only disadvantage I can see is a possible performance bottleneck
> but this must be proved first by numbers.

The other disadvantage is that the dynamic classid used is not predicted
by user space, it is very tricky for user space to handle the classid
allocation then (I mean for the management system like web management).
That is what I try to avoid so far.

> 
> So basically the direction we want to go is to strict separate the
> classification from the queueing to allow the user to customize
> everything by replacing small components. It might be worth to read
> up on the discussion on "ematch" and "action" over the last 3 months.
> 

I agree to this. But I must iterate one thing: the design should be
friendly to user space management for a heavy usage.



-- 
  lark
