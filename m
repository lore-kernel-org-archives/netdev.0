From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] QoS: frg queue (was [RFC] QoS: new per flow queue)
Date: Mon, 18 Apr 2005 20:40:29 +0200
Message-ID: <20050418184029.GV4114@postel.suug.ch>
References: <1113830063.26757.15.camel@localhost.localdomain> <20050418145024.GS4114@postel.suug.ch> <20050419012147.038F.LARK@linux.net.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wang Jian <lark@linux.net.cn>
Content-Disposition: inline
In-Reply-To: <20050419012147.038F.LARK@linux.net.cn>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Wang Jian <20050419012147.038F.LARK@linux.net.cn> 2005-04-19 02:01
> In your big piture,
> 
> 1. the dynamic allocated classids prepresent streams (I avoid using flow
> here ntentionally)
> 2. the dynamic created TBFs are mapped 1:1 to classids, to provide rate
> control
> 
> Let's simplify it to
> 
> 1. namespace represent streams
> 2. rate controls for every name in the namespace (1:1 map)

This is only true for use 1 where the allocator creates indepdendent
qdiscs. Look at use case 2 where a major classid of 11: and 12: create
htb class siblings, this even allows to divided one big flow
namespaces into various group but still respecting global policies.

> 1. there is no necessity that namespace must be classid space.

Agreed.

> 2. considering the resemblance of streams (they usually are the same
> application), the rate control can be simplified. TBF or HTB is overkill.

Argueable.

> 3. grouped rate control method is not suitable for single stream.

I'm not sure what you mean with this.

> 4. fairness on streams, and total guarantee ( rate * n) can guarantee n
> streams very well

Agreed, we can put this into the allocator by letting the user specify
limits and run a rate estimator.

> 5. per stream rate limit and total limit ( rate * n * 1.xx ) make sense
> for bandwidth efficiency.

Agreed, make the allocator create HTB classes and you can have it.

> 6. precisely counting of streams is necessary (when streams is more than
> expected, existing streams are guaranteed, new streams are not
> guaranteed, so at least some will work, not all don't work)

Also agreed, I did not lose too many thoughts on this yet but it's
not hard to implement.

> What FRG does:
> 
> 1. the namespace is conntracks of streams;
> 2. rate control algorithm is very simple, based on the token bucket;
> 3. grouped rate control (HTB) is only used to do total guarantee
> 4. provides fairness on streams, and there is m * rate guarantee for
> dynamic m streams;
> 5. per stream rate limit, total limit ( rate * max_streams * 1.05)
> 6. precisely counting of streams, and guarantees existing max_streams
> stream.

I understand all of your arguments but I would like to, if possible,
avoid to add yet another quite specific qdisc which could have been
implemented in a generic way for everyone to use. Your FRG basically
does what the alloctor + classifier + action + qdiscs can do but it
is orientied at one specific use case.

Let's analyze your enqueue()

1) perflow_is_valid() // BTW, I think you have a typo in there, 2 times TCP ;->
   Should be done in the classifier with ematches:
   ... ematch meta(PROTOCOL eq IP) AND
              (cmp(ip_proto eq TCP) OR cmp(ip_proto eq UDP) ..)

2) perflow_(fill|find|new)_tuple()
   Should be done in the classifier as an action

3) qsch->q.qlen >= q->qlen
   Must be done in the qdisc after classification so this would
   go into the allocator.

4) flow->timer
   Must be handled by the alloctor

5) rate limiting
   IMHO: Should be done in separate qdiscs

Advantages?
 - What happens if you want to allow yet another protocol
   in your flow? You have to change sources etc.
 - Protocol specific flow hashing? No problem, replace the action.
 - ...

The only disadvantage I can see is a possible performance bottleneck
but this must be proved first by numbers.

So basically the direction we want to go is to strict separate the
classification from the queueing to allow the user to customize
everything by replacing small components. It might be worth to read
up on the discussion on "ematch" and "action" over the last 3 months.

Cheers, Thomas
