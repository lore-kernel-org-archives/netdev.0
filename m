From: Wang Jian <lark@linux.net.cn>
Subject: Re: [RFC] QoS: frg queue (was [RFC] QoS: new per flow queue)
Date: Tue, 19 Apr 2005 02:01:21 +0800
Message-ID: <20050419012147.038F.LARK@linux.net.cn>
References: <1113830063.26757.15.camel@localhost.localdomain> <20050418145024.GS4114@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050418145024.GS4114@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Thomas Graf,

In your big piture,

1. the dynamic allocated classids prepresent streams (I avoid using flow
here ntentionally)
2. the dynamic created TBFs are mapped 1:1 to classids, to provide rate
control

Let's simplify it to

1. namespace represent streams
2. rate controls for every name in the namespace (1:1 map)

The consideration:

1. there is no necessity that namespace must be classid space.
2. considering the resemblance of streams (they usually are the same
application), the rate control can be simplified. TBF or HTB is overkill.
3. grouped rate control method is not suitable for single stream.
4. fairness on streams, and total guarantee ( rate * n) can guarantee n
streams very well
5. per stream rate limit and total limit ( rate * n * 1.xx ) make sense
for bandwidth efficiency.
6. precisely counting of streams is necessary (when streams is more than
expected, existing streams are guaranteed, new streams are not
guaranteed, so at least some will work, not all don't work)

What FRG does:

1. the namespace is conntracks of streams;
2. rate control algorithm is very simple, based on the token bucket;
3. grouped rate control (HTB) is only used to do total guarantee
4. provides fairness on streams, and there is m * rate guarantee for
dynamic m streams;
5. per stream rate limit, total limit ( rate * max_streams * 1.05)
6. precisely counting of streams, and guarantees existing max_streams
stream.

FRG is created for VoIP like applications. It can be used to meet per
stream guarantee and prevent over provision.


On Mon, 18 Apr 2005 16:50:24 +0200, Thomas Graf <tgraf@suug.ch> wrote:

> Sorry for entering this discussion so late.
> 
> * jamal <1113830063.26757.15.camel@localhost.localdomain> 2005-04-18 09:14
> > I think you should start by decoupling the classification away from your
> > qdisc.
> 
> Here are my thoughts on per flow queueing, actually the name
> "classification controlled queues" is be more accurate.
> 
> First of all the whole problem must be divided into two parts:
> 
> 1) queueing with per flow specific queueing parameters, i.e. the flow
>    serves a certain purpose and is known by static parameters.
> 2) queueing with generic parameters, i.e. the purpose of a flow
>    is solely to be fair, there is no difference between each flow.
> 
> Both these cases can be handled with the current set of qdiscs
> and classificiation tools but often a combination of both is needed
> and that's where my thought begins:
> 
> We use tc_classid to describe a flow but also to describe its
> assignment to the corresponding flow group (n flows are grouped
> together into a group to define a namespace, generally at the
> level of a qdisc).
> 
> The tc_classid can be set via actions, either by using a generic
> action that creates a flowid out of the common tuple or by
> providing an own simple-action for customization, e.g. one could
> construct tc_classid ::= nfmark << 16 + hash(flowid)
> 
> tc_classid is interpreted by either one of the existing qdiscs
> for static assignment or a new qdisc named "alloctor"
> 
> The purpose of the allocator is to create qdiscs on demand,
> destroy them after they expired and to act as a muxer to enqueue
> into the dynamic leaf qdiscs. The alloactor can be configured to
> interpet the MSB 16bits of tc_classid as a flow group id and
> enqueue the skb to the corresponding clasfull qdisc with matches
> TC_H_MAJ_MASK bits.
> 
> The following is in attempt to convert my scribbling on paper
> into ASCII:
> 
> 
> Use Case 1: Per flow queues using TBF
> 
>                    2. +-----------+  +------------+
>                    +->| cls_basic |->| act_flowid |
>                    |  +-----------+  +------------+
>       1.    +---------------+              |
>   --------->| sch_allocator |<-------------+
>             +---------------+        3. tc_classid=<flowid>
>                    |4.
>        +-----------+---------+- - - - - -
>        |           |         |           |
>     +-----+     +-----+   +-----+     + - - +
>     | TBF |     | TBF |   | TBF |     | TBF |
>     +-----+     +-----+   +-----+     + - - +
> 
> 
> sch_alloctor configuration:
>   - no flow group map
>   - default policy: allocate TBF for every tc_classid && enqueue to new qdisc
>   - default template: tbf add rtnetlink message
>   - default deletion template: tbf del rtnetlink message
> 
> cls_basic configuration:
>   - always true
>  
> act_flowid configuration:
>   - default: generate flowid hash and store in tc_classid
> 
> 
> Use Case 2: Flow groups
> 
>                      3. +---------+
>                      +->| em_meta |
>                      |  +---------+
>                      +----+  |
>                           |  v           4.
>                    2. +-----------+  +-----------------+
>                    +->| cls_basic |->| act_cust_flowid |
>                    |  +-----------+  +-----------------+
>       1.    +-----------------+               |
>   --------->| sch_allocator_1 |<--------------+
>             +-----------------+         5. tc_classid=(nfmark<<16)+(flowid&0xFF)
>                    |6.
>        +-----------+---+----------------+
>        | 11:/12:       | 13:            | *:
>     +-----+     +-----------------+ +---------+
>     | HTB |     | sch_allocator_2 | | default |
>     +-----+     +-----------------+ +---------+
>        |               |
>        |       +-------+- - - -     
>        |       |       |       |
>        |    +-----+ +-----+ + - - +
>        |    | TBF | | TBF | | TBF |
>        |    +-----+ +-----+ + - - +
>        |
>        |
>        +------------------+
>                           |
>                +----------+--------------+
>                |                         |
>          +------------+            +------------+
>          | Class 20:1 |            | Class 20:2 |
>          +------------+            +------------+
>                |                         |
>      +---------+- - - - -              .....
>      |         |         |
>  +-------+ +-------+ +- - - -+
>  | Class | | Class | | Class |
>  +-------+ +-------+ +- - - -+
> 
> 
> sch_alloctor_1 configuration:
>   - flow group map:
>      [11:] create class HTB parent 20:1 && enqueue to 20:
>      [12:] create class HTB parent 20:2 && enqueue to 20:
>      [13:] enqueue to sch_allocator_2
>   - default policy: enqueue to default qdisc
> 
> sch_allocator_2 configuration:
>   - no flow group map
>   - default policy: allocate TBF for every tc_classid && enqueue to new qdisc
>   - default template: tbf add rtnetlink message
>   - default deletion template: tbf del rtnetlink message
>   
> cls_basic configuration:
>   - always true
> 
> em_meta configuration:
>   - filter out unknown nfmarks
> 
> act_cust_flowid configuration:
>   - (nfmark<<16)+(flowid&0xff)
> 
> 
> So basically what sch_allocator does is look at tc_classid, lookup
> the corresponding flow in the flow map or use the default action,
> execute the action, i.e. process the netlink message via a worker
> thread, rewrite tc_classid if needed, manage the created qdiscs/classes,
> account their last activity and destroy them eventually after no
> activity for a certain configurable time by executing the corresponding
> deletion netlink message.
> 
> Thoughts?



-- 
  lark
