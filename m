From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 05:29:42 +0100
Message-ID: <49C078B6.4020603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Finally, with a lot of delay, I've just released the first full public
version of my nftables code (including userspace), which is intended to
become a successor to iptables. Its written from scratch and there are
numerous differences to iptables in both features and design, so I'll
start with a brief overview.

There are three main components:

- the kernel implementation
- libnl netlink communication
- nftables userspace frontend

The kernel provides a netlink configuration interface, as well as
runtime ruleset evaluation using a small classification language
interpreter. libnl contains the low-level functions for communicating
with the kernel, the nftables frontend is what the user interacts with.


Kernel
------


The first major difference is that there's no one-to-one relation of
matches and targets available to the user and those implemented in the
kernel anymore. The kernel provides some generic parameterizable
operations, like loading data from a packet, comparing data with other
data etc. Userspace combines the individual operations appropriately
to get the desired semantic.

Data is represented in a generic way inside the kernel and the
operations are defined on the generic data representations, meaning
its possible to use any matching feature (ranges, masks, set lookups
etc.) with any kind of data. Semantic validation of the operation is
performed in userspace, the kernel doesn't care as long as the
operation doesn't potentially harm the kernel.

The kernel doesn't have a distinction between matches and targets
anymore, operations can be arbitrarily chained, fixing a common
complaint that multiple rules are required to f.i. log and drop a
packet. Terminal operations will stop evaluation of a rule, even if
further operations are specified. Userspace warns about rules
containing operations after unconditionally terminal operations.

Some operations can be runtime-parameterized, f.i. the "meta" module,
which can change meta-data like packet marks. This can be used to
transfer marks between conntracks and packets, transfer routing
realms to marks for binding connections to a route in multipath
environments, or create maps (dictonaries) of parameters depending
on some different value and more.

Last but not least, nftables natively supports set lookups and
dictionary mappings. Sets (as everything else) operate on generic
data and thus can be used for any kind of match. Depending on the
kind of set, they also support range queries, which allows to
specify sets containing f.i. individual hosts as well as entire
networks with different prefix lengths.

Currently implemented are hash lookups and rb-trees (which are
quite suboptimal for this purpose). The internal set representation
is currently selected by userspace, but the goal is to have the
kernel select it automatically based on the required operations.

Dictonaries can associate a different data item that is returned
with each key. This data item may be a generic data item, or one of
the control-flow altering netfilter verdicts, including jumps. This
can be either used (with generic data) for runtime-parameterized
operations, or, in case of verdicts, for creating jump tables, which
allows to create a tree structure for classification with efficient
branching in the nodes. The end-goal is to have userspace optionally
perform a transformation of the ruleset to such a structure.

Some of the less major differences include:

- protocol family independancy: currently supporting IPv4 and IPv6,
   with basic support for bridging. Support for mixed IPv4/IPv6 rulesets
   is planned.

- incremental changes supported, no atomic ruleset replacement anymore

- the core is completely lockless, the few operations that require
   locking take care of this internally

- packet and byte counters are an optional operation, by default
   none exist. This allows to only register chains with netfilter
   when there are actually rules present, reducing the performance
   impact of empty chains to zero.

- tables are normally (currently one exception: nat) created by
   userspace, which also specifies the contained chains and hook
   priority for chains hooked directly with netfilter.

- kernel is dumb and mainly does what it is told, whether it makes
   sense or not. Semantics are validated in userspace, where proper
   error reporting can be done.

- far smaller code size than iptables :)


Userspace
---------


I'll skip libnl here as it contains mainly low-level communication support.

The userspace frontend is probably even more different to iptables than
the kernel. The classification language is based on a real grammar that
is parsed by a bison-generated parser (currently, it might have to be
replaced) and converted to a syntax tree. Besides things like table and
chain operations, the language elements are mainly:

- runtime data describing expressions: "tcp dport", "meta mark", ...

- constant data expressions: "ssh", "22", "192.168.0.1/24", ...

- relational expressions and operations: "equal", "non-equal",
   "member of set", ...

- combining expressions, like sets and flag lists: { 22, 23}
   and established,related

- actions ("log", "drop", "meta mark", ...)

Constant parsing is context-dependant, meaning constants can only
be used when the necessary context exists, i.e. on the RHS of a
relational expression or within a dictionary for the data items,
where the context is defined based on the use of the mapped items
(dnat map tcp dport { 22 => host.com } has an IPv4 address context
for host.com from the DNAT operation). There are currently about 25
defined data types, covering addresses (IPv4/IPv6/LL), numbers,
ports, strings, ethertypes, internet protocols, different protocol
specific flag values, marks, realms, UIDs/GIDs etc. etc. Constants
are automatically converted to the approriate byte order, which is
also dependant on the context. Currently casts are unsupported, but
they might be useful in some cases :)

The frontend supports both dealing with only a single rule at a time
for incremental operations, as well as parsing entire files, In the
later case verification is performed on all rules and changes are only
made after full validation. Currently not implemented, but planned,
is transactional semantic where changes are rolled back when the
kernel reports an error.


At this point a few example might be in order ...

- a single rule, specified incrementally on the command line:

# nft add rule output tcp dport 22 log accept

The default address family is IPv4, the default table is filter. The
full specification would look like this:

# nft add rule inet filter output tcp dport 22 log accept

- a chain containing multiple rules:

#! nft -f

include "ipv4-filter"

chain filter output {
         ct state established,related accept
         tcp dport 22 accept
         counter drop
}

creates the filter table based on the definitions from "ipv4-filter"
and populates the output chain with the given three rules.

OK, back to the internals. After the input has been parsed, it is
evaluated. This stage performs some basic transformations, like
constant folding and propagation, as well as most semantic checks.

During this step, a protocol context is built based on the current
address family and the specified matches, which describes the protocols
of packets that might hit later operations in the same rule. This
allows two things:

- conflict detection:

  ... ip protocol tcp udp dport 53

   results in:

   <cmdline>:1:37-45: Error: conflicting protocols specified: tcp vs. udp
   add filter output ip protocol tcp udp dport 53
                                     ^^^^^^^^^

  ... ip6 filter output ip daddr 192.168.0.1

   <cmdline>:1:19-26: Error: conflicting protocols specified: ip6 vs. ip
   ip6 filter output ip daddr 192.168.0.1
                     ^^^^^^^^

   The context is currently defined based on the tables protocol family,
   any specified payload matches on protocol fields, as well as meta
   data matches on the incoming interface type. Conntrack expressions
   are currently not included, but will be.

- dependency generation:

   To match IPv4 SSH-traffic, the full match specification would be
   "ip protocol 6 tcp dport 22". The shortcut is "tcp dport 22", the
   necessary protocol match can in this case be deduced automatically
   based on the table information (IPv4) and the higher layer
   protocol (TCP).

After evaluation (which contains a few more steps that are getting into
too much detail) of the entire input, a final transformation step is
performed. During this, all sets and dictonaries containing ranges are
converted to elementary interval trees. In the case of sets, no
conflicts can arise from overlapping members and they are simply joined.
In case of dictonaries, overlaps are resolved based on the size of the
range (smaller wins), the assumption being that a smaller range is an
exception to a bigger range. So in the rule:

ip daddr { 192.168.0.0/24 => drop, 192.168.0.100 => accept}

the host 192.168.0.100 would be regarded as an exception to its
containing network. Only when no resoltion based on this is possible,
an error is reported.

Finally, the internal representation is linearized, registers for
passing values between operations are allocated and everything is
sent to the kernel.

The kernel-internal represenation of course doesn't include types and
f.i. payload matches are merely an offset and a length. During dumping,
the entire syntax tree, including types, is reconstructed. Redundant
information might get lost before it is sent to the kernel, but both
the kernel and the reconstructed ruleset are semantically equivalent.


Examples
--------


There are a lot more details that would be worth to describe, but since
its exceeding the volume of a reasonable release announcement, I'll skip
the rest and conclude with a list of supported features and a few more
examples that might be helpful to get started.

- the "describe" command: this can be used to get information about a
   primary expression, like types and pre-defined constants:

  # nft describe ct state

  ct expression, datatype conntrack state (basetype bitmask, integer), 
32 bits

  pre-defined symbolic constants:
          invalid                         0x00000001
          new                             0x00000008
          established                     0x00000002
          related                         0x00000004
          untracked                       0x00000040

  # nft describe ip protocol

  payload expression, datatype Internet protocol (basetype integer), 8 bits

- include files: other files can be included from a ruleset. A default
   search path can be specified using "-i", by default it contains only
   "/etc/nftables". A set of files is included that contain the standard
   table definitions known from iptables.

   Usage: include "ipv4-filter", include "ipv6-mangle", ...

Supported features
------------------

Some very basic documentation is included that might contain some
more details.

Expressions (matches and statement parameterization):
-----------------------------------------------------

Primary expressions:
--------------------

Primary expressions describe a single data item. They can be constant or
non-constant, where non-constant means the data is collected during runtime.

- meta data expression: gather skb meta data

   Usage: meta <key>

   where key is one of: length, protocol, priority, mark, iif, iifname,
                        iiftype, oif, oifname, oiftype, skuid, skgid,
                        rtclassid, secmark

   Use the "nft describe" command to get more information on these.

- conntrack expression: gather conntrack data

   Usage: ct <key>

   where key is one of: state, direction, status, mark, seecmark,
                        expiration, helper, protocol, saddr, daddr,
                        proto-src, proto-dst

- payload expression: gather data from packet payload

   Usage: <key1> <key2>

   with (key1: key2:)

   eth:        	saddr, daddr, type

   vlan:        	id, cfi, pcp, type

   arp:        	htype, ptype, hlen, plen, operation

   ip:        	version, hdrlength, tos, length, id, frag_off, ttl,
                	protocol, checksum, saddr, daddr

   icmp:        	type, code, checksum, id, sequence, gateway, mtu

   ip6:        	version, priority, flowlabel, length, nexthdr, hoplimit,
                 saddr, daddr

   ah:        	nexthdr, hdrlength, reserved, spi, sequence

   esp:        	spi, sequence

   comp:        	nexthdr, flags, cpi

   udp:        	sport, dport, length, checksum

   udplite:      sport, dport, csumcov, checksum

   tcp:        	sport, dport, sequence, ackseq, doff, reserved, flags,
                 window, checksum, urgptr

   dccp:        	sport, dport

   sctp:        	sport, dport

   hbh:        	nexthdr, hdrlength

   rt:        	nexthdr, hdrlength, type, seg_left

   rt0:        	addr[NUM]

   rt2:        	addr

   frag:        	nexthdr, reserved, frag_off, reserved2,
                 more_fragments, id

   dst:        	nexthdr, hdrlength

   mh:           nexthdr, hdrlength, type, reserved, checksum

A lot of these define their own types, use the "describe" command to
get more information.

Combined expressions:
---------------------

Combined expressions combine two primary expressions:

- Bitwise expressions: &, |, ^

   Usage: <expr> <operator> <constant-expr>

   Constant expressions are evaluated in userspace.

- Prefix expressions: network prefixes, may be useful for other types

   Usage: <constant-expr> '/' <NUM>

- Range expressions: value ranges

   Usage: <constant-expr> '-' <constant-expr>

- List expressions: lists of expressions

   Usage: <constant-expr> , <constant-expr> [, ...]

   This is currently only used for specifying multiple flag values.

- Concat expression: concatenate multiple expressions

   <expr> . <expr> [ . ... ]

   Useful for doing a multi-dimensional set lookup. Kernel side
   not implented, currently only works with adjacent header fields.

- Wildcard expression: useful for defining default cases in dictionaries

   Usage: '*'

Relational Expressions:
-----------------------

Relational expressions are used to build match expressions by combining
primary expressions with relational operations:

- basic relational expressions:

   Usage: <expr> <operator> <expr>

   with operator being one of ==, !=, <, <=, >, >=. "==" is implicit
   and can be omitted. When the RHS is a set, the operation defaults
   to "set lookup":

   <expr> [ implicit ] '{' <constant expr>, ... '}'

   The "in-range" relation is implicit when the RHS is a range:

   <expr> [ implicit ] <constant-expr> '-' <constant-expr>

- flag comparisions:

   Usage: <expr> [ implicit ] <flag-list>

   Which basically does "expr & flag-list != 0". flag-list is a comma
   seperated list of constant expressions of basetype bitmask.

Statements (somewhat similar to targets):
-----------------------------------------

- verdicts:

   accept, drop, queue, continue, jump, goto, return

- verdict maps:

   dictionaries of verdicts: ip daddr { 192.168.0.1 => drop, ... }

- byte/packet counters:

   Usage: add "counter" anywhere before a terminal verdict

- logging:  logging using the nf_log mechsism using the primary backend.

   Usage: "log [ prefix "prefix" ] [ group NUM ] [ snaplen NUM ]
               [ queue-threshold NUM ]

- limit: might be broken currently

   Usage: "limit rate RATE/time-unit"

- reject: reject packets

   Usage: "reject" (no parameters currently)

- NAT: SNAT/DNAT targets:

   Usage: "snat [ constant address or map expr ]
                [ constant port or map expression
                  [ ':' constant port or map expr ] ]"

   The port or port-range specification is optional, similar to
   iptables. The snat syntax is identical.

- meta target:

   Usage: meta <key> set <expr>

   See above for valid keys.


Some final notes ...


The source code is available in three git trees:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nft-2.6.git
git://git.netfilter.org/libnl-nft.git
git://git.netfilter.org/nftables.git

The kernel tree will eventually also move to netfilter.org, currently
the git daemon is unable to handle it because of memory shortage.

Ths source code is considered alpha quality and is not meant for users
at this time, it will spew quite a lot of debugging messages and
definitely has bugs. Nevertheless, all of the basic features and most
of the rest should work fine, the last crash has been several months
ago. The two most noticable things that currently don't work is
numerical argument parsing for arguments that have more specific types
(f.i. port numbers), as well as reconstruction of the internal
representation of sets and dictionaries using ranges. Both will be
fixed shortly.

Additionally there are some optimizations missing from the public kernel
tree, I'll forward port and merge them shortly. The plans for the near
future are to complete the missing feature and stabilize the code, in
order to have it in proper shape within a few months.

There is a short TODO list in the nftables source tree. Anyone
interested in working on the code, please let me know, there are a
few self-contained things that are good to get started.

Have fun :)
