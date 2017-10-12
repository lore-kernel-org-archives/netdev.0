From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [ANNOUNCE] nftables 0.8 release
Date: Fri, 13 Oct 2017 01:49:41 +0200
Message-ID: <20171012234941.GA892@salvia>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="8t9RHnE3ZwKMSgU+"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
        netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:49015 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752804AbdJLXtr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 19:49:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi!

The Netfilter project proudly presents:

        nftables 0.8

This release contains new features available up to the (upcoming)
Linux 4.14 kernel release:

* Support for stateful objects, these objects are uniquely identified by
  a user-defined name, you can refer to them from rules, and there is a
  well established interface to operate with them, eg.

     # nft add counter filter test

  This creates a quota object whose name is 'test'.

     # nft list counters
     table ip filter {
            counter test {
                     packets 0 bytes 0
            }

  You can then refer to these objects from maps:

     # nft add table filter
     # nft add chain filter input { type filter hook input priority 0\; }
     # nft add map filter badguys { type ipv4_addr : counter \; }
     # nft add rule filter input counter name ip saddr map @badguys
     # nft add counter filter badguy1
     # nft add counter filter badguy2
     # nft add element filter badguys { 192.168.2.3 : "badguy1" }
     # nft add element filter badguys { 192.168.2.4 : "badguy2" }

  Implicit map definitions are supported too:

     table ip filter {
            counter http-traffic {
                    packets 8 bytes 672
            }

            chain input {
                    type filter hook input priority 0; policy accept;
                    counter name tcp dport map { 80 : "http-traffic", 443 : "http-traffic"}
            }
     }

  You can atomically dump and reset these objects:

     # nft reset counter ip filter badguy1
     counter test {
            packets 1024 bytes 100000
     }
     # nft reset counter ip filter badguy1
     counter test {
            packets 0 bytes 0
     }

  Currently: counters, quota and limit are supported. Note: limit is
  available starting 4.14-rc.

* Sort set elements when listing them, from lower to largest, eg.

     # nft add table x
     # nft add set x y { type ipv4_addr\; }
     # nft add element x y { 192.168.1.2, 192.168.1.1, 192.168.1.4, 192.168.1.3 }
     # nft list ruleset
     table ip x {
            set y {
                    type ipv4_addr
                    elements = { 192.168.1.1, 192.168.1.2,
                                 192.168.1.3, 192.168.1.4 }
            }
     }

  When listing very large sets, nft takes almost the same time as
  before, so impact of this new feature is negligible.

* TCP option matching and mangling support. This includes TCP maximum
  segment size mangling, eg.

    # nft add rule mangle forward tcp flags syn tcp option maxseg size set rt mtu

  People that own routers with ppp interfaces, you have no excuses to
  migrate to nftables, this is your replacement for the TCPMSS target ;-)

* Add new `-s' option for listings without stateful information:

     # nft -s list ruleset
     table ip filter {
            chain output {
                    type filter hook output priority 0; policy accept;
                    tcp dport https counter
                    tcp dport https quota 25 mbytes
            }
     }

* Add new -c/--check option for nft, to tests if your ruleset loads fine,
  into the kernel, this is a dry run mode, eg.

     # nft -c ruleset.nft

  You can also use it in incremental rule updates scenarios:

     # nft -c add rule x y counter

* Connection tracking helper support, eg.

     table ip filter {
             ct helper ftp-standard {
                    type "ftp" protocol tcp
             }

             chain y {
                    tcp dport ftp ct helper set "ftp-standard"
             }
     }

  Note for iptables users: In nftables, you have to specify what helper
  you want to enable specifically, then set it from rules, given the
  former automatic helper assignment approach is deprecated, see for
  more info: https://home.regit.org/netfilter-en/secure-use-of-helpers/

* Add --echo option, to print the handle that the kernel allocates to
  uniquely identify rules, eg.

     # nft --echo --handle add rule ip t c tcp dport {22, 80} accept
     add rule ip t c tcp dport { ssh, http } accept # handle 2

* Conntrack zone support, eg.

     table raw {
            chain pre {
                   type filter hook prerouting priority -300;
                   iif eth3 ct zone set 23
            }
            chain out {
                   type filter hook output priority -300;
                   oif eth3 ct zone set 23
            }
     }

* Symmetric hash support, eg.

     # nft add rule ip nat prerouting ct mark set symhash mod 2

* Add support to include directories from nft natives scripts, files are
  loaded in alphanumerical order, eg.

     include "/foo/*.nft"

  Assuming the following content on such folder:

        /foo
        /foo/02_rules.nft
        /foo/01_rules.nft

  "01_rules.nft" is loaded before "02_rules.nft".

* Allow to check if IPv6 extension header or TCP option exists or is
  missing, eg.

     # nft add rule ip6 x y exthdr frag exists drop
     # nft add rule inet x y tcp option window missing drop

  Same for fib lookups, eg.

     # nft add rule x y fib daddr oif exists accept

* Extend quota support to display wasted bytes, eg.

    table ip x {
            chain y {
                    type filter hook forward priority 0; policy accept;
                    quota over 200 mbytes used 1143 kbytes drop
            }
    }

  This is useful to restore quota between reboots.

* Add ct average matching, to match average bytes per packet a connection has
  transferred so far, to map the existing feature available in the
  iptables connbytes match.

   eg. match average pkt in both directions:
     # nft add rule x y ct avgpkt gt 100

   eg. match avgpkt in original direction:
     # nft add rule x y ct original avgpkt gt 200

* Allow to flush maps and flow tables, eg.

     # nft flush map filter map1
     # nft flush flow table filter ft-https

* Allow to embed set definition into an existing set, eg.

     # nft -f ruleset.nft
     define myset = {
           1.1.1.0,
           2.2.2.0,
     }
     add rule ip saddr { $myset, 3.3.3.0 }

  And scripting like now works too:

     define dnat_ports      = { 1234-1567 }
     define port_allow      = {
            53,             # dns
            $dnat_ports,    # dnat
     }

* Slightly better error reporting when ruleset loaded via nft -f, eg.

     # nft -f /home/test/x
     /home/test/x:4:17-70: Error: Could not process rule: No such file or directory
                    ip saddr { 1.1.1.1, 2.2.2.2, 3.3.3.3, 4.4.4.4 } jump x
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

  In the example above, the chain 'x' that this jump refers to does not exist.
  We can still do better and make it even more fine grain...

* Don't wraparound set elements when listing, eg.

    % nft list ruleset -nnn
    table ip t {
            set s {
                    type inet_service
                    elements = { 1, 2, 3, 4, 10,
                                 432, 433, 434, 435, 436,
                                 437, 438, 439, 440, 441,
                                 442, 443, 444, 445, 446,
                                 447, 448, 449, 450, 12345 }
            }
    }

  Current approach is rather simple, improvable since the number of
  elements to fit in is not calculated based of the number of terminal
  columns, but we can make it at some point.

* Allow to list sets in a table, eg.

     # nft list sets table inet filter

* Conntrack event filtering support via rule, eg.

     # nft add rule x y ct event new counter

... lots of bugfixes too:

* Fix wrong bytecode generation for IPv6 that may result in mismatching
  packets due to extensions placed before the transport header.
* Always print range expressions numerically. This has been a problem
  with network services, where character '-' is possible as part of the
  name.
* Replace getaddrinfo() by inet_service internal lookup table, we don't
  rely on /etc/services anymore, so we have a predictable input from the
  parser side.
* Do not round consumed quota bytes when listing then.
* Fix print of ip dnat address.
* Fix icmp matching in inet tables.
* Fix display of set keys with host byte endian byteorder.
* Fix nested set merge size adjustment, eg.

     # nft add rule ip saddr { { 1.1.1.0/24, 3.3.3.0/24 }, 2.2.2.0/24 }

* Fix missing seed option in hash expression in listings.
* Generate a random seed in hash expression if seed option is empty, eg.

     # nft add rule x y ct mark set jhash ip saddr mod 2

  generates a random seed internally, that is not displayed. If you want
  an explicit seed, you have to specify it.
* Allow to match ICMPv6 packets from IPv4, this is a firewall software so
  we should allow to match even things that don't make sense.
* Fix printing of range elements in named sets in monitor mode.
* Fix printing of optional attributes 'flags', 'gc-interval' and
  'timeout' in set declarations.
* Fix parsing of IPv4-Mapped IPv6 addresses.
* Fix lots of memory leaks.

... and lots of documentation updates! and regression tests!

Resources
=========

The nftables code can be obtained from:

* http://netfilter.org/projects/nftables/downloads.html
* ftp://ftp.netfilter.org/pub/nftables
* git://git.netfilter.org/nftables

To build the code, libnftnl 1.0.8 and libmnl >= 1.0.2 are required:

* http://netfilter.org/projects/libnftnl/index.html
* http://netfilter.org/projects/libmnl/index.html

Visit our wikipage for user documentation at:

* http://wiki.nftables.org

For the manpage reference, check man(8) nft.

In case of bugs and feature request, file them via:

* https://bugzilla.netfilter.org

Make sure you create no duplicates already, thanks!

Happy firewalling!

--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="changes-nftables-0.8.txt"

Anatole Denis (2):
      scanner: fix search_in_include_path test
      erec: Fix input descriptors for included files

Anders K. Pedersen (1):
      netlink_linearize: skip set element expression in set statement key

Arturo Borrero Gonzalez (5):
      payload: explicit network ctx assignment for icmp/icmp6 in special families
      expression: print sets and maps in pretty format
      evaluate: avoid reference to multiple src data in statements which set values
      monitor: add debug messages
      monitor: Fix printing of range elements in named sets

Bertrand Bonnefoy-Claudet (1):
      doc: Fix typo in manpage

Daniel Kahn Gillmor (1):
      man: use https for wiki link

Duncan Roe (3):
      datatype: printf format warnings on 32-bit build
      doc: nft.8 add chain synopsis
      doc: nft.8 Document rule replace

Elise Lennion (27):
      src: sort set elements in netlink_get_setelems()
      tests: shell: add maps tests
      src: Allow to list ruleset without stateful information
      doc: Include stateless option
      tests: py: Use stateless option on tests
      tests: shell: Add test for set element leak bug
      src: Honor obligatory stateless printing of flow tables
      tests: shell: Add test for flush bug on sets with size
      src: Allow reset single stateful object
      src: Allow list single stateful object
      evaluate: Evaluate table name before reset stateful objects in a table
      src: Allow list stateful objects in a table
      tests: py: Add suport for stateful objects in python tests
      tests: py: Add tests for stateful objects
      main: Validate the number of numeric options
      src: Always print range expressions numerically
      configure: Require newer version of libxtables
      datatype: Replace getaddrinfo() by internal lookup table
      doc: Document stateful objects
      doc: Document sets
      statement: Avoid rounding bytes in get_rate()
      doc: Document maps
      parser_bison: Allow flushing flow tables
      parser_bison: Allow flushing maps
      doc: Document add / delete element operations of sets and maps
      src: Make flush command selective of the set structure type
      tests: Add test for flush command selectiveness on sets

Eric Leblond (12):
      src: fix memory leak when listing rules
      parser: fix memory leak in set creation
      parser: fix bison warnings
      parser: error if needed at EOF
      evaluate: fix build with clang
      scanner: free filename when destroying scanner
      cli: fix heap buffer overflow
      mnl: fix error handling in mnl_batch_talk
      src: add nft_ctx_new() and nft_ctx_free()
      src: add nft_run_cmd_*() functions
      src: release caches from nft_ctx_free() path
      src: add flags fo nft_ctx_new

Florian Westphal (75):
      parser_bison: remove obsolete tokens
      evaluate: fix export length and data corruption
      statement: fix print of ip dnat address
      payload: insert implicit meta tcp dependency when matching tcp options
      src: add conntrack zone support
      ct: refactor print function so it can be re-used for ct statement
      src: support zone set statement with optional direction
      tests: add test entries for conntrack zones
      netlink: BUG when object type is unknown
      doc: ct zone set support
      files: provide 'raw' table equivalent
      doc: fix ct mark set example
      src: add initial ct helper support
      evaluate: refactor CMD_OBJ_QUOTA/COUNTER handling
      src: allow listing all ct helpers
      src: implement add/create/delete for ct helper objects
      tests: py: add ct helper tests
      tests: add insert-failure test
      doc: ct helper objects and helper set support
      exthdr: avoid crash with older kernels
      src: fix build warning on i686
      ct: add conntrack event mask support
      parser: allow listing sets in one table
      netlink_delinearize: don't kill dependencies accross statements
      tests: don't kill dependencies accross statements
      netlink_delink_delinearize: don't store dependency unless relop checks is eq check
      src: add a comment wrt. reject dependency insertion
      netlink_delinearize: reject: remove dependency for tcp-resets
      tests: add ip reject with tcp and check for mark too
      payload: split ll proto dependency into helper
      src: allow update of net base w. meta l4proto icmpv6
      src: ipv6: switch implicit dependencies to meta l4proto
      payload: enforce ip/ip6 protocol depending on icmp or icmpv6
      tests: fix up meta l4proto change for ip6 family
      src: ip: switch implicit dependencies to meta l4proto too
      tests: fix up meta l4proto change for ip family
      Merge branch 'meta_l4_dependency'
      ct: fix inet/bridge/netdev family handling for saddr/daddr
      meta: permit meta nfproto ip in ip family
      parser: allow ct eventmask set new,related
      netlink_delinearize: prefer ct event set foo,bar over 'set foo|bar'
      src: rename ct eventmask to event
      tests: restrict ct saddr test to inet family
      tests: remove two non-sensical rules
      tests: restrict meta nfproto test cases to inet family
      evaluate: reject meta nfproto outside of inet family
      tcpopt: make tcptopt structs static
      exhtdr: pacify compiler warning
      parser: compact list of rhs keyword expressions
      rename struct ct to ct_helper
      tests: fix arp chain test
      evaluate: shift immediate value when adjusting size for csum fixup
      tests: add test case for ttl/protocol set
      src: add tcp options set support
      rt: add path mtu support
      tests: add tcp option set support / tcp mss mangling test cases
      files: add arp filter and add in/output to nat skeleton
      evaluate: convert expr_rt byteorder when evaluating statment arg
      evaluate: prepare to store expr key rather than datatype
      src: store expression as set key instead of data type
      src: ct: remove unused functions
      src: prepare for future ct timeout policy support
      src: parser_bison: rename ct_block to ct_helper_block
      bison: permit keywords in list_stmt_expressions
      src: add alternate syntax for ct saddr
      src: ct: store proto base of ct key, if any
      src: ct: add eval part to inject dependencies for ct saddr/daddr
      src: unifiy meta and ct postprocessing
      tests: update inet/bridge icmp test case
      src: ct: print nfproto name for some header fields
      tests: ct: adjust test case commands
      src: rt: add keyword distinction for nexthop vs nexthop6
      tests: rt: fix test cases
      doc: update man page
      Merge branch 'ct_rt_syntax_06'

Harsha Sharma (5):
      INSTALL: Update dependency list and configure with libxtables support
      test: shell: execute shell/run-tests.sh from any directory
      tests: shell: add testcases for named objects
      test: shell: update shell/run-tests.sh to refer to relative path of testcase
      nftables: make pointers in string arrays constant

Ismo Puustinen (8):
      scanner: add support for include directories
      tests: test include directories
      scanner: add files in include dirs in alphabetical order.
      man: add include directory documentation.
      tests: added tests for ordering files in include dirs.
      scanner: support for wildcards in include statements.
      tests: update include directory tests to support wildcard syntax.
      man: add include statement documentation.

JingPiao Chen (1):
      include: remove outdated comment

Laura Garcia Liebana (2):
      src: hash: support of symmetric hash
      src: hash: fix seed attribute not listed

Liping Zhang (4):
      ct: add average bytes per packet counter support
      src: fix crash when inputting an incomplete set add command
      hash: generate a random seed if seed option is empty
      src: delete the old cache when dumping is interrupted

Manuel Messner (7):
      evaluate: fix typo
      include: linux: netfilter: nf_tables: copy file from nf-next
      exthdr: prepare for tcp support
      exthdr: prepare exthdr_gen_dependency for tcp support
      src: add TCP option matching
      payload: automatically kill dependencies for exthdr and tcpopt
      tests: py: Add basic tests for ip, ip6 and inet

Oleksandr Natalenko (2):
      utils: provide array allocation wrapper
      segtree: allocate memory for arrays on heap

Pablo M. Bermudo Garay (5):
      src: add new generic context structure nft_ctx
      src: add --check option flag
      parser: fix typo
      src: add stateful object support for limit
      tests: py: add tests for limit stateful object

Pablo Neira Ayuso (65):
      include: fetch nf_tables.h updates
      src: remove SET_F_* flag definitions
      src: add used quota support
      src: listing of stateful objects
      src: add/create/delete stateful objects
      src: reset internal stateful objects
      parser_bison: allow RESET token from rhs
      src: add stateful object reference expression
      src: add support for stateful object maps
      src: support for stateful object monitoring
      mnl: use nftnl_nlmsg_build_hdr()
      tests: shell: cover cache flush on flush ruleset
      netlink: don't bail out on dump errors
      rule: check for errors from cache_init_objects() for stateful objects
      tests: shell: validate set size
      include: refresh linux/netfilter/nf_tables.h
      tests: shell: remove nft_set_bitmap on each run
      include: add tcpopt.h to Makefile.am
      evaluate: store byteorder for set keys
      netlink: store set byteorder in NFTA_SET_USERDATA
      netlink_delinearize: remove integer_type_postprocess()
      tests: py: fix incorrect bytecode in numgen and hash mappings
      datatype: add DTYPE_F_CLONE flag
      evaluate: set byteorder as lhs expression context in stmt_evaluate_arg()
      src: rename set_keytype_alloc() to set_datatype_alloc()
      netlink: rework NFTNL_SET_USERDATA to accomodate new attributes
      src: store byteorder for set data
      src: revisit tcp options support
      netlink: use nftnl_udata_put_u32()/nftnl_udata_get_u32()
      tests: shell: test comments with small sets
      doc: revisit fib examples
      tests: shell: delete element and chain in transaction
      rule: adjust set expression size accordingly with intervals
      segtree: reset element size counter before adding intervals to set
      netlink: add size description for constant sets
      tests: py: flush stdout on each test run
      expression: don't trim off unary expression on delinearization
      src: remove global nftnl_batch structure in mnl layer
      doc: nft: describe -I override behaviour when path starts by ./ and /
      src: display default directory for file inclusion in -h/--help
      src: error reporting for nested ruleset representation
      evaluate: merge nested set flags
      evaluate: Better error reporting for bad set references
      include: Pass nf_sock where needed as parameter
      src: handle rule tracing as an monitor object
      src: make netlink sequence number non-static
      rule: remove sequence number from struct eval_ctx
      src: add include_paths to struct nft_ctx
      src: add maximum number of parser errors to struct nft_ctx
      src: remove ifdef DEBUG pollution
      src: add struct mnl_ctx
      mnl: pass struct netlink_ctx to mnl_nft_socket_sendmsg()
      src: add debugging mask to context structure
      src: call nft_init() and nft_exit() from context routines
      src: move nf_sock into nft_ctx structure
      netlink: remove nfsock_open()
      src: add nft_ctx_netlink_init()
      mnl: do not set NLM_F_CREATE in deletion requests
      parser_bison: consolidate stmt_expr rule
      parser_bison: use keywords in ct expression
      parser_bison: allow helper keyword in ct object kind
      mnl: fix broken sequence number allocation
      parser_bison: allow to used named limit from dictionaries too
      scanner: IPv4-Mapped IPv6 addresses support
      configure: Bump version to v0.8

Phil Sutter (56):
      Introduce boolean datatype and boolean expression
      exthdr: Add support for exthdr specific flags
      exthdr: Implement existence check
      fib: Support existence check
      tests: Adjust for changed exthdr debug output
      doc: Document boolean type and applications
      proto: Add some exotic ICMPv6 types
      doc: Describe ICMP(v6) expression and types
      evaluate: set: Allow for set elems to be sets
      evaluate: set: Fix nested set merge size adjustment
      tests: Add test cases for nested anonymous sets
      tests: shell: netns/0003many_0: Fix cleanup after error
      sets: Fix for missing space after last element
      nft.8: Enhance NAT documentation
      segtree: Fix expr_value_cmp()
      src: Allow passing the parent set to set_expr_alloc()
      segtree: Introduce flag for half-open range elements
      tests: Add basic monitor testing framework
      monitor: Print NEWGEN events
      tests/monitor: Ignore newgen messages in output
      tests/monitor: Add a small README
      monitor: Fix printing of set declarations
      tests/monitor: Simplify testcases
      tests/monitor: Clear ruleset after testing
      mnl: Consolidate mnl_batch_talk() parameters
      netlink: Pass nlmsg flags from rule.c
      Implement --echo option
      tests: Add a simple test suite for --echo option
      nft.8: Document operations on ruleset
      nft.8: Describe conntrack types
      nft.8: Review reject statement description
      nft.8: Add note about supported hooks for bridge family
      nft.8: Describe base chain details
      nft.8: Complete short description of arp family
      mnl: Drop --echo support for non-batch calls
      netlink: Fix segfault when using --echo flag
      tests: Merge monitor and echo test suites
      echo: Fix for added delays in rule updates
      src: Keep cache in struct nft_ctx
      src: Fix debug_proto_ctx()
      scanner: Fix for memleak due to unclosed file pointer
      scanner: Fix for wrong parameter type of scanner_destroy()
      scanner: Make use of yylex_init_extra()
      parser: Fix for memleak when commands fail
      parser: Fix memleaks for STRING token (and derived ones)
      doc: nft: Fix and enhance synopsis section
      main: Fix for return of uninitialized variable in nft_run_cmd_from_filename()
      monitor: Fix for incorrect debug_mask
      rule: Use C99-style initializer in cache_init()
      exthdr: Simplify tcp option printing a bit
      erec_print: Pass output FILE pointer to netlink_dump_expr()
      rule: Refactor chain_print_declaration()
      src: get rid of printf
      main: Flush output from nft_gmp_print()
      main: Drop stdout hack to expose nft_print() implementation issues
      evaluate: Fix debug output

Shyam Saini (4):
      tests: py: Add test for ambiguity while setting the value
      tests: shell: Add test for incomplete set add set command
      tests: shell: Test input descriptors for included files
      tests: py: Fail test forcefully when bug is not fixed

Timothy Redaelli (1):
      tests: py: fix some typos in README

Tobias Klauser (1):
      build: add missing backslash to list of CFLAGS

Varsha Rao (18):
      src: Remove expire information from list stateless ruleset.
      src: Pass stateless, numeric, ip2name and handle variables as structure members.
      include: Remove datatype_register().
      src: Remove __init and __exit macro definitions.
      src: netlink: Remove variable nf_mon_sock.
      src: nft monitor ruleset
      man: Document nft monitor ruleset.
      src: netlink: Subscribe nft monitor and nft monitor trace to respective groups.
      src: introduce struct nft_cache
      man: Fix typo.
      src: Remove xt_stmt_() functions.
      src: gmputil: Remove mpz_get_be64() function.
      src: cli: Remove cli_display() function.
      src: netlink: Remove unused functions.
      src: mnl: Remove unused functions.
      src: Initialize struct stmt in _match and _target functions.
      tests: shell: Add tests for chain rename.
      tests: files: Remove old tests for chain rename.


--8t9RHnE3ZwKMSgU+--
