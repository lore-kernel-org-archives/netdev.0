From: Anil K Prasad <aprasad@in.ibm.com>
Subject: Re: Linux kernel updates and ip_crossover patch
Date: Mon, 27 Oct 2003 10:34:13 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF42F61DB9.84FB2B55-ON86256DCC.0059F683-86256DCC.005A222B@in.ibm.com>
References: <3F9D44CD.2000609@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Daljeet Maini <mdaljeet@in.ibm.com>,
        Mehulkumar J Patel <mehul.patel@in.ibm.com>,
        Matthias Fruehauf <mfrueh@suse.de>, netdev@oss.sgi.com, olaf@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <3F9D44CD.2000609@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org








>>
>> We at IBM need IP CROSSOVER module as part of kernel source.

>Please send the ip-crossover patch to netdev.  I have written a patch
>to do the same thing, and am interested to see how this patch differs.

Here is the patch for IP-Cross over module.

Thanks,
Anil.

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


diff -urpN --exclude TAGS -X
/home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal
linux-2.4.21/Documentation/Configure.help
working-2.4.21-crossover/Documentation/Configure.help
--- linux-2.4.21/Documentation/Configure.help
2003-06-14 13:59:23.000000000 +1000
+++ working-2.4.21-crossover/Documentation/Configure.help
  2003-07-10 18:16:04.000000000 +1000
@@ -2954,6 +2954,18 @@ CONFIG_IP_NF_COMPAT_IPFWADM
   If you want to compile it as a module, say M here and read
   <file:Documentation/modules.txt>.  If unsure, say `N'.

+IP forced crossover support (EXPERIMENTAL)
+CONFIG_IP_NF_CROSSOVER
+  This option allows you to connect two local network cards
+  with a crossover cable, and then force packets to pass over
+  that cable (Linux will normally short-circuit such packets).
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>: the module will be called
+  ip_crossover.
+
+  Say `N'.
+
 EUI64 address check (EXPERIMENTAL)
 CONFIG_IP6_NF_MATCH_EUI64
   This module performs checking on the IPv6 source address
diff -urpN --exclude TAGS -X
/home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal
linux-2.4.21/net/ipv4/netfilter/Config.in
working-2.4.21-crossover/net/ipv4/netfilter/Config.in
--- linux-2.4.21/net/ipv4/netfilter/Config.in
2003-06-14 14:00:02.000000000 +1000
+++ working-2.4.21-crossover/net/ipv4/netfilter/Config.in
  2003-07-10 18:14:41.000000000 +1000
@@ -129,4 +129,7 @@ if [ "$CONFIG_IP_NF_CONNTRACK" != "y" ];
     fi
   fi
 fi
+
+dep_tristate '  IP forced crossover support (EXPERIMENTAL)'
CONFIG_IP_NF_CROSSOVER $CONFIG_EXPERIMENTAL
+
 endmenu
diff -urpN --exclude TAGS -X
/home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal
linux-2.4.21/net/ipv4/netfilter/Makefile
working-2.4.21-crossover/net/ipv4/netfilter/Makefile
--- linux-2.4.21/net/ipv4/netfilter/Makefile
2003-06-14 14:00:02.000000000 +1000
+++ working-2.4.21-crossover/net/ipv4/netfilter/Makefile
  2003-07-10 18:13:23.000000000 +1000
@@ -110,6 +110,8 @@ obj-$(CONFIG_IP_NF_COMPAT_IPFWADM) += ip

 obj-$(CONFIG_IP_NF_QUEUE) += ip_queue.o

+obj-$(CONFIG_IP_NF_CROSSOVER) += ip_crossover.o
+
 include $(TOPDIR)/Rules.make

 ip_conntrack.o: $(ip_conntrack-objs)
diff -urpN --exclude TAGS -X
/home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal
linux-2.4.21/net/ipv4/netfilter/ip_crossover.c
working-2.4.21-crossover/net/ipv4/netfilter/ip_crossover.c
--- linux-2.4.21/net/ipv4/netfilter/ip_crossover.c
1970-01-01 10:00:00.000000000 +1000
+++ working-2.4.21-crossover/net/ipv4/netfilter/ip_crossover.c
        2003-07-10 18:36:47.000000000 +1000
@@ -0,0 +1,262 @@
+/* Copyright 2003 Rusty Russell, IBM Corporation.
+ *
+ * Simple packet mangling.  The idea is to use a crossover between two
+ * local NICs for testing, then this module creates "phantom" boxes on
+ * each network at the interface address + 1.
+ *
+ * Packets sent to one phantom will come in like they came from the other.
+ *
+ * Usage:
+ *   ifconfig eth0 192.168.1.1
+ *   ifconfig eth1 192.168.2.1
+ *   arp -s 192.168.1.2 <hardware address of eth1>
+ *   arp -s 192.168.2.2 <hardware address of eth0>
+ *   modprobe ip_crossover dev1=eth0 dev2=eth1
+ *
+ *   Then doing ping 192.168.1.2, ICMP ping goes out eth0 and comes
+ *   back in eth1.  Reply goes out eth1 and comes back in eth0.  */
+#include <linux/config.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/ip.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/icmp.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <net/ip.h>
+#include <asm/checksum.h>
+
+struct ifinfo
+{
+                         /* Keep track of name so we can drop reference.
*/
+                         char name[IFNAMSIZ];
+
+                         /* Cached interface addr. */
+                         u32 ifaddr;
+
+                         /* "Phantom" box which gets mapped. */
+                         u32 phantom;
+};
+
+static struct ifinfo devinfo1, devinfo2;
+
+/* Stolen from Alexey's ip_nat_dumb. */
+static int nat_header(struct sk_buff *skb, u32 saddr, u32 daddr)
+{
+                         struct iphdr *iph = skb->nh.iph;
+
+                         u32 odaddr = iph->daddr;
+                         u32 osaddr = iph->saddr;
+                         u16 check;
+
+                         /* Rewrite IP header */
+                         iph->saddr = saddr;
+                         iph->daddr = daddr;
+                         iph->check = 0;
+                         iph->check = ip_fast_csum((unsigned char *)iph,
iph->ihl);
+
+                         /* If it is the first fragment, rewrite protocol
headers */
+                         if (!(iph->frag_off & htons(IP_OFFSET))) {
+                                                 u16 *cksum;
+
+                                                 switch(iph->protocol) {
+                                                 case IPPROTO_TCP:
+
cksum  = (u16*)&((struct tcphdr*)
+

(((char*)iph)+(iph->ihl<<2)))->check;
+
if ((u8*)(cksum+1) > skb->tail)
+
                    return 0;
+
check = *cksum;
+
if (skb->ip_summed != CHECKSUM_HW)
+
                    check = ~check;
+
check = csum_tcpudp_magic(iph->saddr, iph->daddr,
+
                                                                      0, 0,
check);
+
check = csum_tcpudp_magic(~osaddr, ~odaddr, 0, 0,
+

~check);
+
if (skb->ip_summed == CHECKSUM_HW)
+
                    check = ~check;
+
*cksum = check;
+
break;
+                                                 case IPPROTO_UDP:
+
cksum  = (u16*)&((struct udphdr*)
+

(((char*)iph)+(iph->ihl<<2)))->check;
+
if ((u8*)(cksum+1) > skb->tail)
+
                    return 0;
+
if ((check = *cksum) != 0) {
+
                    check = csum_tcpudp_magic(iph->saddr,
+

                iph->daddr, 0, 0,
+

                ~check);
+
                    check = csum_tcpudp_magic(~osaddr, ~odaddr,
+

                0, 0, ~check);
+
                    *cksum = check ? : 0xFFFF;
+                                                                         }
+
break;
+                                                 case IPPROTO_ICMP:
+                                                 {
+
struct icmphdr *icmph
+
                    = (struct icmphdr*)((char*)iph+(iph->ihl<<2));
+
struct iphdr *ciph;
+
u32 idaddr, isaddr;
+
+
if ((icmph->type != ICMP_DEST_UNREACH) &&
+
(icmph->type != ICMP_TIME_EXCEEDED) &&
+
(icmph->type != ICMP_PARAMETERPROB))
+
                    break;
+
+
ciph = (struct iphdr *) (icmph + 1);
+
+
if ((u8*)(ciph+1) > skb->tail)
+
                    return 0;
+
+
isaddr = ciph->saddr;
+
idaddr = ciph->daddr;
+
+
/* Change addresses inside ICMP packet. */
+
ciph->daddr = iph->saddr;
+
ciph->saddr = iph->daddr;
+
cksum  = &icmph->checksum;
+
/* Using tcpudp primitive. Why not? */
+
check  = csum_tcpudp_magic(ciph->saddr, ciph->daddr,
+
                                                                       0,
0, ~(*cksum));
+
*cksum = csum_tcpudp_magic(~isaddr, ~idaddr, 0, 0,
+

~check);
+
break;
+                                                 }
+                                                 default:
+
break;
+                                                 }
+                         }
+                         return 1;
+}
+
+static unsigned int xover_hook(unsigned int hook,
+
struct sk_buff **pskb,
+
const struct net_device *in,
+
const struct net_device *out,
+
int (*okfn)(struct sk_buff *))
+{
+                         /* Going out to phantom box 1: change it to
coming from
+           phantom box 2, and vice versa. */
+                         if ((*pskb)->nh.iph->daddr == devinfo1.phantom) {
+                                    /*           printk(KERN_DEBUG "dev1:
%u.%u.%u.%u->%u.%u.%u.%u"
+                                                        " becomes
%u.%u.%u.%u->%u.%u.%u.%u\n",
+
NIPQUAD((*pskb)->nh.iph->saddr),
+
NIPQUAD((*pskb)->nh.iph->daddr),
+
NIPQUAD(devinfo2.phantom),
+
NIPQUAD(devinfo2.ifaddr));*/
+                                                 if (!nat_header(*pskb,
devinfo2.phantom, devinfo2.ifaddr))
+
return NF_DROP;
+                         } else if ((*pskb)->nh.iph->daddr ==
devinfo2.phantom) {
+                         /*                      printk(KERN_DEBUG "dev1:
%u.%u.%u.%u->%u.%u.%u.%u"
+                                                        " becomes
%u.%u.%u.%u->%u.%u.%u.%u\n",
+
NIPQUAD((*pskb)->nh.iph->saddr),
+
NIPQUAD((*pskb)->nh.iph->daddr),
+
NIPQUAD(devinfo1.phantom),
+
NIPQUAD(devinfo1.ifaddr));*/
+                                                 if (!nat_header(*pskb,
devinfo1.phantom, devinfo1.ifaddr))
+
return NF_DROP;
+                         }
+
+                         return NF_ACCEPT;
+}
+
+static int __set_dev(const char *name, struct ifinfo *ifi)
+{
+                         struct net_device *dev;
+                         struct in_device *indev;
+
+                         dev = dev_get_by_name(name);
+                         if (!dev)
+                                                 goto fail;
+                         indev = __in_dev_get(dev);
+                         if (!indev || !indev->ifa_list)
+                                                 goto put_fail;
+
+                         ifi->ifaddr = indev->ifa_list->ifa_address;
+                         ifi->phantom =
htonl(ntohl(indev->ifa_list->ifa_address) + 1);
+                         if (ifi->phantom ==
indev->ifa_list->ifa_broadcast)
+                                                 goto put_fail;
+
+                         strncpy(ifi->name, name, sizeof(ifi->name)-1);
+                         printk(KERN_INFO "ip_crossover: phantom for %s:
%u.%u.%u.%u\n",
+                                ifi->name, NIPQUAD(ifi->phantom));
+                         return 0;
+
+put_fail:
+                         dev_put(dev);
+fail:
+                         printk(KERN_WARNING "ip_crossover: device %s is
not usable.\n", name);
+                         return -ENOENT;
+}
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,5,50)
+#include <linux/moduleparam.h>
+static int set_dev(const char *val, struct kernel_param *kp)
+{
+                         return __set_dev(val, kp->arg);
+}
+module_param_call(dev1, set_dev, NULL, &devinfo1, 0);
+module_param_call(dev2, set_dev, NULL, &devinfo2, 0);
+
+#define compat_parse_params()
+#define NF_HOOK_OWNER .owner = THIS_MODULE,
+#else
+static char *dev1, *dev2;
+
+MODULE_PARM(dev1, "s");
+MODULE_PARM(dev2, "s");
+
+static void compat_parse_params(void)
+{
+                         if (dev1)
+                                                 __set_dev(dev1,
&devinfo1);
+                         if (dev2)
+                                                 __set_dev(dev2,
&devinfo2);
+}
+
+#define NF_HOOK_OWNER
+#endif /* KERNEL_VERSION */
+
+static struct nf_hook_ops xover_ops
+= { .hook = xover_hook,
+    .pf = PF_INET,
+    .hooknum = NF_IP_POST_ROUTING,
+    .priority = NF_IP_PRI_MANGLE,
+    NF_HOOK_OWNER
+};
+
+static int __init init(void)
+{
+                         compat_parse_params();
+
+                         if (!devinfo1.name[0] || !devinfo2.name[0]) {
+                                                 printk(KERN_ERR
"ip_crossover: need dev1 and dev2 args\n");
+                                                 return -EINVAL;
+                         }
+
+                         return nf_register_hook(&xover_ops);
+}
+
+static void __exit fini(void)
+{
+                         struct net_device *dev;
+
+                         nf_unregister_hook(&xover_ops);
+
+                         /* Release devices. */
+                         dev = dev_get_by_name(devinfo1.name);
+                         dev_put(dev);
+                         dev_put(dev);
+
+                         dev = dev_get_by_name(devinfo2.name);
+                         dev_put(dev);
+                         dev_put(dev);
+}
+
+module_init(init);
+module_exit(fini);
+MODULE_LICENSE("GPL");
+MODULE_PARM_DESC(dev1, "First device for crossover (required)");
+MODULE_PARM_DESC(dev2, "Second device for crossover (required)");
