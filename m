From: jamal <hadi@cyberus.ca>
Subject: [DOC]: generic netlink
Date: Mon, 19 Jun 2006 09:41:22 -0400
Message-ID: <1150724482.5815.48.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-TiX+mEJuoGHiyaCPz3wT"
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Jay Lan <jlan@engr.sgi.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	Per Liden <per.liden@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:11922 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932454AbWFSNl2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 09:41:28 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FsK0R-0004IA-VE
	for netdev@vger.kernel.org; Mon, 19 Jun 2006 09:41:31 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-TiX+mEJuoGHiyaCPz3wT
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Folks,

Attached is a document that should help people wishing to use generic
netlink interface. It is a WIP so a lot more to go if i see interest.
The doc has been around for a while, i spent part of yesterday and this
morning cleaning it up. If you have sent me comments before, please
forgive me for having misplaced them - just send again. 

cheers,
jamal

PS:- I dont have a good place to put this doc and point to, hence the
17K attachment

--=-TiX+mEJuoGHiyaCPz3wT
Content-Disposition: attachment; filename=gnl.txt
Content-Type: text/plain; name=gnl.txt; charset=UTF-8
Content-Transfer-Encoding: 7bit


1.0 Problem Statement
-----------------------

Netlink is a robust wire-format IPC typically used for kernel-user
communication although could also be used to be a communication
carrier between user-user and kernel-kernel.

A typical netlink connection setup is of the form:

netlink_socket = socket(PF_NETLINK, socket_type, netlink_family);

where netlink_family selects the netlink "bus" to communicate
on. Example of a family would be NETLINK_ROUTE which is 0x0 or
NETLINK_XFRM which is 0x6. [Refer to RFC 3549 for a high level view
and look at include/linux/netlink.h for some of the allocated families].

Over the years, due to its robust design, netlink has become very popular.
This has resulted in the danger of running out of family numbers to issue.

In netconf 2005 in Montreal it was decided to find ways to work around
the allocation challenge and as a result NETLINK_GENERIC "bus" was born.

This document gives a mid-level view if NETLINK_GENERIC and how to use it.
The reader does not necessarily have to know what netlink is, but needs
to know at least the encapsulation used - which is described in the next
section. There are some implicit assumptions about what netlink is
or what structures like TLVs are etc. I apologize i dont have much
time to give a tutorial - invite me to some odd conference and i will
be forced to do better than this doc. Better send patches to this doc.

2.0 High Level view
--------------------

In order to illustrate the way different components talk to each
other, the diagram below is used to provide an abstraction on
how the operations happen. There are two (three depending on your
perspective) components:

1) The generic netlink connection which for illustration is refered
to as a "bus". The generic netlink bus is shown as split between user 
and kernel domains: This means programs can connect to the bus from either
kernel or user space.

2) components that talk to each other after attaching to the bus.
a) Two users are shown in user spaces 
b)3 in the kernel.

All boxes have kernel-wide unique identifiers that can be used to 
address them. 
Typicaly, user space boxes exist to control one or more kernel level
boxen i.e they update some attributes that exist in a kernel level
box.
Any of these "boxes" can communicate to each other by first
connecting to the bus and then sending messages addressed to any
box. 

                +----------+          +----------+
                |  user1   |  ......  |  user-n  |
                +--+-------+          +-------+--+
                   |                          |
                   /                          |
                  |                           |                User
        +---------+------------------------+---------+ Space/domain
 user   |                                            |
--------+           Generic Netlink Bus              +-----------
 kernel |                                            |   Kernel
        +------------------+------------------+------+   Space/domain
          |                |                  |
          |                |                  |
          |                |                  |
          |                |                  |
       +--+-------+    +---+-----+     +------+-+
       |controller|    | foobar  |     | googah |
       +----------+    +---------+     +--------+

The controller is a speacial built-in user of the bus. It is the repository
of info on kernel components that have attached to the bus. It has
a reserved address identifier of 0x10. By querying the controller,
one could find out that both foobar and googah are registered and
what their IDs are etc. Essentially its a namespace translator
not unlike DNS is for IP addresses. More later on this.

To get to the point of the most common usage of netlink
(user space control of a kernel component), the diagram below breaks
things down for a single user program that controls a kernel module
called foobar. The example is simple for illustration purposes; as an
example, user space could control a lot more kernel modules.


                         +----------------------+
                         |                      |
                         |    user program      |
      gnl events  ; ->-->|                      |
        (2)    ,-/       +--^-----+----------^--+
             ,'      gnl    |     ^ foobar   ^ foobar
            ,'    discovery ^     | events   | config/query 
           ,'       (1)     |     ^  (4)     ^  (3)
       +--/-------------- +>------|----------|-------------+
       | /               /        \          \             |
       +----------------+----------+<+--------\------------+
         |             /              \        |
         ^            /                \       Y
          \          Y                  \      |
           \         Y                   ^     |
           ++------- '-+                +|-----Y-----+
           | controller|                |   foobar   |
           +-----------+                +------------+

#1: The user space could start by discovering the existence of 
foobar by doing a dump of all existing modules or doing a specific 
query by name. At that point it knows the ID of foobar.

#2: The user space could subscribe to listen to events of newly
appearing kernel modules or departure of existing ones.

#3: The user space could configure foobar or do queries on existing
state

#4: The user space program could subscribe to listen to events on
foobar. Note these events are upto the programmer of foobar. Typical
events could be things like modifications of attributes (example
by other user space programs), or creation, or deletion of attributes etc.

Events (#2, #4) are by definition asynchronous and unidirectional as shown
while configuration and querying (#1, #3) are synchronous query-response 
operations.


2.1 Kernel < --> User space Communication.
-----------------------------------------

Essentially nothing new, Communication is as in standard netlink approach. 
i.e from user space you open a netlink socket to the kernel - in this
case family NETLINK_GENERIC - and send and receive response as well
as asynchronous events.
To receive to events you subscribe to specific multicast groups.

You really should use libnetlink or libnl to simplify your life in
user space.

2.2 Kernel < --> User space encapsulation.
--------------------------------------

Between user space and the kernel, the message passed around looks
as follows:

    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                          nlmsghdr                             |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Generic message header                     |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    optional user specific message header      |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Optional  user specific TLVs               |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+


2.2.1 nlmsghdr 
--------------

   The nlmsghdr is the standard one as in:

   struct nlmsghdr
   {
           __u32           nlmsg_len;      /* Length including header */
           __u16           nlmsg_type;     /* Message content */
           __u16           nlmsg_flags;    /* Additional flags */
           __u32           nlmsg_seq;      /* Sequence number */
           __u32           nlmsg_pid;      /* Sending process PID */
   };

The address of a specific kernel module is carried in nlmsg_type.
The rest of the parts of the netlink header are used exactly the
same as in current netlink (refer to RFC 3549)

2.2.2 Generic message header 
----------------------------

The user specific header looks as follows:

   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |  command    | version       |             reserved            |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

command is an 8 bit field that your kernel/user code understands.
Typical commands are things that get/delete/add/dumping of attributes
or vectors of attributes.

It is defined like so in C-speak:
struct genlmsghdr {
        __u8    cmd;
        __u8    version;
        __u16   reserved;
};

A get passed with a netlink flag NLMSG_F_DUMP is understood to be
requesting for a dumper.

2.2.3 optional user specific message header   
---------------------------------------------

One could add the extra fields preferable to be multiples of 32
bits as:

   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   ~                                                               ~
   ~                                                               ~
   ~                                                               ~
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

The kernel module needs to understand the extra header.
Under typical circumstances this extension header doesnt exist.

2.2.4 Optional  user specific TLVs
----------------------------------

The user specific header is followed typically by a list of
optional attributes in the form of TLV structures.
The example we have below has a few TLVs for illustration
The attributes carry all the data that needs to be exchanged.
This enforces a structured formating.
Messages can of course be batched as long as the socket
buffers allow it. 


3.0 Kernel point of view
------------------------

Inside the kernel, the code wishing to commumicate using netlink
registers its presence by using the structre genl_type which looks as follows:

struct genl_family
{
        unsigned int            id;
        unsigned int            hdrsize;
        char                    name[GENL_NAMSIZ];
        unsigned int            version;
        unsigned int            maxattr;
        struct module *         owner;
        struct nlattr **        attrbuf;        /* private */
        struct list_head        ops_list;       /* private */
        struct list_head        family_list;    /* private */
};

- id is the field which is used in the nlmsg_type of the netlink header.
Messages matching this id which are known to belong to you are
multiplexed to your specific registered handlers (more below).
Ids cannot be below 0x10 and cannot exceed 0xFFFF.
0x10 is reserved for the controller. IDs are unique system wide.

- hdrsize is the size in bytes of your msgheader that follows the 
netlink header but before the TLVs.
If you have no specific messages header, this should be 0.

- name is a the string identifier you wish to be refered to.
names also have to be unique.

-version is whatever version for your own maintainance. The core
code doesnt interpret it.

- maxattr is the maximum number of attributes (TLVs) you expect to see.
You can own upto 2^16 bits of types, the danger is memory is allocated
to hold attributes; so use with care. Typically you shouldnt have more
than 10-30 types of messages you pass around. Keep reading on to see
the examples of what this is.

You probably shouldnt touch the other fields.

3.1 Kernel level Example of registering a component
----------------------------------------------------

First lets talk about registering a component foobar so that it
is visible at the controller.
We then talk about adding support for some simple commands which
can be sent to it via user space.

3.1.1 Adding foobar
------------------

//Your static Id 
//  
#define GENL_ID_FOOBAR 0x123

// all commands you want to process
// typicall 0 is reserved

enum {
        FOOBAR_CMD_UNSPEC,   
        FOOBAR_CMD_NEWTYPE, 
        FOOBAR_CMD_DELTYPE,
        FOOBAR_CMD_GETTYPE,
        FOOBAR_CMD_NEWOPS, 
        FOOBAR_CMD_DELOPS,
        FOOBAR_CMD_GETOPS,
	/* add future commands here */
        __FOOBAR_CMD_MAX,
};

#define FOOBAR_CMD_MAX (__FOOBAR_CMD_MAX - 1)

// the attributes you want to own

enum {
        FOOBAR_ATTR_UNSPEC,
        FOOBAR_ATTR_TYPE,
        FOOBAR_ATTR_TYPEID,
        FOOBAR_ATTR_TYPENAME,
        FOOBAR_ATTR_OPER,
	/* add future attributes here */
        __FOOBAR_ATTR_MAX,
};

#define FOOBAR_ATTR_MAX (__FOOBAR_ATTR_MAX - 1)


static struct genl_type foobar = {
        .id = GENL_ID_FOOBAR,
        .name = "foobar",
        .version = 0x1,
        .hdrsize = sizeof(struct mymsghdr),
        .maxattr = FOOBAR_ATTR_MAX,
};


So then you register yourself to receive these messages ..

Note: Your static id GENL_ID_FOOBAR is _not_ guaranteed to be 
allocated to you. This is so because the system guarantees uniqueness.
If some other code has registered already for that ID - it will be too
late. You can however get a dynamically allocated ID by passing
GENL_ID_GENERATE(0x0) as the ID. In the dynamic case when the 
registration succeeds you get a your .id set to whatever the system 
allocated.
The user space part can discover this id by querying the controller
for your name.

err = genl_register_family(&foobar);

the registration could fail and return you the following:
1) -EINVAL if you do any of the following:
a) have an ID that is less than GENL_MIN_TYPE
b) pass a hdrsize that is either not a multiple of 4 bytes
or is less than the minimal mandated size of 4 bytes

2)-EEXIST if your name or id is already registered

3) -ENOMEM if:
a) you passed GENL_ID_GENERATE and there are no more IDs left
b) the core failed to allocate memory for your .attrbuf.

4) -EBUSY if there are issues loading the module.

on success of registration you get a 0 returned.

You MUST unregister if you are going to exit since some memmory is allocated.
You do this via:
genl_unregister_family(&foobar);


3.1.2 Adding foobar commands
-----------------------------

Next we need to register commands that will be processed by your ID.
There are two classes of commands:

a) A dumper that looks like:
int (*dumpit)(struct sk_buff *skb, struct netlink_callback *cb);

This callback is invoked when user space calls you with the
NLMSG_F_DUMP flag.
You are passed a skb which you fill in with the data you need to
dump.
There is a netlink_callback that you use to store state so you can
continue dumping afterwards.
As long as you return > 0 - the system will continue to call you with
skbs where you can stash more data. 
Typically the trick is you should return skb->len. When you have
nothing left to add skb->len will be 0.
More later.

b) a callback for all other commands.

int  (*doit)(struct sk_buff *skb, struct genl_info *info);

where struct genl_info is:
struct genl_info
{
        u32                     snd_seq;
        u32                     snd_pid;
        struct nlmsghdr *       nlhdr;
        struct genlmsghdr *     genlhdr;
        void *                  userhdr;
        struct nlattr **        attrs;
};


The system will call you with an skb where the message for you is
stored; the nlmsghdr pointer so right at the begining of the message.
the genlhdr is the generic message header mentioned earlier.
If you have a message header, this will passed to you pointed by userhdr.
If your messaging uses TLVs, they will be pointed to by attrs.
and you can process them by indexing by type into attrs.
More later.
You should return a 0 on success and a meaningful error code < 0 on failure.


Ok, so how do you register your command?
Use structure genl_ops which looks like:


struct genl_ops
{
        unsigned int            cmd;
        unsigned int            flags;
        struct nla_policy       *policy;
        int                    (*doit)(struct sk_buff *skb,
                                       struct genl_info *info);
        int                    (*dumpit)(struct sk_buff *skb,
                                         struct netlink_callback *cb);
        struct list_head        ops_list;
};

- command is the cmd identifier.
- flags are descriptors for the command.
- policy is used further to validate attributes.
- doit and dumpit have been discussed above.


To register for the dumper, you must pass GENL_DUMP_CMD in the flags.

Dumper Example:
static int foobar_dump(struct sk_buff *skb, struct netlink_callback *cb)
{
	return 0;
}


static struct genl_ops foobar_dump = {
        .cmd            = FOOBAR_CMD_GETTYPE,
        .flags          = GENL_DUMP_CMD,
        .dump            = foobar_dump,
};

 err = genl_register_ops(&foobar, &foobar_dump);

err will be -EINVAL if foobar is not registered yet or if you pass a
NULL for foobar_dump. -EEXIST is returned if the command is found
to already have been registered.

and example for the standard interface:

static int foobar_do(struct sk_buff *skb, struct genl_info *info)
{

	return 0;
}


Lets register for it to be invoked everytime the command
FOOBAR_CMD_GETTYPE is passed from user space.

static struct genl_ops foobar_do = {
        .cmd            = FOOBAR_CMD_GETTYPE,
        .doit            = foobar_do,
};

 err = genl_register_ops(&foobar, &foobar_do);


TODO:
a) Add a more complete compiling kernel module with events.
Have Thomas put his Mashimaro example and point to it.
b) Describe some details on how user space -> kernel works
probably using libnl??
c) Describe discovery using the controller..
d) talk about policies etc
e) talk about how something coming from user space eventually
gets to you.
f) Talk about the TLV manipulation stuff from Thomas.
g) submit controller patch to iproute2


--=-TiX+mEJuoGHiyaCPz3wT--

