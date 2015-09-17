From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] nftables 0.5 release
Date: Thu, 17 Sep 2015 21:42:00 +0200
Message-ID: <20150917194200.GA18357@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SUOF0GtieIMvvwua"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net,
	kaber@trash.net
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

	nftables 0.5

This release contains bug fixes and new features contained up to the
4.2 kernel release.

New features
============

* Concatenations: You can combine two or more selectors to build a
  tuple, then use it to look up for a matching in sets, eg.

  % nft add rule ip filter input ip saddr . tcp dport { \
                1.1.1.1 . 22 , \
                1.1.1.1 . 80 \
    } counter accept

  So nft will check if the source IP address AND the TCP destination port
  matches what you have in the literal set above, if so it will
  update the rule counter and accept the packet.

  You can also combine concatenations with verdict maps:

  % nft add rule ip filter input ether saddr . ip saddr . meta iif vmap { \
                3c:71:0e:39:bb:20 . 192.168.1.120 . "wlan0" : accept, \
                3c:77:e0:39:aa:21 . 192.168.1.204 . "wlan0" : drop }

  You can declare a set using concatenations, to dynamically update its content
  instead:

  % nft add map filter accesslist { \
        type ether_addr . ipv4_addr . iface_index : verdict \; }
  % nft add rule filter input ether saddr . ip saddr . meta iif vmap @accesslist

  Then, add elements to the set:

  % nft add element filter accesslist { \
        3c:71:0e:39:bb:20 . 192.168.1.120 . wlan0 : accept }

  On a different front, you can also combine concatenations with maps:

  % nft add rule ip nat prerouting dnat ip saddr . tcp dport map { \
                192.168.1.120 . 80 : 1.2.3.4, \
                192.168.1.204 . 22 : 4.3.2.1 }

  In the example above, the destination address that is used in DNAT depends
  on the source IP address and the destination port of the packet.

  You require a Linux kernel >= 4.1 to use this new concatenation feature and
  nftables 0.5 of course.

* Add timeout support for sets: You can specify a lifetime for elements in your
  set declarations, eg.

  % nft add set filter whitelist { type ipv4_addr\; timeout 1h\; }
  % nft add element filter whitelist { 192.168.1.234 }
  % nft list ruleset
  table ip filter {
        set whitelist {
                type ipv4_addr
                timeout 1h
                elements = { 1.2.3.4 expires 59m56s}
        }
  }

  You can also create the set with no specific timeout:

  % nft add set filter whitelist { type ipv4_addr\; flags timeout\; }

  So you can indicate the timeout when adding the element:

  % nft add element filter whitelist { 192.168.2.123 timeout 1h }

  You still can mix this with element that will reside permanently too:

  % nft add element filter whitelist { 192.168.2.180 }

* Add comments per set element, eg.

  % nft add element filter whitelist { 192.168.0.1 comment \"some host\" }

* Support for mini-gmp: If you're running nft from embedded devices,
  you may want to skip the libgmp dependency via:

  % ./configure --with-mini-gmp

  This compiles nft using the minimal gmp implementation that comes in
  the nftables tarball. Note that your nft binary avoids the libgmp
  dependency at the cost of getting a slightly larger binary.

* Dormant tables: You can disable the entire ruleset that is contained in a
  table by setting on the dormant flag:

  % nft add table filter { flags dormant\; }

  You can reenable it by typing:

  % nft add table filter

* Allow to specify default chain policy: You can specify the default chain
  policy by when you create the chain:

  % nft add chain filter input { \
        type filter hook input priority 0\; policy drop\; }

  You can also change it for an existing chain anytime by updating it via:

  % nft add chain filter input { policy accept\; }

Bug fixes
=========

* Command per line ruleset representation: According to what I can find on the
  Internet, it seems some people like to maintain their ruleset in scripts so
  they can add comments and annotate things there. However, this is a problem
  for two reasons: There is no atomic update since rules are published to the
  packet path one after another and this increases the time that nft takes to
  reload your ruleset significantly.

  So, the solution to this problem consists of keeping your ruleset like this:

  % cat my-ruleset-file
  flush ruleset
  add table filter
  add set filter whitelist { type ipv4_addr; }
  add chain filter input { type filter hook input priority 0; }
  add rule filter input iif lo accept
  add rule filter input ct state established,related counter accept
  add rule filter input tcp dport { 22, 80 } counter accept
  add rule filter input ip saddr @whitelist counter accept
  add element filter whitelist { 192.168.1.120 }
  add element filter whitelist { 192.168.1.121 }
  add element filter whitelist { 192.168.1.204 }

  You can also insert comments in the file through '#'.

  Then, you can atomically restore it via:

  % nft -f my-ruleset-file

  You can also use this command per line representation to apply
  incremental ruleset updates atomically:

  % cat incremental-ruleset-update
  delete element filter whitelist { 192.168.1.204 }
  add element filter whitelist { 192.168.2.20 }
  add element filter whitelist { 192.168.3.11 }
  add element filter whitelist { 192.168.4.24 }
  delete element filter whitelist { 192.168.1.120 }
  % nft -f incremental-ruleset-update

* Fix monitor mode, ie. nft monitor, when reloading relatively large rulesets.

* Fix transport matching in bridge when no context is provided, eg.

  % nft add rule bridge filter input tcp dport 22

* Parsing of time, eg. ct expiration lt 1m30s

* Missing family when listing tables, ie.

  % nft list tables
  table ip nat
  table ip filter

* Propagate error to shell on evaluation problems, eg.

 % nft add chain filter input { type filter hook inputt priority 0\; }
 <cmdline>:1:43-48: Error: unknown chain hook inputt
 add chain filter input { type filter hook inputt priority 0; }
                                           ^^^^^^
 % echo $?
 1

Resources
=========

The nftables code can be obtained from:

* http://netfilter.org/projects/nftables/downloads.html
* ftp://ftp.netfilter.org/pub/nftables
* git://git.netfilter.org/nftables

To build the code, libnftnl 1.0.5 and libmnl >= 1.0.2 are required:

* http://netfilter.org/projects/libnftnl/index.html
* http://netfilter.org/projects/libmnl/index.html

Thanks
======

Thanks to Patrick McHardy for finishing the concatenation support as
well as the set timeout and comment support; and Steven Barth for the
mini-gmp support.

Happy testing!

--SUOF0GtieIMvvwua
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-nftables-0.5.txt"

Alvaro Neira Ayuso (1):
      evaluate: clean up unused variables (pctx)

Arturo Borrero (5):
      doc: add a reference to the wiki page in the man page
      rule: delete extra space in rule indentation
      tests: regression: consider policy in base chain
      rule: fix chain details align indentations
      monitor: fix missing space after chain name

Eric Leblond (4):
      tests: regression: fix typo in README
      erec: fix buffer overflow
      erec: fix logic when reading from file
      payload: reorder case in a switch for consistency

Florian Westphal (8):
      datatype: avoid crash in debug mode when printing integers
      tests: avoid more warnings
      tests: meta: use root for uid/gid checks
      tests: validate generated netlink instructions
      tests: add two test cases using binop w. payload
      tests: use the src/nft binary instead of $PATH one
      tests: add 'awkward' prefix match expression
      src: fix build with debug off

Pablo Neira (1):
      netlink_delinearize: restore listing of host byteorder set elements

Pablo Neira Ayuso (67):
      tests: regression: named sets work
      tests: regression: revisit chain tests
      payload: assert when accessing inner transport header
      evaluate: reject: fix dependency generation from nft -f
      build: use -Wno-sign-compare to avoid compilation warning in mini-gmp.c
      src: modify pr_debug() to use printf and introduce to pr_gmp_debug()
      meta: register pkttype_type datatype
      rule: fix object order via nft -f
      main: display errors through stderr
      src: expose table flags
      src: allow to specify the default policy for base chains
      evaluate: missing break; in str2hooknum()
      netlink: fix crash when adding new non-base chain
      tests: regression: masquerade is only allowed from postrouting
      tests: regression: fix bogus warnings in any/mark.t
      src: introduce netlink_init_error()
      src: restore interface to index cache
      mnl: use new libnftnl batch API
      netlink_delinearize: pass ctx pointer to stmt_reject_postprocess()
      netlink_delinearize: keep pointer to current statement from rule_pp_ctx
      netlink_delinearize: add payload_match_expand()
      netlink_delinearize: consolidate range printing
      tests: regression: reduce code duplication a bit on error reporting
      tests: regression: fix warnings related to range listing
      tests: regression: fix NAT tests
      Merge branch 'next-4.1'
      datatype: default to display bitmask in hexadecimal
      proto: use bitmask_type for comp flags
      tests: regression: ip6: reduce warning noise
      parser_bison: allow to use mark as datatype for maps and sets
      netlink: fix use-after-free netlink_events_cache_deltable()
      src: add netdev family support
      payload: fix transport matching with no network layer info in bridge family
      rule: missing family when listing of tables
      src: set chain->hookstr from delinearization
      rule: add do_list_tables()
      netlink: release table object via table_free() in netlink_get_table()
      configure: fix --enable-debug
      main: return error to shell on evaluation problems
      netlink_delinearize: meta l4proto range printing broken on 32bit
      src: restore nft list tables
      Merge branch 'next-4.2'
      src: add cache infrastructure and use it for table objects
      src: add cmd_evaluate_list()
      rule: add reference counter to the table object
      src: add table declaration to cache
      src: use cache infrastructure for set objects
      src: add set declaration to cache
      src: early allocation of the set ID
      rule: add chain reference counter
      src: use cache infrastructure for chain objects
      evaluate: add cmd_evaluate_rename()
      src: add chain declarations to cache
      src: use cache infrastructure for rule objects
      src: use cache infrastructure for set element objects
      src: get rid of EINTR handling for nft_netlink()
      evaluate: display error on unexisting chain when listing
      netlink: don't call netlink_dump_*() from listing functions with --debug=netlink
      tests: sets: don't include listing in payload tests
      tests: redirect: fix payload display
      tests: display error when trying to run tests out of the root directory
      netlink: flush stdout after each event in monitor mode
      mnl: rework netlink socket receive path for events
      evaluate: use existing table object from evaluation context
      tests: add concatenations and maps; combine them too
      src: use new symbols in libnftnl
      Bump version to v0.5

Patrick McHardy (57):
      datatype: generate name for concat types
      datatype: add new subtypes field to account number of concat data types
      datatype: add define for maximum number of bits and mask of datatype id
      utils: add fls()
      datatype: change concat_type_alloc() to construct type from id
      parser: alloc specifying concat types in set declarations
      eval: refactor NAT evaluation functions
      evaluate: add missing datatype compat checks for statement arguments
      netlink_delinearize: fix error handling for invalid registers
      netlink: fix memory leaks
      netlink: remove unnecessary temporary variable
      netlink: style fixes
      netlink: style fixes
      netlink: readability fixes
      netlink_delinearize: rename netlink_parse_*_sreg/dreg functions
      netlink_delinearize: cleanup hard to read code
      concat: add concat subtype lookup/id helpers
      netlink_delinearize: add register parsing helper function
      netlink_linearize: add register dumping helper function
      parser: properly fix handling of large integer values
      set: remove unused set_clone() function
      expr: fix crash when listing non-verdict mappings
      meta: don't print meta keyword for unqualified meta stmts
      evaluate: verify named map is actually a map
      evaluate: properly set datatype of map expression
      evaluate: check that map expressions' datatype matches mappings
      evaluate: use stmt_evaluate_arg() in all cases
      set_elem: convert flag value to inclusive-OR binops during delinearize
      nft-test: don't use colors if output is not a tty
      netlink: fix use after free in netlink_get_table()
      netlink_delinarize: fix payload dependency killing of link layer dependencies
      parser: remove duplicated grammar for chain policy
      datatype: fix parsing of time type
      datatype: less strict time parsing
      datatype: seperate time parsing/printing from time_type
      parser: add a time_spec rule
      parser: fix inconsistencies in set expression rules
      expr: add set_elem_expr as container for set element attributes
      set: add timeout support for sets
      setelem: add timeout support for set elements
      setelem: add support for attaching comments to set elements
      nftables: add set statemet
      netlink_linearize: fix range cmp instruction generation
      ct: add maximum helper length value
      netlink_delinearize: remove obsolete fixme
      Merge remote-tracking branch 'origin/master' into next-4.1
      eval: prohibit variable sized types in concat expressions
      headers: sync headers for new register values
      netlink: pass expression to register allocation/release functions
      netlink_linearize: use NFT_REG32 values internally
      netlink_linearize: generate concat expressions
      netlink: pad constant concat sub-expressions
      netlink_delinearize: introduce register translation helper
      netlink_delinearize: handle relational and lookup concat expressions
      netlink: handle concat expressions in set data
      Merge remote-tracking branch 'origin/next-4.1'
      netlink_delinarize: fix merge conflict

Steven Barth (4):
      parser: rename VERSION token to HDRVERSION
      datatype: use mpz_set_str instead of gmp_sscanf
      erec: use stdio vasprintf instead of gmp_vasprintf
      build: add --with-mini-gmp switch to disable linking libgmp


--SUOF0GtieIMvvwua--
