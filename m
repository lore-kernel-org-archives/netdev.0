From: "David Stevens" <dlstevens@us.ibm.com>
Subject: [PATCH] anycast support for IPv6, updated to 2.5.44
Date: Mon, 28 Oct 2002 14:06:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFC909BFEE.F581E26E-ON88256C60.0072A662@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE6F3DFE120F28f9e8a93df938690918c07BBE6F3DFE120F2"
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE6F3DFE120F28f9e8a93df938690918c07BBE6F3DFE120F2
Content-type: text/plain; charset=us-ascii


Below is a patch to add anycast support for IPv6. It's the same patch as
I've posted previously, but updated with comments from Chris Hellwig and
for kernel version 2.5.44.
      My mailer mangles tabs, so I'm including it in-line (for easy
viewing) and as an attachment at the end (for applying to kernels). A
fuller description is available at:
http://marc.theaimsgroup.com/?l=linux-net&m=103057141321548&w=2
      Currently, IPv6 mobile code is the only user of anycasting, but there
won't be users if it isn't supported. Please consider for inclusion in 2.5.

                                    +-DLS

diff -ruN linux-2.5.44/include/linux/in6.h linux-2.5.44AC/include/linux/in6.h
--- linux-2.5.44/include/linux/in6.h      Fri Oct 18 21:01:59 2002
+++ linux-2.5.44AC/include/linux/in6.h    Mon Oct 28 12:38:09 2002
@@ -56,6 +56,8 @@
      int         ipv6mr_ifindex;
 };

+#define ipv6mr_acaddr  ipv6mr_multiaddr
+
 struct in6_flowlabel_req
 {
      struct in6_addr   flr_dst;
@@ -156,6 +158,9 @@
 #define IPV6_MTU_DISCOVER    23
 #define IPV6_MTU       24
 #define IPV6_RECVERR         25
+/* 26 is IPV6_V6ONLY in USAGI code */
+#define IPV6_JOIN_ANYCAST    27
+#define IPV6_LEAVE_ANYCAST   28

 /* IPV6_MTU_DISCOVER values */
 #define IPV6_PMTUDISC_DONT         0
diff -ruN linux-2.5.44/include/linux/ipv6.h linux-2.5.44AC/include/linux/ipv6.h
--- linux-2.5.44/include/linux/ipv6.h     Fri Oct 18 21:02:26 2002
+++ linux-2.5.44AC/include/linux/ipv6.h   Mon Oct 28 12:38:09 2002
@@ -155,6 +155,7 @@
                              pmtudisc:2;

      struct ipv6_mc_socklist *ipv6_mc_list;
+     struct ipv6_ac_socklist *ipv6_ac_list;
      struct ipv6_fl_socklist *ipv6_fl_list;
      __u32             dst_cookie;

diff -ruN linux-2.5.44/include/linux/netdevice.h linux-2.5.44AC/include/linux/netdevice.h
--- linux-2.5.44/include/linux/netdevice.h      Fri Oct 18 21:02:31 2002
+++ linux-2.5.44AC/include/linux/netdevice.h    Mon Oct 28 12:38:09 2002
@@ -464,6 +464,10 @@
 extern void            dev_add_pack(struct packet_type *pt);
 extern void            dev_remove_pack(struct packet_type *pt);
 extern int       dev_get(const char *name);
+extern struct net_device     *dev_getany(unsigned short flags,
+                             unsigned short mask);
+extern struct net_device     *__dev_getany(unsigned short flags,
+                             unsigned short mask);
 extern struct net_device     *dev_get_by_name(const char *name);
 extern struct net_device     *__dev_get_by_name(const char *name);
 extern struct net_device     *dev_alloc(const char *name, int *err);
diff -ruN linux-2.5.44/include/net/addrconf.h linux-2.5.44AC/include/net/addrconf.h
--- linux-2.5.44/include/net/addrconf.h   Fri Oct 18 21:01:18 2002
+++ linux-2.5.44AC/include/net/addrconf.h Mon Oct 28 12:38:09 2002
@@ -58,7 +58,15 @@
 extern int             ipv6_get_saddr(struct dst_entry *dst,
                                     struct in6_addr *daddr,
                                     struct in6_addr *saddr);
+extern int             ipv6_dev_get_saddr(struct net_device *dev,
+                                    struct in6_addr *daddr,
+                                    struct in6_addr *saddr,
+                                    int onlink);
 extern int             ipv6_get_lladdr(struct net_device *dev, struct in6_addr *);
+extern void                  addrconf_join_solict(struct net_device *dev,
+                             struct in6_addr *addr);
+extern void                  addrconf_leave_solict(struct net_device *dev,
+                             struct in6_addr *addr);

 /*
  *   multicast prototypes (mcast.c)
@@ -88,6 +96,26 @@
 extern void                  addrconf_prefix_rcv(struct net_device *dev,
                                        u8 *opt, int len);

+/*
+ *   anycast prototypes (anycast.c)
+ */
+extern int             ipv6_sock_ac_join(struct sock *sk,
+                                     int ifindex,
+                                     struct in6_addr *addr);
+extern int             ipv6_sock_ac_drop(struct sock *sk,
+                                     int ifindex,
+                                     struct in6_addr *addr);
+extern void                  ipv6_sock_ac_close(struct sock *sk);
+extern int             inet6_ac_check(struct sock *sk, struct in6_addr *addr, int ifindex);
+
+extern int             ipv6_dev_ac_inc(struct net_device *dev,
+                                   struct in6_addr *addr);
+extern int             ipv6_dev_ac_dec(struct net_device *dev,
+                                   struct in6_addr *addr);
+extern int             ipv6_chk_acast_addr(struct net_device *dev,
+                                   struct in6_addr *addr);
+
+
 /* Device notifier */
 extern int register_inet6addr_notifier(struct notifier_block *nb);
 extern int unregister_inet6addr_notifier(struct notifier_block *nb);
diff -ruN linux-2.5.44/include/net/if_inet6.h linux-2.5.44AC/include/net/if_inet6.h
--- linux-2.5.44/include/net/if_inet6.h   Fri Oct 18 21:02:34 2002
+++ linux-2.5.44AC/include/net/if_inet6.h Mon Oct 28 12:38:09 2002
@@ -69,6 +69,25 @@
      spinlock_t        mca_lock;
 };

+/* Anycast stuff */
+
+struct ipv6_ac_socklist
+{
+     struct in6_addr         acl_addr;
+     int               acl_ifindex;
+     struct ipv6_ac_socklist *acl_next;
+};
+
+struct ifacaddr6
+{
+     struct in6_addr         aca_addr;
+     struct inet6_dev  *aca_idev;
+     struct ifacaddr6  *aca_next;
+     int               aca_users;
+     atomic_t          aca_refcnt;
+     spinlock_t        aca_lock;
+};
+
 #define    IFA_HOST    IPV6_ADDR_LOOPBACK
 #define    IFA_LINK    IPV6_ADDR_LINKLOCAL
 #define    IFA_SITE    IPV6_ADDR_SITELOCAL
@@ -96,6 +115,7 @@

      struct inet6_ifaddr     *addr_list;
      struct ifmcaddr6  *mc_list;
+     struct ifacaddr6  *ac_list;
      rwlock_t          lock;
      atomic_t          refcnt;
      __u32             if_flags;
diff -ruN linux-2.5.44/net/core/dev.c linux-2.5.44AC/net/core/dev.c
--- linux-2.5.44/net/core/dev.c     Fri Oct 18 21:01:54 2002
+++ linux-2.5.44AC/net/core/dev.c   Mon Oct 28 12:38:09 2002
@@ -541,6 +541,50 @@
 }

 /**
+ *   dev_getany - find any device with given flags
+ *   @if_flags: IFF_* values
+ *   @mask: bitmask of bits in if_flags to check
+ *
+ *   Search for any interface with the given flags. Returns NULL if a device
+ *   is not found or a pointer to the device. The device returned has
+ *   had a reference added and the pointer is safe until the user calls
+ *   dev_put to indicate they have finished with it.
+ */
+
+struct net_device * dev_getany(unsigned short if_flags, unsigned short mask)
+{
+     struct net_device *dev;
+
+     read_lock(&dev_base_lock);
+     dev = __dev_getany(if_flags, mask);
+     if (dev)
+           dev_hold(dev);
+     read_unlock(&dev_base_lock);
+     return dev;
+}
+
+/**
+ *   __dev_getany - find any device with given flags
+ *   @if_flags: IFF_* values
+ *   @mask: bitmask of bits in if_flags to check
+ *
+ *   Search for any interface with the given flags. Returns NULL if a device
+ *   is not found or a pointer to the device. The caller must hold either
+ *   the RTNL semaphore or @dev_base_lock.
+ */
+
+struct net_device *__dev_getany(unsigned short if_flags, unsigned short mask)
+{
+     struct net_device *dev;
+
+     for (dev = dev_base; dev != NULL; dev = dev->next) {
+           if (((dev->flags ^ if_flags) & mask) == 0)
+                 return dev;
+     }
+     return NULL;
+}
+
+/**
  *   dev_alloc_name - allocate a name for a device
  *   @dev: device
  *   @name: name format string
diff -ruN linux-2.5.44/net/ipv6/Makefile linux-2.5.44AC/net/ipv6/Makefile
--- linux-2.5.44/net/ipv6/Makefile  Fri Oct 18 21:02:27 2002
+++ linux-2.5.44AC/net/ipv6/Makefile      Mon Oct 28 12:38:09 2002
@@ -6,7 +6,7 @@

 obj-$(CONFIG_IPV6) += ipv6.o

-ipv6-objs :=     af_inet6.o ip6_output.o ip6_input.o addrconf.o sit.o \
+ipv6-objs :=     af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o sit.o \
            route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o raw.o \
            protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
            exthdrs.o sysctl_net_ipv6.o datagram.o proc.o \
diff -ruN linux-2.5.44/net/ipv6/addrconf.c linux-2.5.44AC/net/ipv6/addrconf.c
--- linux-2.5.44/net/ipv6/addrconf.c      Fri Oct 18 21:02:31 2002
+++ linux-2.5.44AC/net/ipv6/addrconf.c    Mon Oct 28 12:49:03 2002
@@ -137,21 +137,15 @@

 int ipv6_addr_type(struct in6_addr *addr)
 {
+     int type;
      u32 st;

      st = addr->s6_addr32[0];

-     /* Consider all addresses with the first three bits different of
-        000 and 111 as unicasts.
-      */
-     if ((st & htonl(0xE0000000)) != htonl(0x00000000) &&
-         (st & htonl(0xE0000000)) != htonl(0xE0000000))
-           return IPV6_ADDR_UNICAST;
-
-     if ((st & htonl(0xFF000000)) == htonl(0xFF000000)) {
-           int type = IPV6_ADDR_MULTICAST;
+     if ((st & __constant_htonl(0xFF000000)) == __constant_htonl(0xFF000000)) {
+           type = IPV6_ADDR_MULTICAST;

-           switch((st & htonl(0x00FF0000))) {
+           switch((st & __constant_htonl(0x00FF0000))) {
                  case __constant_htonl(0x00010000):
                        type |= IPV6_ADDR_LOOPBACK;
                        break;
@@ -166,29 +160,53 @@
            };
            return type;
      }
+     /* check for reserved anycast addresses */
+
+     if ((st & __constant_htonl(0xE0000000)) &&
+         ((addr->s6_addr32[2] == __constant_htonl(0xFDFFFFFF) &&
+         (addr->s6_addr32[3] | __constant_htonl(0x7F)) == (u32)~0) ||
+         (addr->s6_addr32[2] == 0 && addr->s6_addr32[3] == 0)))
+           type = IPV6_ADDR_ANYCAST;
+     else
+           type = IPV6_ADDR_UNICAST;
+
+     /* Consider all addresses with the first three bits different of
+        000 and 111 as finished.
+      */
+     if ((st & __constant_htonl(0xE0000000)) != __constant_htonl(0x00000000) &&
+         (st & __constant_htonl(0xE0000000)) != __constant_htonl(0xE0000000))
+           return type;

-     if ((st & htonl(0xFFC00000)) == htonl(0xFE800000))
-           return (IPV6_ADDR_LINKLOCAL | IPV6_ADDR_UNICAST);
+     if ((st & __constant_htonl(0xFFC00000)) == __constant_htonl(0xFE800000))
+           return (IPV6_ADDR_LINKLOCAL | type);

-     if ((st & htonl(0xFFC00000)) == htonl(0xFEC00000))
-           return (IPV6_ADDR_SITELOCAL | IPV6_ADDR_UNICAST);
+     if ((st & __constant_htonl(0xFFC00000)) == __constant_htonl(0xFEC00000))
+           return (IPV6_ADDR_SITELOCAL | type);

      if ((addr->s6_addr32[0] | addr->s6_addr32[1]) == 0) {
            if (addr->s6_addr32[2] == 0) {
-                 if (addr->s6_addr32[3] == 0)
+                 if (addr->in6_u.u6_addr32[3] == 0)
                        return IPV6_ADDR_ANY;

-                 if (addr->s6_addr32[3] == htonl(0x00000001))
-                       return (IPV6_ADDR_LOOPBACK | IPV6_ADDR_UNICAST);
+                 if (addr->s6_addr32[3] == __constant_htonl(0x00000001))
+                       return (IPV6_ADDR_LOOPBACK | type);

-                 return (IPV6_ADDR_COMPATv4 | IPV6_ADDR_UNICAST);
+                 return (IPV6_ADDR_COMPATv4 | type);
            }

-           if (addr->s6_addr32[2] == htonl(0x0000ffff))
+           if (addr->s6_addr32[2] == __constant_htonl(0x0000ffff))
                  return IPV6_ADDR_MAPPED;
      }

-     return IPV6_ADDR_RESERVED;
+     st &= __constant_htonl(0xFF000000);
+     if (st == 0)
+           return IPV6_ADDR_RESERVED;
+     st &= __constant_htonl(0xFE000000);
+     if (st == __constant_htonl(0x02000000))
+           return IPV6_ADDR_RESERVED;    /* for NSAP */
+     if (st == __constant_htonl(0x04000000))
+           return IPV6_ADDR_RESERVED;    /* for IPX */
+     return type;
 }

 static void addrconf_del_timer(struct inet6_ifaddr *ifp)
@@ -224,7 +242,6 @@
      add_timer(&ifp->timer);
 }

-
 /* Nobody refers to this device, we may destroy it. */

 void in6_dev_finish_destroy(struct inet6_dev *idev)
@@ -303,24 +320,91 @@
      return idev;
 }

+void ipv6_addr_prefix(struct in6_addr *prefix,
+     struct in6_addr *addr, int prefix_len)
+{
+     unsigned long mask;
+     int ncopy, nbits;
+
+     memset(prefix, 0, sizeof(*prefix));
+
+     if (prefix_len <= 0)
+           return;
+     if (prefix_len > 128)
+           prefix_len = 128;
+
+     ncopy = prefix_len / 32;
+     switch (ncopy) {
+     case 4:     prefix->s6_addr32[3] = addr->s6_addr32[3];
+     case 3:     prefix->s6_addr32[2] = addr->s6_addr32[2];
+     case 2:     prefix->s6_addr32[1] = addr->s6_addr32[1];
+     case 1:     prefix->s6_addr32[0] = addr->s6_addr32[0];
+     case 0:     break;
+     }
+     nbits = prefix_len % 32;
+     if (nbits == 0)
+           return;
+
+     mask = ~((1 << (32 - nbits)) - 1);
+     mask = htonl(mask);
+
+     prefix->s6_addr32[ncopy] = addr->s6_addr32[ncopy] & mask;
+}
+
+
+static void dev_forward_change(struct inet6_dev *idev)
+{
+     struct net_device *dev;
+     struct inet6_ifaddr *ifa;
+     struct in6_addr addr;
+
+     if (!idev)
+           return;
+     dev = idev->dev;
+     if (dev && (dev->flags & IFF_MULTICAST)) {
+           ipv6_addr_all_routers(&addr);
+
+           if (idev->cnf.forwarding)
+                 ipv6_dev_mc_inc(dev, &addr);
+           else
+                 ipv6_dev_mc_dec(dev, &addr);
+     }
+     for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
+           ipv6_addr_prefix(&addr, &ifa->addr, ifa->prefix_len);
+           if (addr.s6_addr32[0] == 0 && addr.s6_addr32[1] == 0 &&
+               addr.s6_addr32[2] == 0 && addr.s6_addr32[3] == 0)
+                 continue;
+           if (idev->cnf.forwarding)
+                 ipv6_dev_ac_inc(idev->dev, &addr);
+           else
+                 ipv6_dev_ac_dec(idev->dev, &addr);
+     }
+}
+
+
 static void addrconf_forward_change(struct inet6_dev *idev)
 {
      struct net_device *dev;

-     if (idev)
+     if (idev) {
+           dev_forward_change(idev);
            return;
+     }

      read_lock(&dev_base_lock);
      for (dev=dev_base; dev; dev=dev->next) {
            read_lock(&addrconf_lock);
            idev = __in6_dev_get(dev);
-           if (idev)
+           if (idev) {
                  idev->cnf.forwarding = ipv6_devconf.forwarding;
+                 dev_forward_change(idev);
+           }
            read_unlock(&addrconf_lock);
      }
      read_unlock(&dev_base_lock);
 }

+
 /* Nobody refers to this ifaddr, destroy it */

 void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
@@ -458,29 +542,20 @@
  *         an address of the attached interface
  *   iii)  don't use deprecated addresses
  */
-int ipv6_get_saddr(struct dst_entry *dst,
-              struct in6_addr *daddr, struct in6_addr *saddr)
+int ipv6_dev_get_saddr(struct net_device *dev,
+              struct in6_addr *daddr, struct in6_addr *saddr, int onlink)
 {
-     int scope;
      struct inet6_ifaddr *ifp = NULL;
      struct inet6_ifaddr *match = NULL;
-     struct net_device *dev = NULL;
      struct inet6_dev *idev;
-     struct rt6_info *rt;
+     int scope;
      int err;

-     rt = (struct rt6_info *) dst;
-     if (rt)
-           dev = rt->rt6i_dev;

-     scope = ipv6_addr_scope(daddr);
-     if (rt && (rt->rt6i_flags & RTF_ALLONLINK)) {
-           /*
-            *    route for the "all destinations on link" rule
-            *    when no routers are present
-            */
+     if (!onlink)
+           scope = ipv6_addr_scope(daddr);
+     else
            scope = IFA_LINK;
-     }

      /*
       *    known dev
@@ -568,6 +643,24 @@
      return err;
 }

+
+int ipv6_get_saddr(struct dst_entry *dst,
+              struct in6_addr *daddr, struct in6_addr *saddr)
+{
+     struct rt6_info *rt;
+     struct net_device *dev = NULL;
+     int onlink;
+
+     rt = (struct rt6_info *) dst;
+     if (rt)
+           dev = rt->rt6i_dev;
+
+     onlink = (rt && (rt->rt6i_flags & RTF_ALLONLINK));
+
+     return ipv6_dev_get_saddr(dev, daddr, saddr, onlink);
+}
+
+
 int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
 {
      struct inet6_dev *idev;
@@ -660,7 +753,7 @@

 /* Join to solicited addr multicast group. */

-static void addrconf_join_solict(struct net_device *dev, struct in6_addr *addr)
+void addrconf_join_solict(struct net_device *dev, struct in6_addr *addr)
 {
      struct in6_addr maddr;

@@ -671,7 +764,7 @@
      ipv6_dev_mc_inc(dev, &maddr);
 }

-static void addrconf_leave_solict(struct net_device *dev, struct in6_addr *addr)
+void addrconf_leave_solict(struct net_device *dev, struct in6_addr *addr)
 {
      struct in6_addr maddr;

@@ -1554,6 +1647,15 @@
            addrconf_mod_timer(ifp, AC_RS, ifp->idev->cnf.rtr_solicit_interval);
            spin_unlock_bh(&ifp->lock);
      }
+
+     if (ifp->idev->cnf.forwarding) {
+           struct in6_addr addr;
+
+           ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
+           if (addr.s6_addr32[0] || addr.s6_addr32[1] ||
+               addr.s6_addr32[2] || addr.s6_addr32[3])
+                 ipv6_dev_ac_inc(ifp->idev->dev, &addr);
+     }
 }

 #ifdef CONFIG_PROC_FS
@@ -1853,6 +1955,14 @@
            break;
      case RTM_DELADDR:
            addrconf_leave_solict(ifp->idev->dev, &ifp->addr);
+           if (ifp->idev->cnf.forwarding) {
+                 struct in6_addr addr;
+
+                 ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
+                 if (addr.s6_addr32[0] || addr.s6_addr32[1] ||
+                     addr.s6_addr32[2] || addr.s6_addr32[3])
+                       ipv6_dev_ac_dec(ifp->idev->dev, &addr);
+           }
            if (!ipv6_chk_addr(&ifp->addr, NULL))
                  ip6_rt_addr_del(&ifp->addr, ifp->idev->dev);
            break;
@@ -1875,11 +1985,7 @@
            struct inet6_dev *idev = NULL;

            if (valp != &ipv6_devconf.forwarding) {
-                 struct net_device *dev = dev_get_by_index(ctl->ctl_name);
-                 if (dev) {
-                       idev = in6_dev_get(dev);
-                       dev_put(dev);
-                 }
+                 idev = (struct inet6_dev *)ctl->extra1;
                  if (idev == NULL)
                        return ret;
            } else
@@ -1889,8 +1995,6 @@

            if (*valp)
                  rt6_purge_dflt_routers(0);
-           if (idev)
-                 in6_dev_put(idev);
      }

         return ret;
@@ -1967,6 +2071,7 @@
      for (i=0; i<sizeof(t->addrconf_vars)/sizeof(t->addrconf_vars[0])-1; i++) {
            t->addrconf_vars[i].data += (char*)p - (char*)&ipv6_devconf;
            t->addrconf_vars[i].de = NULL;
+           t->addrconf_vars[i].extra1 = idev; /* embedded; no ref */
      }
      if (dev) {
            t->addrconf_dev[0].procname = dev->name;
diff -ruN linux-2.5.44/net/ipv6/af_inet6.c linux-2.5.44AC/net/ipv6/af_inet6.c
--- linux-2.5.44/net/ipv6/af_inet6.c      Fri Oct 18 21:01:57 2002
+++ linux-2.5.44AC/net/ipv6/af_inet6.c    Mon Oct 28 12:38:09 2002
@@ -76,6 +76,7 @@
 /* IPv6 procfs goodies... */

 #ifdef CONFIG_PROC_FS
+extern int anycast6_get_info(char *, char **, off_t, int);
 extern int raw6_get_info(char *, char **, off_t, int);
 extern int tcp6_get_info(char *, char **, off_t, int);
 extern int udp6_get_info(char *, char **, off_t, int);
@@ -380,6 +381,9 @@
      /* Free mc lists */
      ipv6_sock_mc_close(sk);

+     /* Free ac lists */
+     ipv6_sock_ac_close(sk);
+
      return inet_release(sock);
 }

@@ -694,6 +698,8 @@
            goto proc_sockstat6_fail;
      if (!proc_net_create("snmp6", 0, afinet6_get_snmp))
            goto proc_snmp6_fail;
+     if (!proc_net_create("anycast6", 0, anycast6_get_info))
+           goto proc_anycast6_fail;
 #endif
      ipv6_netdev_notif_init();
      ipv6_packet_init();
@@ -709,6 +715,8 @@
      return 0;

 #ifdef CONFIG_PROC_FS
+proc_anycast6_fail:
+     proc_net_remove("anycast6");
 proc_snmp6_fail:
      proc_net_remove("sockstat6");
 proc_sockstat6_fail:
@@ -744,6 +752,7 @@
      proc_net_remove("udp6");
      proc_net_remove("sockstat6");
      proc_net_remove("snmp6");
+     proc_net_remove("anycast6");
 #endif
      /* Cleanup code parts. */
      sit_cleanup();
diff -ruN linux-2.5.44/net/ipv6/anycast.c linux-2.5.44AC/net/ipv6/anycast.c
--- linux-2.5.44/net/ipv6/anycast.c Wed Dec 31 16:00:00 1969
+++ linux-2.5.44AC/net/ipv6/anycast.c     Mon Oct 28 13:28:07 2002
@@ -0,0 +1,489 @@
+/*
+ *   Anycast support for IPv6
+ *   Linux INET6 implementation
+ *
+ *   Authors:
+ *   David L Stevens (dlstevens@us.ibm.com)
+ *
+ *   based heavily on net/ipv6/mcast.c
+ *
+ *   This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/random.h>
+#include <linux/string.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/sched.h>
+#include <linux/net.h>
+#include <linux/in6.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/route.h>
+#include <linux/init.h>
+#include <linux/proc_fs.h>
+
+#include <net/sock.h>
+#include <net/snmp.h>
+
+#include <net/ipv6.h>
+#include <net/protocol.h>
+#include <net/if_inet6.h>
+#include <net/ndisc.h>
+#include <net/addrconf.h>
+#include <net/ip6_route.h>
+
+#include <net/checksum.h>
+
+/* Big ac list lock for all the sockets */
+static rwlock_t ipv6_sk_ac_lock = RW_LOCK_UNLOCKED;
+
+/* XXX ip6_addr_match() and ip6_onlink() really belong in net/core.c */
+
+static int
+ip6_addr_match(struct in6_addr *addr1, struct in6_addr *addr2, int prefix)
+{
+     __u32 mask;
+     int   i;
+
+     if (prefix > 128 || prefix < 0)
+           return 0;
+     if (prefix == 0)
+           return 1;
+     for (i=0; i<4; ++i) {
+           if (prefix >= 32)
+                 mask = ~0;
+           else
+                 mask = htonl(~0 << (32 - prefix));
+           if ((addr1->s6_addr32[i] ^ addr2->s6_addr32[i]) & mask)
+                 return 0;
+           prefix -= 32;
+           if (prefix <= 0)
+                 break;
+     }
+     return 1;
+}
+
+static int
+ip6_onlink(struct in6_addr *addr, struct net_device *dev)
+{
+     struct inet6_dev  *idev;
+     struct inet6_ifaddr     *ifa;
+     int   onlink;
+
+     onlink = 0;
+     read_lock(&addrconf_lock);
+     idev = __in6_dev_get(dev);
+     if (idev) {
+           read_lock_bh(&idev->lock);
+           for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
+                 onlink = ip6_addr_match(addr, &ifa->addr,
+                             ifa->prefix_len);
+                 if (onlink)
+                       break;
+           }
+           read_unlock_bh(&idev->lock);
+     }
+     read_unlock(&addrconf_lock);
+     return onlink;
+}
+
+
+/*
+ *   socket join an anycast group
+ */
+
+int ipv6_sock_ac_join(struct sock *sk, int ifindex, struct in6_addr *addr)
+{
+     struct ipv6_pinfo *np = inet6_sk(sk);
+     struct net_device *dev = NULL;
+     struct inet6_dev *idev;
+     struct ipv6_ac_socklist *pac;
+     int   ishost = !ipv6_devconf.forwarding;
+     int   err = 0;
+
+     if (ipv6_addr_type(addr) & IPV6_ADDR_MULTICAST)
+           return -EINVAL;
+
+     pac = sock_kmalloc(sk, sizeof(struct ipv6_ac_socklist), GFP_KERNEL);
+     if (pac == NULL)
+           return -ENOMEM;
+     pac->acl_next = NULL;
+     ipv6_addr_copy(&pac->acl_addr, addr);
+
+     if (ifindex == 0) {
+           struct rt6_info *rt;
+
+           rt = rt6_lookup(addr, NULL, 0, 0);
+           if (rt) {
+                 dev = rt->rt6i_dev;
+                 dev_hold(dev);
+                 dst_release(&rt->u.dst);
+           } else if (ishost) {
+                 sock_kfree_s(sk, pac, sizeof(*pac));
+                 return -EADDRNOTAVAIL;
+           } else {
+                 /* router, no matching interface: just pick one */
+
+                 dev = dev_getany(IFF_UP, IFF_UP|IFF_LOOPBACK);
+           }
+     } else
+           dev = dev_get_by_index(ifindex);
+
+     if (dev == NULL) {
+           sock_kfree_s(sk, pac, sizeof(*pac));
+           return -ENODEV;
+     }
+
+     idev = in6_dev_get(dev);
+     if (!idev) {
+           sock_kfree_s(sk, pac, sizeof(*pac));
+           dev_put(dev);
+           if (ifindex)
+                 return -ENODEV;
+           else
+                 return -EADDRNOTAVAIL;
+     }
+     /* reset ishost, now that we have a specific device */
+     ishost = !idev->cnf.forwarding;
+     in6_dev_put(idev);
+
+     pac->acl_ifindex = dev->ifindex;
+
+     /* XXX
+      * For hosts, allow link-local or matching prefix anycasts.
+      * This obviates the need for propagating anycast routes while
+      * still allowing some non-router anycast participation.
+      *
+      * allow anyone to join anycasts that don't require a special route
+      * and can't be spoofs of unicast addresses (reserved anycast only)
+      */
+     if (!ip6_onlink(addr, dev)) {
+           if (ishost)
+                 err = -EADDRNOTAVAIL;
+           else if (!capable(CAP_NET_ADMIN))
+                 err = -EPERM;
+           if (err) {
+                 sock_kfree_s(sk, pac, sizeof(*pac));
+                 dev_put(dev);
+                 return err;
+           }
+     } else if (!(ipv6_addr_type(addr) & IPV6_ADDR_ANYCAST) &&
+              !capable(CAP_NET_ADMIN))
+           return -EPERM;
+
+     err = ipv6_dev_ac_inc(dev, addr);
+     if (err) {
+           sock_kfree_s(sk, pac, sizeof(*pac));
+           dev_put(dev);
+           return err;
+     }
+
+     write_lock_bh(&ipv6_sk_ac_lock);
+     pac->acl_next = np->ipv6_ac_list;
+     np->ipv6_ac_list = pac;
+     write_unlock_bh(&ipv6_sk_ac_lock);
+
+     dev_put(dev);
+
+     return 0;
+}
+
+/*
+ *   socket leave an anycast group
+ */
+int ipv6_sock_ac_drop(struct sock *sk, int ifindex, struct in6_addr *addr)
+{
+     struct ipv6_pinfo *np = inet6_sk(sk);
+     struct net_device *dev;
+     struct ipv6_ac_socklist *pac, *prev_pac;
+
+     write_lock_bh(&ipv6_sk_ac_lock);
+     prev_pac = 0;
+     for (pac = np->ipv6_ac_list; pac; pac = pac->acl_next) {
+           if ((ifindex == 0 || pac->acl_ifindex == ifindex) &&
+                ipv6_addr_cmp(&pac->acl_addr, addr) == 0)
+                 break;
+           prev_pac = pac;
+     }
+     if (!pac) {
+           write_unlock_bh(&ipv6_sk_ac_lock);
+           return -ENOENT;
+     }
+     if (prev_pac)
+           prev_pac->acl_next = pac->acl_next;
+     else
+           np->ipv6_ac_list = pac->acl_next;
+
+     write_unlock_bh(&ipv6_sk_ac_lock);
+
+     dev = dev_get_by_index(pac->acl_ifindex);
+     if (dev) {
+           ipv6_dev_ac_dec(dev, &pac->acl_addr);
+           dev_put(dev);
+     }
+     sock_kfree_s(sk, pac, sizeof(*pac));
+     return 0;
+}
+
+void ipv6_sock_ac_close(struct sock *sk)
+{
+     struct ipv6_pinfo *np = inet6_sk(sk);
+     struct net_device *dev = 0;
+     struct ipv6_ac_socklist *pac;
+     int   prev_index;
+
+     write_lock_bh(&ipv6_sk_ac_lock);
+     pac = np->ipv6_ac_list;
+     np->ipv6_ac_list = 0;
+     write_unlock_bh(&ipv6_sk_ac_lock);
+
+     prev_index = 0;
+     while (pac) {
+           struct ipv6_ac_socklist *next = pac->acl_next;
+
+           if (pac->acl_ifindex != prev_index) {
+                 if (dev)
+                       dev_put(dev);
+                 dev = dev_get_by_index(pac->acl_ifindex);
+                 prev_index = pac->acl_ifindex;
+           }
+           if (dev)
+                 ipv6_dev_ac_dec(dev, &pac->acl_addr);
+           sock_kfree_s(sk, pac, sizeof(*pac));
+           pac = next;
+     }
+     if (dev)
+           dev_put(dev);
+}
+
+int inet6_ac_check(struct sock *sk, struct in6_addr *addr, int ifindex)
+{
+     struct ipv6_ac_socklist *pac;
+     struct ipv6_pinfo *np = inet6_sk(sk);
+     int   found;
+
+     found = 0;
+     read_lock(&ipv6_sk_ac_lock);
+     for (pac=np->ipv6_ac_list; pac; pac=pac->acl_next) {
+           if (ifindex && pac->acl_ifindex != ifindex)
+                 continue;
+           found = ipv6_addr_cmp(&pac->acl_addr, addr) == 0;
+           if (found)
+                 break;
+     }
+     read_unlock(&ipv6_sk_ac_lock);
+
+     return found;
+}
+
+static void aca_put(struct ifacaddr6 *ac)
+{
+     if (atomic_dec_and_test(&ac->aca_refcnt)) {
+           in6_dev_put(ac->aca_idev);
+           kfree(ac);
+     }
+}
+
+/*
+ *   device anycast group inc (add if not found)
+ */
+int ipv6_dev_ac_inc(struct net_device *dev, struct in6_addr *addr)
+{
+     struct ifacaddr6 *aca;
+     struct inet6_dev *idev;
+
+     idev = in6_dev_get(dev);
+
+     if (idev == NULL)
+           return -EINVAL;
+
+     write_lock_bh(&idev->lock);
+     if (idev->dead) {
+           write_unlock_bh(&idev->lock);
+           in6_dev_put(idev);
+           return -ENODEV;
+     }
+
+     for (aca = idev->ac_list; aca; aca = aca->aca_next) {
+           if (ipv6_addr_cmp(&aca->aca_addr, addr) == 0) {
+                 aca->aca_users++;
+                 write_unlock_bh(&idev->lock);
+                 in6_dev_put(idev);
+                 return 0;
+           }
+     }
+
+     /*
+      *    not found: create a new one.
+      */
+
+     aca = kmalloc(sizeof(struct ifacaddr6), GFP_ATOMIC);
+
+     if (aca == NULL) {
+           write_unlock_bh(&idev->lock);
+           in6_dev_put(idev);
+           return -ENOMEM;
+     }
+
+     memset(aca, 0, sizeof(struct ifacaddr6));
+
+     ipv6_addr_copy(&aca->aca_addr, addr);
+     aca->aca_idev = idev;
+     aca->aca_users = 1;
+     atomic_set(&aca->aca_refcnt, 2);
+     aca->aca_lock = SPIN_LOCK_UNLOCKED;
+
+     aca->aca_next = idev->ac_list;
+     idev->ac_list = aca;
+     write_unlock_bh(&idev->lock);
+
+     ip6_rt_addr_add(&aca->aca_addr, dev);
+
+     addrconf_join_solict(dev, &aca->aca_addr);
+
+     aca_put(aca);
+     return 0;
+}
+
+/*
+ *   device anycast group decrement
+ */
+int ipv6_dev_ac_dec(struct net_device *dev, struct in6_addr *addr)
+{
+     struct inet6_dev *idev;
+     struct ifacaddr6 *aca, *prev_aca;
+
+     idev = in6_dev_get(dev);
+     if (idev == NULL)
+           return -ENODEV;
+
+     write_lock_bh(&idev->lock);
+     prev_aca = 0;
+     for (aca = idev->ac_list; aca; aca = aca->aca_next) {
+           if (ipv6_addr_cmp(&aca->aca_addr, addr) == 0)
+                 break;
+           prev_aca = aca;
+     }
+     if (!aca) {
+           write_unlock_bh(&idev->lock);
+           in6_dev_put(idev);
+           return -ENOENT;
+     }
+     if (--aca->aca_users > 0) {
+           write_unlock_bh(&idev->lock);
+           in6_dev_put(idev);
+           return 0;
+     }
+     if (prev_aca)
+           prev_aca->aca_next = aca->aca_next;
+     else
+           idev->ac_list = aca->aca_next;
+     write_unlock_bh(&idev->lock);
+     addrconf_leave_solict(dev, &aca->aca_addr);
+
+     ip6_rt_addr_del(&aca->aca_addr, dev);
+
+     aca_put(aca);
+     in6_dev_put(idev);
+     return 0;
+}
+
+/*
+ *   check if the interface has this anycast address
+ */
+static int ipv6_chk_acast_dev(struct net_device *dev, struct in6_addr *addr)
+{
+     struct inet6_dev *idev;
+     struct ifacaddr6 *aca;
+
+     idev = in6_dev_get(dev);
+     if (idev) {
+           read_lock_bh(&idev->lock);
+           for (aca = idev->ac_list; aca; aca = aca->aca_next)
+                 if (ipv6_addr_cmp(&aca->aca_addr, addr) == 0)
+                       break;
+           read_unlock_bh(&idev->lock);
+           in6_dev_put(idev);
+           return aca != 0;
+     }
+     return 0;
+}
+
+/*

+ *   check if given interface (or any, if dev==0) has this anycast address
+ */
+int ipv6_chk_acast_addr(struct net_device *dev, struct in6_addr *addr)
+{
+     if (dev)
+           return ipv6_chk_acast_dev(dev, addr);
+     read_lock(&dev_base_lock);
+     for (dev=dev_base; dev; dev=dev->next)
+           if (ipv6_chk_acast_dev(dev, addr))
+                 break;
+     read_unlock(&dev_base_lock);
+     return dev != 0;
+}
+
+
+#ifdef CONFIG_PROC_FS
+int anycast6_get_info(char *buffer, char **start, off_t offset, int length)
+{
+     off_t pos=0, begin=0;
+     struct ifacaddr6 *im;
+     int len=0;
+     struct net_device *dev;
+
+     read_lock(&dev_base_lock);
+     for (dev = dev_base; dev; dev = dev->next) {
+           struct inet6_dev *idev;
+
+           if ((idev = in6_dev_get(dev)) == NULL)
+                 continue;
+
+           read_lock_bh(&idev->lock);
+           for (im = idev->ac_list; im; im = im->aca_next) {
+                 int i;
+
+                 len += sprintf(buffer+len,"%-4d %-15s ", dev->ifindex, dev->name);
+
+                 for (i=0; i<16; i++)
+                       len += sprintf(buffer+len, "%02x", im->aca_addr.s6_addr[i]);
+
+                 len += sprintf(buffer+len, " %5d\n", im->aca_users);
+
+                 pos=begin+len;
+                 if (pos < offset) {
+                       len=0;
+                       begin=pos;
+                 }
+                 if (pos > offset+length) {
+                       read_unlock_bh(&idev->lock);
+                       in6_dev_put(idev);
+                       goto done;
+                 }
+           }
+           read_unlock_bh(&idev->lock);
+           in6_dev_put(idev);
+     }
+
+done:
+     read_unlock(&dev_base_lock);
+
+     *start=buffer+(offset-begin);
+     len-=(offset-begin);
+     if(len>length)
+           len=length;
+     if (len<0)
+           len=0;
+     return len;
+}
+
+#endif
diff -ruN linux-2.5.44/net/ipv6/icmp.c linux-2.5.44AC/net/ipv6/icmp.c
--- linux-2.5.44/net/ipv6/icmp.c    Fri Oct 18 21:01:20 2002
+++ linux-2.5.44AC/net/ipv6/icmp.c  Mon Oct 28 12:38:09 2002
@@ -388,7 +388,8 @@

      saddr = &skb->nh.ipv6h->daddr;

-     if (ipv6_addr_type(saddr) & IPV6_ADDR_MULTICAST)
+     if (ipv6_addr_type(saddr) & IPV6_ADDR_MULTICAST ||
+         ipv6_chk_acast_addr(0, saddr))
            saddr = NULL;

      msg.icmph.icmp6_type = ICMPV6_ECHO_REPLY;
diff -ruN linux-2.5.44/net/ipv6/ipv6_sockglue.c linux-2.5.44AC/net/ipv6/ipv6_sockglue.c
--- linux-2.5.44/net/ipv6/ipv6_sockglue.c Fri Oct 18 21:01:09 2002
+++ linux-2.5.44AC/net/ipv6/ipv6_sockglue.c     Mon Oct 28 12:38:09 2002
@@ -351,6 +351,24 @@
                  retv = ipv6_sock_mc_drop(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_multiaddr);
            break;
      }
+     case IPV6_JOIN_ANYCAST:
+     case IPV6_LEAVE_ANYCAST:
+     {
+           struct ipv6_mreq mreq;
+
+           if (optlen != sizeof(struct ipv6_mreq))
+                 goto e_inval;
+
+           retv = -EFAULT;
+           if (copy_from_user(&mreq, optval, sizeof(struct ipv6_mreq)))
+                 break;
+
+           if (optname == IPV6_JOIN_ANYCAST)
+                 retv = ipv6_sock_ac_join(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_acaddr);
+           else
+                 retv = ipv6_sock_ac_drop(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_acaddr);
+           break;
+     }
      case IPV6_ROUTER_ALERT:
            retv = ip6_ra_control(sk, val, NULL);
            break;
diff -ruN linux-2.5.44/net/ipv6/ndisc.c linux-2.5.44AC/net/ipv6/ndisc.c
--- linux-2.5.44/net/ipv6/ndisc.c   Fri Oct 18 21:01:59 2002
+++ linux-2.5.44AC/net/ipv6/ndisc.c Mon Oct 28 13:12:27 2002
@@ -378,7 +378,10 @@
               struct in6_addr *daddr, struct in6_addr *solicited_addr,
               int router, int solicited, int override, int inc_opt)
 {
+     static struct in6_addr tmpaddr;
+     struct inet6_ifaddr *ifp;
         struct sock *sk = ndisc_socket->sk;
+     struct in6_addr *src_addr;
         struct nd_msg *msg;
         int len;
         struct sk_buff *skb;
@@ -400,13 +403,23 @@
            ND_PRINTK1("send_na: alloc skb failed\n");
            return;
      }
+     /* for anycast or proxy, solicited_addr != src_addr */
+     ifp = ipv6_get_ifaddr(solicited_addr, dev);
+     if (ifp) {
+           src_addr = solicited_addr;
+           in6_ifa_put(ifp);
+     } else {
+           if (ipv6_dev_get_saddr(dev, daddr, &tmpaddr, 0))
+                 return;
+           src_addr = &tmpaddr;
+     }

      if (ndisc_build_ll_hdr(skb, dev, daddr, neigh, len) == 0) {
            kfree_skb(skb);
            return;
      }

-     ip6_nd_hdr(sk, skb, dev, solicited_addr, daddr, IPPROTO_ICMPV6, len);
+     ip6_nd_hdr(sk, skb, dev, src_addr, daddr, IPPROTO_ICMPV6, len);

      msg = (struct nd_msg *) skb_put(skb, len);

@@ -426,7 +439,7 @@
            ndisc_fill_option(msg->opt, ND_OPT_TARGET_LL_ADDR, dev->dev_addr, dev->addr_len);

      /* checksum */
-     msg->icmph.icmp6_cksum = csum_ipv6_magic(solicited_addr, daddr, len,
+     msg->icmph.icmp6_cksum = csum_ipv6_magic(src_addr, daddr, len,
                                     IPPROTO_ICMPV6,
                                     csum_partial((__u8 *) msg,
                                                len, 0));
@@ -1133,6 +1146,51 @@
                        }
                  }
                  in6_ifa_put(ifp);
+           } else if (ipv6_chk_acast_addr(dev, &msg->target)) {
+                 struct inet6_dev *idev = in6_dev_get(dev);
+                 int addr_type = ipv6_addr_type(saddr);
+
+                 /* anycast */
+
+                 if (!idev) {
+                       /* XXX: count this drop? */
+                       return 0;
+                 }
+
+                 if (addr_type == IPV6_ADDR_ANY) {
+                       struct in6_addr maddr;
+
+                       ipv6_addr_all_nodes(&maddr);
+                       ndisc_send_na(dev, NULL, &maddr, &msg->target,
+                                   idev->cnf.forwarding, 0, 0, 1);
+                       in6_dev_put(idev);
+                       return 0;
+                 }
+
+                 if (addr_type & IPV6_ADDR_UNICAST) {
+                       int inc = ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
+                       if (inc)
+                             nd_tbl.stats.rcv_probes_mcast++;
+                       else
+                             nd_tbl.stats.rcv_probes_ucast++;
+
+                       /*
+                        *   update / create cache entry
+                        *   for the source adddress
+                        */
+
+                       neigh = neigh_event_ns(&nd_tbl, lladdr, saddr, skb->dev);
+
+                       if (neigh || !dev->hard_header) {
+                             ndisc_send_na(dev, neigh, saddr,
+                                   &msg->target,
+                                     idev->cnf.forwarding, 1, 0, inc);
+                             if (neigh)
+                                   neigh_release(neigh);
+                       }
+                 }
+                 in6_dev_put(idev);
+
            } else {
                  struct inet6_dev *in6_dev = in6_dev_get(dev);
                  int addr_type = ipv6_addr_type(saddr);
diff -ruN linux-2.5.44/net/netsyms.c linux-2.5.44AC/net/netsyms.c
--- linux-2.5.44/net/netsyms.c      Fri Oct 18 21:01:49 2002
+++ linux-2.5.44AC/net/netsyms.c    Mon Oct 28 12:38:09 2002
@@ -469,6 +469,8 @@
 EXPORT_SYMBOL(unregister_netdevice);
 EXPORT_SYMBOL(netdev_state_change);
 EXPORT_SYMBOL(dev_new_index);
+EXPORT_SYMBOL(dev_getany);
+EXPORT_SYMBOL(__dev_getany);
 EXPORT_SYMBOL(dev_get_by_index);
 EXPORT_SYMBOL(__dev_get_by_index);
 EXPORT_SYMBOL(dev_get_by_name);

(See attached file: anycast-2.5.44.patch)

--0__=07BBE6F3DFE120F28f9e8a93df938690918c07BBE6F3DFE120F2
Content-type: application/octet-stream;
	name="anycast-2.5.44.patch"
Content-Disposition: attachment; filename="anycast-2.5.44.patch"
Content-transfer-encoding: base64

ZGlmZiAtcnVOIGxpbnV4LTIuNS40NC9pbmNsdWRlL2xpbnV4L2luNi5oIGxp
bnV4LTIuNS40NEFDL2luY2x1ZGUvbGludXgvaW42LmgKLS0tIGxpbnV4LTIu
NS40NC9pbmNsdWRlL2xpbnV4L2luNi5oCUZyaSBPY3QgMTggMjE6MDE6NTkg
MjAwMgorKysgbGludXgtMi41LjQ0QUMvaW5jbHVkZS9saW51eC9pbjYuaAlN
b24gT2N0IDI4IDEyOjM4OjA5IDIwMDIKQEAgLTU2LDYgKzU2LDggQEAKIAlp
bnQJCWlwdjZtcl9pZmluZGV4OwogfTsKIAorI2RlZmluZSBpcHY2bXJfYWNh
ZGRyCWlwdjZtcl9tdWx0aWFkZHIKKwogc3RydWN0IGluNl9mbG93bGFiZWxf
cmVxCiB7CiAJc3RydWN0IGluNl9hZGRyCWZscl9kc3Q7CkBAIC0xNTYsNiAr
MTU4LDkgQEAKICNkZWZpbmUgSVBWNl9NVFVfRElTQ09WRVIJMjMKICNkZWZp
bmUgSVBWNl9NVFUJCTI0CiAjZGVmaW5lIElQVjZfUkVDVkVSUgkJMjUKKy8q
IDI2IGlzIElQVjZfVjZPTkxZIGluIFVTQUdJIGNvZGUgKi8KKyNkZWZpbmUg
SVBWNl9KT0lOX0FOWUNBU1QJMjcKKyNkZWZpbmUgSVBWNl9MRUFWRV9BTllD
QVNUCTI4CiAKIC8qIElQVjZfTVRVX0RJU0NPVkVSIHZhbHVlcyAqLwogI2Rl
ZmluZSBJUFY2X1BNVFVESVNDX0RPTlQJCTAKZGlmZiAtcnVOIGxpbnV4LTIu
NS40NC9pbmNsdWRlL2xpbnV4L2lwdjYuaCBsaW51eC0yLjUuNDRBQy9pbmNs
dWRlL2xpbnV4L2lwdjYuaAotLS0gbGludXgtMi41LjQ0L2luY2x1ZGUvbGlu
dXgvaXB2Ni5oCUZyaSBPY3QgMTggMjE6MDI6MjYgMjAwMgorKysgbGludXgt
Mi41LjQ0QUMvaW5jbHVkZS9saW51eC9pcHY2LmgJTW9uIE9jdCAyOCAxMjoz
ODowOSAyMDAyCkBAIC0xNTUsNiArMTU1LDcgQEAKIAkgICAgICAgICAgICAg
ICAgICAgICAgICBwbXR1ZGlzYzoyOwogCiAJc3RydWN0IGlwdjZfbWNfc29j
a2xpc3QJKmlwdjZfbWNfbGlzdDsKKwlzdHJ1Y3QgaXB2Nl9hY19zb2NrbGlz
dAkqaXB2Nl9hY19saXN0OwogCXN0cnVjdCBpcHY2X2ZsX3NvY2tsaXN0ICpp
cHY2X2ZsX2xpc3Q7CiAJX191MzIJCQlkc3RfY29va2llOwogCmRpZmYgLXJ1
TiBsaW51eC0yLjUuNDQvaW5jbHVkZS9saW51eC9uZXRkZXZpY2UuaCBsaW51
eC0yLjUuNDRBQy9pbmNsdWRlL2xpbnV4L25ldGRldmljZS5oCi0tLSBsaW51
eC0yLjUuNDQvaW5jbHVkZS9saW51eC9uZXRkZXZpY2UuaAlGcmkgT2N0IDE4
IDIxOjAyOjMxIDIwMDIKKysrIGxpbnV4LTIuNS40NEFDL2luY2x1ZGUvbGlu
dXgvbmV0ZGV2aWNlLmgJTW9uIE9jdCAyOCAxMjozODowOSAyMDAyCkBAIC00
NjQsNiArNDY0LDEwIEBACiBleHRlcm4gdm9pZAkJZGV2X2FkZF9wYWNrKHN0
cnVjdCBwYWNrZXRfdHlwZSAqcHQpOwogZXh0ZXJuIHZvaWQJCWRldl9yZW1v
dmVfcGFjayhzdHJ1Y3QgcGFja2V0X3R5cGUgKnB0KTsKIGV4dGVybiBpbnQJ
CWRldl9nZXQoY29uc3QgY2hhciAqbmFtZSk7CitleHRlcm4gc3RydWN0IG5l
dF9kZXZpY2UJKmRldl9nZXRhbnkodW5zaWduZWQgc2hvcnQgZmxhZ3MsCisJ
CQkJCXVuc2lnbmVkIHNob3J0IG1hc2spOworZXh0ZXJuIHN0cnVjdCBuZXRf
ZGV2aWNlCSpfX2Rldl9nZXRhbnkodW5zaWduZWQgc2hvcnQgZmxhZ3MsCisJ
CQkJCXVuc2lnbmVkIHNob3J0IG1hc2spOwogZXh0ZXJuIHN0cnVjdCBuZXRf
ZGV2aWNlCSpkZXZfZ2V0X2J5X25hbWUoY29uc3QgY2hhciAqbmFtZSk7CiBl
eHRlcm4gc3RydWN0IG5ldF9kZXZpY2UJKl9fZGV2X2dldF9ieV9uYW1lKGNv
bnN0IGNoYXIgKm5hbWUpOwogZXh0ZXJuIHN0cnVjdCBuZXRfZGV2aWNlCSpk
ZXZfYWxsb2MoY29uc3QgY2hhciAqbmFtZSwgaW50ICplcnIpOwpkaWZmIC1y
dU4gbGludXgtMi41LjQ0L2luY2x1ZGUvbmV0L2FkZHJjb25mLmggbGludXgt
Mi41LjQ0QUMvaW5jbHVkZS9uZXQvYWRkcmNvbmYuaAotLS0gbGludXgtMi41
LjQ0L2luY2x1ZGUvbmV0L2FkZHJjb25mLmgJRnJpIE9jdCAxOCAyMTowMTox
OCAyMDAyCisrKyBsaW51eC0yLjUuNDRBQy9pbmNsdWRlL25ldC9hZGRyY29u
Zi5oCU1vbiBPY3QgMjggMTI6Mzg6MDkgMjAwMgpAQCAtNTgsNyArNTgsMTUg
QEAKIGV4dGVybiBpbnQJCQlpcHY2X2dldF9zYWRkcihzdHJ1Y3QgZHN0X2Vu
dHJ5ICpkc3QsIAogCQkJCQkgICAgICAgc3RydWN0IGluNl9hZGRyICpkYWRk
ciwKIAkJCQkJICAgICAgIHN0cnVjdCBpbjZfYWRkciAqc2FkZHIpOworZXh0
ZXJuIGludAkJCWlwdjZfZGV2X2dldF9zYWRkcihzdHJ1Y3QgbmV0X2Rldmlj
ZSAqZGV2LCAKKwkJCQkJICAgICAgIHN0cnVjdCBpbjZfYWRkciAqZGFkZHIs
CisJCQkJCSAgICAgICBzdHJ1Y3QgaW42X2FkZHIgKnNhZGRyLAorCQkJCQkg
ICAgICAgaW50IG9ubGluayk7CiBleHRlcm4gaW50CQkJaXB2Nl9nZXRfbGxh
ZGRyKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYsIHN0cnVjdCBpbjZfYWRkciAq
KTsKK2V4dGVybiB2b2lkCQkJYWRkcmNvbmZfam9pbl9zb2xpY3Qoc3RydWN0
IG5ldF9kZXZpY2UgKmRldiwKKwkJCQkJc3RydWN0IGluNl9hZGRyICphZGRy
KTsKK2V4dGVybiB2b2lkCQkJYWRkcmNvbmZfbGVhdmVfc29saWN0KHN0cnVj
dCBuZXRfZGV2aWNlICpkZXYsCisJCQkJCXN0cnVjdCBpbjZfYWRkciAqYWRk
cik7CiAKIC8qCiAgKgltdWx0aWNhc3QgcHJvdG90eXBlcyAobWNhc3QuYykK
QEAgLTg4LDYgKzk2LDI2IEBACiBleHRlcm4gdm9pZAkJCWFkZHJjb25mX3By
ZWZpeF9yY3Yoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKIAkJCQkJCSAgICB1
OCAqb3B0LCBpbnQgbGVuKTsKIAorLyoKKyAqCWFueWNhc3QgcHJvdG90eXBl
cyAoYW55Y2FzdC5jKQorICovCitleHRlcm4gaW50CQkJaXB2Nl9zb2NrX2Fj
X2pvaW4oc3RydWN0IHNvY2sgKnNrLCAKKwkJCQkJCSAgaW50IGlmaW5kZXgs
IAorCQkJCQkJICBzdHJ1Y3QgaW42X2FkZHIgKmFkZHIpOworZXh0ZXJuIGlu
dAkJCWlwdjZfc29ja19hY19kcm9wKHN0cnVjdCBzb2NrICpzaywKKwkJCQkJ
CSAgaW50IGlmaW5kZXgsIAorCQkJCQkJICBzdHJ1Y3QgaW42X2FkZHIgKmFk
ZHIpOworZXh0ZXJuIHZvaWQJCQlpcHY2X3NvY2tfYWNfY2xvc2Uoc3RydWN0
IHNvY2sgKnNrKTsKK2V4dGVybiBpbnQJCQlpbmV0Nl9hY19jaGVjayhzdHJ1
Y3Qgc29jayAqc2ssIHN0cnVjdCBpbjZfYWRkciAqYWRkciwgaW50IGlmaW5k
ZXgpOworCitleHRlcm4gaW50CQkJaXB2Nl9kZXZfYWNfaW5jKHN0cnVjdCBu
ZXRfZGV2aWNlICpkZXYsCisJCQkJCQlzdHJ1Y3QgaW42X2FkZHIgKmFkZHIp
OworZXh0ZXJuIGludAkJCWlwdjZfZGV2X2FjX2RlYyhzdHJ1Y3QgbmV0X2Rl
dmljZSAqZGV2LAorCQkJCQkJc3RydWN0IGluNl9hZGRyICphZGRyKTsKK2V4
dGVybiBpbnQJCQlpcHY2X2Noa19hY2FzdF9hZGRyKHN0cnVjdCBuZXRfZGV2
aWNlICpkZXYsCisJCQkJCQlzdHJ1Y3QgaW42X2FkZHIgKmFkZHIpOworCisK
IC8qIERldmljZSBub3RpZmllciAqLwogZXh0ZXJuIGludCByZWdpc3Rlcl9p
bmV0NmFkZHJfbm90aWZpZXIoc3RydWN0IG5vdGlmaWVyX2Jsb2NrICpuYik7
CiBleHRlcm4gaW50IHVucmVnaXN0ZXJfaW5ldDZhZGRyX25vdGlmaWVyKHN0
cnVjdCBub3RpZmllcl9ibG9jayAqbmIpOwpkaWZmIC1ydU4gbGludXgtMi41
LjQ0L2luY2x1ZGUvbmV0L2lmX2luZXQ2LmggbGludXgtMi41LjQ0QUMvaW5j
bHVkZS9uZXQvaWZfaW5ldDYuaAotLS0gbGludXgtMi41LjQ0L2luY2x1ZGUv
bmV0L2lmX2luZXQ2LmgJRnJpIE9jdCAxOCAyMTowMjozNCAyMDAyCisrKyBs
aW51eC0yLjUuNDRBQy9pbmNsdWRlL25ldC9pZl9pbmV0Ni5oCU1vbiBPY3Qg
MjggMTI6Mzg6MDkgMjAwMgpAQCAtNjksNiArNjksMjUgQEAKIAlzcGlubG9j
a190CQltY2FfbG9jazsKIH07CiAKKy8qIEFueWNhc3Qgc3R1ZmYgKi8KKwor
c3RydWN0IGlwdjZfYWNfc29ja2xpc3QKK3sKKwlzdHJ1Y3QgaW42X2FkZHIJ
CWFjbF9hZGRyOworCWludAkJCWFjbF9pZmluZGV4OworCXN0cnVjdCBpcHY2
X2FjX3NvY2tsaXN0ICphY2xfbmV4dDsKK307CisKK3N0cnVjdCBpZmFjYWRk
cjYKK3sKKwlzdHJ1Y3QgaW42X2FkZHIJCWFjYV9hZGRyOworCXN0cnVjdCBp
bmV0Nl9kZXYJKmFjYV9pZGV2OworCXN0cnVjdCBpZmFjYWRkcjYJKmFjYV9u
ZXh0OworCWludAkJCWFjYV91c2VyczsKKwlhdG9taWNfdAkJYWNhX3JlZmNu
dDsKKwlzcGlubG9ja190CQlhY2FfbG9jazsKK307CisKICNkZWZpbmUJSUZB
X0hPU1QJSVBWNl9BRERSX0xPT1BCQUNLCiAjZGVmaW5lCUlGQV9MSU5LCUlQ
VjZfQUREUl9MSU5LTE9DQUwKICNkZWZpbmUJSUZBX1NJVEUJSVBWNl9BRERS
X1NJVEVMT0NBTApAQCAtOTYsNiArMTE1LDcgQEAKIAogCXN0cnVjdCBpbmV0
Nl9pZmFkZHIJKmFkZHJfbGlzdDsKIAlzdHJ1Y3QgaWZtY2FkZHI2CSptY19s
aXN0OworCXN0cnVjdCBpZmFjYWRkcjYJKmFjX2xpc3Q7CiAJcndsb2NrX3QJ
CWxvY2s7CiAJYXRvbWljX3QJCXJlZmNudDsKIAlfX3UzMgkJCWlmX2ZsYWdz
OwpkaWZmIC1ydU4gbGludXgtMi41LjQ0L25ldC9jb3JlL2Rldi5jIGxpbnV4
LTIuNS40NEFDL25ldC9jb3JlL2Rldi5jCi0tLSBsaW51eC0yLjUuNDQvbmV0
L2NvcmUvZGV2LmMJRnJpIE9jdCAxOCAyMTowMTo1NCAyMDAyCisrKyBsaW51
eC0yLjUuNDRBQy9uZXQvY29yZS9kZXYuYwlNb24gT2N0IDI4IDEyOjM4OjA5
IDIwMDIKQEAgLTU0MSw2ICs1NDEsNTAgQEAKIH0KIAogLyoqCisgKglkZXZf
Z2V0YW55IC0gZmluZCBhbnkgZGV2aWNlIHdpdGggZ2l2ZW4gZmxhZ3MKKyAq
CUBpZl9mbGFnczogSUZGXyogdmFsdWVzCisgKglAbWFzazogYml0bWFzayBv
ZiBiaXRzIGluIGlmX2ZsYWdzIHRvIGNoZWNrCisgKgorICoJU2VhcmNoIGZv
ciBhbnkgaW50ZXJmYWNlIHdpdGggdGhlIGdpdmVuIGZsYWdzLiBSZXR1cm5z
IE5VTEwgaWYgYSBkZXZpY2UKKyAqCWlzIG5vdCBmb3VuZCBvciBhIHBvaW50
ZXIgdG8gdGhlIGRldmljZS4gVGhlIGRldmljZSByZXR1cm5lZCBoYXMgCisg
KgloYWQgYSByZWZlcmVuY2UgYWRkZWQgYW5kIHRoZSBwb2ludGVyIGlzIHNh
ZmUgdW50aWwgdGhlIHVzZXIgY2FsbHMKKyAqCWRldl9wdXQgdG8gaW5kaWNh
dGUgdGhleSBoYXZlIGZpbmlzaGVkIHdpdGggaXQuCisgKi8KKworc3RydWN0
IG5ldF9kZXZpY2UgKiBkZXZfZ2V0YW55KHVuc2lnbmVkIHNob3J0IGlmX2Zs
YWdzLCB1bnNpZ25lZCBzaG9ydCBtYXNrKQoreworCXN0cnVjdCBuZXRfZGV2
aWNlICpkZXY7CisKKwlyZWFkX2xvY2soJmRldl9iYXNlX2xvY2spOworCWRl
diA9IF9fZGV2X2dldGFueShpZl9mbGFncywgbWFzayk7CisJaWYgKGRldikK
KwkJZGV2X2hvbGQoZGV2KTsKKwlyZWFkX3VubG9jaygmZGV2X2Jhc2VfbG9j
ayk7CisJcmV0dXJuIGRldjsKK30KKworLyoqCisgKglfX2Rldl9nZXRhbnkg
LSBmaW5kIGFueSBkZXZpY2Ugd2l0aCBnaXZlbiBmbGFncworICoJQGlmX2Zs
YWdzOiBJRkZfKiB2YWx1ZXMKKyAqCUBtYXNrOiBiaXRtYXNrIG9mIGJpdHMg
aW4gaWZfZmxhZ3MgdG8gY2hlY2sKKyAqCisgKglTZWFyY2ggZm9yIGFueSBp
bnRlcmZhY2Ugd2l0aCB0aGUgZ2l2ZW4gZmxhZ3MuIFJldHVybnMgTlVMTCBp
ZiBhIGRldmljZQorICoJaXMgbm90IGZvdW5kIG9yIGEgcG9pbnRlciB0byB0
aGUgZGV2aWNlLiBUaGUgY2FsbGVyIG11c3QgaG9sZCBlaXRoZXIKKyAqCXRo
ZSBSVE5MIHNlbWFwaG9yZSBvciBAZGV2X2Jhc2VfbG9jay4KKyAqLworCitz
dHJ1Y3QgbmV0X2RldmljZSAqX19kZXZfZ2V0YW55KHVuc2lnbmVkIHNob3J0
IGlmX2ZsYWdzLCB1bnNpZ25lZCBzaG9ydCBtYXNrKQoreworCXN0cnVjdCBu
ZXRfZGV2aWNlICpkZXY7CisKKwlmb3IgKGRldiA9IGRldl9iYXNlOyBkZXYg
IT0gTlVMTDsgZGV2ID0gZGV2LT5uZXh0KSB7CisJCWlmICgoKGRldi0+Zmxh
Z3MgXiBpZl9mbGFncykgJiBtYXNrKSA9PSAwKQorCQkJcmV0dXJuIGRldjsK
Kwl9CisJcmV0dXJuIE5VTEw7Cit9CisKKy8qKgogICoJZGV2X2FsbG9jX25h
bWUgLSBhbGxvY2F0ZSBhIG5hbWUgZm9yIGEgZGV2aWNlCiAgKglAZGV2OiBk
ZXZpY2UKICAqCUBuYW1lOiBuYW1lIGZvcm1hdCBzdHJpbmcKZGlmZiAtcnVO
IGxpbnV4LTIuNS40NC9uZXQvaXB2Ni9NYWtlZmlsZSBsaW51eC0yLjUuNDRB
Qy9uZXQvaXB2Ni9NYWtlZmlsZQotLS0gbGludXgtMi41LjQ0L25ldC9pcHY2
L01ha2VmaWxlCUZyaSBPY3QgMTggMjE6MDI6MjcgMjAwMgorKysgbGludXgt
Mi41LjQ0QUMvbmV0L2lwdjYvTWFrZWZpbGUJTW9uIE9jdCAyOCAxMjozODow
OSAyMDAyCkBAIC02LDcgKzYsNyBAQAogCiBvYmotJChDT05GSUdfSVBWNikg
Kz0gaXB2Ni5vCiAKLWlwdjYtb2JqcyA6PQlhZl9pbmV0Ni5vIGlwNl9vdXRw
dXQubyBpcDZfaW5wdXQubyBhZGRyY29uZi5vIHNpdC5vIFwKK2lwdjYtb2Jq
cyA6PQlhZl9pbmV0Ni5vIGFueWNhc3QubyBpcDZfb3V0cHV0Lm8gaXA2X2lu
cHV0Lm8gYWRkcmNvbmYubyBzaXQubyBcCiAJCXJvdXRlLm8gaXA2X2ZpYi5v
IGlwdjZfc29ja2dsdWUubyBuZGlzYy5vIHVkcC5vIHJhdy5vIFwKIAkJcHJv
dG9jb2wubyBpY21wLm8gbWNhc3QubyByZWFzc2VtYmx5Lm8gdGNwX2lwdjYu
byBcCiAJCWV4dGhkcnMubyBzeXNjdGxfbmV0X2lwdjYubyBkYXRhZ3JhbS5v
IHByb2MubyBcCmRpZmYgLXJ1TiBsaW51eC0yLjUuNDQvbmV0L2lwdjYvYWRk
cmNvbmYuYyBsaW51eC0yLjUuNDRBQy9uZXQvaXB2Ni9hZGRyY29uZi5jCi0t
LSBsaW51eC0yLjUuNDQvbmV0L2lwdjYvYWRkcmNvbmYuYwlGcmkgT2N0IDE4
IDIxOjAyOjMxIDIwMDIKKysrIGxpbnV4LTIuNS40NEFDL25ldC9pcHY2L2Fk
ZHJjb25mLmMJTW9uIE9jdCAyOCAxMjo0OTowMyAyMDAyCkBAIC0xMzcsMjEg
KzEzNywxNSBAQAogCiBpbnQgaXB2Nl9hZGRyX3R5cGUoc3RydWN0IGluNl9h
ZGRyICphZGRyKQogeworCWludCB0eXBlOwogCXUzMiBzdDsKIAogCXN0ID0g
YWRkci0+czZfYWRkcjMyWzBdOwogCi0JLyogQ29uc2lkZXIgYWxsIGFkZHJl
c3NlcyB3aXRoIHRoZSBmaXJzdCB0aHJlZSBiaXRzIGRpZmZlcmVudCBvZgot
CSAgIDAwMCBhbmQgMTExIGFzIHVuaWNhc3RzLgotCSAqLwotCWlmICgoc3Qg
JiBodG9ubCgweEUwMDAwMDAwKSkgIT0gaHRvbmwoMHgwMDAwMDAwMCkgJiYK
LQkgICAgKHN0ICYgaHRvbmwoMHhFMDAwMDAwMCkpICE9IGh0b25sKDB4RTAw
MDAwMDApKQotCQlyZXR1cm4gSVBWNl9BRERSX1VOSUNBU1Q7Ci0KLQlpZiAo
KHN0ICYgaHRvbmwoMHhGRjAwMDAwMCkpID09IGh0b25sKDB4RkYwMDAwMDAp
KSB7Ci0JCWludCB0eXBlID0gSVBWNl9BRERSX01VTFRJQ0FTVDsKKwlpZiAo
KHN0ICYgX19jb25zdGFudF9odG9ubCgweEZGMDAwMDAwKSkgPT0gX19jb25z
dGFudF9odG9ubCgweEZGMDAwMDAwKSkgeworCQl0eXBlID0gSVBWNl9BRERS
X01VTFRJQ0FTVDsKIAotCQlzd2l0Y2goKHN0ICYgaHRvbmwoMHgwMEZGMDAw
MCkpKSB7CisJCXN3aXRjaCgoc3QgJiBfX2NvbnN0YW50X2h0b25sKDB4MDBG
RjAwMDApKSkgewogCQkJY2FzZSBfX2NvbnN0YW50X2h0b25sKDB4MDAwMTAw
MDApOgogCQkJCXR5cGUgfD0gSVBWNl9BRERSX0xPT1BCQUNLOwogCQkJCWJy
ZWFrOwpAQCAtMTY2LDI5ICsxNjAsNTMgQEAKIAkJfTsKIAkJcmV0dXJuIHR5
cGU7CiAJfQorCS8qIGNoZWNrIGZvciByZXNlcnZlZCBhbnljYXN0IGFkZHJl
c3NlcyAqLworCQorCWlmICgoc3QgJiBfX2NvbnN0YW50X2h0b25sKDB4RTAw
MDAwMDApKSAmJgorCSAgICAoKGFkZHItPnM2X2FkZHIzMlsyXSA9PSBfX2Nv
bnN0YW50X2h0b25sKDB4RkRGRkZGRkYpICYmCisJICAgIChhZGRyLT5zNl9h
ZGRyMzJbM10gfCBfX2NvbnN0YW50X2h0b25sKDB4N0YpKSA9PSAodTMyKX4w
KSB8fAorCSAgICAoYWRkci0+czZfYWRkcjMyWzJdID09IDAgJiYgYWRkci0+
czZfYWRkcjMyWzNdID09IDApKSkKKwkJdHlwZSA9IElQVjZfQUREUl9BTllD
QVNUOworCWVsc2UKKwkJdHlwZSA9IElQVjZfQUREUl9VTklDQVNUOworCisJ
LyogQ29uc2lkZXIgYWxsIGFkZHJlc3NlcyB3aXRoIHRoZSBmaXJzdCB0aHJl
ZSBiaXRzIGRpZmZlcmVudCBvZgorCSAgIDAwMCBhbmQgMTExIGFzIGZpbmlz
aGVkLgorCSAqLworCWlmICgoc3QgJiBfX2NvbnN0YW50X2h0b25sKDB4RTAw
MDAwMDApKSAhPSBfX2NvbnN0YW50X2h0b25sKDB4MDAwMDAwMDApICYmCisJ
ICAgIChzdCAmIF9fY29uc3RhbnRfaHRvbmwoMHhFMDAwMDAwMCkpICE9IF9f
Y29uc3RhbnRfaHRvbmwoMHhFMDAwMDAwMCkpCisJCXJldHVybiB0eXBlOwog
CQotCWlmICgoc3QgJiBodG9ubCgweEZGQzAwMDAwKSkgPT0gaHRvbmwoMHhG
RTgwMDAwMCkpCi0JCXJldHVybiAoSVBWNl9BRERSX0xJTktMT0NBTCB8IElQ
VjZfQUREUl9VTklDQVNUKTsKKwlpZiAoKHN0ICYgX19jb25zdGFudF9odG9u
bCgweEZGQzAwMDAwKSkgPT0gX19jb25zdGFudF9odG9ubCgweEZFODAwMDAw
KSkKKwkJcmV0dXJuIChJUFY2X0FERFJfTElOS0xPQ0FMIHwgdHlwZSk7CiAK
LQlpZiAoKHN0ICYgaHRvbmwoMHhGRkMwMDAwMCkpID09IGh0b25sKDB4RkVD
MDAwMDApKQotCQlyZXR1cm4gKElQVjZfQUREUl9TSVRFTE9DQUwgfCBJUFY2
X0FERFJfVU5JQ0FTVCk7CisJaWYgKChzdCAmIF9fY29uc3RhbnRfaHRvbmwo
MHhGRkMwMDAwMCkpID09IF9fY29uc3RhbnRfaHRvbmwoMHhGRUMwMDAwMCkp
CisJCXJldHVybiAoSVBWNl9BRERSX1NJVEVMT0NBTCB8IHR5cGUpOwogCiAJ
aWYgKChhZGRyLT5zNl9hZGRyMzJbMF0gfCBhZGRyLT5zNl9hZGRyMzJbMV0p
ID09IDApIHsKIAkJaWYgKGFkZHItPnM2X2FkZHIzMlsyXSA9PSAwKSB7Ci0J
CQlpZiAoYWRkci0+czZfYWRkcjMyWzNdID09IDApCisJCQlpZiAoYWRkci0+
aW42X3UudTZfYWRkcjMyWzNdID09IDApCiAJCQkJcmV0dXJuIElQVjZfQURE
Ul9BTlk7CiAKLQkJCWlmIChhZGRyLT5zNl9hZGRyMzJbM10gPT0gaHRvbmwo
MHgwMDAwMDAwMSkpCi0JCQkJcmV0dXJuIChJUFY2X0FERFJfTE9PUEJBQ0sg
fCBJUFY2X0FERFJfVU5JQ0FTVCk7CisJCQlpZiAoYWRkci0+czZfYWRkcjMy
WzNdID09IF9fY29uc3RhbnRfaHRvbmwoMHgwMDAwMDAwMSkpCisJCQkJcmV0
dXJuIChJUFY2X0FERFJfTE9PUEJBQ0sgfCB0eXBlKTsKIAotCQkJcmV0dXJu
IChJUFY2X0FERFJfQ09NUEFUdjQgfCBJUFY2X0FERFJfVU5JQ0FTVCk7CisJ
CQlyZXR1cm4gKElQVjZfQUREUl9DT01QQVR2NCB8IHR5cGUpOwogCQl9CiAK
LQkJaWYgKGFkZHItPnM2X2FkZHIzMlsyXSA9PSBodG9ubCgweDAwMDBmZmZm
KSkKKwkJaWYgKGFkZHItPnM2X2FkZHIzMlsyXSA9PSBfX2NvbnN0YW50X2h0
b25sKDB4MDAwMGZmZmYpKQogCQkJcmV0dXJuIElQVjZfQUREUl9NQVBQRUQ7
CiAJfQogCi0JcmV0dXJuIElQVjZfQUREUl9SRVNFUlZFRDsKKwlzdCAmPSBf
X2NvbnN0YW50X2h0b25sKDB4RkYwMDAwMDApOworCWlmIChzdCA9PSAwKQor
CQlyZXR1cm4gSVBWNl9BRERSX1JFU0VSVkVEOworCXN0ICY9IF9fY29uc3Rh
bnRfaHRvbmwoMHhGRTAwMDAwMCk7CisJaWYgKHN0ID09IF9fY29uc3RhbnRf
aHRvbmwoMHgwMjAwMDAwMCkpCisJCXJldHVybiBJUFY2X0FERFJfUkVTRVJW
RUQ7CS8qIGZvciBOU0FQICovCisJaWYgKHN0ID09IF9fY29uc3RhbnRfaHRv
bmwoMHgwNDAwMDAwMCkpCisJCXJldHVybiBJUFY2X0FERFJfUkVTRVJWRUQ7
CS8qIGZvciBJUFggKi8KKwlyZXR1cm4gdHlwZTsKIH0KIAogc3RhdGljIHZv
aWQgYWRkcmNvbmZfZGVsX3RpbWVyKHN0cnVjdCBpbmV0Nl9pZmFkZHIgKmlm
cCkKQEAgLTIyNCw3ICsyNDIsNiBAQAogCWFkZF90aW1lcigmaWZwLT50aW1l
cik7CiB9CiAKLQogLyogTm9ib2R5IHJlZmVycyB0byB0aGlzIGRldmljZSwg
d2UgbWF5IGRlc3Ryb3kgaXQuICovCiAKIHZvaWQgaW42X2Rldl9maW5pc2hf
ZGVzdHJveShzdHJ1Y3QgaW5ldDZfZGV2ICppZGV2KQpAQCAtMzAzLDI0ICsz
MjAsOTEgQEAKIAlyZXR1cm4gaWRldjsKIH0KIAordm9pZCBpcHY2X2FkZHJf
cHJlZml4KHN0cnVjdCBpbjZfYWRkciAqcHJlZml4LAorCXN0cnVjdCBpbjZf
YWRkciAqYWRkciwgaW50IHByZWZpeF9sZW4pCit7CisJdW5zaWduZWQgbG9u
ZyBtYXNrOworCWludCBuY29weSwgbmJpdHM7CisKKwltZW1zZXQocHJlZml4
LCAwLCBzaXplb2YoKnByZWZpeCkpOworCisJaWYgKHByZWZpeF9sZW4gPD0g
MCkKKwkJcmV0dXJuOworCWlmIChwcmVmaXhfbGVuID4gMTI4KQorCQlwcmVm
aXhfbGVuID0gMTI4OworCisJbmNvcHkgPSBwcmVmaXhfbGVuIC8gMzI7CisJ
c3dpdGNoIChuY29weSkgeworCWNhc2UgNDoJcHJlZml4LT5zNl9hZGRyMzJb
M10gPSBhZGRyLT5zNl9hZGRyMzJbM107CisJY2FzZSAzOglwcmVmaXgtPnM2
X2FkZHIzMlsyXSA9IGFkZHItPnM2X2FkZHIzMlsyXTsKKwljYXNlIDI6CXBy
ZWZpeC0+czZfYWRkcjMyWzFdID0gYWRkci0+czZfYWRkcjMyWzFdOworCWNh
c2UgMToJcHJlZml4LT5zNl9hZGRyMzJbMF0gPSBhZGRyLT5zNl9hZGRyMzJb
MF07CisJY2FzZSAwOglicmVhazsKKwl9CisJbmJpdHMgPSBwcmVmaXhfbGVu
ICUgMzI7CisJaWYgKG5iaXRzID09IDApCisJCXJldHVybjsKKworCW1hc2sg
PSB+KCgxIDw8ICgzMiAtIG5iaXRzKSkgLSAxKTsKKwltYXNrID0gaHRvbmwo
bWFzayk7CisKKwlwcmVmaXgtPnM2X2FkZHIzMltuY29weV0gPSBhZGRyLT5z
Nl9hZGRyMzJbbmNvcHldICYgbWFzazsKK30KKworCitzdGF0aWMgdm9pZCBk
ZXZfZm9yd2FyZF9jaGFuZ2Uoc3RydWN0IGluZXQ2X2RldiAqaWRldikKK3sK
KwlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2OworCXN0cnVjdCBpbmV0Nl9pZmFk
ZHIgKmlmYTsKKwlzdHJ1Y3QgaW42X2FkZHIgYWRkcjsKKworCWlmICghaWRl
dikKKwkJcmV0dXJuOworCWRldiA9IGlkZXYtPmRldjsKKwlpZiAoZGV2ICYm
IChkZXYtPmZsYWdzICYgSUZGX01VTFRJQ0FTVCkpIHsKKwkJaXB2Nl9hZGRy
X2FsbF9yb3V0ZXJzKCZhZGRyKTsKKwkKKwkJaWYgKGlkZXYtPmNuZi5mb3J3
YXJkaW5nKQorCQkJaXB2Nl9kZXZfbWNfaW5jKGRldiwgJmFkZHIpOworCQll
bHNlCisJCQlpcHY2X2Rldl9tY19kZWMoZGV2LCAmYWRkcik7CisJfQorCWZv
ciAoaWZhPWlkZXYtPmFkZHJfbGlzdDsgaWZhOyBpZmE9aWZhLT5pZl9uZXh0
KSB7CisJCWlwdjZfYWRkcl9wcmVmaXgoJmFkZHIsICZpZmEtPmFkZHIsIGlm
YS0+cHJlZml4X2xlbik7CisJCWlmIChhZGRyLnM2X2FkZHIzMlswXSA9PSAw
ICYmIGFkZHIuczZfYWRkcjMyWzFdID09IDAgJiYKKwkJICAgIGFkZHIuczZf
YWRkcjMyWzJdID09IDAgJiYgYWRkci5zNl9hZGRyMzJbM10gPT0gMCkKKwkJ
CWNvbnRpbnVlOworCQlpZiAoaWRldi0+Y25mLmZvcndhcmRpbmcpCisJCQlp
cHY2X2Rldl9hY19pbmMoaWRldi0+ZGV2LCAmYWRkcik7CisJCWVsc2UKKwkJ
CWlwdjZfZGV2X2FjX2RlYyhpZGV2LT5kZXYsICZhZGRyKTsKKwl9Cit9CisK
Kwogc3RhdGljIHZvaWQgYWRkcmNvbmZfZm9yd2FyZF9jaGFuZ2Uoc3RydWN0
IGluZXQ2X2RldiAqaWRldikKIHsKIAlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2
OwogCi0JaWYgKGlkZXYpCisJaWYgKGlkZXYpIHsKKwkJZGV2X2ZvcndhcmRf
Y2hhbmdlKGlkZXYpOwogCQlyZXR1cm47CisJfQogCiAJcmVhZF9sb2NrKCZk
ZXZfYmFzZV9sb2NrKTsKIAlmb3IgKGRldj1kZXZfYmFzZTsgZGV2OyBkZXY9
ZGV2LT5uZXh0KSB7CiAJCXJlYWRfbG9jaygmYWRkcmNvbmZfbG9jayk7CiAJ
CWlkZXYgPSBfX2luNl9kZXZfZ2V0KGRldik7Ci0JCWlmIChpZGV2KQorCQlp
ZiAoaWRldikgewogCQkJaWRldi0+Y25mLmZvcndhcmRpbmcgPSBpcHY2X2Rl
dmNvbmYuZm9yd2FyZGluZzsKKwkJCWRldl9mb3J3YXJkX2NoYW5nZShpZGV2
KTsKKwkJfQogCQlyZWFkX3VubG9jaygmYWRkcmNvbmZfbG9jayk7CiAJfQog
CXJlYWRfdW5sb2NrKCZkZXZfYmFzZV9sb2NrKTsKIH0KIAorCiAvKiBOb2Jv
ZHkgcmVmZXJzIHRvIHRoaXMgaWZhZGRyLCBkZXN0cm95IGl0ICovCiAKIHZv
aWQgaW5ldDZfaWZhX2ZpbmlzaF9kZXN0cm95KHN0cnVjdCBpbmV0Nl9pZmFk
ZHIgKmlmcCkKQEAgLTQ1OCwyOSArNTQyLDIwIEBACiAgKgkJYW4gYWRkcmVz
cyBvZiB0aGUgYXR0YWNoZWQgaW50ZXJmYWNlIAogICoJaWlpKQlkb24ndCB1
c2UgZGVwcmVjYXRlZCBhZGRyZXNzZXMKICAqLwotaW50IGlwdjZfZ2V0X3Nh
ZGRyKHN0cnVjdCBkc3RfZW50cnkgKmRzdCwKLQkJICAgc3RydWN0IGluNl9h
ZGRyICpkYWRkciwgc3RydWN0IGluNl9hZGRyICpzYWRkcikKK2ludCBpcHY2
X2Rldl9nZXRfc2FkZHIoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwKKwkJICAg
c3RydWN0IGluNl9hZGRyICpkYWRkciwgc3RydWN0IGluNl9hZGRyICpzYWRk
ciwgaW50IG9ubGluaykKIHsKLQlpbnQgc2NvcGU7CiAJc3RydWN0IGluZXQ2
X2lmYWRkciAqaWZwID0gTlVMTDsKIAlzdHJ1Y3QgaW5ldDZfaWZhZGRyICpt
YXRjaCA9IE5VTEw7Ci0Jc3RydWN0IG5ldF9kZXZpY2UgKmRldiA9IE5VTEw7
CiAJc3RydWN0IGluZXQ2X2RldiAqaWRldjsKLQlzdHJ1Y3QgcnQ2X2luZm8g
KnJ0OworCWludCBzY29wZTsKIAlpbnQgZXJyOwogCi0JcnQgPSAoc3RydWN0
IHJ0Nl9pbmZvICopIGRzdDsKLQlpZiAocnQpCi0JCWRldiA9IHJ0LT5ydDZp
X2RldjsKIAotCXNjb3BlID0gaXB2Nl9hZGRyX3Njb3BlKGRhZGRyKTsKLQlp
ZiAocnQgJiYgKHJ0LT5ydDZpX2ZsYWdzICYgUlRGX0FMTE9OTElOSykpIHsK
LQkJLyoKLQkJICoJcm91dGUgZm9yIHRoZSAiYWxsIGRlc3RpbmF0aW9ucyBv
biBsaW5rIiBydWxlCi0JCSAqCXdoZW4gbm8gcm91dGVycyBhcmUgcHJlc2Vu
dAotCQkgKi8KKwlpZiAoIW9ubGluaykKKwkJc2NvcGUgPSBpcHY2X2FkZHJf
c2NvcGUoZGFkZHIpOworCWVsc2UKIAkJc2NvcGUgPSBJRkFfTElOSzsKLQl9
CiAKIAkvKgogCSAqCWtub3duIGRldgpAQCAtNTY4LDYgKzY0MywyNCBAQAog
CXJldHVybiBlcnI7CiB9CiAKKworaW50IGlwdjZfZ2V0X3NhZGRyKHN0cnVj
dCBkc3RfZW50cnkgKmRzdCwKKwkJICAgc3RydWN0IGluNl9hZGRyICpkYWRk
ciwgc3RydWN0IGluNl9hZGRyICpzYWRkcikKK3sKKwlzdHJ1Y3QgcnQ2X2lu
Zm8gKnJ0OworCXN0cnVjdCBuZXRfZGV2aWNlICpkZXYgPSBOVUxMOworCWlu
dCBvbmxpbms7CisKKwlydCA9IChzdHJ1Y3QgcnQ2X2luZm8gKikgZHN0Owor
CWlmIChydCkKKwkJZGV2ID0gcnQtPnJ0NmlfZGV2OworCisJb25saW5rID0g
KHJ0ICYmIChydC0+cnQ2aV9mbGFncyAmIFJURl9BTExPTkxJTkspKTsKKwor
CXJldHVybiBpcHY2X2Rldl9nZXRfc2FkZHIoZGV2LCBkYWRkciwgc2FkZHIs
IG9ubGluayk7Cit9CisKKwogaW50IGlwdjZfZ2V0X2xsYWRkcihzdHJ1Y3Qg
bmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgaW42X2FkZHIgKmFkZHIpCiB7CiAJ
c3RydWN0IGluZXQ2X2RldiAqaWRldjsKQEAgLTY2MCw3ICs3NTMsNyBAQAog
CiAvKiBKb2luIHRvIHNvbGljaXRlZCBhZGRyIG11bHRpY2FzdCBncm91cC4g
Ki8KIAotc3RhdGljIHZvaWQgYWRkcmNvbmZfam9pbl9zb2xpY3Qoc3RydWN0
IG5ldF9kZXZpY2UgKmRldiwgc3RydWN0IGluNl9hZGRyICphZGRyKQordm9p
ZCBhZGRyY29uZl9qb2luX3NvbGljdChzdHJ1Y3QgbmV0X2RldmljZSAqZGV2
LCBzdHJ1Y3QgaW42X2FkZHIgKmFkZHIpCiB7CiAJc3RydWN0IGluNl9hZGRy
IG1hZGRyOwogCkBAIC02NzEsNyArNzY0LDcgQEAKIAlpcHY2X2Rldl9tY19p
bmMoZGV2LCAmbWFkZHIpOwogfQogCi1zdGF0aWMgdm9pZCBhZGRyY29uZl9s
ZWF2ZV9zb2xpY3Qoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgc3RydWN0IGlu
Nl9hZGRyICphZGRyKQordm9pZCBhZGRyY29uZl9sZWF2ZV9zb2xpY3Qoc3Ry
dWN0IG5ldF9kZXZpY2UgKmRldiwgc3RydWN0IGluNl9hZGRyICphZGRyKQog
ewogCXN0cnVjdCBpbjZfYWRkciBtYWRkcjsKIApAQCAtMTU1NCw2ICsxNjQ3
LDE1IEBACiAJCWFkZHJjb25mX21vZF90aW1lcihpZnAsIEFDX1JTLCBpZnAt
PmlkZXYtPmNuZi5ydHJfc29saWNpdF9pbnRlcnZhbCk7CiAJCXNwaW5fdW5s
b2NrX2JoKCZpZnAtPmxvY2spOwogCX0KKworCWlmIChpZnAtPmlkZXYtPmNu
Zi5mb3J3YXJkaW5nKSB7CisJCXN0cnVjdCBpbjZfYWRkciBhZGRyOworCisJ
CWlwdjZfYWRkcl9wcmVmaXgoJmFkZHIsICZpZnAtPmFkZHIsIGlmcC0+cHJl
Zml4X2xlbik7CisJCWlmIChhZGRyLnM2X2FkZHIzMlswXSB8fCBhZGRyLnM2
X2FkZHIzMlsxXSB8fAorCQkgICAgYWRkci5zNl9hZGRyMzJbMl0gfHwgYWRk
ci5zNl9hZGRyMzJbM10pCisJCQlpcHY2X2Rldl9hY19pbmMoaWZwLT5pZGV2
LT5kZXYsICZhZGRyKTsKKwl9CiB9CiAKICNpZmRlZiBDT05GSUdfUFJPQ19G
UwpAQCAtMTg1Myw2ICsxOTU1LDE0IEBACiAJCWJyZWFrOwogCWNhc2UgUlRN
X0RFTEFERFI6CiAJCWFkZHJjb25mX2xlYXZlX3NvbGljdChpZnAtPmlkZXYt
PmRldiwgJmlmcC0+YWRkcik7CisJCWlmIChpZnAtPmlkZXYtPmNuZi5mb3J3
YXJkaW5nKSB7CisJCQlzdHJ1Y3QgaW42X2FkZHIgYWRkcjsKKworCQkJaXB2
Nl9hZGRyX3ByZWZpeCgmYWRkciwgJmlmcC0+YWRkciwgaWZwLT5wcmVmaXhf
bGVuKTsKKwkJCWlmIChhZGRyLnM2X2FkZHIzMlswXSB8fCBhZGRyLnM2X2Fk
ZHIzMlsxXSB8fAorCQkJICAgIGFkZHIuczZfYWRkcjMyWzJdIHx8IGFkZHIu
czZfYWRkcjMyWzNdKQorCQkJCWlwdjZfZGV2X2FjX2RlYyhpZnAtPmlkZXYt
PmRldiwgJmFkZHIpOworCQl9CiAJCWlmICghaXB2Nl9jaGtfYWRkcigmaWZw
LT5hZGRyLCBOVUxMKSkKIAkJCWlwNl9ydF9hZGRyX2RlbCgmaWZwLT5hZGRy
LCBpZnAtPmlkZXYtPmRldik7CiAJCWJyZWFrOwpAQCAtMTg3NSwxMSArMTk4
NSw3IEBACiAJCXN0cnVjdCBpbmV0Nl9kZXYgKmlkZXYgPSBOVUxMOwogCiAJ
CWlmICh2YWxwICE9ICZpcHY2X2RldmNvbmYuZm9yd2FyZGluZykgewotCQkJ
c3RydWN0IG5ldF9kZXZpY2UgKmRldiA9IGRldl9nZXRfYnlfaW5kZXgoY3Rs
LT5jdGxfbmFtZSk7Ci0JCQlpZiAoZGV2KSB7Ci0JCQkJaWRldiA9IGluNl9k
ZXZfZ2V0KGRldik7Ci0JCQkJZGV2X3B1dChkZXYpOwotCQkJfQorCQkJaWRl
diA9IChzdHJ1Y3QgaW5ldDZfZGV2ICopY3RsLT5leHRyYTE7CiAJCQlpZiAo
aWRldiA9PSBOVUxMKQogCQkJCXJldHVybiByZXQ7CiAJCX0gZWxzZQpAQCAt
MTg4OSw4ICsxOTk1LDYgQEAKIAogCQlpZiAoKnZhbHApCiAJCQlydDZfcHVy
Z2VfZGZsdF9yb3V0ZXJzKDApOwotCQlpZiAoaWRldikKLQkJCWluNl9kZXZf
cHV0KGlkZXYpOwogCX0KIAogICAgICAgICByZXR1cm4gcmV0OwpAQCAtMTk2
Nyw2ICsyMDcxLDcgQEAKIAlmb3IgKGk9MDsgaTxzaXplb2YodC0+YWRkcmNv
bmZfdmFycykvc2l6ZW9mKHQtPmFkZHJjb25mX3ZhcnNbMF0pLTE7IGkrKykg
ewogCQl0LT5hZGRyY29uZl92YXJzW2ldLmRhdGEgKz0gKGNoYXIqKXAgLSAo
Y2hhciopJmlwdjZfZGV2Y29uZjsKIAkJdC0+YWRkcmNvbmZfdmFyc1tpXS5k
ZSA9IE5VTEw7CisJCXQtPmFkZHJjb25mX3ZhcnNbaV0uZXh0cmExID0gaWRl
djsgLyogZW1iZWRkZWQ7IG5vIHJlZiAqLwogCX0KIAlpZiAoZGV2KSB7CiAJ
CXQtPmFkZHJjb25mX2RldlswXS5wcm9jbmFtZSA9IGRldi0+bmFtZTsKZGlm
ZiAtcnVOIGxpbnV4LTIuNS40NC9uZXQvaXB2Ni9hZl9pbmV0Ni5jIGxpbnV4
LTIuNS40NEFDL25ldC9pcHY2L2FmX2luZXQ2LmMKLS0tIGxpbnV4LTIuNS40
NC9uZXQvaXB2Ni9hZl9pbmV0Ni5jCUZyaSBPY3QgMTggMjE6MDE6NTcgMjAw
MgorKysgbGludXgtMi41LjQ0QUMvbmV0L2lwdjYvYWZfaW5ldDYuYwlNb24g
T2N0IDI4IDEyOjM4OjA5IDIwMDIKQEAgLTc2LDYgKzc2LDcgQEAKIC8qIElQ
djYgcHJvY2ZzIGdvb2RpZXMuLi4gKi8KIAogI2lmZGVmIENPTkZJR19QUk9D
X0ZTCitleHRlcm4gaW50IGFueWNhc3Q2X2dldF9pbmZvKGNoYXIgKiwgY2hh
ciAqKiwgb2ZmX3QsIGludCk7CiBleHRlcm4gaW50IHJhdzZfZ2V0X2luZm8o
Y2hhciAqLCBjaGFyICoqLCBvZmZfdCwgaW50KTsKIGV4dGVybiBpbnQgdGNw
Nl9nZXRfaW5mbyhjaGFyICosIGNoYXIgKiosIG9mZl90LCBpbnQpOwogZXh0
ZXJuIGludCB1ZHA2X2dldF9pbmZvKGNoYXIgKiwgY2hhciAqKiwgb2ZmX3Qs
IGludCk7CkBAIC0zODAsNiArMzgxLDkgQEAKIAkvKiBGcmVlIG1jIGxpc3Rz
ICovCiAJaXB2Nl9zb2NrX21jX2Nsb3NlKHNrKTsKIAorCS8qIEZyZWUgYWMg
bGlzdHMgKi8KKwlpcHY2X3NvY2tfYWNfY2xvc2Uoc2spOworCiAJcmV0dXJu
IGluZXRfcmVsZWFzZShzb2NrKTsKIH0KIApAQCAtNjk0LDYgKzY5OCw4IEBA
CiAJCWdvdG8gcHJvY19zb2Nrc3RhdDZfZmFpbDsKIAlpZiAoIXByb2NfbmV0
X2NyZWF0ZSgic25tcDYiLCAwLCBhZmluZXQ2X2dldF9zbm1wKSkKIAkJZ290
byBwcm9jX3NubXA2X2ZhaWw7CisJaWYgKCFwcm9jX25ldF9jcmVhdGUoImFu
eWNhc3Q2IiwgMCwgYW55Y2FzdDZfZ2V0X2luZm8pKQorCQlnb3RvIHByb2Nf
YW55Y2FzdDZfZmFpbDsKICNlbmRpZgogCWlwdjZfbmV0ZGV2X25vdGlmX2lu
aXQoKTsKIAlpcHY2X3BhY2tldF9pbml0KCk7CkBAIC03MDksNiArNzE1LDgg
QEAKIAlyZXR1cm4gMDsKIAogI2lmZGVmIENPTkZJR19QUk9DX0ZTCitwcm9j
X2FueWNhc3Q2X2ZhaWw6CisJcHJvY19uZXRfcmVtb3ZlKCJhbnljYXN0NiIp
OwogcHJvY19zbm1wNl9mYWlsOgogCXByb2NfbmV0X3JlbW92ZSgic29ja3N0
YXQ2Iik7CiBwcm9jX3NvY2tzdGF0Nl9mYWlsOgpAQCAtNzQ0LDYgKzc1Miw3
IEBACiAJcHJvY19uZXRfcmVtb3ZlKCJ1ZHA2Iik7CiAJcHJvY19uZXRfcmVt
b3ZlKCJzb2Nrc3RhdDYiKTsKIAlwcm9jX25ldF9yZW1vdmUoInNubXA2Iik7
CisJcHJvY19uZXRfcmVtb3ZlKCJhbnljYXN0NiIpOwogI2VuZGlmCiAJLyog
Q2xlYW51cCBjb2RlIHBhcnRzLiAqLwogCXNpdF9jbGVhbnVwKCk7CmRpZmYg
LXJ1TiBsaW51eC0yLjUuNDQvbmV0L2lwdjYvYW55Y2FzdC5jIGxpbnV4LTIu
NS40NEFDL25ldC9pcHY2L2FueWNhc3QuYwotLS0gbGludXgtMi41LjQ0L25l
dC9pcHY2L2FueWNhc3QuYwlXZWQgRGVjIDMxIDE2OjAwOjAwIDE5NjkKKysr
IGxpbnV4LTIuNS40NEFDL25ldC9pcHY2L2FueWNhc3QuYwlNb24gT2N0IDI4
IDEzOjI4OjA3IDIwMDIKQEAgLTAsMCArMSw0ODkgQEAKKy8qCisgKglBbnlj
YXN0IHN1cHBvcnQgZm9yIElQdjYKKyAqCUxpbnV4IElORVQ2IGltcGxlbWVu
dGF0aW9uIAorICoKKyAqCUF1dGhvcnM6CisgKglEYXZpZCBMIFN0ZXZlbnMg
KGRsc3RldmVuc0B1cy5pYm0uY29tKQorICoKKyAqCWJhc2VkIGhlYXZpbHkg
b24gbmV0L2lwdjYvbWNhc3QuYworICoKKyAqCVRoaXMgcHJvZ3JhbSBpcyBm
cmVlIHNvZnR3YXJlOyB5b3UgY2FuIHJlZGlzdHJpYnV0ZSBpdCBhbmQvb3IK
KyAqICAgICAgbW9kaWZ5IGl0IHVuZGVyIHRoZSB0ZXJtcyBvZiB0aGUgR05V
IEdlbmVyYWwgUHVibGljIExpY2Vuc2UKKyAqICAgICAgYXMgcHVibGlzaGVk
IGJ5IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5kYXRpb247IGVpdGhlciB2ZXJz
aW9uCisgKiAgICAgIDIgb2YgdGhlIExpY2Vuc2UsIG9yIChhdCB5b3VyIG9w
dGlvbikgYW55IGxhdGVyIHZlcnNpb24uCisgKi8KKworI2luY2x1ZGUgPGxp
bnV4L2NvbmZpZy5oPgorI2luY2x1ZGUgPGxpbnV4L21vZHVsZS5oPgorI2lu
Y2x1ZGUgPGxpbnV4L2Vycm5vLmg+CisjaW5jbHVkZSA8bGludXgvdHlwZXMu
aD4KKyNpbmNsdWRlIDxsaW51eC9yYW5kb20uaD4KKyNpbmNsdWRlIDxsaW51
eC9zdHJpbmcuaD4KKyNpbmNsdWRlIDxsaW51eC9zb2NrZXQuaD4KKyNpbmNs
dWRlIDxsaW51eC9zb2NraW9zLmg+CisjaW5jbHVkZSA8bGludXgvc2NoZWQu
aD4KKyNpbmNsdWRlIDxsaW51eC9uZXQuaD4KKyNpbmNsdWRlIDxsaW51eC9p
bjYuaD4KKyNpbmNsdWRlIDxsaW51eC9uZXRkZXZpY2UuaD4KKyNpbmNsdWRl
IDxsaW51eC9pZl9hcnAuaD4KKyNpbmNsdWRlIDxsaW51eC9yb3V0ZS5oPgor
I2luY2x1ZGUgPGxpbnV4L2luaXQuaD4KKyNpbmNsdWRlIDxsaW51eC9wcm9j
X2ZzLmg+CisKKyNpbmNsdWRlIDxuZXQvc29jay5oPgorI2luY2x1ZGUgPG5l
dC9zbm1wLmg+CisKKyNpbmNsdWRlIDxuZXQvaXB2Ni5oPgorI2luY2x1ZGUg
PG5ldC9wcm90b2NvbC5oPgorI2luY2x1ZGUgPG5ldC9pZl9pbmV0Ni5oPgor
I2luY2x1ZGUgPG5ldC9uZGlzYy5oPgorI2luY2x1ZGUgPG5ldC9hZGRyY29u
Zi5oPgorI2luY2x1ZGUgPG5ldC9pcDZfcm91dGUuaD4KKworI2luY2x1ZGUg
PG5ldC9jaGVja3N1bS5oPgorCisvKiBCaWcgYWMgbGlzdCBsb2NrIGZvciBh
bGwgdGhlIHNvY2tldHMgKi8KK3N0YXRpYyByd2xvY2tfdCBpcHY2X3NrX2Fj
X2xvY2sgPSBSV19MT0NLX1VOTE9DS0VEOworCisvKiBYWFggaXA2X2FkZHJf
bWF0Y2goKSBhbmQgaXA2X29ubGluaygpIHJlYWxseSBiZWxvbmcgaW4gbmV0
L2NvcmUuYyAqLworCitzdGF0aWMgaW50CitpcDZfYWRkcl9tYXRjaChzdHJ1
Y3QgaW42X2FkZHIgKmFkZHIxLCBzdHJ1Y3QgaW42X2FkZHIgKmFkZHIyLCBp
bnQgcHJlZml4KQoreworCV9fdTMyCW1hc2s7CisJaW50CWk7CisKKwlpZiAo
cHJlZml4ID4gMTI4IHx8IHByZWZpeCA8IDApCisJCXJldHVybiAwOworCWlm
IChwcmVmaXggPT0gMCkKKwkJcmV0dXJuIDE7CisJZm9yIChpPTA7IGk8NDsg
KytpKSB7CisJCWlmIChwcmVmaXggPj0gMzIpCisJCQltYXNrID0gfjA7CisJ
CWVsc2UKKwkJCW1hc2sgPSBodG9ubCh+MCA8PCAoMzIgLSBwcmVmaXgpKTsK
KwkJaWYgKChhZGRyMS0+czZfYWRkcjMyW2ldIF4gYWRkcjItPnM2X2FkZHIz
MltpXSkgJiBtYXNrKQorCQkJcmV0dXJuIDA7CisJCXByZWZpeCAtPSAzMjsK
KwkJaWYgKHByZWZpeCA8PSAwKQorCQkJYnJlYWs7CisJfQorCXJldHVybiAx
OworfQorCitzdGF0aWMgaW50CitpcDZfb25saW5rKHN0cnVjdCBpbjZfYWRk
ciAqYWRkciwgc3RydWN0IG5ldF9kZXZpY2UgKmRldikKK3sKKwlzdHJ1Y3Qg
aW5ldDZfZGV2CSppZGV2OworCXN0cnVjdCBpbmV0Nl9pZmFkZHIJKmlmYTsK
KwlpbnQJb25saW5rOworCisJb25saW5rID0gMDsKKwlyZWFkX2xvY2soJmFk
ZHJjb25mX2xvY2spOworCWlkZXYgPSBfX2luNl9kZXZfZ2V0KGRldik7CisJ
aWYgKGlkZXYpIHsKKwkJcmVhZF9sb2NrX2JoKCZpZGV2LT5sb2NrKTsKKwkJ
Zm9yIChpZmE9aWRldi0+YWRkcl9saXN0OyBpZmE7IGlmYT1pZmEtPmlmX25l
eHQpIHsKKwkJCW9ubGluayA9IGlwNl9hZGRyX21hdGNoKGFkZHIsICZpZmEt
PmFkZHIsCisJCQkJCWlmYS0+cHJlZml4X2xlbik7CisJCQlpZiAob25saW5r
KQorCQkJCWJyZWFrOworCQl9CisJCXJlYWRfdW5sb2NrX2JoKCZpZGV2LT5s
b2NrKTsKKwl9CisJcmVhZF91bmxvY2soJmFkZHJjb25mX2xvY2spOworCXJl
dHVybiBvbmxpbms7Cit9CisKKworLyoKKyAqCXNvY2tldCBqb2luIGFuIGFu
eWNhc3QgZ3JvdXAKKyAqLworCitpbnQgaXB2Nl9zb2NrX2FjX2pvaW4oc3Ry
dWN0IHNvY2sgKnNrLCBpbnQgaWZpbmRleCwgc3RydWN0IGluNl9hZGRyICph
ZGRyKQoreworCXN0cnVjdCBpcHY2X3BpbmZvICpucCA9IGluZXQ2X3NrKHNr
KTsKKwlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2ID0gTlVMTDsKKwlzdHJ1Y3Qg
aW5ldDZfZGV2ICppZGV2OworCXN0cnVjdCBpcHY2X2FjX3NvY2tsaXN0ICpw
YWM7CisJaW50CWlzaG9zdCA9ICFpcHY2X2RldmNvbmYuZm9yd2FyZGluZzsK
KwlpbnQJZXJyID0gMDsKKworCWlmIChpcHY2X2FkZHJfdHlwZShhZGRyKSAm
IElQVjZfQUREUl9NVUxUSUNBU1QpCisJCXJldHVybiAtRUlOVkFMOworCisJ
cGFjID0gc29ja19rbWFsbG9jKHNrLCBzaXplb2Yoc3RydWN0IGlwdjZfYWNf
c29ja2xpc3QpLCBHRlBfS0VSTkVMKTsKKwlpZiAocGFjID09IE5VTEwpCisJ
CXJldHVybiAtRU5PTUVNOworCXBhYy0+YWNsX25leHQgPSBOVUxMOworCWlw
djZfYWRkcl9jb3B5KCZwYWMtPmFjbF9hZGRyLCBhZGRyKTsKKworCWlmIChp
ZmluZGV4ID09IDApIHsKKwkJc3RydWN0IHJ0Nl9pbmZvICpydDsKKworCQly
dCA9IHJ0Nl9sb29rdXAoYWRkciwgTlVMTCwgMCwgMCk7CisJCWlmIChydCkg
eworCQkJZGV2ID0gcnQtPnJ0NmlfZGV2OworCQkJZGV2X2hvbGQoZGV2KTsK
KwkJCWRzdF9yZWxlYXNlKCZydC0+dS5kc3QpOworCQl9IGVsc2UgaWYgKGlz
aG9zdCkgeworCQkJc29ja19rZnJlZV9zKHNrLCBwYWMsIHNpemVvZigqcGFj
KSk7CisJCQlyZXR1cm4gLUVBRERSTk9UQVZBSUw7CisJCX0gZWxzZSB7CisJ
CQkvKiByb3V0ZXIsIG5vIG1hdGNoaW5nIGludGVyZmFjZToganVzdCBwaWNr
IG9uZSAqLworCisJCQlkZXYgPSBkZXZfZ2V0YW55KElGRl9VUCwgSUZGX1VQ
fElGRl9MT09QQkFDSyk7CisJCX0KKwl9IGVsc2UKKwkJZGV2ID0gZGV2X2dl
dF9ieV9pbmRleChpZmluZGV4KTsKKworCWlmIChkZXYgPT0gTlVMTCkgewor
CQlzb2NrX2tmcmVlX3Moc2ssIHBhYywgc2l6ZW9mKCpwYWMpKTsKKwkJcmV0
dXJuIC1FTk9ERVY7CisJfQorCisJaWRldiA9IGluNl9kZXZfZ2V0KGRldik7
CisJaWYgKCFpZGV2KSB7CisJCXNvY2tfa2ZyZWVfcyhzaywgcGFjLCBzaXpl
b2YoKnBhYykpOworCQlkZXZfcHV0KGRldik7CisJCWlmIChpZmluZGV4KQor
CQkJcmV0dXJuIC1FTk9ERVY7CisJCWVsc2UKKwkJCXJldHVybiAtRUFERFJO
T1RBVkFJTDsKKwl9CisJLyogcmVzZXQgaXNob3N0LCBub3cgdGhhdCB3ZSBo
YXZlIGEgc3BlY2lmaWMgZGV2aWNlICovCisJaXNob3N0ID0gIWlkZXYtPmNu
Zi5mb3J3YXJkaW5nOworCWluNl9kZXZfcHV0KGlkZXYpOworCisJcGFjLT5h
Y2xfaWZpbmRleCA9IGRldi0+aWZpbmRleDsKKworCS8qIFhYWAorCSAqIEZv
ciBob3N0cywgYWxsb3cgbGluay1sb2NhbCBvciBtYXRjaGluZyBwcmVmaXgg
YW55Y2FzdHMuCisJICogVGhpcyBvYnZpYXRlcyB0aGUgbmVlZCBmb3IgcHJv
cGFnYXRpbmcgYW55Y2FzdCByb3V0ZXMgd2hpbGUKKwkgKiBzdGlsbCBhbGxv
d2luZyBzb21lIG5vbi1yb3V0ZXIgYW55Y2FzdCBwYXJ0aWNpcGF0aW9uLgor
CSAqCisJICogYWxsb3cgYW55b25lIHRvIGpvaW4gYW55Y2FzdHMgdGhhdCBk
b24ndCByZXF1aXJlIGEgc3BlY2lhbCByb3V0ZQorCSAqIGFuZCBjYW4ndCBi
ZSBzcG9vZnMgb2YgdW5pY2FzdCBhZGRyZXNzZXMgKHJlc2VydmVkIGFueWNh
c3Qgb25seSkKKwkgKi8KKwlpZiAoIWlwNl9vbmxpbmsoYWRkciwgZGV2KSkg
eworCQlpZiAoaXNob3N0KQorCQkJZXJyID0gLUVBRERSTk9UQVZBSUw7CisJ
CWVsc2UgaWYgKCFjYXBhYmxlKENBUF9ORVRfQURNSU4pKQorCQkJZXJyID0g
LUVQRVJNOworCQlpZiAoZXJyKSB7CisJCQlzb2NrX2tmcmVlX3Moc2ssIHBh
Yywgc2l6ZW9mKCpwYWMpKTsKKwkJCWRldl9wdXQoZGV2KTsKKwkJCXJldHVy
biBlcnI7CisJCX0KKwl9IGVsc2UgaWYgKCEoaXB2Nl9hZGRyX3R5cGUoYWRk
cikgJiBJUFY2X0FERFJfQU5ZQ0FTVCkgJiYKKwkJICAgIWNhcGFibGUoQ0FQ
X05FVF9BRE1JTikpCisJCXJldHVybiAtRVBFUk07CisKKwllcnIgPSBpcHY2
X2Rldl9hY19pbmMoZGV2LCBhZGRyKTsKKwlpZiAoZXJyKSB7CisJCXNvY2tf
a2ZyZWVfcyhzaywgcGFjLCBzaXplb2YoKnBhYykpOworCQlkZXZfcHV0KGRl
dik7CisJCXJldHVybiBlcnI7CisJfQorCisJd3JpdGVfbG9ja19iaCgmaXB2
Nl9za19hY19sb2NrKTsKKwlwYWMtPmFjbF9uZXh0ID0gbnAtPmlwdjZfYWNf
bGlzdDsKKwlucC0+aXB2Nl9hY19saXN0ID0gcGFjOworCXdyaXRlX3VubG9j
a19iaCgmaXB2Nl9za19hY19sb2NrKTsKKworCWRldl9wdXQoZGV2KTsKKwor
CXJldHVybiAwOworfQorCisvKgorICoJc29ja2V0IGxlYXZlIGFuIGFueWNh
c3QgZ3JvdXAKKyAqLworaW50IGlwdjZfc29ja19hY19kcm9wKHN0cnVjdCBz
b2NrICpzaywgaW50IGlmaW5kZXgsIHN0cnVjdCBpbjZfYWRkciAqYWRkcikK
K3sKKwlzdHJ1Y3QgaXB2Nl9waW5mbyAqbnAgPSBpbmV0Nl9zayhzayk7CisJ
c3RydWN0IG5ldF9kZXZpY2UgKmRldjsKKwlzdHJ1Y3QgaXB2Nl9hY19zb2Nr
bGlzdCAqcGFjLCAqcHJldl9wYWM7CisKKwl3cml0ZV9sb2NrX2JoKCZpcHY2
X3NrX2FjX2xvY2spOworCXByZXZfcGFjID0gMDsKKwlmb3IgKHBhYyA9IG5w
LT5pcHY2X2FjX2xpc3Q7IHBhYzsgcGFjID0gcGFjLT5hY2xfbmV4dCkgewor
CQlpZiAoKGlmaW5kZXggPT0gMCB8fCBwYWMtPmFjbF9pZmluZGV4ID09IGlm
aW5kZXgpICYmCisJCSAgICAgaXB2Nl9hZGRyX2NtcCgmcGFjLT5hY2xfYWRk
ciwgYWRkcikgPT0gMCkKKwkJCWJyZWFrOworCQlwcmV2X3BhYyA9IHBhYzsK
Kwl9CisJaWYgKCFwYWMpIHsKKwkJd3JpdGVfdW5sb2NrX2JoKCZpcHY2X3Nr
X2FjX2xvY2spOworCQlyZXR1cm4gLUVOT0VOVDsKKwl9CisJaWYgKHByZXZf
cGFjKQorCQlwcmV2X3BhYy0+YWNsX25leHQgPSBwYWMtPmFjbF9uZXh0Owor
CWVsc2UKKwkJbnAtPmlwdjZfYWNfbGlzdCA9IHBhYy0+YWNsX25leHQ7CisK
Kwl3cml0ZV91bmxvY2tfYmgoJmlwdjZfc2tfYWNfbG9jayk7CisKKwlkZXYg
PSBkZXZfZ2V0X2J5X2luZGV4KHBhYy0+YWNsX2lmaW5kZXgpOworCWlmIChk
ZXYpIHsKKwkJaXB2Nl9kZXZfYWNfZGVjKGRldiwgJnBhYy0+YWNsX2FkZHIp
OworCQlkZXZfcHV0KGRldik7CisJfQorCXNvY2tfa2ZyZWVfcyhzaywgcGFj
LCBzaXplb2YoKnBhYykpOworCXJldHVybiAwOworfQorCit2b2lkIGlwdjZf
c29ja19hY19jbG9zZShzdHJ1Y3Qgc29jayAqc2spCit7CisJc3RydWN0IGlw
djZfcGluZm8gKm5wID0gaW5ldDZfc2soc2spOworCXN0cnVjdCBuZXRfZGV2
aWNlICpkZXYgPSAwOworCXN0cnVjdCBpcHY2X2FjX3NvY2tsaXN0ICpwYWM7
CisJaW50CXByZXZfaW5kZXg7CisKKwl3cml0ZV9sb2NrX2JoKCZpcHY2X3Nr
X2FjX2xvY2spOworCXBhYyA9IG5wLT5pcHY2X2FjX2xpc3Q7CisJbnAtPmlw
djZfYWNfbGlzdCA9IDA7CisJd3JpdGVfdW5sb2NrX2JoKCZpcHY2X3NrX2Fj
X2xvY2spOworCisJcHJldl9pbmRleCA9IDA7CisJd2hpbGUgKHBhYykgewor
CQlzdHJ1Y3QgaXB2Nl9hY19zb2NrbGlzdCAqbmV4dCA9IHBhYy0+YWNsX25l
eHQ7CisKKwkJaWYgKHBhYy0+YWNsX2lmaW5kZXggIT0gcHJldl9pbmRleCkg
eworCQkJaWYgKGRldikKKwkJCQlkZXZfcHV0KGRldik7CisJCQlkZXYgPSBk
ZXZfZ2V0X2J5X2luZGV4KHBhYy0+YWNsX2lmaW5kZXgpOworCQkJcHJldl9p
bmRleCA9IHBhYy0+YWNsX2lmaW5kZXg7CisJCX0KKwkJaWYgKGRldikKKwkJ
CWlwdjZfZGV2X2FjX2RlYyhkZXYsICZwYWMtPmFjbF9hZGRyKTsKKwkJc29j
a19rZnJlZV9zKHNrLCBwYWMsIHNpemVvZigqcGFjKSk7CisJCXBhYyA9IG5l
eHQ7CisJfQorCWlmIChkZXYpCisJCWRldl9wdXQoZGV2KTsKK30KKworaW50
IGluZXQ2X2FjX2NoZWNrKHN0cnVjdCBzb2NrICpzaywgc3RydWN0IGluNl9h
ZGRyICphZGRyLCBpbnQgaWZpbmRleCkKK3sKKwlzdHJ1Y3QgaXB2Nl9hY19z
b2NrbGlzdCAqcGFjOworCXN0cnVjdCBpcHY2X3BpbmZvICpucCA9IGluZXQ2
X3NrKHNrKTsKKwlpbnQJZm91bmQ7CisKKwlmb3VuZCA9IDA7CisJcmVhZF9s
b2NrKCZpcHY2X3NrX2FjX2xvY2spOworCWZvciAocGFjPW5wLT5pcHY2X2Fj
X2xpc3Q7IHBhYzsgcGFjPXBhYy0+YWNsX25leHQpIHsKKwkJaWYgKGlmaW5k
ZXggJiYgcGFjLT5hY2xfaWZpbmRleCAhPSBpZmluZGV4KQorCQkJY29udGlu
dWU7CisJCWZvdW5kID0gaXB2Nl9hZGRyX2NtcCgmcGFjLT5hY2xfYWRkciwg
YWRkcikgPT0gMDsKKwkJaWYgKGZvdW5kKQorCQkJYnJlYWs7CisJfQorCXJl
YWRfdW5sb2NrKCZpcHY2X3NrX2FjX2xvY2spOworCisJcmV0dXJuIGZvdW5k
OworfQorCitzdGF0aWMgdm9pZCBhY2FfcHV0KHN0cnVjdCBpZmFjYWRkcjYg
KmFjKQoreworCWlmIChhdG9taWNfZGVjX2FuZF90ZXN0KCZhYy0+YWNhX3Jl
ZmNudCkpIHsKKwkJaW42X2Rldl9wdXQoYWMtPmFjYV9pZGV2KTsKKwkJa2Zy
ZWUoYWMpOworCX0KK30KKworLyoKKyAqCWRldmljZSBhbnljYXN0IGdyb3Vw
IGluYyAoYWRkIGlmIG5vdCBmb3VuZCkKKyAqLworaW50IGlwdjZfZGV2X2Fj
X2luYyhzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgaW42X2FkZHIg
KmFkZHIpCit7CisJc3RydWN0IGlmYWNhZGRyNiAqYWNhOworCXN0cnVjdCBp
bmV0Nl9kZXYgKmlkZXY7CisKKwlpZGV2ID0gaW42X2Rldl9nZXQoZGV2KTsK
KworCWlmIChpZGV2ID09IE5VTEwpCisJCXJldHVybiAtRUlOVkFMOworCisJ
d3JpdGVfbG9ja19iaCgmaWRldi0+bG9jayk7CisJaWYgKGlkZXYtPmRlYWQp
IHsKKwkJd3JpdGVfdW5sb2NrX2JoKCZpZGV2LT5sb2NrKTsKKwkJaW42X2Rl
dl9wdXQoaWRldik7CisJCXJldHVybiAtRU5PREVWOworCX0KKworCWZvciAo
YWNhID0gaWRldi0+YWNfbGlzdDsgYWNhOyBhY2EgPSBhY2EtPmFjYV9uZXh0
KSB7CisJCWlmIChpcHY2X2FkZHJfY21wKCZhY2EtPmFjYV9hZGRyLCBhZGRy
KSA9PSAwKSB7CisJCQlhY2EtPmFjYV91c2VycysrOworCQkJd3JpdGVfdW5s
b2NrX2JoKCZpZGV2LT5sb2NrKTsKKwkJCWluNl9kZXZfcHV0KGlkZXYpOwor
CQkJcmV0dXJuIDA7CisJCX0KKwl9CisKKwkvKgorCSAqCW5vdCBmb3VuZDog
Y3JlYXRlIGEgbmV3IG9uZS4KKwkgKi8KKworCWFjYSA9IGttYWxsb2Moc2l6
ZW9mKHN0cnVjdCBpZmFjYWRkcjYpLCBHRlBfQVRPTUlDKTsKKworCWlmIChh
Y2EgPT0gTlVMTCkgeworCQl3cml0ZV91bmxvY2tfYmgoJmlkZXYtPmxvY2sp
OworCQlpbjZfZGV2X3B1dChpZGV2KTsKKwkJcmV0dXJuIC1FTk9NRU07CisJ
fQorCisJbWVtc2V0KGFjYSwgMCwgc2l6ZW9mKHN0cnVjdCBpZmFjYWRkcjYp
KTsKKworCWlwdjZfYWRkcl9jb3B5KCZhY2EtPmFjYV9hZGRyLCBhZGRyKTsK
KwlhY2EtPmFjYV9pZGV2ID0gaWRldjsKKwlhY2EtPmFjYV91c2VycyA9IDE7
CisJYXRvbWljX3NldCgmYWNhLT5hY2FfcmVmY250LCAyKTsKKwlhY2EtPmFj
YV9sb2NrID0gU1BJTl9MT0NLX1VOTE9DS0VEOworCisJYWNhLT5hY2FfbmV4
dCA9IGlkZXYtPmFjX2xpc3Q7CisJaWRldi0+YWNfbGlzdCA9IGFjYTsKKwl3
cml0ZV91bmxvY2tfYmgoJmlkZXYtPmxvY2spOworCisJaXA2X3J0X2FkZHJf
YWRkKCZhY2EtPmFjYV9hZGRyLCBkZXYpOworCisJYWRkcmNvbmZfam9pbl9z
b2xpY3QoZGV2LCAmYWNhLT5hY2FfYWRkcik7CisKKwlhY2FfcHV0KGFjYSk7
CisJcmV0dXJuIDA7Cit9CisKKy8qCisgKglkZXZpY2UgYW55Y2FzdCBncm91
cCBkZWNyZW1lbnQKKyAqLworaW50IGlwdjZfZGV2X2FjX2RlYyhzdHJ1Y3Qg
bmV0X2RldmljZSAqZGV2LCBzdHJ1Y3QgaW42X2FkZHIgKmFkZHIpCit7CisJ
c3RydWN0IGluZXQ2X2RldiAqaWRldjsKKwlzdHJ1Y3QgaWZhY2FkZHI2ICph
Y2EsICpwcmV2X2FjYTsKKworCWlkZXYgPSBpbjZfZGV2X2dldChkZXYpOwor
CWlmIChpZGV2ID09IE5VTEwpCisJCXJldHVybiAtRU5PREVWOworCisJd3Jp
dGVfbG9ja19iaCgmaWRldi0+bG9jayk7CisJcHJldl9hY2EgPSAwOworCWZv
ciAoYWNhID0gaWRldi0+YWNfbGlzdDsgYWNhOyBhY2EgPSBhY2EtPmFjYV9u
ZXh0KSB7CisJCWlmIChpcHY2X2FkZHJfY21wKCZhY2EtPmFjYV9hZGRyLCBh
ZGRyKSA9PSAwKQorCQkJYnJlYWs7CisJCXByZXZfYWNhID0gYWNhOworCX0K
KwlpZiAoIWFjYSkgeworCQl3cml0ZV91bmxvY2tfYmgoJmlkZXYtPmxvY2sp
OworCQlpbjZfZGV2X3B1dChpZGV2KTsKKwkJcmV0dXJuIC1FTk9FTlQ7CisJ
fQorCWlmICgtLWFjYS0+YWNhX3VzZXJzID4gMCkgeworCQl3cml0ZV91bmxv
Y2tfYmgoJmlkZXYtPmxvY2spOworCQlpbjZfZGV2X3B1dChpZGV2KTsKKwkJ
cmV0dXJuIDA7CisJfQorCWlmIChwcmV2X2FjYSkKKwkJcHJldl9hY2EtPmFj
YV9uZXh0ID0gYWNhLT5hY2FfbmV4dDsKKwllbHNlCisJCWlkZXYtPmFjX2xp
c3QgPSBhY2EtPmFjYV9uZXh0OworCXdyaXRlX3VubG9ja19iaCgmaWRldi0+
bG9jayk7CisJYWRkcmNvbmZfbGVhdmVfc29saWN0KGRldiwgJmFjYS0+YWNh
X2FkZHIpOworCisJaXA2X3J0X2FkZHJfZGVsKCZhY2EtPmFjYV9hZGRyLCBk
ZXYpOworCisJYWNhX3B1dChhY2EpOworCWluNl9kZXZfcHV0KGlkZXYpOwor
CXJldHVybiAwOworfQorCisvKgorICoJY2hlY2sgaWYgdGhlIGludGVyZmFj
ZSBoYXMgdGhpcyBhbnljYXN0IGFkZHJlc3MKKyAqLworc3RhdGljIGludCBp
cHY2X2Noa19hY2FzdF9kZXYoc3RydWN0IG5ldF9kZXZpY2UgKmRldiwgc3Ry
dWN0IGluNl9hZGRyICphZGRyKQoreworCXN0cnVjdCBpbmV0Nl9kZXYgKmlk
ZXY7CisJc3RydWN0IGlmYWNhZGRyNiAqYWNhOworCisJaWRldiA9IGluNl9k
ZXZfZ2V0KGRldik7CisJaWYgKGlkZXYpIHsKKwkJcmVhZF9sb2NrX2JoKCZp
ZGV2LT5sb2NrKTsKKwkJZm9yIChhY2EgPSBpZGV2LT5hY19saXN0OyBhY2E7
IGFjYSA9IGFjYS0+YWNhX25leHQpCisJCQlpZiAoaXB2Nl9hZGRyX2NtcCgm
YWNhLT5hY2FfYWRkciwgYWRkcikgPT0gMCkKKwkJCQlicmVhazsKKwkJcmVh
ZF91bmxvY2tfYmgoJmlkZXYtPmxvY2spOworCQlpbjZfZGV2X3B1dChpZGV2
KTsKKwkJcmV0dXJuIGFjYSAhPSAwOworCX0KKwlyZXR1cm4gMDsKK30KKwor
LyoKKyAqCWNoZWNrIGlmIGdpdmVuIGludGVyZmFjZSAob3IgYW55LCBpZiBk
ZXY9PTApIGhhcyB0aGlzIGFueWNhc3QgYWRkcmVzcworICovCitpbnQgaXB2
Nl9jaGtfYWNhc3RfYWRkcihzdHJ1Y3QgbmV0X2RldmljZSAqZGV2LCBzdHJ1
Y3QgaW42X2FkZHIgKmFkZHIpCit7CisJaWYgKGRldikKKwkJcmV0dXJuIGlw
djZfY2hrX2FjYXN0X2RldihkZXYsIGFkZHIpOworCXJlYWRfbG9jaygmZGV2
X2Jhc2VfbG9jayk7CisJZm9yIChkZXY9ZGV2X2Jhc2U7IGRldjsgZGV2PWRl
di0+bmV4dCkKKwkJaWYgKGlwdjZfY2hrX2FjYXN0X2RldihkZXYsIGFkZHIp
KQorCQkJYnJlYWs7CisJcmVhZF91bmxvY2soJmRldl9iYXNlX2xvY2spOwor
CXJldHVybiBkZXYgIT0gMDsKK30KKworCisjaWZkZWYgQ09ORklHX1BST0Nf
RlMKK2ludCBhbnljYXN0Nl9nZXRfaW5mbyhjaGFyICpidWZmZXIsIGNoYXIg
KipzdGFydCwgb2ZmX3Qgb2Zmc2V0LCBpbnQgbGVuZ3RoKQoreworCW9mZl90
IHBvcz0wLCBiZWdpbj0wOworCXN0cnVjdCBpZmFjYWRkcjYgKmltOworCWlu
dCBsZW49MDsKKwlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2OworCQorCXJlYWRf
bG9jaygmZGV2X2Jhc2VfbG9jayk7CisJZm9yIChkZXYgPSBkZXZfYmFzZTsg
ZGV2OyBkZXYgPSBkZXYtPm5leHQpIHsKKwkJc3RydWN0IGluZXQ2X2RldiAq
aWRldjsKKworCQlpZiAoKGlkZXYgPSBpbjZfZGV2X2dldChkZXYpKSA9PSBO
VUxMKQorCQkJY29udGludWU7CisKKwkJcmVhZF9sb2NrX2JoKCZpZGV2LT5s
b2NrKTsKKwkJZm9yIChpbSA9IGlkZXYtPmFjX2xpc3Q7IGltOyBpbSA9IGlt
LT5hY2FfbmV4dCkgeworCQkJaW50IGk7CisKKwkJCWxlbiArPSBzcHJpbnRm
KGJ1ZmZlcitsZW4sIiUtNGQgJS0xNXMgIiwgZGV2LT5pZmluZGV4LCBkZXYt
Pm5hbWUpOworCisJCQlmb3IgKGk9MDsgaTwxNjsgaSsrKQorCQkJCWxlbiAr
PSBzcHJpbnRmKGJ1ZmZlcitsZW4sICIlMDJ4IiwgaW0tPmFjYV9hZGRyLnM2
X2FkZHJbaV0pOworCisJCQlsZW4gKz0gc3ByaW50ZihidWZmZXIrbGVuLCAi
ICU1ZFxuIiwgaW0tPmFjYV91c2Vycyk7CisKKwkJCXBvcz1iZWdpbitsZW47
CisJCQlpZiAocG9zIDwgb2Zmc2V0KSB7CisJCQkJbGVuPTA7CisJCQkJYmVn
aW49cG9zOworCQkJfQorCQkJaWYgKHBvcyA+IG9mZnNldCtsZW5ndGgpIHsK
KwkJCQlyZWFkX3VubG9ja19iaCgmaWRldi0+bG9jayk7CisJCQkJaW42X2Rl
dl9wdXQoaWRldik7CisJCQkJZ290byBkb25lOworCQkJfQorCQl9CisJCXJl
YWRfdW5sb2NrX2JoKCZpZGV2LT5sb2NrKTsKKwkJaW42X2Rldl9wdXQoaWRl
dik7CisJfQorCitkb25lOgorCXJlYWRfdW5sb2NrKCZkZXZfYmFzZV9sb2Nr
KTsKKworCSpzdGFydD1idWZmZXIrKG9mZnNldC1iZWdpbik7CisJbGVuLT0o
b2Zmc2V0LWJlZ2luKTsKKwlpZihsZW4+bGVuZ3RoKQorCQlsZW49bGVuZ3Ro
OworCWlmIChsZW48MCkKKwkJbGVuPTA7CisJcmV0dXJuIGxlbjsKK30KKwor
I2VuZGlmCmRpZmYgLXJ1TiBsaW51eC0yLjUuNDQvbmV0L2lwdjYvaWNtcC5j
IGxpbnV4LTIuNS40NEFDL25ldC9pcHY2L2ljbXAuYwotLS0gbGludXgtMi41
LjQ0L25ldC9pcHY2L2ljbXAuYwlGcmkgT2N0IDE4IDIxOjAxOjIwIDIwMDIK
KysrIGxpbnV4LTIuNS40NEFDL25ldC9pcHY2L2ljbXAuYwlNb24gT2N0IDI4
IDEyOjM4OjA5IDIwMDIKQEAgLTM4OCw3ICszODgsOCBAQAogCiAJc2FkZHIg
PSAmc2tiLT5uaC5pcHY2aC0+ZGFkZHI7CiAKLQlpZiAoaXB2Nl9hZGRyX3R5
cGUoc2FkZHIpICYgSVBWNl9BRERSX01VTFRJQ0FTVCkKKwlpZiAoaXB2Nl9h
ZGRyX3R5cGUoc2FkZHIpICYgSVBWNl9BRERSX01VTFRJQ0FTVCB8fAorCSAg
ICBpcHY2X2Noa19hY2FzdF9hZGRyKDAsIHNhZGRyKSkgCiAJCXNhZGRyID0g
TlVMTDsKIAogCW1zZy5pY21waC5pY21wNl90eXBlID0gSUNNUFY2X0VDSE9f
UkVQTFk7CmRpZmYgLXJ1TiBsaW51eC0yLjUuNDQvbmV0L2lwdjYvaXB2Nl9z
b2NrZ2x1ZS5jIGxpbnV4LTIuNS40NEFDL25ldC9pcHY2L2lwdjZfc29ja2ds
dWUuYwotLS0gbGludXgtMi41LjQ0L25ldC9pcHY2L2lwdjZfc29ja2dsdWUu
YwlGcmkgT2N0IDE4IDIxOjAxOjA5IDIwMDIKKysrIGxpbnV4LTIuNS40NEFD
L25ldC9pcHY2L2lwdjZfc29ja2dsdWUuYwlNb24gT2N0IDI4IDEyOjM4OjA5
IDIwMDIKQEAgLTM1MSw2ICszNTEsMjQgQEAKIAkJCXJldHYgPSBpcHY2X3Nv
Y2tfbWNfZHJvcChzaywgbXJlcS5pcHY2bXJfaWZpbmRleCwgJm1yZXEuaXB2
Nm1yX211bHRpYWRkcik7CiAJCWJyZWFrOwogCX0KKwljYXNlIElQVjZfSk9J
Tl9BTllDQVNUOgorCWNhc2UgSVBWNl9MRUFWRV9BTllDQVNUOgorCXsKKwkJ
c3RydWN0IGlwdjZfbXJlcSBtcmVxOworCisJCWlmIChvcHRsZW4gIT0gc2l6
ZW9mKHN0cnVjdCBpcHY2X21yZXEpKQorCQkJZ290byBlX2ludmFsOworCisJ
CXJldHYgPSAtRUZBVUxUOworCQlpZiAoY29weV9mcm9tX3VzZXIoJm1yZXEs
IG9wdHZhbCwgc2l6ZW9mKHN0cnVjdCBpcHY2X21yZXEpKSkKKwkJCWJyZWFr
OworCisJCWlmIChvcHRuYW1lID09IElQVjZfSk9JTl9BTllDQVNUKQorCQkJ
cmV0diA9IGlwdjZfc29ja19hY19qb2luKHNrLCBtcmVxLmlwdjZtcl9pZmlu
ZGV4LCAmbXJlcS5pcHY2bXJfYWNhZGRyKTsKKwkJZWxzZQorCQkJcmV0diA9
IGlwdjZfc29ja19hY19kcm9wKHNrLCBtcmVxLmlwdjZtcl9pZmluZGV4LCAm
bXJlcS5pcHY2bXJfYWNhZGRyKTsKKwkJYnJlYWs7CisJfQogCWNhc2UgSVBW
Nl9ST1VURVJfQUxFUlQ6CiAJCXJldHYgPSBpcDZfcmFfY29udHJvbChzaywg
dmFsLCBOVUxMKTsKIAkJYnJlYWs7CmRpZmYgLXJ1TiBsaW51eC0yLjUuNDQv
bmV0L2lwdjYvbmRpc2MuYyBsaW51eC0yLjUuNDRBQy9uZXQvaXB2Ni9uZGlz
Yy5jCi0tLSBsaW51eC0yLjUuNDQvbmV0L2lwdjYvbmRpc2MuYwlGcmkgT2N0
IDE4IDIxOjAxOjU5IDIwMDIKKysrIGxpbnV4LTIuNS40NEFDL25ldC9pcHY2
L25kaXNjLmMJTW9uIE9jdCAyOCAxMzoxMjoyNyAyMDAyCkBAIC0zNzgsNyAr
Mzc4LDEwIEBACiAJCSAgIHN0cnVjdCBpbjZfYWRkciAqZGFkZHIsIHN0cnVj
dCBpbjZfYWRkciAqc29saWNpdGVkX2FkZHIsCiAJCSAgIGludCByb3V0ZXIs
IGludCBzb2xpY2l0ZWQsIGludCBvdmVycmlkZSwgaW50IGluY19vcHQpIAog
eworCXN0YXRpYyBzdHJ1Y3QgaW42X2FkZHIgdG1wYWRkcjsKKwlzdHJ1Y3Qg
aW5ldDZfaWZhZGRyICppZnA7CiAgICAgICAgIHN0cnVjdCBzb2NrICpzayA9
IG5kaXNjX3NvY2tldC0+c2s7CisJc3RydWN0IGluNl9hZGRyICpzcmNfYWRk
cjsKICAgICAgICAgc3RydWN0IG5kX21zZyAqbXNnOwogICAgICAgICBpbnQg
bGVuOwogICAgICAgICBzdHJ1Y3Qgc2tfYnVmZiAqc2tiOwpAQCAtNDAwLDEz
ICs0MDMsMjMgQEAKIAkJTkRfUFJJTlRLMSgic2VuZF9uYTogYWxsb2Mgc2ti
IGZhaWxlZFxuIik7CiAJCXJldHVybjsKIAl9CisJLyogZm9yIGFueWNhc3Qg
b3IgcHJveHksIHNvbGljaXRlZF9hZGRyICE9IHNyY19hZGRyICovCisJaWZw
ID0gaXB2Nl9nZXRfaWZhZGRyKHNvbGljaXRlZF9hZGRyLCBkZXYpOworCWlm
IChpZnApIHsKKwkJc3JjX2FkZHIgPSBzb2xpY2l0ZWRfYWRkcjsKKwkJaW42
X2lmYV9wdXQoaWZwKTsKKwl9IGVsc2UgeworCQlpZiAoaXB2Nl9kZXZfZ2V0
X3NhZGRyKGRldiwgZGFkZHIsICZ0bXBhZGRyLCAwKSkKKwkJCXJldHVybjsK
KwkJc3JjX2FkZHIgPSAmdG1wYWRkcjsKKwl9CiAKIAlpZiAobmRpc2NfYnVp
bGRfbGxfaGRyKHNrYiwgZGV2LCBkYWRkciwgbmVpZ2gsIGxlbikgPT0gMCkg
ewogCQlrZnJlZV9za2Ioc2tiKTsKIAkJcmV0dXJuOwogCX0KIAotCWlwNl9u
ZF9oZHIoc2ssIHNrYiwgZGV2LCBzb2xpY2l0ZWRfYWRkciwgZGFkZHIsIElQ
UFJPVE9fSUNNUFY2LCBsZW4pOworCWlwNl9uZF9oZHIoc2ssIHNrYiwgZGV2
LCBzcmNfYWRkciwgZGFkZHIsIElQUFJPVE9fSUNNUFY2LCBsZW4pOwogCiAJ
bXNnID0gKHN0cnVjdCBuZF9tc2cgKikgc2tiX3B1dChza2IsIGxlbik7CiAK
QEAgLTQyNiw3ICs0MzksNyBAQAogCQluZGlzY19maWxsX29wdGlvbihtc2ct
Pm9wdCwgTkRfT1BUX1RBUkdFVF9MTF9BRERSLCBkZXYtPmRldl9hZGRyLCBk
ZXYtPmFkZHJfbGVuKTsKIAogCS8qIGNoZWNrc3VtICovCi0JbXNnLT5pY21w
aC5pY21wNl9ja3N1bSA9IGNzdW1faXB2Nl9tYWdpYyhzb2xpY2l0ZWRfYWRk
ciwgZGFkZHIsIGxlbiwgCisJbXNnLT5pY21waC5pY21wNl9ja3N1bSA9IGNz
dW1faXB2Nl9tYWdpYyhzcmNfYWRkciwgZGFkZHIsIGxlbiwgCiAJCQkJCQkg
SVBQUk9UT19JQ01QVjYsCiAJCQkJCQkgY3N1bV9wYXJ0aWFsKChfX3U4ICop
IG1zZywgCiAJCQkJCQkJICAgICAgbGVuLCAwKSk7CkBAIC0xMTMzLDYgKzEx
NDYsNTEgQEAKIAkJCQl9CiAJCQl9CiAJCQlpbjZfaWZhX3B1dChpZnApOwor
CQl9IGVsc2UgaWYgKGlwdjZfY2hrX2FjYXN0X2FkZHIoZGV2LCAmbXNnLT50
YXJnZXQpKSB7CisJCQlzdHJ1Y3QgaW5ldDZfZGV2ICppZGV2ID0gaW42X2Rl
dl9nZXQoZGV2KTsKKwkJCWludCBhZGRyX3R5cGUgPSBpcHY2X2FkZHJfdHlw
ZShzYWRkcik7CisJCisJCQkvKiBhbnljYXN0ICovCisJCisJCQlpZiAoIWlk
ZXYpIHsKKwkJCQkvKiBYWFg6IGNvdW50IHRoaXMgZHJvcD8gKi8KKwkJCQly
ZXR1cm4gMDsKKwkJCX0KKwkKKwkJCWlmIChhZGRyX3R5cGUgPT0gSVBWNl9B
RERSX0FOWSkgeworCQkJCXN0cnVjdCBpbjZfYWRkciBtYWRkcjsKKwkKKwkJ
CQlpcHY2X2FkZHJfYWxsX25vZGVzKCZtYWRkcik7CisJCQkJbmRpc2Nfc2Vu
ZF9uYShkZXYsIE5VTEwsICZtYWRkciwgJm1zZy0+dGFyZ2V0LAorCQkJCQkg
ICAgICBpZGV2LT5jbmYuZm9yd2FyZGluZywgMCwgMCwgMSk7CisJCQkJaW42
X2Rldl9wdXQoaWRldik7CisJCQkJcmV0dXJuIDA7CisJCQl9CisJCisJCQlp
ZiAoYWRkcl90eXBlICYgSVBWNl9BRERSX1VOSUNBU1QpIHsKKwkJCQlpbnQg
aW5jID0gaXB2Nl9hZGRyX3R5cGUoZGFkZHIpJklQVjZfQUREUl9NVUxUSUNB
U1Q7CisJCQkJaWYgKGluYykgIAorCQkJCQluZF90Ymwuc3RhdHMucmN2X3By
b2Jlc19tY2FzdCsrOworCSAJCQllbHNlCisJCQkJCW5kX3RibC5zdGF0cy5y
Y3ZfcHJvYmVzX3VjYXN0Kys7CisJCisJCQkJLyoKKwkJCQkgKiAgIHVwZGF0
ZSAvIGNyZWF0ZSBjYWNoZSBlbnRyeQorCQkJCSAqICAgZm9yIHRoZSBzb3Vy
Y2UgYWRkZHJlc3MKKwkJCQkgKi8KKworCQkJCW5laWdoID0gbmVpZ2hfZXZl
bnRfbnMoJm5kX3RibCwgbGxhZGRyLCBzYWRkciwgc2tiLT5kZXYpOworCisJ
CQkJaWYgKG5laWdoIHx8ICFkZXYtPmhhcmRfaGVhZGVyKSB7CisJCQkJCW5k
aXNjX3NlbmRfbmEoZGV2LCBuZWlnaCwgc2FkZHIsCisJCQkJCQkmbXNnLT50
YXJnZXQsIAorCQkJCQkgICAgICAgIGlkZXYtPmNuZi5mb3J3YXJkaW5nLCAx
LCAwLCBpbmMpOworCQkJCQlpZiAobmVpZ2gpCisJCQkJCQluZWlnaF9yZWxl
YXNlKG5laWdoKTsKKwkJCQl9CisJCQl9CisJCQlpbjZfZGV2X3B1dChpZGV2
KTsKKwogCQl9IGVsc2UgewogCQkJc3RydWN0IGluZXQ2X2RldiAqaW42X2Rl
diA9IGluNl9kZXZfZ2V0KGRldik7CiAJCQlpbnQgYWRkcl90eXBlID0gaXB2
Nl9hZGRyX3R5cGUoc2FkZHIpOwpkaWZmIC1ydU4gbGludXgtMi41LjQ0L25l
dC9uZXRzeW1zLmMgbGludXgtMi41LjQ0QUMvbmV0L25ldHN5bXMuYwotLS0g
bGludXgtMi41LjQ0L25ldC9uZXRzeW1zLmMJRnJpIE9jdCAxOCAyMTowMTo0
OSAyMDAyCisrKyBsaW51eC0yLjUuNDRBQy9uZXQvbmV0c3ltcy5jCU1vbiBP
Y3QgMjggMTI6Mzg6MDkgMjAwMgpAQCAtNDY5LDYgKzQ2OSw4IEBACiBFWFBP
UlRfU1lNQk9MKHVucmVnaXN0ZXJfbmV0ZGV2aWNlKTsKIEVYUE9SVF9TWU1C
T0wobmV0ZGV2X3N0YXRlX2NoYW5nZSk7CiBFWFBPUlRfU1lNQk9MKGRldl9u
ZXdfaW5kZXgpOworRVhQT1JUX1NZTUJPTChkZXZfZ2V0YW55KTsKK0VYUE9S
VF9TWU1CT0woX19kZXZfZ2V0YW55KTsKIEVYUE9SVF9TWU1CT0woZGV2X2dl
dF9ieV9pbmRleCk7CiBFWFBPUlRfU1lNQk9MKF9fZGV2X2dldF9ieV9pbmRl
eCk7CiBFWFBPUlRfU1lNQk9MKGRldl9nZXRfYnlfbmFtZSk7Cg==

--0__=07BBE6F3DFE120F28f9e8a93df938690918c07BBE6F3DFE120F2--
