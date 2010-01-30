From: Jon Masters <jonathan@jonmasters.org>
Subject: debug: nt_conntrack and KVM crash
Date: Fri, 29 Jan 2010 20:10:32 -0500
Message-ID: <1264813832.2793.446.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,

I've hooked up Jason's kgb/kgdb patches and been able to gather some
more information about the most recent crashes on this test system.

The last few crashes have occurred after starting an F12 guest, at which
point __nf_conntrack_find is called with the following tuple:

--- begin ---
(gdb) print tuple->src->u3
$45 = {all = {16777343, 0, 0, 0}, ip = 16777343, ip6 = {16777343, 0, 0,
0},
  in = {s_addr = 16777343}, in6 = {in6_u = {
      u6_addr8 = "\177\000\000\001", '\000' <repeats 11 times>,
u6_addr16 = {
        127, 256, 0, 0, 0, 0, 0, 0}, u6_addr32 = {16777343, 0, 0, 0}}}}

(gdb) print tuple->src->u
$46 = {all = 3607, tcp = {port = 3607}, udp = {port = 3607}, icmp = {
    id = 3607}, dccp = {port = 3607}, sctp = {port = 3607}, gre = {key =
3607}}

(gdb) print tuple->dst
$48 = {u3 = {all = {16777343, 0, 0, 0}, ip = 16777343, ip6 = {16777343,
0, 0,
      0}, in = {s_addr = 16777343}, in6 = {in6_u = {
        u6_addr8 = "\177\000\000\001", '\000' <repeats 11 times>,
u6_addr16 = {
          127, 256, 0, 0, 0, 0, 0, 0}, u6_addr32 = {16777343, 0, 0,
0}}}},
  u = {all = 12761, tcp = {port = 12761}, udp = {port = 12761}, icmp = {
      type = 217 '\331', code = 49 '1'}, dccp = {port = 12761}, sctp = {
      port = 12761}, gre = {key = 12761}}, protonum = 6 '\006', dir = 0
'\000'}
---end ---

Which (after converting from network to host addressing) is a VNC (port
5902) TCP packet being broadcast (by the guest maybe? I didn't know
Fedora started VNC by default these days, but I'll look).

After looking through the netfilter code, I understand now that it
maintains a hashtable (which size is computed at boot time according to
system memory size, and is usually kmalloced but might be vmalloced if
there is a problem - not here though). Each time a packet of interest
relating to a connection we might want to track comes in, we get a
"tuple" passed in to the conntrack functions, and this is hashed using
hash_conntrack into an entry in an array of hlists (buckets) stored in
the "ct" (conntrack) entry in the current network namespace (there is
only one on this system, I checked that). In this case, when we come to
look at the hashtable, it contains a number of valid entries (I looked)
but not for the hashed entry calculated for this VNC packet.

I would love to have advice on the best way to debug conntrack hashtable
missbehavior (there's a lot of RCU use in there), especially with
freeing entries. Is there more debug code I can turn on? Is there
anything you guys would suggest that I look at?

Jon.


