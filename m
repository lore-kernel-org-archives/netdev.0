From: Matteo Croce <technoboy85@gmail.com>
Subject: [PATCH] add stealth mode
Date: Thu, 2 Jul 2015 00:53:54 +0200
Message-ID: <CAFnufp3wM5rb=B4N8Ad+cLcTu8sx-f9OXpqp33uCKXe=q=je3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add option to disable any reply not related to a listening socket,
like RST/ACK for TCP and ICMP Dest-Unreach for UDP.
Also disables ICMP replies to echo request and timestamp.
The stealth mode can be enabled selectively for a single interface.
---
 include/linux/inetdevice.h | 1 +
 include/linux/ipv6.h       | 1 +
 include/uapi/linux/ip.h    | 1 +
 net/ipv4/devinet.c         | 1 +
 net/ipv4/icmp.c            | 6 ++++++
 net/ipv4/tcp_ipv4.c        | 3 ++-
 net/ipv4/udp.c             | 4 +++-
 net/ipv6/addrconf.c        | 7 +++++++
 net/ipv6/icmp.c            | 3 ++-
 net/ipv6/tcp_ipv6.c        | 2 +-
 net/ipv6/udp.c             | 3 ++-
 11 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index a4328ce..a64c01e 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -128,6 +128,7 @@ static inline void ipv4_devconf_setall(struct
in_device *in_dev)
 #define IN_DEV_ARP_ANNOUNCE(in_dev) IN_DEV_MAXCONF((in_dev), ARP_ANNOUNCE)
 #define IN_DEV_ARP_IGNORE(in_dev) IN_DEV_MAXCONF((in_dev), ARP_IGNORE)
 #define IN_DEV_ARP_NOTIFY(in_dev) IN_DEV_MAXCONF((in_dev), ARP_NOTIFY)
+#define IN_DEV_STEALTH(in_dev) IN_DEV_MAXCONF((in_dev), STEALTH)

 struct in_ifaddr {
  struct hlist_node hash;
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 82806c6..49494ec 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -53,6 +53,7 @@ struct ipv6_devconf {
  __s32           ndisc_notify;
  __s32 suppress_frag_ndisc;
  __s32 accept_ra_mtu;
+ __s32 stealth;
  struct ipv6_stable_secret {
  bool initialized;
  struct in6_addr secret;
diff --git a/include/uapi/linux/ip.h b/include/uapi/linux/ip.h
index 08f894d..4acbf99 100644
--- a/include/uapi/linux/ip.h
+++ b/include/uapi/linux/ip.h
@@ -165,6 +165,7 @@ enum
  IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL,
  IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL,
  IPV4_DEVCONF_IGNORE_ROUTES_WITH_LINKDOWN,
+ IPV4_DEVCONF_STEALTH,
  __IPV4_DEVCONF_MAX
 };

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7498716..6b9930a 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2178,6 +2178,7 @@ static struct devinet_sysctl_table {
       "promote_secondaries"),
  DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
       "route_localnet"),
+ DEVINET_SYSCTL_RW_ENTRY(STEALTH, "stealth"),
  },
 };

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f5203fb..2f1b31f 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -882,6 +882,9 @@ static bool icmp_echo(struct sk_buff *skb)
 {
  struct net *net;

+ if(IN_DEV_STEALTH(skb->dev->ip_ptr))
+ return true;
+
  net = dev_net(skb_dst(skb)->dev);
  if (!net->ipv4.sysctl_icmp_echo_ignore_all) {
  struct icmp_bxm icmp_param;
@@ -915,6 +918,9 @@ static bool icmp_timestamp(struct sk_buff *skb)
  if (skb->len < 4)
  goto out_err;

+ if(IN_DEV_STEALTH(skb->dev->ip_ptr))
+ return true;
+
  /*
  * Fill in the current time as ms since midnight UT:
  */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d7d4c2b..c887d6e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -77,6 +77,7 @@
 #include <net/busy_poll.h>

 #include <linux/inet.h>
+#include <linux/inetdevice.h>
 #include <linux/ipv6.h>
 #include <linux/stddef.h>
 #include <linux/proc_fs.h>
@@ -1652,7 +1653,7 @@ csum_error:
  TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
 bad_packet:
  TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
- } else {
+ } else if(!IN_DEV_STEALTH(skb->dev->ip_ptr)) {
  tcp_v4_send_reset(NULL, skb);
  }

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 83aa604..b3b0dee 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -96,6 +96,7 @@
 #include <linux/timer.h>
 #include <linux/mm.h>
 #include <linux/inet.h>
+#include <linux/inetdevice.h>
 #include <linux/netdevice.h>
 #include <linux/slab.h>
 #include <net/tcp_states.h>
@@ -1823,7 +1824,8 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct
udp_table *udptable,
  goto csum_error;

  UDP_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
- icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+ if(!IN_DEV_STEALTH(skb->dev->ip_ptr))
+ icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);

  /*
  * Hmm.  We got an UDP packet to a port to which we
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21c2c81..b9e44e2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5585,6 +5585,13 @@ static struct addrconf_sysctl_table
  .proc_handler = addrconf_sysctl_stable_secret,
  },
  {
+ .procname = "stealth",
+ .data = &ipv6_devconf.stealth,
+ .maxlen = sizeof(int),
+ .mode = 0644,
+ .proc_handler = proc_dointvec,
+ },
+ {
  /* sentinel */
  }
  },
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 713d743..94b08ac 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -723,7 +723,8 @@ static int icmpv6_rcv(struct sk_buff *skb)

  switch (type) {
  case ICMPV6_ECHO_REQUEST:
- icmpv6_echo_reply(skb);
+ if(!idev->cnf.stealth)
+ icmpv6_echo_reply(skb);
  break;

  case ICMPV6_ECHO_REPLY:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6748c42..cae96d7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1445,7 +1445,7 @@ csum_error:
  TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
 bad_packet:
  TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
- } else {
+ } else if(!__in6_dev_get(skb->dev)->cnf.stealth) {
  tcp_v6_send_reset(NULL, skb);
  }

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e51fc3e..c0cee63 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -934,7 +934,8 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct
udp_table *udptable,
  goto csum_error;

  UDP6_INC_STATS_BH(net, UDP_MIB_NOPORTS, proto == IPPROTO_UDPLITE);
- icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);
+ if(!__in6_dev_get(skb->dev)->cnf.stealth)
+ icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0);

  kfree_skb(skb);
  return 0;
-- 
2.1.4
