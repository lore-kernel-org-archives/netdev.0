From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] nftables 0.7 release
Date: Tue, 20 Dec 2016 21:46:36 +0100
Message-ID: <20161220204636.GA11674@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
        netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47284 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932908AbcLTUqs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Dec 2016 15:46:48 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 2C41B117430
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 21:46:45 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 18D948E665
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 21:46:45 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C85578E666
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2016 21:46:41 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        nftables 0.7

This release contains many accumulated bug fixes and new features
available up to the (upcoming) Linux 4.10-rc1 kernel release.

* Facilitate migration from iptables to nftables:

  At compilation time, you have to pass this option.

  # ./configure --with-xtables

  And libxtables needs to be installed in your system. This allows you
  to list a ruleset containing xt extensions loaded through
  iptables-compat-restore tool. The nft tool provides a native
  translation for iptables extensions (if available).

* Add new fib expression, which can be used to obtain the output
  interface from the route table based on either source or destination
  address of a packet. This can be used to e.g. add reverse path
  filtering, eg. drop if not coming from the same interface packet
  arrived on:

  # nft add rule x prerouting fib saddr . iif oif eq 0 drop

  Accept only if from eth:

  # nft add rule x prerouting fib saddr . iif oif eq "eth0" accept

  Accept if from any valid interface:

  # nft add rule x prerouting fib saddr oif accept

  Querying of address type is also supported, this can be used
  to only accept packets to addresses configured in the same
  interface, eg.

  # nft add rule x prerouting fib daddr . iif type local accept

  Its also possible to use mark and verdict map, eg,

  # nft add rule x prerouting \
        meta mark set 0xdead fib daddr . mark type vmap {
                blackhole : drop,
                prohibit : drop,
                unicast : accept
        }

* Support hashing of any arbitrary key combination, eg.

  # nft add rule x y \
        dnat to jhash ip saddr . tcp dport mod 2 map { \
                0 : 192.168.20.100, \
                1 : 192.168.30.100 \
        }

  Another usecase: Set packet marks based on any arbitrary hashing.

* Add number generation support. Useful for round-robin packet mark
  setting, eg.

  # nft add rule filter prerouting meta mark set numgen inc mod 2

  You can also specify an offset to indicate from what value you want
  to start from.

  The modulus provides the scale of the counting sequence. You can
  also use this from maps, eg.

  # nft add rule nat prerouting \
        dnat to numgen inc mod 2 map { 0 : 192.168.10.100, 1 : 192.168.20.200 }

  So this is distributing new connections in a round-robin fashion
  between 192.168.10.100 and 192.168.20.200. Don't forget the special NAT
  chain semantics: Only the first packet evaluates the rule, follow up
  packets rely on conntrack to apply the NAT information.

  You can also emulate flow distribution with different backend weights
  using intervals, eg.

  # nft add rule nat prerouting \
        dnat to numgen inc mod 10 map { 0-5 : 192.168.10.100, 6-9 : 192.168.20.200 }

* Add quota support, eg.

  # nft add rule filter input \
            flow table http { ip saddr timeout 60s quota over 50 mbytes } drop

  This creates a flow table, where every flow gets a quota of 50
  mbytes. You can also from use simple rules too to enforce quotas, of
  course.

* Introduce routing expression, for routing related data with support
  for nexthop (i.e. the directly connected IP address that an outgoing
  packet is sent to), which can be used either for matching or accounting, eg.

     # nft add rule filter postrouting \
          ip daddr 192.168.1.0/24 rt nexthop != 192.168.0.1 drop

  This will drop any traffic to 192.168.1.0/24 that is not routed via
  192.168.0.1.

     # nft add rule filter postrouting \
          flow table acct { rt nexthop timeout 600s counter }

     # nft add rule ip6 filter postrouting \
          flow table acct { rt nexthop timeout 600s counter }

  These rules count outgoing traffic per nexthop. Note that the timeout
  releases an entry if no traffic is seen for this nexthop within 10
  minutes.

* Notrack support, to explicitly skip connection tracking for matching
  packets, eg.

     # nft add rule ip raw prerouting tcp dport { 80, 443 } notrack

  So you can skip tracking for http and https traffic.

* Support to set non-byte bound packet header fields, including
  checksum adjustment, eg. ip6 ecn set 1.

* Add 'create set' and 'create element' commands, eg.

     # nft add set x y { type ipv4_addr\; }
     # nft create set x y { type ipv4_addr\; }
     <cmdline>:1:1-35: Error: Could not process rule: File exists
     create set x y { type ipv4_addr; }
     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
     # nft add set x y { type ipv4_addr\; }
     #

  So 'create' bails out if the set already exists, while 'add'
  doesn't, for more ergonomic usage as several users requested on
  the mailing list.

* Allow to use variable reference for set element definitions, eg.

  # cat ruleset.nft
    define s-ext-2-int = { 10.10.10.10 . 25, 10.10.10.10 . 143 }

    table inet forward {
            set s-ext-2-int {
                 type ipv4_addr . inet_service
                 elements = $s-ext-2-int
            }
    }
  # nft -f ruleset.nft

  Useful to improve ruleset maintainability, as you can split out
  variable and set definitions from the filtering policy itself.

* Allow to use variable definitions from element commands, eg.

     define whitelist_v4 = { 1.1.1.1 }

     table inet filter {
        set whitelist_v4 { type ipv4_addr; }
     }

     add element inet filter whitelist_v4 $whitelist_v4

* Add support to flush set. You can use this new command to remove all
  existing elements in a set, eg.

  # nft flush set filter xyz

  Note that this requires (upcoming) Linux kernel 4.10-rc versions.

* Inverted set lookups, eg. tcp dport != { 80, 443 }.

* Honor absolute and relative paths via include file, where:

    include "./ruleset.nft"

  refers to a file in the working directory.

    include "ruleset.nft"

  refers to a file in the nftables root path (via sysconfdir), and:

    include "/etc/nftables/ruleset.nft"

  provides an absolute reference to the file that need to be included.
  This also solves an ambiguity if the same file name is used both under
  sysconfdir and the current working directory.

* Support log flags, to enable logging TCP sequence and options:

     # nft add rule x y log flags tcp sequence,options

  ... IP options, eg:

     # nft add rule x y log flags ip options

  ... socket UID, eg.

     # nft add rule x y log flags skuid

  ... decide ethernet link layer address, eg.

     # nft add rule x y log flags ether

  ... or simply set on all flags:

     # nft add rule x y log flags all

* tc classid parser support, eg.

    nft add rule filter forward meta priority abcd:1234

* Allow numeric connlabels, so if connlabel still works with undefined
  labels, eg. ct label set 2.

* Document log, reject, counter, meta, limit, nat, ct, payload and
  queue statements from nft(8) manpage.

Bugfixes
========

Not strictly limited to this list below, but some highlights:

* Allow split table definitions, eg.

  # cat ruleset.nft
  table inet filter {
       chain ssh {
               type filter hook input priority 0; policy accept;
               tcp dport ssh accept;
       }
  }
  table inet filter {
       chain input {
               type filter hook input priority 1; policy drop;
       }
  }
  # nft -f ruleset.nft

* Use new range expression to represent inverted intervals, eg.
  ip saddr != 1.1.1.1-2.2.2.2, since previously generated bytecode was
  not correct.
* Solve endianness problems with link layer address.
* Fix parser to keep map flag around on definition.
* Skip timeout attribute in dynamic set updates, other kernel bails
  out with EINVAL.
* Restore parsing of dynamic set element updates.
* The time datatype now uses milliseconds, as the kernel expects.
* Allow numeric interface index numbers, eg. in meta iif, oif.
* Fix monitor trace crash with netdev family.
* Flow table with concatenation fixes.
* Keep element comments around when using set intervals.
* Fixed memory corruption in userspace when deleting lots of elements
  in one go via nft -f.
* Several nft internal cache fixes, including cache reset on 'flush
  ruleset'.
* Restore parens on right-hand side of relational expression.
* Replace getnameinfo() by internal lookup table, so we don't rely on
  /etc/services anymore for service names, so we restrict them to
  a well-known set that is supported by our scanner. You can list
  service names via 'nft describe tcp dport'.
* Display symbol table values in the right hostbyte order and
  decimal/hexadecimal representation.
* Fix a nasty bug in the set interval code triggering huge memory
  consumption in userspace for set and map intervals with runtime
  updates.

We also got lots more tests added to our infrastructure to catch up
regressions.

Syntax updates
==============

Several minor syntax updates, although previous syntax has been
preserved by now to facilitate transition, the new one is prefered:

* Consistency grammar fixes: 'snat' and 'dnat' now require 'to', eg.
  snat to 1.2.3.4. For consistency with existing statements such as
  redirect, masquerade, dup and fwd. Moreover, add colon after 'to' in
  'redirect' for consistency with nat and masq statements.

* Allow ct l3proto/protocol without direction since they are unrelated
  to the direction.

* Explicit ruleset exportation, eg. nft export ruleset json, for
  consistency with other existing ruleset commands.

* Always quote user-defined strings from rules when listing them.

* Support for RFC2732 IPv6 address format with brackets, eg.

  dnat to [2001:838:35f:1::]:80

* Allow strings starting by underscores and dots in user-define
  strings, conforming with POSIX.1-2008 (which is simultaneously IEEE
  Std 1003.1-2008).

Resources
=========

The nftables code can be obtained from:

* http://netfilter.org/projects/nftables/downloads.html
* ftp://ftp.netfilter.org/pub/nftables
* git://git.netfilter.org/nftables

To build the code, libnftnl 1.0.7 and libmnl >= 1.0.2 are required:

* http://netfilter.org/projects/libnftnl/index.html
* http://netfilter.org/projects/libmnl/index.html

Visit our wikipage for user documentation at:

* http://wiki.nftables.org

For the manpage reference, check man(8) nft.

In case of bugs and feature request, file them via:

* https://bugzilla.netfilter.org

Make sure you create no duplicates already, thanks!

Happy holidays!

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="changes-nftables-0.7.txt"
Content-Transfer-Encoding: 8bit

Anatole Denis (7):
      evaluate: Add set to cache only when well-formed
      tests: Add regression test for malformed sets
      Revert "evaluate: check for NULL datatype in rhs in lookup expr"
      src: Interpret OP_NEQ against a set as OP_LOOKUP
      tests/py: Unmask negative set lookup
      rule: Introduce helper function cache_flush
      evaluate: Update cache on flush ruleset

Anders K. Pedersen (4):
      rt: introduce routing expression
      Replace tests/files/expr-rt with Python based tests, and replace ether type     with meta nfproto, which generates a bit fewer instructions.
      evaluate: Allow concatenation of rt nexthop etc.
      doc: fix synopsis for ct expression

Arturo Borrero (3):
      tests: shell: delete unused variable in run-tests.sh
      tests: shell: cleanup tempfile handling in testcases/sets/cache_handling_0
      tests: shell: run-tests.sh: use src/nft binary by default

Arturo Borrero Gonzalez (12):
      tests: shell: update kernel modules to clean
      xt: update Arturo Borrero Gonzalez email address
      tests: shell: delete useless stderr output in testcase
      tests: shell: introduce the cache testcases directory
      tests: shell: add a new testcase for ruleset loading bug
      tests: shell: add testcases for comments in set elements
      tests: shell: allow to execute a single testcase
      tests: shell: testcase for adding many set elements
      tests: shell: testcase for deleting many set elements
      tests: shell: another testcase for deleting many set elements
      tests: shell: add a testcase for many defines
      tests: shell: add testcase for different defines usage

Carlos Falgueras García (1):
      src: Simplify parser rule_spec tree

Elise Lennion (4):
      datatype: Replace getnameinfo() by internal lookup table
      datatype: Display pre-defined inet_service values in host byte order
      datatype: Display pre-defined inet_service values in decimal base
      expression: Show the base which pre-defined constants are displayed

Florian Westphal (30):
      payload: don't update protocol context if we can't find a description
      meta: add random support
      meta: add tests for meta random
      ct: use nftables sysconf location for connlabel configuration
      tests: add basic payload tests
      tests: add ether payload set test
      netlink: add __binop_adjust helper
      payload: print base and raw values for unknown payloads
      evaluate: add small helper to check if payload expr needs binop adjustment
      evaluate: add support to set IPv6 non-byte header fields
      netlink: decode payload statment
      tests: ip6 dscp, flowlabel and ecn test cases
      netlink: make checksum fixup work with odd-sized header fields
      tests: ip payload set support for ecn and dscp
      ct: allow numeric conntrack labels
      ct: display bit number instead of raw value
      doc: update meta expression
      doc: payload and conntrack statement
      datatype: ll: use big endian byte ordering
      tests: catch ordering issue w. ether set
      payload: remove byteorder conversion
      meta: permit numeric interface type
      netlink: fix monitor trace crash with netdev family
      meta: fix pkttype name and add 'other' symbol
      utils: provide snprintf helper macro
      ct: allow resolving ct keys at run time
      meta: allow resolving meta keys at run time
      src: add fib expression
      Revert "tests: py: nft-tests.py: Add function for loading and removing kernel modules"
      bison: remove old log level tokens

Jon Jensen (1):
      Correct description of -n/--numeric option

Laura Garcia Liebana (5):
      doc: Update datatypes
      src: add offset attribute for numgen expression
      netlink: fix linearize numgen type
      src: make hash seed attribute optional
      src: add offset attribute for hash expression

Liping Zhang (14):
      tests: shell: make testcases which using tcp/udp port more rubost
      tests: shell: add endless jump loop tests
      parser_bison: keep snat/dnat existing syntax unchanged
      tests: shell: add testcase for reject expr
      meta: fix memory leak in tc classid parser
      tests: py: replace "eth0" with "lo" in dup expr tests
      src: fix compile error due to _UNTIL renamed to _MODULUS in libnftnl
      tests: py: add more test cases for queue expr
      tests: py: fix numgen case failed due to changes in libnftnl
      src: support ct l3proto/protocol without direction syntax
      ct: fix "ct l3proto/protocol" syntax broken
      log: rename the log level "warning" to "warn"
      src: add log flags syntax support
      tests: shell: add test case for inserting element into verdict map

Manuel Johannes Messner (3):
      tests: py: nft-tests.py: Add function for loading and removing kernel modules
      tests: py: any: Make tests more generic by using other interfaces
      tests: py: any: Remove duplicate tests

Nicholas Vinson (1):
      nft: configure.ac: Replace magic dblatex dep.

Pablo Neira (2):
      src: expose delinearize/linearize structures and stmt_error()
      src: trigger layer 4 checksum when pseudoheader fields are modified

Pablo Neira Ayuso (71):
      src: use new definitions from libnftnl
      segtree: don't check for overlaps if set definition is empty
      tests: shell: cover transactions via nft -f using flat syntax
      datatype: time_type should send milliseconds to userspace
      parser_bison: restore parsing of dynamic set element updates
      netlink_linearize: skip NFTNL_EXPR_DYNSET_TIMEOUT attribute if timeout is unset
      include: cache ip_tables.h, ip6_tables.h, arp_tables.h and ebtables.h
      src: add xt compat support
      parser_bison: fix typo in symbol redefinition error reporting
      tests: shell: make sure split table definition works via nft -f
      xt: use struct xt_xlate_{mt,tg}_params
      parser_bison: keep map flag around when flags are specified
      scanner: honor absolute and relative paths via include file
      scanner: don't fall back on current directory if include is not found
      scanner: don't break line on include error message
      tests: tests to include files
      ct: add missing slash to connlabel path
      ct: release ct_label table on exit
      src: quote user-defined strings when used from rule selectors
      src: add 'to' for snat and dnat
      src: support for RFC2732 IPv6 address format with brackets
      parser_bison: missing token string in QUOTED_ASTERISK and ASTERISK_STRING
      scanner: allow strings starting by underscores and dots
      scanner: remove range expression
      src: rename datatype name from tc_handle to classid
      src: simplify classid printing using %x instead of %04x
      src: meta priority support using tc classid
      parser_bison: redirect to :port for consistency with nat/masq statement
      parser_bison: explicit indication on export ruleset
      src: add create set command
      tests: shell: cover add and create set command
      src: create element command
      tests: shell: cover add and create set command
      include: refresh uapi/linux/netfilter/nf_tables.h copy
      tests: py: adapt it to new add element command semantics
      src: add quota statement
      src: add numgen expression
      src: add hash expression
      evaluate: add expr_evaluate_integer()
      evaluate: validate maximum hash and numgen value
      parser_bison: add variable_expr rule
      parser_bison: allow variable references in set elements definition
      tests: py: adapt netlink bytecode output of numgen and hash
      evaluate: display expression, statement and command name on debug
      netlink_delinearize: Avoid potential null pointer deref
      doc: nft: add my copyright statement to the manpage
      doc: nft: document log, reject, counter, meta, limit, nat and queue statements
      src: use new range expression for != [a,b] intervals
      parser_bison: allow to use variable to add/create/delete elements
      src: don't need keyword for log level
      parser: add offset keyword and parser rule
      tests/py: add missing payload test for numgen offset
      netlink_linearize: skip set element expression in flow table key
      segtree: keep element comments in set intervals
      tests: py: add some testcases for log flags
      tests: py: missing range conversion in icmpv6
      src: add notrack support
      mnl: use nftnl_set_elems_nlmsg_build_payload_iter() when deleting elements
      include: refresh nf_tables.h header
      datatype: honor -nn option from inet_service_type_print()
      evaluate: return ctx->table from table_lookup_global()
      src: add support to flush sets
      segtree: wrong prefix expression length on interval_map_decompose()
      segtree: don't trigger error on exact overlaps
      mnl: don't send empty set elements netlink message to kernel
      tests: py: update quota and payload
      netlink_linearize: fix IPv6 layer 4 checksum mangling
      mnl: add mnl_nft_setelem_batch_flush() and use it from netlink_flush_setelems()
      xt: use NFTNL_* definitions
      configure: Bump version to v0.7
      include: Missing noinst_HEADERS updates

Phil Sutter (5):
      evaluate: Fix datalen checks in expr_evaluate_string()
      evaluate: reject: Have a generic fix for missing network context
      evaluate: Avoid undefined behaviour in concat_subtype_id()
      parser_bison: Allow parens on RHS of relational_expr
      tests: py: Test TCP flags match with parentheses


--sdtB3X0nJg68CQEu--
