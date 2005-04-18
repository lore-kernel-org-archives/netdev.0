From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] QoS: frg queue (was [RFC] QoS: new per flow queue)
Date: Mon, 18 Apr 2005 16:50:24 +0200
Message-ID: <20050418145024.GS4114@postel.suug.ch>
References: <20050407203631.02CF.LARK@linux.net.cn> <1112964208.1088.226.camel@jzny.localdomain> <20050413131916.030F.LARK@linux.net.cn> <1113830063.26757.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Jian <lark@linux.net.cn>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1113830063.26757.15.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry for entering this discussion so late.

* jamal <1113830063.26757.15.camel@localhost.localdomain> 2005-04-18 09:14
> I think you should start by decoupling the classification away from your
> qdisc.

Here are my thoughts on per flow queueing, actually the name
"classification controlled queues" is be more accurate.

First of all the whole problem must be divided into two parts:

1) queueing with per flow specific queueing parameters, i.e. the flow
   serves a certain purpose and is known by static parameters.
2) queueing with generic parameters, i.e. the purpose of a flow
   is solely to be fair, there is no difference between each flow.

Both these cases can be handled with the current set of qdiscs
and classificiation tools but often a combination of both is needed
and that's where my thought begins:

We use tc_classid to describe a flow but also to describe its
assignment to the corresponding flow group (n flows are grouped
together into a group to define a namespace, generally at the
level of a qdisc).

The tc_classid can be set via actions, either by using a generic
action that creates a flowid out of the common tuple or by
providing an own simple-action for customization, e.g. one could
construct tc_classid ::= nfmark << 16 + hash(flowid)

tc_classid is interpreted by either one of the existing qdiscs
for static assignment or a new qdisc named "alloctor"

The purpose of the allocator is to create qdiscs on demand,
destroy them after they expired and to act as a muxer to enqueue
into the dynamic leaf qdiscs. The alloactor can be configured to
interpet the MSB 16bits of tc_classid as a flow group id and
enqueue the skb to the corresponding clasfull qdisc with matches
TC_H_MAJ_MASK bits.

The following is in attempt to convert my scribbling on paper
into ASCII:


Use Case 1: Per flow queues using TBF

                   2. +-----------+  +------------+
                   +->| cls_basic |->| act_flowid |
                   |  +-----------+  +------------+
      1.    +---------------+              |
  --------->| sch_allocator |<-------------+
            +---------------+        3. tc_classid=<flowid>
                   |4.
       +-----------+---------+- - - - - -
       |           |         |           |
    +-----+     +-----+   +-----+     + - - +
    | TBF |     | TBF |   | TBF |     | TBF |
    +-----+     +-----+   +-----+     + - - +


sch_alloctor configuration:
  - no flow group map
  - default policy: allocate TBF for every tc_classid && enqueue to new qdisc
  - default template: tbf add rtnetlink message
  - default deletion template: tbf del rtnetlink message

cls_basic configuration:
  - always true
 
act_flowid configuration:
  - default: generate flowid hash and store in tc_classid


Use Case 2: Flow groups

                     3. +---------+
                     +->| em_meta |
                     |  +---------+
                     +----+  |
                          |  v           4.
                   2. +-----------+  +-----------------+
                   +->| cls_basic |->| act_cust_flowid |
                   |  +-----------+  +-----------------+
      1.    +-----------------+               |
  --------->| sch_allocator_1 |<--------------+
            +-----------------+         5. tc_classid=(nfmark<<16)+(flowid&0xFF)
                   |6.
       +-----------+---+----------------+
       | 11:/12:       | 13:            | *:
    +-----+     +-----------------+ +---------+
    | HTB |     | sch_allocator_2 | | default |
    +-----+     +-----------------+ +---------+
       |               |
       |       +-------+- - - -     
       |       |       |       |
       |    +-----+ +-----+ + - - +
       |    | TBF | | TBF | | TBF |
       |    +-----+ +-----+ + - - +
       |
       |
       +------------------+
                          |
               +----------+--------------+
               |                         |
         +------------+            +------------+
         | Class 20:1 |            | Class 20:2 |
         +------------+            +------------+
               |                         |
     +---------+- - - - -              .....
     |         |         |
 +-------+ +-------+ +- - - -+
 | Class | | Class | | Class |
 +-------+ +-------+ +- - - -+


sch_alloctor_1 configuration:
  - flow group map:
     [11:] create class HTB parent 20:1 && enqueue to 20:
     [12:] create class HTB parent 20:2 && enqueue to 20:
     [13:] enqueue to sch_allocator_2
  - default policy: enqueue to default qdisc

sch_allocator_2 configuration:
  - no flow group map
  - default policy: allocate TBF for every tc_classid && enqueue to new qdisc
  - default template: tbf add rtnetlink message
  - default deletion template: tbf del rtnetlink message
  
cls_basic configuration:
  - always true

em_meta configuration:
  - filter out unknown nfmarks

act_cust_flowid configuration:
  - (nfmark<<16)+(flowid&0xff)


So basically what sch_allocator does is look at tc_classid, lookup
the corresponding flow in the flow map or use the default action,
execute the action, i.e. process the netlink message via a worker
thread, rewrite tc_classid if needed, manage the created qdiscs/classes,
account their last activity and destroy them eventually after no
activity for a certain configurable time by executing the corresponding
deletion netlink message.

Thoughts?
