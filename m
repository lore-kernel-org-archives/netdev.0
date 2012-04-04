From: Helge Deller <deller@gmx.de>
Subject: [RFC] API to modify /proc/sys/net/ipv4/ip_local_reserved_ports
Date: Wed, 04 Apr 2012 22:24:08 +0200
Message-ID: <4F7CADE8.3060205@gmx.de>
References: <4F5BE563.9050506@gmx.de> <4F5FAF28.5030205@gmx.de> <4F611835.4080904@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Octavian Purdila <octavian.purdila@intel.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Frank Danapfel <fdanapfe@redhat.com>,
	Laszlo Ersek <lersek@redhat.com>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:37917 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751956Ab2DDUZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 16:25:05 -0400
In-Reply-To: <4F611835.4080904@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like to follow up on my last patch series to be able to modify
the contents of the /proc/sys/net/ipv4/ip_local_reserved_ports port list
from userspace.

My last patch (https://lkml.org/lkml/2012/3/10/187) was based on
modifications to the proc interface, which - based on the feedback here
on the list - seemed to not be the right way to go (although I personally
still like the idea very much :-)).

Anyway, with this RFC I would like to get feedback about a new proposed
API and attached kernel patch.

The idea is to introduce a new <optname> value for get/setsockopt()
named SO_RESERVED_PORTS to get/set the ip_local_reserved_ports
bitmap via standard get/setsockopt() syscalls.
As far as I understand this seems to be similiar to how iptables works.

An untested kernel patch for review and feedback is attached below.

In userspace it then would be possible to write a new tool or to extend
for example the "ip" tool to accept commands like:
$> ip reserved_ports add 100-2000
$> ip reserved_ports remove 50-60
$> ip reserved_ports list     (to show current reserved port list)

This userspace tool could then read the port bitmap from kernel via
a) socket(PF_INET, SOCK_RAW, IPPROTO_RAW)
b) getsockopt(3, SOL_SOCKET, SO_RESERVED_PORTS, <bitmaplist>)
and write back the results after modification via
c) setsockopt(3, SOL_SOCKET, SO_RESERVED_PORTS, <bitmaplist>)

Would that be an acceptable solution?
If yes, I will of course write the kernel patch and the userspace 
implementation and
post it here for review again...

Thanks,
Helge


diff --git a/include/asm-generic/socket.h b/include/asm-generic/socket.h
--- a/include/asm-generic/socket.h
+++ b/include/asm-generic/socket.h
@@ -67,4 +67,6 @@

  #define SO_WIFI_STATUS        41
  #define SCM_WIFI_STATUS    SO_WIFI_STATUS
+
+#define SO_RESERVED_PORTS    42
  #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/include/net/ip.h b/include/net/ip.h
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -214,6 +214,7 @@ extern struct local_ports {
  } sysctl_local_ports;
  extern void inet_get_local_port_range(int *low, int *high);

+#define SYSCTL_LOCAL_RESERVED_PORTS_BYTES (65536 / 8)
  extern unsigned long *sysctl_local_reserved_ports;
  static inline int inet_is_reserved_local_port(int port)
  {
diff --git a/net/core/sock.c b/net/core/sock.c
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -793,6 +793,13 @@ set_rcvbuf:
          sock_valbool_flag(sk, SOCK_WIFI_STATUS, valbool);
          break;

+    case SO_RESERVED_PORTS:
+        ret = -EINVAL;
+        if (optlen == SYSCTL_LOCAL_RESERVED_PORTS_BYTES)
+            ret = copy_from_user(sysctl_local_reserved_ports, optval, 
optlen);
+        break;
+
+
      default:
          ret = -ENOPROTOOPT;
          break;
@@ -1018,6 +1025,13 @@ int sock_getsockopt(struct socket *sock, int 
level, int optname,
          v.val = !!sock_flag(sk, SOCK_WIFI_STATUS);
          break;

+    case SO_RESERVED_PORTS:
+        if (len != SYSCTL_LOCAL_RESERVED_PORTS_BYTES)
+            return -EINVAL;
+        if (copy_to_user(optval, sysctl_local_reserved_ports, len))
+            return -EFAULT;
+        goto lenout;
+
      default:
          return -ENOPROTOOPT;
      }
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1642,7 +1642,7 @@ static int __init inet_init(void)

      BUILD_BUG_ON(sizeof(struct inet_skb_parm) > sizeof(dummy_skb->cb));

-    sysctl_local_reserved_ports = kzalloc(65536 / 8, GFP_KERNEL);
+    sysctl_local_reserved_ports = 
kzalloc(SYSCTL_LOCAL_RESERVED_PORTS_BYTES, GFP_KERNEL);
      if (!sysctl_local_reserved_ports)
          goto out;
