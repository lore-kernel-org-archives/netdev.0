From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [DOC]: generic netlink
Date: Wed, 12 Jul 2006 07:30:40 -0400
Message-ID: <1152703840.5105.73.camel@jzny2>
References: <1150724482.5815.48.camel@jzny2>
	 <44972743.3040904@watson.ibm.com> <1150815013.5270.73.camel@jzny2>
	 <20060711165743.fe41a43b.rdunlap@xenotime.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-U2na1AiVmnUL4md9LybK"
Cc: nagar@watson.ibm.com, per.liden@ericsson.com, jlan@engr.sgi.com,
	tgraf@suug.ch, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:18628 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750999AbWGLLax
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 07:30:53 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G0cvc-0008Nl-Mn
	for netdev@vger.kernel.org; Wed, 12 Jul 2006 07:30:52 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060711165743.fe41a43b.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-U2na1AiVmnUL4md9LybK
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2006-11-07 at 16:57 -0700, Randy.Dunlap wrote:

> so make it a patch to Documentation/networking/...
> 

I was going to when it got in better shape. Good suggestion, I will do
this soon and put it there as a patch.

> I have some doc corrections, Jamal.  Do I send them against
> the 2006-june-19 doc posting?  and as email comments or as a patch?
> 

There has been some small changes; last time i punted it to Shailabh for
additional changes. You can extend the attached version (from june 20)
or send me a patch - whichever is convinient. 


cheers,
jamal


--=-U2na1AiVmnUL4md9LybK
Content-Disposition: attachment; filename=gnl.txt
Content-Type: text/plain; name=gnl.txt; charset=utf-8
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

2.0 Overview
-------------

In order to illustrate the way different components talk to each
other, the diagram below is used to provide an abstraction on
how the operations happen. 

1) The generic netlink connection which for illustration is refered
to as a "bus". The generic netlink bus is shown as split between user 
and kernel domains: This means programs can connect to the bus from either
kernel or user space.

2) Users : who use the connection to get information or set variables.
These are typically programs in user space but don't have to be.

3) Providers: who supply the information sent through the connection or to
execute kernel functions in response to user commands. This is
always some kernel subsystem, typically but not necessarily a module.

4) Commands: which typically define what is sent by the user and acted upon
by the provider. Commands are registered with the generic netlink bus by
providers.

In the diagram, controller, foobar and googah are providers, user1 through
user-n users in userspace and kuser-1 a user in kernel space. For brevity,
kernel space users are not discussed further.

All boxes  have kernel-wide unique identifiers that can be used to
address them.

Any users can communicate with one or more providers. The interface to a
provider is defined primarily by the commands it exports as well as the
optional provider specific headers that it mandates in messages exchanged
with users, explained further below.


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
          |                |                  |       \
          |                |                  |        \   +---------+
          |                |                  |         \_ | kuser-1 |
          |                |                  |            +---------+
       +--+-------+    +---+-----+     +------+-+
       |controller|    | foobar  |     | googah |
       +----------+    +---------+     +--------+

The controller is a special built-in provider. It is the repository
of info on other providers attached to the bus.  It has
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
events could be notification of things like modifications of attributes 
(example by other user space programs), or creation, or deletion of 
attributes etc.

Events (#2, #4) are by definition asynchronous and unidirectional as shown
while configuration and querying (#1, #3) are synchronous query-response 
operations.

The details of the above communication are explained by first showing an
example of a user communicating with a provider, followed by how a provider 
is written and what it provides, and ending with the format of messages 
exchanged between the user and provider.

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

/* Attributes defined by provider */

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


static struct genl_type foobar_reg = {
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


The system invokes the callback with
skb pointing to where the message for the provider is stored and
info pointing to a genl_info structure whose fields are set as follows
     nlmsghdr: pointer to begining of the message
     genlhdr: beginning of NETLINK_GENERIC message header
     userhdr: beginning of provider specific header, if any. Null otherwise.
     attrs: TLVs of the message, if used. More on this later.

The doit callback should return a 0 on success and a meaningful error code
< 0 on failure.

Ok, so how does the provider register a command of either of the above types ?
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

- cmd is the cmd identifier.
- flags are descriptors for the command.
- policy is used to validate attributes/TLVs of the message.
- doit and dumper callbacks for the command.

3.2.1 Example: Adding a dumper command
--------------------------------------

static int foobar_dump(struct sk_buff *skb, struct netlink_callback *cb)
{
	return 0;
}

static struct genl_ops foobar_dump = {
        .cmd            = FOOBAR_CMD_GETTYPE,
        .flags          = GENL_DUMP_CMD,
        .dump           = foobar_dump,
};


	err = genl_register_ops(&foobar, &foobar_dump);

err will be -EINVAL if foobar is not registered yet or if you pass a
NULL for foobar_dump. -EEXIST is returned if the command is found
to already have been registered.

3.2.2. Example: Adding a standard command
-----------------------------------------

static int foobar_do(struct sk_buff *skb, struct genl_info *info)
{

	return 0;
}

static struct genl_ops foobar_do = {
        .cmd           = FOOBAR_CMD_GETTYPE,
        .doit          = foobar_do,
};

	err = genl_register_ops(&foobar, &foobar_do);

Error return values are similar to the dumper command example above.



4.0 User <--> Provider message format
-------------------------------------

The messages exchanged between users and providers looks as follows:

    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Netlink header (nlmsghdr)                  |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Generic netlink header (genlmsghdr)        |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Optional provider specific message header  |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |                    Optional provider specific TLVs            |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+


4.1 nlmsghdr
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

4.2 genlmsghdr
----------------

The generic netlink header looks like:

    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   |  cmd        |    version    |             reserved            |
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

or, in C-speak
struct genlmsghdr {
        __u8    cmd;
        __u8    version;
        __u16   reserved;
};

cmd: typically one of the commands exported by the provider. Typical
commands are things that get/delete/add/dumping of attributes
or vectors of attributes. In messages which are responses from the provider,
this field also contains some value determined by the provider though that
value is not a command as such.

version: supplied by the user and used by the provider to ensure they are
both at the same version of the interface. Generic netlink core code does not
interpret this.

4.3 Optional provider specific message header
-----------------------------------------------

Providers can define/mandate a header specific to themselves
using extra fields, preferably in multiples of 32 bits as follows:

    0                   1                   2                   3
    0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   ~                                                               ~
   ~                                                               ~
   ~                                                               ~
   +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

The provider code in the kernel needs to understand the extra header - it is
opaque to the generic netlink code. Under typical circumstances, this optional
header doesnt exist.

4.4 Optional provider specific TLVs
-------------------------------------

The data exchanged between a user and provider needs to conform to some
interface defined by the provider.

If the format of this data is solely defined by some structure defined by
the provider (typically in a header file), then the corresponding part of the
message needs to be parsed entirely by the provider. Typically parsing the data
involves validation of length, legal values etc.

Netlink, and hence generic netlink, provides support for parsing of
this data through the netlink attributes interface. If the user<->provider
data exchange is defined as a string of netlink attributes, then both the user
and the provider code can use library functions, provided respectively by
libnetlink/libnl in user space and net/netlink/attr.c in the kernel) to
validate the data and extract it into known data types.

In addition, using netlink attributes makes it easy to extend the interface
defined by the provider. Extra attributes defined in a newer version of the
provider can be dropped/ignored easily by user space programs.

The netlink attributes interface is described in include/net/netlink.h.

Messages can of course be batched as long as the socket buffers allow it.


5.0 Asynchronous event handling
-------------------------------

Besides responses to commands sent, users can also receive messages from
providers asynchronously, say as a result of some kernel event.

Providers specify a netlink multicast group number as part of their interface
The group number space is private to the provider

	#define FOOBAR_LISTEN_GROUP	0x1

Asynchronously, providers send messages to listening users by using

	genlmsg_multicast(skb, pid, FOOBAR_LISTEN_GROUP)

where
skb: struct sk_buff encapsulating the data to be sent
pid: any pid to be ignored while doing the multicast

To receive such messages, the user program only needs to connect to the
generic netlink using multicast, as follows:


	nlh = nl_handle_alloc();
	if (nlh) {
		nl_disable_sequence_check(nlh);
		nl_join_groups(nlh, groups);
		nl_connect(nlh, NETLINK_GENERIC);
	}

and typically change its handling of received messages to operate in an
infinite loop so it can receive all such messages sent by the provider.

	while (nlmsg_ok(rep, n)) {
		nla = nlmsg_attrdata(rep, GENL_HDRLEN);
		len = nlmsg_attrlen(rep, GENL_HDRLEN);
		if (nla_ok(nla, len)) {
		      	<process netlink attribute>
		else
			break;
		rep = nlmsg_next(rep, &n);
	}


6.0 Discovering providers using the controller
----------------------------------------------

As noted in Section 3.1.1, providers are encouraged to let the generic netlink
code assign their family id when they register instead of statically specifying
their id. The former guarantees a unique id will be assigned while the latter
risks failure of the genl_register_family call due to selection of a non-unique
id by the provider code writer.

If ids are dynamically assigned, how do users discover the id for a provider ?
In short, it is by querying the special "controller"  using the name
of the provider they are seeking.

The following snippet shows how a user program can determine the ID of
provider "googah"


	struct timeval tv = { .tv_sec = 10, .tv_usec = 0 };

	msg = (struct nl_msg *)nlmsg_build(&req);
	genlh.cmd = CTRL_CMD_GETFAMILY;
	genlh.version = 0x1;
	nlmsg_append(msg, &genlh, GENL_HDRLEN, 0);
	ret = nla_put_string(msg, CTRL_ATTR_FAMILY_NAME, "googah");
	if (ret < 0)
		goto err;
	nl_send_auto_complete(nlh, nlmsg_hdr(msg));

	FD_ZERO(&nlhs);
	sd = nl_handle_get_fd(nlh);
	FD_SET(sd, &nlhs);

	ret = select(sd + 1, &nlhs, 0, 0, &tv);
	if (ret < 0)
		err(1, "no response from netlink\n");
	n = nl_recv(nlh, &peer, &rmsg);
	rep = (struct nlmsghdr *)rmsg;
	while (nlmsg_ok(rep, n)) {
		nla = nlmsg_attrdata(rep, GENL_HDRLEN);
		len = nlmsg_attrlen(rep, GENL_HDRLEN);
		if (nla_ok(nla, len)) {
			nla = nla_find(nla, len, CTRL_ATTR_FAMILY_ID);
			if (nla) {
				id = nla_get_u16(nla);
				goto done;
			}
		}
		rep = nlmsg_next(rep, &n);
	}
done:
	free(rmsg);
	nlmsg_free(msg);
	return id;
err:
	return -1;







------------------------------------------------------------------------

DONE (or unnecessary)

a) Add a more complete compiling kernel module with events.
Have Thomas put his Mashimaro example and point to it.
b) Describe some details on how user space -> kernel works
probably using libnl??
c) Describe discovery using the controller..

TODOS

d) talk about policies etc
e) talk about how something coming from user space eventually
gets to you.
f) Talk about the TLV manipulation stuff from Thomas.
g) submit controller patch to iproute2


--=-U2na1AiVmnUL4md9LybK--

