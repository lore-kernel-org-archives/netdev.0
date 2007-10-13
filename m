From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [PATCH 14/14] Add documentation
Date: Sat, 13 Oct 2007 19:36:11 +0200
Message-ID: <20071013173611.22517.58118.stgit@nessa.odu>
References: <20071013172857.22517.84760.stgit@nessa.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.sch.bme.hu ([152.66.208.40]:58852 "EHLO balu.sch.bme.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756581AbXJMRjD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 13:39:03 -0400
Received: from nessa.odu ([152.66.208.5])
 by balu.sch.bme.hu (Sun Java System Messaging Server 6.2-7.05 (built Sep  5
 2006)) with ESMTP id <0JPV00A5T25CGO30@balu.sch.bme.hu> for
 netdev@vger.kernel.org; Sat, 13 Oct 2007 19:34:24 +0200 (CEST)
In-reply-to: <20071013172857.22517.84760.stgit@nessa.odu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add basic usage instructions to Documentation/networking.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 Documentation/networking/tproxy.txt |   62 +++++++++++++++++++++++++++++++++++
 1 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/tproxy.txt b/Documentation/networking/tproxy.txt
new file mode 100644
index 0000000..dfcb613
--- /dev/null
+++ b/Documentation/networking/tproxy.txt
@@ -0,0 +1,62 @@
+Transparent proxy support
+=========================
+
+This feature adds Linux 2.2-like transparent proxy support to current kernels.
+To use it, enable NETFILTER_TPROXY, the socket match and the TPROXY target in
+your kernel config. You will need policy routing too, so be sure to enable that
+as well.
+
+1. Making non-local sockets work
+================================
+
+The idea is that you identify packets with destination address matching a local
+socket your box, set the packet mark to a certain value, and then match on that
+value using policy routing to have those packets delivered locally:
+
+# iptables -t mangle -N DIVERT
+# iptables -t mangle -A PREROUTING -p tcp -m socket -j DIVERT
+# iptables -t mangle -A DIVERT -j MARK --set-mark 1
+# iptables -t mangle -A DIVERT -j ACCEPT
+
+# ip rule add fwmark 1 lookup 100
+# ip route add local 0.0.0.0/0 dev lo table 100
+
+Because of certain restrictions in the IPv4 routing output code you'll have to
+modify your application to allow it sending datagrams _from_ non-local IP
+addresses. All you have to do is to enable the (SOL_IP, IP_TRANSPARENT) socket
+option before calling bind:
+
+fd = socket(AF_INET, SOCK_STREAM, 0);
+/* - 8< -*/
+int value = 1;
+setsockopt(fd, SOL_IP, IP_TRANSPARENT, &value, sizeof(value));
+/* - 8< -*/
+name.sin_family = AF_INET;
+name.sin_port = htons(0xCAFE);
+name.sin_addr.s_addr = htonl(0xDEADBEEF);
+bind(fd, &name, sizeof(name));
+
+A trivial patch for netcat is available here:
+http://people.netfilter.org/hidden/tproxy/netcat-ip_transparent-support.patch
+
+
+2. Redirecting traffic
+======================
+
+Transparent proxying often involves "intercepting" traffic on a router. This is
+usually done with the iptables REDIRECT target, however, there are serious
+limitations of that method. One of the major issues is that it actually
+modifies the packets to change the destination address -- which might not be
+acceptable in certain situations. (Think of proxying UDP for example: you won't
+be able to find out the original destination address. Even in case of TCP
+getting the original destination address is racy.)
+
+The 'TPROXY' target provides similar functionality without relying on NAT. Simply
+add rules like this to the iptables ruleset above:
+
+# iptables -t mangle -A PREROUTING -p tcp --dport 80 -j TPROXY \
+  --tproxy-mark 0x1/0x1 --on-port 50080
+
+Note that for this to work you'll have to modify the proxy to enable (SOL_IP,
+IP_TRANSPARENT) for the listening socket.
+

