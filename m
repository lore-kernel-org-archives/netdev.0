From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] nftables 0.6 release
Date: Thu, 2 Jun 2016 18:59:40 +0200
Message-ID: <20160602165940.GA1874@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="W/nzBZO5zC0uMSeA"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45126 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030190AbcFBQ7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 12:59:53 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 53A961153126
	for <netdev@vger.kernel.org>; Thu,  2 Jun 2016 18:59:51 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3F3859EBA4
	for <netdev@vger.kernel.org>; Thu,  2 Jun 2016 18:59:51 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1145F9EBAB
	for <netdev@vger.kernel.org>; Thu,  2 Jun 2016 18:59:46 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

	nftables 0.6

This release contains many accumulated bug fixes and new features
availale up to the Linux 4.7-rc1 kernel release.

New features
============

* Rule replacement: You can replace any rule from the unique 64-bits
  handle. You have to retrieve the handle from the ruleset listing.

  # nft list ruleset -a
  table ip filter {
        chain input {
                ...
                ct state new tcp dport ssh accept counter packets 0 bytes 0 # handle 4
        }
  }

  Then, indicate this handle from the new rule that you want to
  replace, eg.

  # nft replace rule filter input handle 4 ct state new \
        tcp dport { 22, 80} counter accept

* Flow table support: This provides a native replacement for the
  hashlimit match in iptables. The rule below creates a 'ssh' flow table
  declares a ratelimit of 10 packets per second for each source IP address:

  # nft add rule filter input tcp dport 22 ct state new \
        flow table ssh { ip saddr limit rate 10/second } accept

  This is actually way more than hashlimit since you can use any selector
  and build your own tuple of selectors through concatenations, eg.

  # nft add rule filter input \
        flow table acct { iif . ip saddr timeout 60s counter }

  Then, if you want to list the content of the 'acct' flow table:

  # nft list flow table acct
  table ip filter {
        flow table acct {
                type iface_index . ipv4_addr
                flags timeout
                elements = { eth0 . 218.68.110.274 expires 3m56s : counter packets 1 bytes 98, eth0 . 180.29.103.19 expires 3m57s : counter packets 2 bytes 80, eth0 . 8.8.8.8 expires 3m44s : counter packets 1 bytes 84}
        }
  }

  Note that this listing format is still unstable though, so don't make
  tools to parse this output yet. Commands to empty flow tables and remove
  specific entries are still missing.

  Moreover, flow tables require a Linux kernel >= 4.3.

* New tracing infrastructure: Useful for ruleset debugging, you have
  to enable tracing via:

    # nft filter input tcp dport 10000 nftrace set 1
    # nft filter input icmp type echo-request nftrace set 1

  Then, you can monitor traces through:

    # nft -nn monitor trace

  That generates the following outputs:

    trace id e1f5055f ip filter input packet: iif eth0 ether saddr
63:f6:4b:00:54:52 ether daddr c9:4b:a9:00:54:52 ip saddr 192.168.122.1
ip daddr 192.168.122.83 ip tos 0 ip ttl 64 ip id 32315 ip length 84
icmp type echo-request icmp code 0 icmp id 10087 icmp sequence 1
    trace id e1f5055f ip filter input rule icmp type echo-request
nftrace set 1 (verdict continue)
    trace id e1f5055f ip filter input verdict continue
    trace id e1f5055f ip filter input
    trace id 74e47ad2 ip filter input packet: iif vlan0 ether saddr
63:f6:4b:00:54:52 ether daddr c9:4b:a9:00:54:52 vlan pcp 0 vlan cfi 1
vlan id 1000 ip saddr 10.0.0.1 ip daddr 10.0.0.2 ip tos 0 ip ttl 64 ip
id 49030 ip length 84 icmp type echo-request icmp code 0 icmp id 10095
icmp sequence 1
    trace id 74e47ad2 ip filter input rule icmp type echo-request
nftrace set 1 (verdict continue)
    trace id 74e47ad2 ip filter input verdict continue
    trace id 74e47ad2 ip filter input
    trace id 3030de23 ip filter input packet: iif vlan0 ether saddr
63:f6:4b:00:54:52 ether daddr c9:4b:a9:00:54:52 vlan pcp 0 vlan cfi 1
vlan id 1000 ip saddr 10.0.0.1 ip daddr 10.0.0.2 ip tos 16 ip ttl 64
ip id 59062 ip length 60 tcp sport 55438 tcp dport 10000 tcp flags ==
syn tcp window 29200
    trace id 3030de23 ip filter input rule tcp dport 10000 nftrace set
1 (verdict continue)
    trace id 3030de23 ip filter input verdict continue
    trace id 3030de23 ip filter input

  The trace id is unique for each packet, there above you can see the
  travel of this packet through the nft packet classifier.

* Ratelimiting enhancements: You can now specify ratelimits in terms
  of bytes/second, eg.

  # nft add rule filter forward \
        limit rate 1024 mbytes/second counter accept

  The rule above matches packets under the specified ratelimit. This
  requires a Linux kernel >= 4.3 btw.

  You can also indicate the amount of traffic that can go over the
  threshold via 'burst', eg.

  # nft add rule filter forward \
        limit rate 1024 mbytes/second burst 10240 bytes counter accept

  You may also need to match based on inverted logic, eg.

  # nft add rule filter forward \
        limit rate over 1024 mbytes/second log prefix "OVERLIMIT: " drop

* VLAN matching: You can match any vlan header field and combine this
  with any of the existing upper layer header selectors, eg.

  # nft add rule bridge filter prerouting vlan id 24 \
              ip saddr 192.168.1.0/24 counter accept

* Packet duplication: When used from any of the supported layer 3 families,
  this allows you to clone packets to a given destination address, eg.
  duplicate all packets whose mark is 0xffff:

  # nft add rule filter forward \
        meta mark 0xffff dup to 172.20.0.2 counter

  You can actually combine this new feature with maps:

  # nft add rule filter forward meta mark 0xffff \
        dup to meta mark map { \
                0xffff : 172.20.0.2, \
                0xeeee : 172.20.0.3 } counter

  So the destination for the duplicated packet depends on the packet
  mark.

  You can also use this from layer 2 ingress, eg.

  # nft add table netdev filter
  # nft add chain netdev filter ingress { \
        type filter hook ingress device eth0 priority 0\; }
  # nft add rule netdev filter ingress dup to dummy0

  In this case, you specify the nic that is used to transmit the
  duplicated packet.

* Packet forwarding from the new ingress family, eg.

  # nft add rule netdev filter ingress iif eth0 fwd to eth1

  To forward packets that enter from eth0, then make them go through
  eth1.

* String prefix matching through '*' (asterisk), eg.

  # nft add filter forward iifname eth\* ...

  This is equivalent to iptables ... -i eth+

* DSCP and ECN matching, eg.

  # nft add rule filter forward ip dscp cs1 counter
  # nft add rule ip6 filter forward ip6 dscp cs4 counter
  # nft add rule ip filter forward ip ecn ce counter
  # nft add rule ip6 filter forward ip6 ecn ce counter

* Stateless payload mangling, eg.

  # nft add rule filter forward tcp dport 8080 tcp dport set 80

  This rule above mangles the destination port from 8080 to 80. Beware
  of interactions with conntrack, flows whose traffic is mangled must
  be untracked. However, we don't support NOTRACK yet though in nft.

* Conntrack direction-based matching, eg. ct original saddr 1.2.3.4.

* Support for ICMP router advertisement and solicitation, eg.

  # nft add rule ip filter input \
        icmp type {router-advertisement, router-solicitation} counter accept

* Better listing support: You can perform selective listing of
  objects, eg.

  To display the existing declararation tables (without no content).

  # nft list tables ip
     table ip filter
  # nft list tables ip6
     table ip6 filter
  # nft list tables
     table ip filter
     table ip6 filter

  List existing chains, eg.

  # nft list chains
  table ip filter {
         chain test1 {
         }
         chain test2 {
         }
         chain input {
              type filter hook input priority 0; policy accept;
         }
  }

  List existing set declaration, eg.

  # nft list sets
  table ip filter {
         set libssh {
              type ipv4_addr
         }
  }

  Note the listing above shows no elements, to see the set content,
  you must specify set name, eg.

  # nft list set ip filter libssh
  table ip filter {
        set libssh {
                type ipv4_addr
                elements = { 163.123.166.2}
        }
  }

  You can also list existing maps, eg.

  # nft list map ip6 filter test
  table ip6 filter {
        map test {
                type ipv6_addr : inet_service
                elements = { 2001:db8::ff00:42:8329 : http}
        }
  }

  In general, the same logic applies for every nft object, ie. generic
  listing shows declarations, then if the object name is specified, the
  its content is shown.

* Masquerading port range selection: Allows us to restricts the ports
  that will be used in the masquerading.

  # nft add rule nat postrouting ip protocol tcp masquerade to :1024-10024

* A new shell-based testsuite, to complement the existing python-based
  unitary tests. Nothing fancy for users, but useful for us developers :)


Bugfixes
========

Not strictly limited to this list below, but some highlights:

* Resolve problems with prefixes in named sets, eg.

  # nft add set filter blacklist { type ipv4_addr\; flags interval\; }
  # nft add element filter blacklist { 192.168.1.0/24 }
  # nft add element filter blacklist { 192.168.5.0/24, 192.168.7.0/24 }
  # nft delete element filter blacklist { 192.168.5.0/24, 192.168.7.0/24 }

  Note: this requires a couple of patches in Linux >= 4.7-rc1, I will
  request submission to -stable asap.

* Resolve dynamic map evaluation problems, so this below now works:

  # cat ruleset.file
  table ip mangle {
        map CLASS05 {
                type ipv4_addr : mark
                elements = { 192.168.0.10 : 0x00000001}
        }

        chain OUTPUT {
                type route hook output priority 0; policy accept;
                mark set ip saddr map @CLASS05
        }
  }
  # nft -f ruleset.file

* Filtering based on layer 2 header selectors from the in inet family,
  eg.

  # nft add rule inet filter forward ether saddr 00:0f:54:0c:11:40 \
        tcp dport 22 counter accept

* Fix wrong dependency handling, eg. ip protocol != tcp udp dport ssh

* Enforce ip6 proto with exthdr expression.

* Generate the correct bytecode on NAT redirection where ports are
  specified, eg.

  # nft add rule ip nat prerouting tcp dport 80 redirect to 1025-2048

* Printing of rule comments where misplace when listing the rule
  handle, the example below shows the right output:

  # nft list ruleset -a
  table filter {
        chain input {
             ...
             iifname eth0 comment "test" # handle 1
        }
  }

* Restore matching of icmp redirect type and ct status snat and dnat.

Resources
=========

The nftables code can be obtained from:

* http://netfilter.org/projects/nftables/downloads.html
* ftp://ftp.netfilter.org/pub/nftables
* git://git.netfilter.org/nftables

To build the code, libnftnl 1.0.6 and libmnl >= 1.0.2 are required:

* http://netfilter.org/projects/libnftnl/index.html
* http://netfilter.org/projects/libmnl/index.html

Visit our wikipage for user documentation at:

* http://wiki.nftables.org

For the manpage reference, check man(8) nft.

In case of bugs and feature request, file them via:

* https://bugzilla.netfilter.org

Make sure you create no duplicates already, thanks!

Happy testing!


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: attachment; filename="changes-nftables-0.6.txt"
Content-Transfer-Encoding: 8bit

Arturo Borrero (27):
      tests/: rearrange tests directory
      tests/: add shell test-suite
      tests/shell: add maps tests cases
      tests/shell: add test case for cache bug
      tests/shell: add tests for handles and comments
      rule: don't list anonymous sets
      rule: delete extra space in sets printing
      tests/shell: add first `nft -f' tests
      tests/listing: add some listing tests
      tests/shell: unload modules between tests
      tests/shell/run-tests.sh: tune kernel cleanup
      tests/shell: add chain validations tests
      rule: don't print trailing statement whitespace
      tests/shell: add new testcases for commit/rollback
      tests/shell: add some tests for network namespaces
      evaluate: improve rule management checks
      test: shell: also unload NAT modules
      tests/shell: add testcases for Netfilter bug #965
      tests/shell: delete tempfile failover in testcases
      tests: shell: add testcases for named sets with intervals
      tests: py: allow to run tests with other nft binaries
      dist: include tests/ directory and files in tarball
      evaluate: check for NULL datatype in rhs in lookup expr
      tests/shell: add testcase for 'nft -f' load with actions
      tests/shell: add testcase to catch segfault if invalid syntax was used
      tests/shell/run-tests.sh: execute tests in sorted order
      tests/shell/run-tests.sh: print hint about testcase being executed

Arturo Borrero Gonzalez (1):
      rule: fix printing of rule comments

Carlos Falgueras García (6):
      src: Add command "replace" for rules
      rule: Use libnftnl user data TLV infrastructure
      netlink_linearize: do not duplicate user data when linearizing user data
      set_elem: Use libnftnl/udata to store set element comment
      parser: Consolidate comment production
      parser: cap comment length to 128 bytes

Florian Westphal (54):
      tests: don't depend on set element order
      nft: allow stacking vlan header on top of ethernet
      payload: disable payload merge if offsets are not on byte boundary.
      src: netlink_linearize: handle sub-byte lengths
      src: netlink: don't truncate set key lengths
      nft: fill in doff and fix ihl/version template entries
      netlink: cmp: shift rhs constant if lhs offset doesn't start on byte boundary
      tests: add tests for ip version/hdrlength/tcp doff
      nft: support listing expressions that use non-byte header fields
      tests: vlan tests
      vlan: make != tests work
      expression: provide clone operation for set element ops
      src: allow filtering on L2 header in inet family
      tests: add tests matching on ether saddr for inet, bridge, ip, ip6
      rule: don't reorder protocol payload expressions when merging
      tests: add test cases for ethernet header matching
      tests: add inet test for ip/ether concatenation
      tests: regression: fix arp.t expected payload
      doc: update meta and ct expression keyword lists
      ct: add support for directional keys
      netlink: don't handle lhs zero-length expression as concat type
      netlink: only drop mask if it matches left known-size operand
      src: ct: make ct l3proto work
      tests: add ct tests for ip family
      nft: swap key and direction in ct_dir syntax
      ct: add packet/byte counter support
      netlink_linearize: use u64 conversion for 64bit quantities
      ct regression tests for bytes, packets
      tests: ct: remove BUG cases that work with current master
      doc: update ct expression
      netlink: move binop postprocess to extra function
      tests: add two map test cases
      netlink: do binop postprocessing also for map lookups
      netlink_delinearize: only remove protocol if equal cmp is used
      meta: fix error checks in tc handle parser
      examples: use current type names
      evaluate: reject set references in set elements
      evaluate: enforce ip6 proto with exthdr expression
      netlink: split generic part of netlink_gen_payload_mask into helper
      netlink: add and use netlink_gen_exthdr_mask
      payload: move payload_gen_dependency generic part to helper
      exthdr: generate dependencies for inet/bridge/netdev family
      tests: add/fix inet+exthdr tests
      exthdr: remove implicit dependencies
      exthdr: store offset for later use
      netlink_delinearize: prepare binop_postprocess for exthdr demux
      netlink_delinearize: handle extension header templates with odd sizes
      tests: frag: enable more tests
      netlink_delinearize: fix bogus offset w exthdr expressions
      nft-test: don't zap remainder of rule after handling a set
      netlink_delinarize: shift constant for ranges too
      tests: frag: enable more tests
      payload: only merge if adjacent and combined size fits into a register
      netlink_delinerize: don't use meta_match_postprocess for ct pp

Laura Garcia Liebana (3):
      proto: Add router advertisement and solicitation icmp types
      doc: fix compression parameter index
      doc: fix old parameters and update datatypes

Liping Zhang (4):
      evaluate: fix crash if we add an error format rule
      meta: fix endianness in priority
      meta: fix a format error display when we set priority to root or none
      parser: fix crash if we add a chain with an error chain type

Magnus Öberg (1):
      build: include/mini-gmp.h is not included at "make dist"

Pablo M. Bermudo Garay (16):
      tests: regression: homogenize indentation style
      tests: regression: allow to run tests from anywhere
      tests: add *.got files to .gitignore
      tests: remove useless logic
      tests: fix crash when rule test is malformed
      tests/py: remove unused variables
      tests/py: fix style
      tests/py: simplify use of globals
      tests/py: convert chains and tables to objects
      tests/py: modify supported test file syntax
      tests/py: update test files syntax
      rule: add 'list flow tables' support
      rule: add support for display flow tables content
      src: add 'list maps' support
      src: add support for display maps content
      evaluate: fix "list set" unexpected behaviour

Pablo Neira Ayuso (96):
      src: add per-bytes limit
      src: add burst parameter to limit
      tests: limit: extend them to validate new bytes/second and burst parameters
      rule: filter out tables depending on family
      parser: show all tables via list tables with no family
      src: add dup statement support
      tests: add tests for dup
      rule: display table when listing sets
      src: add `list chains' command
      rule: display table when listing one set
      evaluate: check if set exists before listing it
      rule: `list sets' only displays declaration, not definition
      rule: rework list chain
      parser_bison: show all sets via list sets with no family
      evaluate: check if table and chain exists when adding rules
      netlink_linearize: factor out prefix generation
      evaluate: fix mapping evaluation
      src: add interface wildcard matching
      evaluate: fix string matching on big endian
      netlink_delinearize: fix use-after-free
      tests: vlan pcp and cfi are located in the first byte
      src: fix sub-byte protocol header definitions
      netlink_delinearize: postprocess expression before range merge
      netlink_delinearize: add previous statement to rule_pp_ctx
      src: add new netdev protocol description
      tests: py: check set value from selector and map
      parser: restrict relational rhs expression recursion
      parser: add redirect constant to rhs_expr rule
      parser: get rid of multiton_expr from lhs relational expression
      parser: rename multiton_expr to multiton_rhs_expr
      parser: restore bitwise operations from the rhs of relational expressions
      parser_bison: initializer_expr must use rhs_expr
      tests/py: don't test log statement from protocol match
      tests/py: test udp from ip and ip6 families
      tests/py: netdev family with ingress chain
      src: support limit rate over value
      src: add dup statement for netdev
      src: add fwd statement for netdev
      tests/py: test port ranges and maps for redirect
      evaluate: resolve_protocol_conflict() should return int
      evaluate: move inet/netdev protocol context supersede logic to supersede_dep()
      evaluate: check if we have to resolve a conflict in first place
      evaluate: don't adjust offset from resolve_protocol_conflict()
      evaluate: only try to replace dummy protocol from link-layer context
      evaluate: assert on invalid base in resolve_protocol_conflict()
      evaluate: wrap protocol context debunk into function
      evaluate: generate ether type payload after meta iiftype
      proto: proto_dev_type() returns interface type for base protocols too
      src: annotate follow up dependency just after killing another
      tests/py: test vlan on ingress
      netlink_delinearize: prune implicit binop before payload_match_postprocess()
      proto: use parameter-problem for icmpv6 type
      tests/py: extend masquerade to cover ports too
      rule: simplify ("rule: delete extra space in sets printing")
      parser: remove 'reset' as reserve keyword
      tests/py: enable tests for dccp types
      parser_bison: allow 'snat' and 'dnat' keywords from the right-hand side
      tests/py: add tests for router-advertisement and router-solicitation icmp types
      src: revisit cache population logic
      evaluate: use table_lookup_global() from expr_evaluate_symbol()
      parser_bison: simplify hook_spec rule
      parser_bison: duplicate string returned by chain_type_name_lookup()
      parser_bison: release parsed type and hook name strings
      src: store parser location for handle and position specifiers
      segtree: perform stricter expression type validation from expr_value()
      segtree: clone full expression from interval_map_decompose()
      segtree: handle adjacent interval nodes from expr_value_cmp()
      segtree: explicit initialization via set_to_intervals()
      rule: support for incremental set interval element updates
      segtree: special handling for the first non-matching segment
      evaluate: bail out on prefix or range to non-interval set
      segtree: set expr->len for prefix expression from interval_map_decompose()
      segtree: add expr_to_intervals()
      segtree: rename set expression set_to_segtree()
      segtree: add interval overlap detection for dynamic updates
      tests/py: add more interval tests for anonymous sets
      tests/py: explicitly indication of set type and flags from test definitions
      tests/py: add interval tests
      evaluate: transfer right shifts to range side
      evaluate: transfer right shifts to set reference side
      src: move payload sub-byte matching to the evaluation step
      evaluate: handle payload matching split in two bytes
      proto: update IPv6 flowlabel offset and length according to RFC2460
      proto: remove priority field definition from IPv6 header
      src: add dscp support
      src: add ecn support
      tests/py: add missing netdev ip dscp payload tests
      tests/py: fix fragment-offset field
      tests/py: fix payload of dccp type in set elements
      netlink: several function constifications
      src: declare interval_map_decompose() from header file
      tests/py: update for changed set name in payload
      parser_bison: update flow table syntax
      include: constify nlexpr field in location structure
      tests/py: add tests for frag more-fragments and frag reserved2
      Bump version to v0.6

Patrick McHardy (17):
      rule: move comment out of handle
      proto: add checksum key information to struct proto_desc
      payload: add payload statement
      proto: fix arpop symbol table endianess
      netlink: fix up indentation damage
      payload: fix stacked headers protocol context tracking
      nft: resync kernel header files
      payload: move payload depedency tracking to payload.c
      payload: add payload_is_stacked()
      proto: add protocol header fields filter and ordering for packet decoding
      nft monitor [ trace ]
      evaluate: transfer right shifts to constant side
      set: allow non-constant implicit set declarations
      set: explicitly supply name to implicit set declarations
      netlink_delinearize: support parsing statements not contained within a rule
      stmt: support generating stateful statements outside of rule context
      src: add flow statement

Piyush Pangtey (3):
      doc: nft: Fixed a typo and added/changed punctuation
      nft: Modified punctuation used in nft's show_help
      rule: Remove memory leak

Shivani Bhardwaj (5):
      src: datatype: Modify symbol table for icmpv6 packet types
      ip6: Add tests for icmpv6 packet types
      src: netlink_linearize: Fix bug for redirect target
      src: Add support for masquerade port selection
      src: evaluate: Show error for fanout without balance


--W/nzBZO5zC0uMSeA--
