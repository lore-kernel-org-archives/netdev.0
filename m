From: "Vink, Ronald" <ronald.vink@boskalis.com>
Subject: UNSUBSCIBE
Date: Mon, 9 Jan 2017 06:56:24 +0000
Message-ID: <AM3PR04MB1218498F36B828250E14F5B199640@AM3PR04MB1218.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
        "netfilter-announce@lists.netfilter.org"
        <netfilter-announce@lists.netfilter.org>
To: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Language: en-US
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



-----Original Message-----
From: netfilter-announce [mailto:netfilter-announce-bounces@lists.netfilter=
.org] On Behalf Of Pablo Neira Ayuso
Sent: dinsdag 20 december 2016 21:47
To: netfilter-devel@vger.kernel.org
Cc: lwn@lwn.net; netdev@vger.kernel.org; netfilter@vger.kernel.org; netfilt=
er-announce@lists.netfilter.org
Subject: [ANNOUNCE] nftables 0.7 release

Hi!

The Netfilter project proudly presents:

        nftables 0.7

This release contains many accumulated bug fixes and new features available=
 up to the (upcoming) Linux 4.10-rc1 kernel release.

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
        dnat to numgen inc mod 2 map { 0 : 192.168.10.100, 1 : 192.168.20.2=
00 }

  So this is distributing new connections in a round-robin fashion
  between 192.168.10.100 and 192.168.20.200. Don't forget the special NAT
  chain semantics: Only the first packet evaluates the rule, follow up
  packets rely on conntrack to apply the NAT information.

  You can also emulate flow distribution with different backend weights
  using intervals, eg.

  # nft add rule nat prerouting \
        dnat to numgen inc mod 10 map { 0-5 : 192.168.10.100, 6-9 : 192.168=
.20.200 }

* Add quota support, eg.

  # nft add rule filter input \
            flow table http { ip saddr timeout 60s quota over 50 mbytes } d=
rop

  This creates a flow table, where every flow gets a quota of 50
  mbytes. You can also from use simple rules too to enforce quotas, of
  course.

* Introduce routing expression, for routing related data with support
  for nexthop (i.e. the directly connected IP address that an outgoing
  packet is sent to), which can be used either for matching or accounting, =
eg.

     # nft add rule filter postrouting \
          ip daddr 192.168.1.0/24 rt nexthop !=3D 192.168.0.1 drop

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
    define s-ext-2-int =3D { 10.10.10.10 . 25, 10.10.10.10 . 143 }

    table inet forward {
            set s-ext-2-int {
                 type ipv4_addr . inet_service
                 elements =3D $s-ext-2-int
            }
    }
  # nft -f ruleset.nft

  Useful to improve ruleset maintainability, as you can split out
  variable and set definitions from the filtering policy itself.

* Allow to use variable definitions from element commands, eg.

     define whitelist_v4 =3D { 1.1.1.1 }

     table inet filter {
        set whitelist_v4 { type ipv4_addr; }
     }

     add element inet filter whitelist_v4 $whitelist_v4

* Add support to flush set. You can use this new command to remove all
  existing elements in a set, eg.

  # nft flush set filter xyz

  Note that this requires (upcoming) Linux kernel 4.10-rc versions.

* Inverted set lookups, eg. tcp dport !=3D { 80, 443 }.

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
=3D=3D=3D=3D=3D=3D=3D=3D

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
  ip saddr !=3D 1.1.1.1-2.2.2.2, since previously generated bytecode was
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

We also got lots more tests added to our infrastructure to catch up regress=
ions.

Syntax updates
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Several minor syntax updates, although previous syntax has been preserved b=
y now to facilitate transition, the new one is prefered:

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
=3D=3D=3D=3D=3D=3D=3D=3D=3D

The nftables code can be obtained from:

* http://netfilter.org/projects/nftables/downloads.html
* ftp://ftp.netfilter.org/pub/nftables
* git://git.netfilter.org/nftables

To build the code, libnftnl 1.0.7 and libmnl >=3D 1.0.2 are required:

* http://netfilter.org/projects/libnftnl/index.html
* http://netfilter.org/projects/libmnl/index.html

Visit our wikipage for user documentation at:

* http://wiki.nftables.org

For the manpage reference, check man(8) nft.

In case of bugs and feature request, file them via:

* https://bugzilla.netfilter.org

Make sure you create no duplicates already, thanks!

Happy holidays!
