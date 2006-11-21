From: Paul Moore <paul.moore@hp.com>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Tue, 21 Nov 2006 17:24:15 -0500
Message-ID: <45637C8F.90001@hp.com>
References: <45541757.90800@hp.com> <20061110173642.GL8693@postel.suug.ch>	 <20061113072347.GB1892@ff.dom.local> <200611130908.18644.paul.moore@hp.com>	 <1163427457.6825.14.camel@jzny2> <4558D061.5090802@hp.com>	 <1163768753.5107.11.camel@jzny2> <1163792874.5219.49.camel@jzny2>	 <455E4B67.9020703@hp.com> <1163869619.5221.43.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Thomas Graf <tgraf@suug.ch>,
	Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:16105 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1756795AbWKUWYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Nov 2006 17:24:18 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163869619.5221.43.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on the discussion with Jamal I moved some things around in the doc so that
the examples were closer to the top and the details were towards the bottom.
There are some other minor changes as well, mostly changes already discussed in
the thread.

I think it may be a good idea to renew the discussion about where this document
should live.  My first thought was in Documentation/ but both Jamal and Stephen
Hemminger have suggested the OSDL networking wiki (we could always put a pointer
in Documentation/ if we went this route).  In order to eliminate the out-of-sync
problem I'd like to keep only one copy around; do people have a preference?

An Introduction To Using Generic Netlink
===============================================================================

Last Updated: November 21, 2006

Table of Contents

 1. Introduction
 1.1. Document Overview
 1.2. Netlink And Generic Netlink
 2. Generic Netlink By Example
    2.1. Registering A Family
    2.2. Kernel Communication
         2.2.1. Sending Messages
         2.2.2. Receiving Messages
    2.4. Userspace Communication
 3. Architectural Overview
 4. Implementation Details
    4.1. Message Format
    4.2. Data Structures
         4.2.1. The genl_family Structure
         4.2.2. The genl_ops Structure
 5. Recommendations
    5.1. Attributes And Message Payloads
    5.2. Operation Granularity
    5.3. Acknowledgment And Error Reporting
 6. References


1. Introduction
------------------------------------------------------------------------------

1.1. Document Overview
------------------------------------------------------------------------------

This document gives a brief introduction to Generic Netlink, some simple
examples on how to use it, and some recommendations on how to make the most of
the Generic Netlink communications interface.  While this document does not
require that the reader have a detailed understanding of what Netlink is
and how it works, some basic Netlink knowledge is assumed.  As usual, the
kernel source code is your best friend here.

While this document talks briefly about Generic Netlink from a userspace point
of view, its primary focus is on the kernel's Generic Netlink API.  It is
recommended that application developers who are interested in using Generic
Netlink make use of the libnl library[1].

1.2. Netlink And Generic Netlink
------------------------------------------------------------------------------

Netlink is a flexible, robust wire-format communications channel typically
used for kernel to user communication although it can also be used for
user to user and kernel to kernel communications.  Netlink communication
channels are associated with families or "busses", where each bus deals with a
specific service; for example, different Netlink busses exist for routing,
XFRM, netfilter, and several other kernel subsystems.  More information about
Netlink can be found in RFC 3549[2].

Over the years, Netlink has become very popular which has brought about a very
real concern that the number of Netlink family numbers may be exhausted in the
near future.  In response to this the Generic Netlink family was created which
acts as a Netlink multiplexer, allowing multiple services to use a single
Netlink bus.

2. Generic Netlink By Example
------------------------------------------------------------------------------

This section deals with the Generic Netlink subsystem in the Linux kernel and
provides a simple example of how in-kernel users can make use of the Generic
Netlink API.  Don't forget to review section #5, "Recommendations", before
writing any code as it could save you, and the people who review your code,
lots of time!

The first section explains how to register a Generic Netlink family which is
required for Generic Netlink users who wish to act as servers, listening over
the Generic Netlink "bus".  The second section explains how to send and receive
Generic Netlink messages in the kernel.  Finally, the third section provides
a brief introduction to using Generic Netlink in userspace.

2.1. Registering A Family
------------------------------------------------------------------------------

Registering a Generic Netlink family is a simple four step process: define the
family, define the operations, register the family, register the operations.
In order to help demonstrate these steps below is a simple example broken down
and explained in detail.

The first step is to define the family itself, which we do by creating an
instance of the genl_family structure.  In our simple example we are going to
create a new Generic Netlink family named "DOC_EXMPL".

  /* attributes */
  enum {
        DOC_EXMPL_A_UNSPEC,
        DOC_EXMPL_A_MSG,
        __DOC_EXMPL_A_MAX,
  };
  #define DOC_EXMPL_A_MAX (__DOC_EXMPL_A_MAX - 1)

  /* attribute policy */
  static struct nla_policy doc_exmpl_genl_policy[DOC_EXMPL_A_MAX + 1] = {
        [DOC_EXMPL_A_MSG] = { .type = NLA_NUL_STRING },
  };

  /* family definition */
  static struct genl_family doc_exmpl_gnl_family = {
        .id = GENL_ID_GENERATE,
        .hdrsize = 0,
        .name = "DOC_EXMPL",
        .version = 1,
        .maxattr = DOC_EXMPL_A_MAX,
  };

  Figure 1: The DOC_EXMPL family, attributes and policy

You can see above that we defined a new family and the family recognizes a
single attribute, DOC_EXMPL_A_MSG, which is a NULL terminated string.  The
GENL_ID_GENERATE macro/constant is really just the value 0x0 and it signifies
that we want the Generic Netlink controller to assign the channel number when
we register the family.

The second step is to define the operations for the family, which we do by
creating at least one instance of the genl_ops structure.  In this example we
are only going to define one operation but you can define up to 255 unique
operations for each family.

  /* handler */
  int doc_exmpl_echo(struct sk_buff *skb, struct genl_info *info)
  {
        /* message handling code goes here; return 0 on success, negative
         * values on failure */
  }

  /* commands */
  enum {
        DOC_EXMPL_C_UNSPEC,
        DOC_EXMPL_C_ECHO,
        __DOC_EXMPL_C_MAX,
  };
  #define DOC_EXMPL_C_MAX (__DOC_EXMPL_C_MAX - 1)

  /* operation definition */
  struct genl_ops doc_exmpl_gnl_ops_echo = {
        .cmd = DOC_EXMPL_C_ECHO,
        .flags = 0,
        .policy = doc_exmpl_genl_policy,
	.doit = doc_exmpl_echo,
	.dumpit = NULL,
  };

  Figure 2: The DOC_EXMPL_C_ECHO operation

Here we have defined a single operation, DOC_EXMPL_C_ECHO, which uses the
Netlink attribute policy we defined above.  Once registered, this particular
operation would call the doc_exmpl_echo() function whenever a
DOC_EXMPL_C_ECHO message is sent to the DOC_EXMPL family over the Generic
Netlink bus.

The third step it to register the DOC_EXMPL family with the Generic Netlink
operation.  We do this with a single function call:

  int rc;

  rc = genl_register_family(&doc_exmpl_gnl_family);
  if (rc != 0)
      goto failure;

This call registers the new family name with the Generic Netlink mechanism and
requests a new channel number which is stored in the genl_family struct,
replacing the GENL_ID_GENERATE value.  It is important to remember to
unregister Generic Netlink families when done as the kernel does allocate
resources for each registered family.

The fourth and final step is to register the operations for the family.  Once
again this is a simple function call:

  int rc;

  rc = genl_register_ops(&doc_exmpl_gnl_family, &doc_exmpl_gnl_ops_echo);
  if (rc != 0)
      goto failure;

This call registers the DOC_EXMPL_C_ECHO operation in association with the
DOC_EXMPL family.  The process is now complete.  Other Generic Netlink users
can now issue DOC_EXMPL_C_ECHO commands and they will be handled as desired.

2.2. Kernel Communication
------------------------------------------------------------------------------

The kernel provides two sets of interfaces for sending, receiving and
processing Generic Netlink messages.  The majority of the API consists of the
general purpose Netlink interfaces, however, there are a small number of
interfaces specific to Generic Netlink.  The following two 'include' files
define the Netlink and Generic Netlink API for the kernel:

 * include/net/netlink.h
 * include/net/genetlink.h

2.2.1. Sending Messages

Sending Generic Netlink messages is a three step process: allocate memory for
the message buffer, create the message, send the message.  In order to help
demonstrate these steps below is a simple example using the DOC_EXMPL family.

The first step is to allocate a Netlink message buffer; the easiest way to do
this is with the nlsmsg_new() function.

  struct sk_buff *skb;

  skb = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
  if (skb == NULL)
      goto failure;

  Figure 3: Allocating a Generic Netlink message buffer

The NLMSG_GOODSIZE macro/constant is a good value to use when you do not know
the size of the message buffer at the time of allocation.  Don't forget that
the genlmsg_new() function automatically adds space for the Netlink and Generic
Netlink message headers.

The second step is to actually create the message payload.  This is obviously
something which is very specific to each service, but a simple example is
shown below.

  int rc;
  void *msg_head;

  /* create the message headers */
  msg_head = genlmsg_put(skb, pid, seq, type, 0, flags, DOC_EXMPL_C_ECHO, 1);
  if (msg_head == NULL) {
      rc = -ENOMEM;
      goto failure;
  }
  /* add a DOC_EXMPL_A_MSG attribute */
  rc = nla_put_string(skb, DOC_EXMPL_A_MSG, "Generic Netlink Rocks");
  if (rc != 0)
      goto failure;
  /* finalize the message */
  genlmsg_end(skb, msg_head);

  Figure 4: Creating a Generic Netlink message payload

The genlmsg_put() function creates the required Netlink and Generic Netlink
message headers, populating them with the given values; see the Generic
Netlink header file for a description of the parameters.  The nla_put_string()
function is a standard Netlink attribute function which adds a string
attribute to the end of the Netlink message; see the Netlink header file for a
description of the parameters.  The genlmsg_end() function updates the Netlink
message header once the message payload has been finalized, this function
should be called before sending the message.

The third and final step is to send the Generic Netlink message which can be
done with a single function call.  The example below is for a unicast send,
but interfaces exist for doing a multicast send of Generic Netlink message.

  int rc;

  rc = genlmsg_unicast(skb, pid);
  if (rc != 0)
      goto failure;

  Figure 5: Sending Generic Netlink messages

2.2.2. Receiving Messages

Typically, kernel modules act as Generic Netlink servers which means that the
act of receiving messages is handled automatically by the Generic Netlink bus.
Once the bus receives the message and determines the correct routing, the
message is passed directly to the family specific operation callback for
processing.  If the kernel is acting as a Generic Netlink client, server
response messages can be received over the Generic Netlink socket using
standard kernel socket interfaces.

2.3. Userspace Communication
------------------------------------------------------------------------------

While Generic Netlink messages can be sent and received using the standard
socket API it is recommended that user space applications use the libnl
library[1].  The libnl library insulates applications from many of the low
level Netlink tasks and uses an API which is very similar to the kernel API
shown above.

3. Architectural Overview
------------------------------------------------------------------------------

Figure #6 illustrates the basic Generic Netlink architecture which is
composed of five different types of components:

 1) The Netlink subsystem which serves as the underlying transport layer for
    all of the Generic Netlink communications.

 2) The Generic Netlink bus which is implemented inside the kernel, but which
    is available to userspace through the socket API and inside the kernel via
    the normal Netlink and Generic Netlink APIs.

 3) The Generic Netlink users who communicate with each other over the Generic
    Netlink bus; users can exist both in kernel and user space.

 4) The Generic Netlink controller which is part of the kernel and is
    responsible for dynamically allocating Generic Netlink communication
    channels and other management tasks.  The Generic Netlink controller is
    implemented as a standard Generic Netlink user, however, it listens on a
    special, pre-allocated Generic Netlink channel.

 5) The kernel socket API.  Generic Netlink sockets are created with the
    PF_NETLINK domain and the NETLINK_GENERIC protocol values.

      +---------------------+      +---------------------+
      | (3) application "A" |      | (3) application "B" |
      +------+--------------+      +--------------+------+
             |                                    |
             \                                    /
              \                                  /
               |                                |
       +-------+--------------------------------+-------+
       |        :                               :       |   user-space
  =====+        :   (5)  kernel socket API      :       +================
       |        :                               :       |   kernel-space
       +--------+-------------------------------+-------+
                |                               |
          +-----+-------------------------------+----+
          |        (1)  Netlink subsystem            |
          +---------------------+--------------------+
                                |
          +---------------------+--------------------+
          |       (2) Generic Netlink bus            |
          +--+--------------------------+-------+----+
             |                          |       |
     +-------+---------+                |       |
     |  (4) controller |               /         \
     +-----------------+              /           \
                                      |           |
                   +------------------+--+     +--+------------------+
                   | (3) kernel user "X" |     | (3) kernel user "Y" |
                   +---------------------+     +---------------------+

  Figure 6: Generic Netlink Architecture

When looking at figure #6 it is important to note that any Generic Netlink
user can communicate with any other user over the bus using the same API
regardless of where the user resides in relation to the kernel/userspace
boundary.

Generic Netlink communications are essentially a series of different
communication channels which are multiplexed on a single Netlink family.
Communication channels are uniquely identified by channel numbers which are
dynamically allocated by the Generic Netlink controller.  The controller is a
special Generic Netlink user which listens on a fixed communication channel,
number 0x10, which is always present.  Kernel or userspace users which provide
services over the Generic Netlink bus establish new communication channels by
registering their services with the Generic Netlink controller.  Users who
want to use an existing service query the controller to see if it exists and
determine the correct channel number.

4. Implementation Details
------------------------------------------------------------------------------

This section provides a more in depth explanation of the Generic Netlink
message formats and data structures.

4.1. Message Format
------------------------------------------------------------------------------

Generic Netlink uses the standard Netlink subsystem as a transport layer which
means that the foundation of the Generic Netlink message is the standard
Netlink message format - the only difference is the inclusion of a Generic
Netlink message header.  The format of the message is defined as shown below:

   0                   1                   2                   3
   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |                Netlink message header (nlmsghdr)              |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |           Generic Netlink message header (genlmsghdr)         |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |             Optional user specific message header             |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  |           Optional Generic Netlink message payload            |
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

  Figure 7: Generic Netlink message format

Figure #7 is included only to give you a rough idea of how Generic Netlink
messages are formatted and sent on the "wire".  In practice the Netlink and
Generic Netlink API should insulate most users from the details of the message
format and the Netlink message headers.


4.2. Data Structures
------------------------------------------------------------------------------

This section focuses on the Generic Netlink data structures as they are defined
in the kernel.  A similar API exists for userspace applications using the libnl
library[1].

4.2.1. The genl_family Structure

Generic Netlink families are defined by the genl_family structure, which is
shown below:

  struct genl_family
  {
        unsigned int            id;
        unsigned int            hdrsize;
        char                    name[GENL_NAMSIZ];
        unsigned int            version;
        unsigned int            maxattr;
        struct nlattr **        attrbuf;
        struct list_head        ops_list;
        struct list_head        family_list;
  };

  Figure 8: The genl_family structure

The genl_family structure fields are used in the following manner:

 * unsigned int id

   This is the dynamically allocated channel number.  A value of 0x0 signifies
   that the channel number should be assigned by the controller and the 0x10
   value is reserved for use by the controller.  Users should always use
   GENL_ID_GENERATE macro/constant (value 0x0) when registering a new family.

 * unsigned int hdrsize

   If the family makes use of a family specific header, its size is stored
   here.  If there is no family specific header this value should be zero.

 * char name[GENL_NAMSIZ]

   This string should be unique to the family as it is the key that the
   controller uses to lookup channel numbers when requested.

 * unsigned int version

   Family specific version number.

 * unsigned int maxattr

   Generic Netlink makes use of the standard Netlink attributes, this value
   holds the maximum number of attributes defined for the Generic Netlink
   family.

 * struct nlattr **attrbuf
 * struct list_head ops_list
 * struct list_head family_list

   These are private fields and should not be modified.

4.2.2. The genl_ops Structure

Generic Netlink operations are defined by the genl_ops structure, which is
shown below:

  struct genl_ops
  {
        u8                      cmd;
        unsigned int            flags;
        struct nla_policy       *policy;
        int                     (*doit)(struct sk_buff *skb,
                                        struct genl_info *info);
        int                     (*dumpit)(struct sk_buff *skb,
                                          struct netlink_callback *cb);
        struct list_head        ops_list;
  };

  Figure 9: The genl_ops structure

The genl_ops structure fields are used in the following manner:

 * u8 cmd

   This value is unique across the corresponding Generic Netlink family and is
   used to reference the operation.

 * unsigned int flags

   This field is used to specify any special attributes of the operation.  The
   following flags may be used (multiple flags can be OR'd together):

   - GENL_ADMIN_PERM

     The operation requires the CAP_NET_ADMIN privilege

 * struct nla_policy policy

   This field defines the Netlink attribute policy for the operation request
   message.  If specified, the Generic Netlink mechanism uses this policy to
   verify all of the attributes in an operation request message before calling
   the operation handler.

   The attribute policy is defined as an array of nla_policy structures indexed
   by the attribute number.  The nla_policy structure is defined as shown in
   figure #10.

     struct nla_policy
     {
        u16             type;
        u16             len;
     };

     Figure 10: The nla_policy structure

   The fields are used in the following manner:

   - u16 type

     This specifies the type of the attribute; presently the following types
     are defined for general use:

     o NLA_UNSPEC

       Undefined type

     o NLA_U8

       An 8-bit unsigned integer

     o NLA_U16

       A 16-bit unsigned integer

     o NLA_U32

       A 32-bit unsigned integer

     o NLA_U64

       A 64-bit unsigned integer

     o NLA_FLAG

       A simple boolean flag

     o NLA_MSECS

       A 64-bit time value in msecs

     o NLA_STRING

       A variable length string

     o NLA_NUL_STRING

       A variable length NULL terminated string

     o NLA_NESTED

       A stream of attributes

   - u16 len

     When the attribute type is one of the string types then this field should
     be set to the maximum length of the string, not including the terminal
     NULL byte.  If the attribute type is unknown or NLA_UNSPEC then this field
     should be set to the exact length of the attribute's payload.

     Unless the attribute type is one of the fixed-length types above, a value
     of zero indicates that no validation of the attribute should be performed.

 * int (*doit)(struct skbuff *skb, struct genl_info *info)

   This callback is similar in use to the standard Netlink 'doit' callback, the
   primary difference being the change in parameters.

   The 'doit' handler receives two parameters: the first is the message buffer
   which triggered the handler and the second is a Generic Netlink genl_info
   structure which is defined as shown in figure #11.

     struct genl_info
     {
        u32                     snd_seq;
        u32                     snd_pid;
        struct nlmsghdr *       nlhdr;
        struct genlmsghdr *     genlhdr;
        void *                  userhdr;
        struct nlattr **        attrs;
     };

     Figure 11: The genl_info structure

   The fields are populated in the following manner:

   - u32 snd_seq

     This is the Netlink sequence number of the request.

   - u32 snd_pid

     This is the Netlink PID of the client which issued the request, it is
     important to note that the Netlink PID is not the same as the standard
     kernel PID.

   - struct nlmsghdr *nlhdr

     This is set to point to the Netlink message header of the request.

   - struct genlmsghdr *genlhdr

     This is set to point to the Generic Netlink message header of the request.

   - void *userhdr

     If the Generic Netlink family makes use of a family specific header, this
     pointer will be set to point to the start of the family specific header.

   - struct nlattr **attrs

     The parsed Netlink attributes from the request; if the Generic Netlink
     family definition specified a Netlink attribute policy then the
     attributes would have already been validated.

   The 'doit' handler should do whatever processing is necessary and return
   zero on success or a negative value on failure.  Negative return values
   will cause a NLMSG_ERROR message to be sent while a zero return value will
   only cause a NLMSG_ERROR message to be sent if the request is received with
   the NLM_F_ACK flag set.

 * int (*dumpit)(struct sk_buff *skb, struct netlink_callback *cb)

   This callback is similar in use to the standard Netlink 'dumpit' callback.
   The 'dumpit' callback is invoked when a Generic Netlink message is received
   with the NLM_F_DUMP flag set.

   The main difference between the 'dumpit' handler and the 'doit' handler is
   that the 'dumpit' handler does not allocate a message buffer for a response;
   a pre-allocated sk_buff is passed to the 'dumpit' handler as the first
   parameter.  The 'dumpit' handler should fill the message buffer with the
   appropriate response message and return the size of the sk_buff,
   i.e. sk_buff->len, and the message buffer will automatically be sent to the
   Generic Netlink client that initiated the request.  As long as the 'dumpit'
   handler returns a value greater than zero it will be called again with a
   newly allocated message buffer to fill.  When the handler has no more data
   to send it should return zero; error conditions are indicated by returning
   a negative value.  If necessary, state can be preserved in the
   netlink_callback parameter which is passed to the 'dumpit' handler; the
   netlink_callback parameter values will be preserved across handler calls
   for a single request.

 * struct list_head ops_list

   This is a private field and should not be modified.

5. Recommendations
------------------------------------------------------------------------------

The Generic Netlink mechanism is a very flexible communications mechanism and
as a result there are many different ways it can be used.  The following
recommendations are based on conventions within the Linux kernel and should be
followed whenever possible.  While not all existing kernel code follows the
recommendations outlined here, all new code should consider these
recommendations as requirements.

5.1. Attributes And Message Payloads
------------------------------------------------------------------------------

When defining new Generic Netlink message formats you must make use of the
Netlink attributes wherever possible.  The Netlink attribute mechanism has
been carefully designed to allow for future message expansion while preserving
backward compatibility.  There are also additional benefits from using Netlink
attributes which include developer familiarity and basic input checking.

Most common data structures can be represented with Netlink attributes:

 * scalar values

   Most scalar values already have well-defined attribute types; see section 4
   for details.

 * structures

   Structures can be represented using a nested attribute with the structure
   fields represented as attributes in the payload of the container attribute.

 * arrays

   Arrays can be represented by using a single nested attribute as a container
   with several of the same attribute type inside each representing a spot in
   the array.

It is also important to use unique attributes as much as possible.  This helps
make the most of the Netlink attribute mechanisms and provides for easy changes
to the message format in the future.

5.2. Operation Granularity
------------------------------------------------------------------------------

While it may be tempting to register a single operation for a Generic Netlink
family and multiplex multiple sub-commands on the single operation, this
is strongly discouraged for security reasons.  Combining multiple behaviors
into one operation makes it difficult to restrict the operations using the
existing Linux kernel security mechanisms.

5.3. Acknowledgment and Error Reporting
------------------------------------------------------------------------------

It is often necessary for Generic Netlink services to return an ACK or error
code to the client.  It is not necessary to implement an explicit
acknowledgment message as Netlink already provides a flexible acknowledgment
and error reporting message type called NLMSG_ERROR.  When an error occurs a
NLMSG_ERROR message is returned to the client with the error code returned by
the Generic Netlink operation handler.  Clients can also request a NLMSG_ERROR
message when no error has occurred by setting the NLM_F_ACK flag on requests.

6. References
------------------------------------------------------------------------------

[1] http://people.suug.ch/~tgr/libnl
[2] ftp://ftp.rfc-editor.org/in-notes/rfc3549.txt

-- 
paul moore
linux security @ hp
