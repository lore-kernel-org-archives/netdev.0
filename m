From: Patrick McHardy <kaber@trash.net>
Subject: [ANNOUNCE]: Release of nftables 0.2
Date: Mon, 14 Apr 2014 13:39:36 +0200
Message-ID: <20140414113933.GA20756@macbook.localnet>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Cc: netfilter@vger.kernel.org, announce@lists.netfilter.org,
	netdev@vger.kernel.org, coreteam@netfilter.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60381 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbaDNLjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 07:39:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The netfilter project presents:

	nftables 0.2

This release contains a rather large number of bug fixes, syntax cleanups,
new features, support for all new features contained in the recent 3.14
kernel release as well as *drumroll* documentation.


Syntax changes
==============

* More consistency in data type names

  Data type names are used in set declarations. All address related types
  now follow the naming scheme *_addr, all protocol related types *_proto
  and the network interface related type iface_*. The arphrd type has been
  renamed to iface_type.

* Unqualified meta expressions

  A number of keys of the meta expressions can be used without the meta
  keyword for simplicity. These are mark, iif, iifname, iiftype, oif,
  oifname, oiftype, skuid, skgid, nftrace and rtclassid. The meta keyword
  may still be used if desired.

  - nft filter output meta skuid root accept

  becomes

  - nft filter output skuid root accept


New features
============

The more prominent new features include:

* Support for hybrid IPv4/IPv6 tables

  nftables now supports the "inet" family, which can be used to create
  hybrid tables that contain rules for both IPv4 and IPv6. This should
  greatly help reduce maintenance overhead for dual stack setups.

  To create a standard filter table, use the supplied table template:

  nft -f /etc/nftables/inet-filter

  Rules in the inet family can apply to either just IPv4, just IPv6 or
  both types of packets:

  nft inet filter input ip saddr 192.168.0.0/24 jump from_lan
  nft inet filter input ip6 saddr 2001::/64 jump from_lan
  nft inet filter input tcp dport ssh accept
  nft inet filter input iif lo accept

* Support to set meta keys

  Corresponding to the iptables MARK, CLASSIFY and TRACE targets, nftables
  now supports changing meta data associated with a packet.

  - nft filter input mark set 0x1

    will set the packet mark to 0x1.

  - nft filter input mark set mark | 0x1

    will OR the current value with 0x1.

  Using maps, you can do neat things like setting the mark dependant on
  the source address in a single rule:

  nft filter input mark set ip saddr map {
	192.168.0.0/24 : 0x1,
	192.168.1.0-192.168.1.64 : 0x2,
	192.168.2.1 : 0x3,
	* : 0x4
  }

  Or set it based on the network number using bitwise operations:

  nft filter input ip saddr 192.168.0.0/16 mark set ip saddr & 0xff00

  The packet classification can be changed in a similar fashion using
  "meta priority set ...", tracing can be enabled using "nftrace set 1".

* Support to set conntrack keys

  Similar to the meta keys feature, it is now possible to change data
  associated with connection tracking entries. At this time only the
  conntrack mark is supported.

  - nft filter input ct mark set mark

  will set the conntrack mark to the packet mark

  - nft filter output mark set ct mark

  will set the packet mark to the conntrack mark

  - nft filter output ct mark set 0x1

  will set the conntrack mark to the value 0x1.

* connlabel support

  Support for connection tracking labels (connlabels) has been added.
  connlabel.conf is parsed and the values can be used as symbolic
  constants in combination with the "ct label" expression.

  - nft filter input ct label clients,servers accept

  will accept packets of connections labeled with either clients or servers.

* Queue load balancing

  The queue statement now supports load balancing, CPU fanout, queue bypass
  etc.

  - nft filter output queue num 3 total 2 options fanout

  will queue packets to queue numbers 3 and 4 using CPU fanout.

* XML/JSON ruleset export

  Using "nft export <xml|json>", the ruleset can be exported in either format.
  A corresponding import facility will follow soon.

* Human readable comments in the ruleset

  nftables supports storing comments together with a rule in the ruleset
  that are displayed when listing the ruleset. The syntax is

  - nft filter input tcp dport ssh accept comment "SSH access"

  Please note that the syntax may change before the next release.

* Full file parsing

  nftables now recovers from errors during ruleset parsing and continues
  up to a threshold of 10 errors before aborting. This allows to quicker
  validate and fix up an erroneous ruleset.

* "create" command

  The create command can be used to create tables and chains, but unlike
  the add command it doesn't return an error if the object already exists.

* Misc

 A larger number of smaller improvements have been made to  error
 reporting, ruleset listing, and other parts have been made.
 

Bug fixes
=========

* Big endian support

  A number of problems on big endian architectures have been fixed. A
  single bugfix for the kernel is still in the queue, once it has hit
  -stable this release should be fully functional on big endian.

* Flag comparision for single flag values

  When no operation is explicitly specified in a relational expression,
  nftables determines the operation based on the data types of the
  right hand side expression. For bitmask types, the operation is a flag
  comparision, i.e.

  tcp flags syn,ack

  tests if either SYN or ACK is set. In the case that the right hand side
  consisted of only a single value, nftables so far incorrectly generated
  an equlity expression, IOW "tcp flags syn" would match on SYN and only
  SYN. Now the expected thing is done and all packets that have the SYN
  flag set will match.

* Operator precedence in ruleset listing

  When using bitwise expressions, the ruleset listing will now print
  expressions in when required by operator precedence.

* Symbolic variable existance and redefinitions

  nftables will check for existance of a symbolic variable at time of use
  instead of during evaluation. Redefinitions of existing variables now
  trigger an error.

* Map interval conflicts

  When maps contain overlapping ranges (ranges or prefix expressions), the
  ranges are prioritized based on their size. A smaller (more specific)
  range takes precedence over larger (less specific) ones. When the ranges
  have an identical size, no precedence can be determined and an error is
  returned if the associated data/verdict differs.
 
* Misc

  A number of crashes, failed assertions, incorrect definitions and more
  have been fixed.


Documentation
=============

Some reference documentation (man-page / PDF) has been added. Unfortunately
I did not manage to complete it so far, but work is ongoing and shouldn't
take very long anymore. The incomplete sections are mainly a number of
statement types, set and map declarations and higher order expressions.


Name
====

As Keith Alexander is no longer the director of the NSA and we don't know
specifics about the mischief committed by his successor Michael S. Rogers
yet, this release is simply called "Support Edward Snowden", which is a
timeless worthy cause. 

If you're in Germany, you can order some stickers to show your support for
asylum for Snowden at https://shop.digitalcourage.de/snowden.html for free.

$ nft -v
nftables v0.2 (Support Edward Snowden)


Resources
=========

The nftables code can be obtained from:

* http://netfilter.org/projects/nftables/downloads.html
* ftp://ftp.netfilter.org/pub/nftables
* git://git.netfilter.org/nftables

To build the code, you libnftnl and libmnl are required:

* http://netfilter.org/projects/libnftnl/index.html
* http://netfilter.org/projects/libmnl/index.html

The iptables compatibility layer is available at:

* git://git.netfilter.org/iptables-nftables


The website updates are still in progress, but will be completed soon.


Outlook
=======

The pace of development is still increasing and lots of interesting things
are in the pipeline. Features currently worked on and most likely included
in the next version include:

* netlink event monitor - monitor ruleset events, set changes etc.

* support for concatenations - multidimensional exact matches in O(1)

* new transaction infrastructure - fully atomic updates for all object types

* set selection - automatic selection of the optimal set implementation

* JSON/XML import - the counterpart to the new ruleset export facility


Thanks
======

Thanks to all our contributors, testers and bug reporters, whom have all
helped to improve nftables.


On behalf of the Netfilter Core Team,
Happy bytecode execution :)

--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="shortlog.txt"

Ana Rey (4):
      src: proto: fixed a rreply symbol
      src: proto: fixed a rreply symbol
      nftables: Fix list of sets by family
      rule: fix crash in set listing

Arturo Borrero (4):
      netlink: delete unused variable
      netlink: fix chain attribute parsing
      src: fix expr_binary_error()-related compilation warnings
      ct: add support for setting ct mark

Arturo Borrero Gonzalez (2):
      ruleset: add XML/JSON export
      expression: fix constant expression allocation on big endian

Eric Leblond (1):
      src: add support for queue

Florian Westphal (6):
      netlink_delinearize: meta: fix wrong type in attributes
      ct: direction should be integer, not bitmask
      ct: connlabel matching support
      datatype: don't leak file ptr on error
      expr: do not suppress OP_EQ when RHS is bitmask type
      build: drop AC_FUNC_MALLOC/REALLOC

Pablo Neira Ayuso (7):
      netlink: add support to set meta keys
      build: use libnftnl instead of libnftables in configure.in
      bump release number to 0.100
      mnl: fix inclusion of last rule in batch page
      Merge branch 'master' into next-3.14
      meta: remove line break when printing priority
      src: add support for rule human-readable comments

Patrick McHardy (67):
      expr: replace PAYLOAD_PROTOCOL_EXPR by generic flag
      nftables: generic procotol contexts
      expr: add protocol context update callback
      proto: add helper function to update protocol context
      proto: add debugging for protocol context updates
      ct expr: protocol context updates and dynamic typing
      include: resync nftables.h with kernel
      nftables: add support for the "inet" family
      netlink_delinearize: remove implied meta expressions
      proto: add support for meta templates
      meta: add nfproto support
      meta: add l4proto support
      Merge remote-tracking branch 'origin/master' into next-3.14
      netlink_delinearize: fix compiler warning
      Merge remote-tracking branch 'origin/master' into next-3.14
      Merge remote-tracking branch 'origin/master' into next-3.14
      Merge remote-tracking branch 'origin/master' into next-3.14
      expr: remove secmark from ct and meta expression
      meta: don't require "meta" keyword for a subset of meta expressions
      Merge branch 'master' into next-3.14
      Merge branch 'master' into next-3.14
      Merge remote-tracking branch 'origin/master' into next-3.14
      Merge remote-tracking branch 'origin/master' into next-3.14
      parser: use symbolic expressions for parsing keywords as protocol values
      Merge remote-tracking branch 'origin/master' into next-3.14
      Merge remote-tracking branch 'origin/master' into next-3.14
      cmd: add create command for tables and chains
      set: add abstract set descriptions
      Revert "set: add abstract set descriptions"
      evaluate: determine implicit relational op before RHS constant checks
      scanner: don't update location's line_offset for newlines
      scanner: update last_line in struct location
      erec: skip includes with INDESC_INTERNAL
      parser: close scope when encountering an error in a table or chain block
      parser: recover from errors in any block
      parser: evaluate commands immediately after parsing
      tests: add two tests for error reporting
      parser: prohibit redefinitions of symbols and verify existance on use
      files: add inet filter table definition
      cmd: initialize cmd list and use list_splice_tail() for adding to command list
      netlink: add netlink specific location
      eval: use list_splice_tail() properly
      netlink_linearize: fix flagcmp op
      Merge branch 'next-3.14' of git.netfilter.org:nftables into next-3.14
      evaluate: use flagcmp for single RHS bitmask expression
      binop: take care of operator precedence when printing binop arguments
      netlink_delinarize: convert *all* bitmask values into individual bit values
      netlink: fix prefix expression handling
      expr: make expr_binary_error() usable outside of evaluation
      expr: add comparison function for singleton expressions
      set: abort on interval conflicts
      netlink: use set location for IO errors
      parser: add grammatical distinction for verdict maps
      set: properly account set size when merging recursive set definitions
      segtree: sort set elements before decomposition
      utils: fix -Wcast-align warnings on sparc
      parser: fix ether keyword clash
      Merge branch 'master' of git.netfilter.org:nftables
      gmputil: use MSF/LSF in import/export functions dependant on host byte order
      netlink: fix length value of concat data
      build: fix documentation build
      doc: documentation update
      datatypes: rename some types for more consistency
      doc: fix programlisting indentation
      doc: change documentation license to CC BY-SA 4.0
      doc: fix make install problems
      Bump version to v0.2


--0OAP2g/MAC+5xKAE--
