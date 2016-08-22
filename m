From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [ovs-dev] [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Mon, 22 Aug 2016 13:04:45 +0200
Message-ID: <20160822110444.GA29971@penelope.isobedori.kobe.vergenet.net>
References: <20160713073152.GC29661@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
 <20160718045025.GA2490@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_C3Hq-V4uPWLELSc2VMywjYSnKiFJ4VJQDnPpCu7s1Xkw@mail.gmail.com>
 <20160720000243.GA4688@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_CUPCfAPKfoco9GghiAZ=QyEqxpd90uo3NvEtG9STXMVA@mail.gmail.com>
 <20160808151716.GA8477@penelope.isobedori.kobe.vergenet.net>
 <CAOrHB_BYtGsWPSs2pxTjPajqFEP=5YySmqjc93NbdtY96-dYfw@mail.gmail.com>
 <20160810102043.GE5451@penelope.isobedori.kobe.vergenet.net>
 <CAPWQB7F4bSMUhzoCJhEk5bP7V_yOTvBQwDmzCXb6Jpa72ov76g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pravin shelar <pshelar@ovn.org>, ovs dev <dev@openvswitch.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36922 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751294AbcHVLEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:04:50 -0400
Received: by mail-wm0-f51.google.com with SMTP id i5so137719324wmg.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 04:04:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAPWQB7F4bSMUhzoCJhEk5bP7V_yOTvBQwDmzCXb6Jpa72ov76g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 10:17:30AM -0700, Joe Stringer wrote:
> On 10 August 2016 at 03:20, Simon Horman <simon.horman@netronome.com> wrote:
> > On Tue, Aug 09, 2016 at 08:47:40AM -0700, pravin shelar wrote:
> >> On Mon, Aug 8, 2016 at 8:17 AM, Simon Horman <simon.horman@netronome.com> wrote:
> >> > Light testing seems to indicate that it works for GSO skbs
> >> > received over both L3 and L2 GRE tunnels by OvS with both
> >> > IP-in-MPLS and IP (without MPLS) payloads.
> >> >
> >>
> >> Thanks for testing it. Can you also add those tests to OVS kmod test suite?
> >> ..
> >
> > Sure, I will look into doing that.
> > Am I correct in thinking Joe Stringer is the best person to contact if
> > I run into trouble there?
> 
> Sure. The basics of running the tests is documented here:
> https://github.com/openvswitch/ovs/blob/master/INSTALL.md#datapath-testing
> 
> You should be able to get a good feel for how to add tests by perusing
> the commits to tests/system-{traffic,kmod-macros}.at in the OVS source
> tree.

Thanks Joe,

it took me a while but I think that I have something working
against the head branch of the OVS tree. I'd value opinions
on the direction I have taken.

Subject: [PATCH] system-traffic: Exercise GSO

Exercise GSO for: unencapsulated; MPLS; GRE; and MPLS in GRE.

There is scope to extend this testing to other encapsulation formats
if desired.

This is motivated by a desire to test GRE and MPLS encapsulation in
the context of L3/VPN (MPLS over non-TEB GRE work). That is not
tested here but tests for those cases would ideally be based on those in
this patch.

---
 tests/system-common-macros.at |  36 +++++--
 tests/system-kmod-macros.at   |  22 +++++
 tests/system-traffic.at       | 225 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 274 insertions(+), 9 deletions(-)

diff --git a/tests/system-common-macros.at b/tests/system-common-macros.at
index 4ffc3822a4d3..a201cf8ce100 100644
--- a/tests/system-common-macros.at
+++ b/tests/system-common-macros.at
@@ -56,7 +56,7 @@ m4_define([ADD_INT],
     ]
 )
 
-# ADD_VETH([port], [namespace], [ovs-br], [ip_addr] [mac_addr [gateway]])
+# ADD_VETH([port], [namespace], [ovs-br], [ip_addr] [mac_addr [gateway [ofport]]])
 #
 # Add a pair of veth ports. 'port' will be added to name space 'namespace',
 # and "ovs-'port'" will be added to ovs bridge 'ovs-br'.
@@ -64,8 +64,8 @@ m4_define([ADD_INT],
 # The 'port' in 'namespace' will be brought up with static IP address
 # with 'ip_addr' in CIDR notation.
 #
-# Optionally, one can specify the 'mac_addr' for 'port' and the default
-# 'gateway'.
+# Optionally, one can specify the 'mac_addr' for 'port', the default
+# 'gateway' and the 'ofport' number.
 #
 # The existing 'port' or 'ovs-port' will be removed before new ones are added.
 #
@@ -74,8 +74,14 @@ m4_define([ADD_VETH],
       CONFIGURE_VETH_OFFLOADS([$1])
       AT_CHECK([ip link set $1 netns $2])
       AT_CHECK([ip link set dev ovs-$1 up])
-      AT_CHECK([ovs-vsctl add-port $3 ovs-$1 -- \
-                set interface ovs-$1 external-ids:iface-id="$1"])
+      if test -n "$7"; then
+        AT_CHECK([ovs-vsctl add-port $3 ovs-$1 -- \
+                  set interface ovs-$1 external-ids:iface-id="$1" \
+                  ofport_request=$7])
+      else
+        AT_CHECK([ovs-vsctl add-port $3 ovs-$1 -- \
+                  set interface ovs-$1 external-ids:iface-id="$1"])
+      fi
       NS_CHECK_EXEC([$2], [ip addr add $4 dev $1])
       NS_CHECK_EXEC([$2], [ip link set dev $1 up])
       if test -n "$5"; then
@@ -99,7 +105,7 @@ m4_define([ADD_VLAN],
     ]
 )
 
-# ADD_OVS_TUNNEL([type], [bridge], [port], [remote-addr], [overlay-addr])
+# ADD_OVS_TUNNEL([type], [bridge], [port], [remote-addr], [overlay-addr [ofport]])
 #
 # Add an ovs-based tunnel device in the root namespace, with name 'port' and
 # type 'type'. The tunnel device will be configured as point-to-point with the
@@ -107,9 +113,17 @@ m4_define([ADD_VLAN],
 #
 # 'port will be configured with the address 'overlay-addr'.
 #
+# Optionally one can specify the 'ofport' number
+#
 m4_define([ADD_OVS_TUNNEL],
-   [AT_CHECK([ovs-vsctl add-port $2 $3 -- \
-              set int $3 type=$1 options:remote_ip=$4])
+   [if test -n "$6"; then
+      AT_CHECK([ovs-vsctl add-port $2 $3 -- \
+                set int $3 type=$1 options:remote_ip=$4 \
+		ofport_request=$6])
+    else
+      AT_CHECK([ovs-vsctl add-port $2 $3 -- \
+                set int $3 type=$1 options:remote_ip=$4])
+    fi
     AT_CHECK([ip addr add dev $2 $5])
     AT_CHECK([ip link set dev $2 up])
     AT_CHECK([ip link set dev $2 mtu 1450])
@@ -143,6 +157,12 @@ m4_define([ADD_NATIVE_TUNNEL],
 #
 m4_define([FORMAT_PING], [grep "transmitted" | sed 's/time.*ms$/time 0ms/'])
 
+# FORMAT_DD([])
+#
+# Strip variant pieces from dd output so the output can be reliably compared.
+#
+m4_define([FORMAT_DD], [sed 's/copied,.*$/copied, .../'])
+
 # FORMAT_CT([ip-addr])
 #
 # Strip content from the piped input which would differ from test to test
diff --git a/tests/system-kmod-macros.at b/tests/system-kmod-macros.at
index e1b5707925a5..c71186630e99 100644
--- a/tests/system-kmod-macros.at
+++ b/tests/system-kmod-macros.at
@@ -95,3 +95,25 @@ m4_define([CHECK_CONNTRACK_LOCAL_STACK])
 # always supports NAT, so no check is needed.
 #
 m4_define([CHECK_CONNTRACK_NAT])
+
+# CHECK_MPLS()
+#
+# Perform requirements checks for running MPLS tests.
+#
+m4_define([CHECK_MPLS],
+    [AT_SKIP_IF([test $HAVE_PYTHON = no])
+     m4_foreach([mod], [[mpls_router]],
+                [modprobe mod || echo "Module mod not loaded."
+                 on_exit 'modprobe -r mod'
+                ])
+     # Requires Linux v4.7+ and ip route v4.7+
+     AT_CHECK([# Prepare
+               echo 101 > /proc/sys/net/mpls/platform_labels || exit 77 # skip
+               ip -f mpls route del 100
+               # Test
+               ip -f mpls route add 100 dev lo && \
+               # Cleanup \
+               ip -f mpls route del 100 && \
+               echo 0 > /proc/sys/net/mpls/platform_labels || exit 77 #skip])
+    ]
+)
diff --git a/tests/system-traffic.at b/tests/system-traffic.at
index 2f42efaeacbc..f14a9ff47a5b 100644
--- a/tests/system-traffic.at
+++ b/tests/system-traffic.at
@@ -33,12 +33,27 @@ ADD_NAMESPACES(at_ns0, at_ns1)
 ADD_VETH(p0, at_ns0, br0, "10.1.1.1/24")
 ADD_VETH(p1, at_ns1, br0, "10.1.1.2/24")
 
+dnl Disable TSO as to exercise software segmentation
+dnl when outputting GSO skbs over GRE from OvS
+AT_CHECK([ethtool -K ovs-p0 tso off])
+
 NS_CHECK_EXEC([at_ns0], [ping -q -c 3 -i 0.3 -w 2 10.1.1.2 | FORMAT_PING], [0], [dnl
 3 packets transmitted, 3 received, 0% packet loss, time 0ms
 ])
 
+AT_CHECK([yes | dd bs=1k count=32 of=32k.txt], [0], [], stderr)
+AT_CHECK([cat stderr | FORMAT_DD], [0], [dnl
+32+0 records in
+32+0 records out
+32768 bytes (33 kB) copied, ...
+])
 NETNS_DAEMONIZE([at_ns1], [[$PYTHON $srcdir/test-l7.py]], [http0.pid])
-NS_CHECK_EXEC([at_ns0], [wget 10.1.1.2 -t 3 -T 1 --retry-connrefused -v -o wget0.log])
+NS_CHECK_EXEC([at_ns0], [wget 10.1.1.2/32k.txt -t 3 -T 1 --retry-connrefused -v -o wget0.log])
+
+dnl Use the absence of retransmitted segments as a proxy for functioning TSO
+NS_CHECK_EXEC([at_ns1], [netstat -s | grep retransmited], [0], [dnl
+    0 segments retransmited
+])
 
 OVS_TRAFFIC_VSWITCHD_STOP
 AT_CLEANUP
@@ -69,6 +84,69 @@ NS_CHECK_EXEC([at_ns0], [ping -s 3200 -q -c 3 -i 0.3 -w 2 10.2.2.2 | FORMAT_PING
 OVS_TRAFFIC_VSWITCHD_STOP
 AT_CLEANUP
 
+AT_SETUP([datapath - http over mpls between two ports])
+CHECK_MPLS()
+OVS_TRAFFIC_VSWITCHD_START()
+
+ADD_NAMESPACES(at_ns0, at_ns1)
+
+dnl Set up underlay
+ADD_VETH(p0, at_ns0, br0, "172.31.1.1/24", [], [], 2)
+ADD_VETH(p1, at_ns1, br0, "172.31.1.2/24", [], [], 3)
+
+dnl Set up MPLS overlay
+dnl IP is encapsulated in MPLS when sent from and recieved from ns0
+dnl OvS, sitting between ns0 and ns1 pushes MPLS onto IP recieved from ns1
+dnl befor sending to ns0, and pops MPLS recieved from ns0 and sends the
+dnl resulting IP packets to ns1
+NS_CHECK_EXEC([at_ns1], [ip addr add 10.1.1.2/24 dev p1])
+
+dnl push MPLS LSE on packets from p1 (ns1) to p0 (ns0)
+AT_CHECK([ovs-ofctl add-flow br0 "in_port=3,ip,nw_src=10.1.1.2,actions=push_mpls:0x8847,set_field:101->mpls_label,output:2"])
+
+dnl pop MPLS LSE from packets from p0 (ns0) to p1 (ns1)
+AT_CHECK([ovs-ofctl add-flow br0 "in_port=2,dl_type=0x8847,mpls_label=100,actions=pop_mpls:0x0800,output:3"])
+
+dnl Default to normal rule
+AT_CHECK([ovs-ofctl add-flow br0 "actions=normal"])
+
+dnl Allow MPLS forwarding of packets received on p0 in ns0
+NS_CHECK_EXEC([at_ns0], [echo 1 > /proc/sys/net/mpls/conf/p0/input])
+dnl Larger than MPLS label to be routed by ns0 (101)
+NS_CHECK_EXEC([at_ns0], [echo 102 > /proc/sys/net/mpls/platform_labels])
+
+dnl Set up route to encapsulate 10.1.1.0/24 packets in MPLS
+NS_CHECK_EXEC([at_ns0], [ip route add 10.1.1.0/24 encap mpls 100 via inet 172.31.1.2 dev p0])
+
+dnl Set up route to decapsulate MPLS label 101 and deliver locally
+NS_CHECK_EXEC([at_ns0], [ip -f mpls route add 101 dev lo])
+
+dnl Set loopback interface up for local delivery
+NS_CHECK_EXEC([at_ns0], [ip link set up dev lo])
+
+dnl Test ping
+NS_CHECK_EXEC([at_ns0], [ping -q -c 3 -i 0.3 -w 2 10.1.1.2 | FORMAT_PING], [0], [dnl
+3 packets transmitted, 3 received, 0% packet loss, time 0ms
+])
+
+dnl Test http
+AT_CHECK([yes | dd bs=1k count=32 of=32k.txt], [0], [], stderr)
+AT_CHECK([cat stderr | FORMAT_DD], [0], [dnl
+32+0 records in
+32+0 records out
+32768 bytes (33 kB) copied, ...
+])
+NETNS_DAEMONIZE([at_ns1], [[$PYTHON $srcdir/test-l7.py]], [http0.pid])
+NS_CHECK_EXEC([at_ns0], [wget 10.1.1.2/32k.txt -t 3 -T 1 --retry-connrefused -v -o wget0.log])
+
+dnl Use the absence of retransmitted segments as a proxy for functioning GSO
+NS_CHECK_EXEC([at_ns1], [netstat -s | grep retransmited], [0], [dnl
+    0 segments retransmited
+])
+
+OVS_TRAFFIC_VSWITCHD_STOP
+AT_CLEANUP
+
 AT_SETUP([datapath - ping6 between two ports])
 OVS_TRAFFIC_VSWITCHD_START()
 
@@ -206,6 +284,151 @@ NS_CHECK_EXEC([at_ns0], [ping -s 3200 -q -c 3 -i 0.3 -w 2 10.1.1.100 | FORMAT_PI
 3 packets transmitted, 3 received, 0% packet loss, time 0ms
 ])
 
+AT_CHECK([yes | dd bs=1k count=32 of=32k.txt], [0], [], stderr)
+AT_CHECK([cat stderr | FORMAT_DD], [0], [dnl
+32+0 records in
+32+0 records out
+32768 bytes (33 kB) copied, ...
+])
+NETNS_DAEMONIZE([at_ns1], [[$PYTHON $srcdir/test-l7.py]], [http0.pid])
+NS_CHECK_EXEC([at_ns0], [wget 10.1.1.2/32k.txt -t 3 -T 1 --retry-connrefused -v -o wget0.log])
+
+OVS_TRAFFIC_VSWITCHD_STOP
+AT_CLEANUP
+
+AT_SETUP([datapath - http over gre tunnel])
+OVS_CHECK_GRE()
+
+OVS_TRAFFIC_VSWITCHD_START()
+ADD_BR([br-underlay])
+
+AT_CHECK([ovs-ofctl add-flow br0 "actions=normal"])
+AT_CHECK([ovs-ofctl add-flow br-underlay "actions=normal"])
+
+ADD_NAMESPACES(at_ns0, at_ns1)
+
+dnl Set up underlay link from host into the at_ns0 namespace using veth pair.
+ADD_VETH(p0, at_ns0, br-underlay, "172.31.1.1/24")
+AT_CHECK([ip addr add dev br-underlay "172.31.1.100/24"])
+AT_CHECK([ip link set dev br-underlay up])
+
+dnl Set up tunnel endpoints on OVS outside the at_ns0 namespace and
+dnl with a native linux device inside the namespace.
+ADD_OVS_TUNNEL([gre], [br0], [at_gre0], [172.31.1.1], [10.1.1.100/24])
+ADD_NATIVE_TUNNEL([gretap], [ns_gre0], [at_ns0], [172.31.1.100], [10.1.1.1/24])
+
+dnl Add veth pair connected to to br0 and at_ns1 namespace
+ADD_VETH(p1, at_ns1, br0, "10.1.1.2/24")
+
+dnl Disable TSO as to exercise software segmentation
+dnl when outputting GSO skbs over GRE from OvS
+AT_CHECK([ethtool -K ovs-p0 tso off])
+
+dnl First check the underlay
+NS_CHECK_EXEC([at_ns0], [ping -q -c 3 -i 0.3 -w 2 172.31.1.100 | FORMAT_PING], [0], [dnl
+3 packets transmitted, 3 received, 0% packet loss, time 0ms
+])
+
+dnl Next check the overlay
+NS_CHECK_EXEC([at_ns0], [ping -q -c 3 -i 0.3 -w 2 10.1.1.2  | FORMAT_PING], [0], [dnl
+3 packets transmitted, 3 received, 0% packet loss, time 0ms
+])
+
+dnl Now check HTTP transfer
+AT_CHECK([yes | dd bs=1k count=32 of=32k.txt], [0], [], stderr)
+AT_CHECK([cat stderr | FORMAT_DD], [0], [dnl
+32+0 records in
+32+0 records out
+32768 bytes (33 kB) copied, ...
+])
+NETNS_DAEMONIZE([at_ns1], [[$PYTHON $srcdir/test-l7.py]], [http0.pid])
+NS_CHECK_EXEC([at_ns0], [wget 10.1.1.2/32k.txt -t 3 -T 1 --retry-connrefused -v -o wget0.log])
+
+dnl Use the absence of retransmitted segments as a proxy for functioning TSO
+NS_CHECK_EXEC([at_ns1], [netstat -s | grep retransmited], [0], [dnl
+    0 segments retransmited
+])
+
+OVS_TRAFFIC_VSWITCHD_STOP
+AT_CLEANUP
+
+AT_SETUP([datapath - http over mpls over gre tunnel])
+OVS_CHECK_GRE()
+OVS_CHECK_MPLS()
+
+OVS_TRAFFIC_VSWITCHD_START()
+ADD_BR([br-underlay])
+
+ADD_NAMESPACES(at_ns0, at_ns1)
+
+dnl Set up underlay link from host into the at_ns0 namespace using veth pair.
+ADD_VETH(p0, at_ns0, br-underlay, "172.31.1.1/24")
+AT_CHECK([ip addr add dev br-underlay "172.31.1.100/24"])
+AT_CHECK([ip link set dev br-underlay up])
+
+dnl Set up tunnel endpoints on OVS outside the at_ns0 namespace and
+dnl with a native linux device inside the namespace.
+ADD_OVS_TUNNEL([gre], [br0], [at_gre0], [172.31.1.1], [10.1.1.100/24], 2)
+ADD_NATIVE_TUNNEL([gretap], [ns_gre0], [at_ns0], [172.31.1.100], [10.1.1.1/24])
+
+dnl Add veth pair connected to to br0 and at_ns1 namespace
+ADD_VETH(p1, at_ns1, br0, "10.1.1.2/24", [], [], 3)
+
+dnl Set up MPLS overlay
+dnl IP is encapsulated in MPLS when sent from and recieved from ns0
+dnl OvS, sitting between ns0 and ns1 pushes MPLS onto IP recieved from ns1
+dnl befor sending to ns0, and pops MPLS recieved from ns0 and sends the
+dnl resulting IP packets to ns1
+NS_CHECK_EXEC([at_ns1], [ip addr add 10.1.2.2/24 dev p1])
+
+dnl push MPLS LSE on packets from p1 (ns1) to p0 (ns0)
+AT_CHECK([ovs-ofctl add-flow br0 "in_port=3,ip,nw_src=10.1.2.2,actions=push_mpls:0x8847,set_field:101->mpls_label,output:2"])
+
+dnl pop MPLS LSE from packets from p0 (ns0) to p1 (ns1)
+AT_CHECK([ovs-ofctl add-flow br0 "in_port=2,dl_type=0x8847,mpls_label=100,actions=pop_mpls:0x0800,output:3"])
+
+AT_CHECK([ovs-ofctl add-flow br0 "actions=normal"])
+AT_CHECK([ovs-ofctl add-flow br-underlay "actions=normal"])
+
+dnl Allow MPLS forwarding of packets received on p0 in ns0
+NS_CHECK_EXEC([at_ns0], [echo 1 > /proc/sys/net/mpls/conf/ns_gre0/input])
+dnl Larger than MPLS label to be routed by ns0 (101)
+NS_CHECK_EXEC([at_ns0], [echo 102 > /proc/sys/net/mpls/platform_labels])
+
+dnl Set up route to encapsulate 10.1.2.0/24 packets in MPLS
+NS_CHECK_EXEC([at_ns0], [ip route add 10.1.2.0/24 encap mpls 100 via inet 10.1.1.2 dev ns_gre0])
+
+dnl Set up route to decapsulate MPLS label 101 and deliver locally
+NS_CHECK_EXEC([at_ns0], [ip -f mpls route add 101 dev lo])
+
+dnl Set loopback interface up for local delivery
+NS_CHECK_EXEC([at_ns0], [ip link set up dev lo])
+
+dnl First check the underlay
+NS_CHECK_EXEC([at_ns0], [ping -q -c 3 -i 0.3 -w 2 172.31.1.100 | FORMAT_PING], [0], [dnl
+3 packets transmitted, 3 received, 0% packet loss, time 0ms
+])
+
+dnl Next check the overlay
+NS_CHECK_EXEC([at_ns0], [ping -q -c 3 -i 0.3 -w 2 10.1.2.2  | FORMAT_PING], [0], [dnl
+3 packets transmitted, 3 received, 0% packet loss, time 0ms
+])
+
+dnl Now check HTTP transfer
+AT_CHECK([yes | dd bs=1k count=32 of=32k.txt], [0], [], stderr)
+AT_CHECK([cat stderr | FORMAT_DD], [0], [dnl
+32+0 records in
+32+0 records out
+32768 bytes (33 kB) copied, ...
+])
+NETNS_DAEMONIZE([at_ns1], [[$PYTHON $srcdir/test-l7.py]], [http0.pid])
+NS_CHECK_EXEC([at_ns0], [wget 10.1.2.2/32k.txt -t 3 -T 1 --retry-connrefused -v -o wget0.log])
+
+dnl Use the absence of retransmitted segments as a proxy for functioning GSO
+NS_CHECK_EXEC([at_ns1], [netstat -s | grep retransmited], [0], [dnl
+    0 segments retransmited
+])
+
 OVS_TRAFFIC_VSWITCHD_STOP
 AT_CLEANUP
 
-- 
2.7.0.rc3.207.g0ac5344
