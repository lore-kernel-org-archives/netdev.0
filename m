From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] Prefix List patch against 2.5.70
Date: Fri, 30 May 2003 18:15:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ED80230.2030508@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

Following is a modified patch to implement Prefix List in IPv6. This has =
the
following changes from the patch submitted previously :

- Added user interface to retrieve the prefix list and other RA parameter=
s for
   DHVPv6 (http://sourceforge.net/projects/dhcpv6). Also incorporated Yos=
hifuji=E2=80=99s
   suggestion to change the user interface to use rtnetlink instead of /p=
roc (I
   have kept an OPTIONAL extra user interface which is provided as a file=
 in
   /proc/net, but that code can be removed - it is clearly marked as OPTI=
ONAL). I
   am not an expert in netlink code, so please excuse me if I have commit=
ted any
   blunders.
- Changed to support different parameters of a RA (flags, lifetime, addre=
ss of
   the router, etc.

Alexey had originally asked why I am not using fib to store the prefix li=
st, and
the reasons for the way this is designed as part of the dev are :

- To be a prefix list entry, it should come via an RA. So a manual ifconf=
ig
   <address> should not cause a prefix entry to be created. This can howe=
ver be
   avoided by adding more code to determine if this is an RA added routin=
g entry
   or a manual one. However, a routing table is per destination, while th=
e Prefix
   List is conceptualized as being per interface.

- Routing table will have lots of address prefixes that are not configure=
d to
   the local interface. Eg, none of the interfaces might have the address
   2002::2, but a route entry can exist for this; or I can add a route my=
self and
   should not expect to see the prefix of this route in the Prefix List. =
More
   code (flags) needs to be present to parse each entry in this case. Eg,=
 for
   each routing entry, you need to make sure it is the same device, that =
it is
   not a Link Local destination, and there is no 'next hop' field.

- Also, when the user requests the Prefix List, the search over a longer =
routing
   table across all radix tree nodes is more time consuming since there i=
s no key
   to use for the lookup (you have to always walk the entire tree). I thi=
nk it
   would be faster in the case where the routing table is very large, and=
 there
   aren't too many interfaces. The difference is that in case of routing =
table
   lookup, you go through the entire tree and parse each entry, while in =
the
   proposed approach, the linear search is only done to locate the 'dev' =
and then
   the work is more straightforward =E2=80=93  return all entries.

The implementation is done by adding the prefix on receipt of a RA (or up=
date
the prefix) to the list of prefixes off the inet6_dev structure (along wi=
th
addr_list, mc_list, ac_list, etc). This also has a new spinlock in the st=
ructure
so that the idev->lock need not be held in writer mode on every RA, rathe=
r the
spinlock is held.

Following is the patch against 2.5.70 (I have created against 2.4.20 also=
, but
am holding off on that).

Thanks,

- KK

diff -ruN linux-2.5.70.org/include/linux/icmpv6.h=20
linux-2.5.70/include/linux/icmpv6.h
--- linux-2.5.70.org/include/linux/icmpv6.h	2003-05-26 18:00:26.000000000=
 -0700
+++ linux-2.5.70/include/linux/icmpv6.h	2003-05-30 15:14:46.000000000 -07=
00
@@ -122,6 +122,12 @@
  #define ICMPV6_UNK_OPTION		2

  /*
+ *	Bit flags of the RA
+ */
+#define ND_RA_FLAG_MANAGED		0x80
+#define ND_RA_FLAG_OTHER		0x40
+
+/*
   *	constants for (set|get)sockopt
   */

diff -ruN linux-2.5.70.org/include/linux/rtnetlink.h=20
linux-2.5.70/include/linux/rtnetlink.h
--- linux-2.5.70.org/include/linux/rtnetlink.h	2003-05-26 18:00:46.000000=
000 -0700
+++ linux-2.5.70/include/linux/rtnetlink.h	2003-05-30 15:14:46.000000000 =
-0700
@@ -47,7 +47,9 @@
  #define	RTM_DELTFILTER	(RTM_BASE+29)
  #define	RTM_GETTFILTER	(RTM_BASE+30)

-#define	RTM_MAX		(RTM_BASE+31)
+#define	RTM_GETPLIST	(RTM_BASE+34)
+
+#define	RTM_MAX		(RTM_BASE+35)

  /*
     Generic structure for encapsulation optional route information.
diff -ruN linux-2.5.70.org/include/net/addrconf.h=20
linux-2.5.70/include/net/addrconf.h
--- linux-2.5.70.org/include/net/addrconf.h	2003-05-26 18:00:46.000000000=
 -0700
+++ linux-2.5.70/include/net/addrconf.h	2003-05-30 15:16:29.000000000 -07=
00
@@ -45,6 +45,29 @@

  #define IN6_ADDR_HSIZE		16

+/* An element of the prefix list, which is added to idev->prefix_list */
+struct prefix_element {
+	struct list_head list;		/* linkage member for this entry */
+	struct prefix_info pinfo;	/* actual prefix information */
+	unsigned long timestamp;	/* jiffies when RA was received */
+	unsigned int ra_flags;		/* bit-flags contained in the RA */
+	struct in6_addr ra_addr;	/* router's address */
+};
+
+/* prefix list returned to user space in this structure */
+struct plist_user_info {
+	char name[IFNAMSIZ];		/* interface name */
+	int ifindex;			/* interface index */
+	int nprefixes;			/* number of elements in 'prefix' */
+	struct var_plist_user_info {	/* multiple elements */
+		char flags[3];		/* router advertised flags */
+		int plen;		/* prefix length */
+		__u32 valid;		/* valid lifetime */
+		struct in6_addr ra_addr;/* advertising router */
+		struct in6_addr prefix;	/* prefix */
+	} plist_vars[0];
+};
+
  extern void			addrconf_init(void);
  extern void			addrconf_cleanup(void);

@@ -95,7 +118,8 @@
  extern int ipv6_chk_mcast_addr(struct net_device *dev, struct in6_addr =
*group,
  		struct in6_addr *src_addr);

-extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len=
);
+extern void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len=
,
+		struct in6_addr *ra_addr, struct ra_msg *ra);

  /*
   *	anycast prototypes (anycast.c)
diff -ruN linux-2.5.70.org/include/net/if_inet6.h=20
linux-2.5.70/include/net/if_inet6.h
--- linux-2.5.70.org/include/net/if_inet6.h	2003-05-26 18:00:59.000000000=
 -0700
+++ linux-2.5.70/include/net/if_inet6.h	2003-05-30 15:17:59.000000000 -07=
00
@@ -176,6 +176,12 @@
  	struct timer_list	mc_gq_timer;	/* general query timer */
  	struct timer_list	mc_ifc_timer;	/* interface change timer */

+#ifdef CONFIG_IPV6_PREFIXLIST
+	struct list_head	prefix_list;
+	spinlock_t		prefix_lock;
+	int			prefix_count;	/* number of prefixes */
+#endif
+
  	struct ifacaddr6	*ac_list;
  	rwlock_t		lock;
  	atomic_t		refcnt;
diff -ruN linux-2.5.70.org/net/ipv6/Kconfig linux-2.5.70/net/ipv6/Kconfig
--- linux-2.5.70.org/net/ipv6/Kconfig	2003-05-26 18:00:40.000000000 -0700
+++ linux-2.5.70/net/ipv6/Kconfig	2003-05-30 17:58:10.000000000 -0700
@@ -42,4 +42,13 @@

  	  If unsure, say Y.

+config IPV6_PREFIXLIST
+	bool "IPv6: Prefix List"
+	depends on IPV6
+	---help---
+	  For applications needing to retrieve the list of prefixes supported
+	  on the system. Defined in RFC2461.
+
+	  If unsure, say Y.
+
  source "net/ipv6/netfilter/Kconfig"
diff -ruN linux-2.5.70.org/net/ipv6/addrconf.c linux-2.5.70/net/ipv6/addr=
conf.c
--- linux-2.5.70.org/net/ipv6/addrconf.c	2003-05-26 18:00:58.000000000 -0=
700
+++ linux-2.5.70/net/ipv6/addrconf.c	2003-05-30 17:55:31.000000000 -0700
@@ -67,6 +67,7 @@
  #include <net/ip.h>
  #include <linux/if_tunnel.h>
  #include <linux/rtnetlink.h>
+#include <linux/inet.h>

  #ifdef CONFIG_IPV6_PRIVACY
  #include <linux/random.h>
@@ -87,6 +88,8 @@
  #define ADBG(x)
  #endif

+#define INFINITE	0xffffffff
+
  #ifdef CONFIG_SYSCTL
  static void addrconf_sysctl_register(struct inet6_dev *idev, struct=20
ipv6_devconf *p);
  static void addrconf_sysctl_unregister(struct ipv6_devconf *p);
@@ -292,6 +295,9 @@
  	struct net_device *dev =3D idev->dev;
  	BUG_TRAP(idev->addr_list=3D=3DNULL);
  	BUG_TRAP(idev->mc_list=3D=3DNULL);
+#ifdef CONFIG_IPV6_PREFIXLIST
+	BUG_TRAP(list_empty(&idev->prefix_list) =3D=3D 1);
+#endif
  #ifdef NET_REFCNT_DEBUG
  	printk(KERN_DEBUG "in6_dev_finish_destroy: %s\n", dev ? dev->name : "N=
IL");
  #endif
@@ -319,6 +325,10 @@
  	if (ndev) {
  		memset(ndev, 0, sizeof(struct inet6_dev));

+#ifdef CONFIG_IPV6_PREFIXLIST
+		INIT_LIST_HEAD(&ndev->prefix_list);
+		ndev->prefix_lock =3D SPIN_LOCK_UNLOCKED;
+#endif
  		ndev->lock =3D RW_LOCK_UNLOCKED;
  		ndev->dev =3D dev;
  		memcpy(&ndev->cnf, &ipv6_devconf_dflt, sizeof(ndev->cnf));
@@ -746,6 +756,321 @@
  }
  #endif

+#ifdef CONFIG_IPV6_PREFIXLIST
+
+/* Adds a prefix to the list of prefixes on this interface */
+static int ipv6_add_prefix(struct inet6_dev *idev, struct prefix_info *p=
info,
+                __u32 lifetime, struct in6_addr *ra_addr, struct ra_msg =
*ra)
+{
+	int ifindex;
+	struct in6_addr	prefix;
+	struct list_head *head;
+	struct prefix_element *p;
+
+	ipv6_addr_prefix(&prefix, &pinfo->prefix, pinfo->prefix_len);
+
+	/* Check if the prefix exists in our list */
+
+	read_lock_bh(&idev->lock);
+	spin_lock_bh(&idev->prefix_lock);
+	ifindex =3D idev->dev->ifindex;
+	list_for_each(head, &idev->prefix_list) {
+		p =3D list_entry(head, struct prefix_element, list);
+		if (p->pinfo.prefix_len =3D=3D pinfo->prefix_len
+		    && ipv6_addr_cmp(&p->pinfo.prefix, &prefix) =3D=3D 0) {
+			/* Existing Prefix, modify it with new values */
+			p->pinfo.valid =3D lifetime;
+			p->timestamp =3D jiffies;
+			ipv6_addr_copy(&p->ra_addr, ra_addr);
+			p->ra_flags =3D 0; /* overwrite prev value */
+			if (ra->icmph.icmp6_addrconf_managed)
+				p->ra_flags |=3D ND_RA_FLAG_MANAGED;
+			if (ra->icmph.icmp6_addrconf_other)
+				p->ra_flags |=3D ND_RA_FLAG_OTHER;
+			spin_unlock_bh(&idev->prefix_lock);
+			read_unlock_bh(&idev->lock);
+			return 0;
+		}
+	}
+
+	/* New Prefix, allocate one and fill in */
+	if ((p =3D kmalloc(sizeof(struct prefix_element), GFP_ATOMIC)) =3D=3D N=
ULL) {
+		ADBG(("ipv6_add_prefix: malloc failed\n"));
+		spin_unlock_bh(&idev->prefix_lock);
+		read_unlock_bh(&idev->lock);
+		return -1;
+	}
+	memset(p, 0, sizeof(*p));
+	INIT_LIST_HEAD(&p->list);
+	p->pinfo.valid =3D lifetime;
+	p->timestamp =3D jiffies;
+	p->pinfo.prefix_len =3D pinfo->prefix_len;
+	ipv6_addr_copy(&p->pinfo.prefix, &prefix);
+	ipv6_addr_copy(&p->ra_addr, ra_addr);
+	if (ra->icmph.icmp6_addrconf_managed)
+		p->ra_flags =3D ND_RA_FLAG_MANAGED;
+	if (ra->icmph.icmp6_addrconf_other)
+		p->ra_flags |=3D ND_RA_FLAG_OTHER;
+
+	list_add(&p->list, idev->prefix_list.prev);	/* add to end of list */
+	idev->prefix_count++;
+	spin_unlock_bh(&idev->prefix_lock);
+	read_unlock_bh(&idev->lock);
+	return 0;
+}
+
+/* Kernel level interface to the prefix list */
+int ipv6_get_prefix_entries(struct prefix_info **plist, int ifindex, int=
 plen)
+{
+	int count;
+	struct net_device *dev;
+	struct inet6_dev *idev;
+	struct list_head *head;
+	struct prefix_element *p;
+
+	if (plist =3D=3D NULL) {
+		BUG_TRAP(plist !=3D NULL);
+		return -EINVAL;
+	}
+	if ((dev =3D dev_get_by_index(ifindex)) =3D=3D NULL) {
+		printk(KERN_WARNING "Bad I/F (%d) in ipv6_get_prefix_entries\n",
+		       ifindex);
+		return -EINVAL;
+	}
+
+	if ((idev =3D __in6_dev_get(dev)) =3D=3D NULL) {
+		dev_put(dev);
+		return -EINVAL;
+	}
+
+	read_lock_bh(&idev->lock);
+	if (!(count =3D idev->prefix_count)) {
+		/* No elements on list */
+		goto out;
+	}
+	if ((*plist =3D kmalloc(count * sizeof(struct prefix_info),
+			      GFP_ATOMIC)) =3D=3D NULL) {
+		count =3D -ENOMEM;
+		goto out;
+	}
+	count =3D 0;
+	spin_lock_bh(&idev->prefix_lock);
+	list_for_each(head, &idev->prefix_list) {
+		p =3D list_entry(head, struct prefix_element, list);
+		if (plen =3D=3D 0 || p->pinfo.prefix_len =3D=3D plen) {
+			memcpy(*plist + count, &p->pinfo,
+			       sizeof(struct prefix_info));
+			count++;
+		}
+	}
+	spin_unlock_bh(&idev->prefix_lock);
+ out:
+	read_unlock_bh(&idev->lock);
+	dev_put(dev);
+	return count;
+}
+
+/* User level interface to the prefix list */
+int prefix_list_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	/* variables for manipulating prefix_list */
+	int i, nprefixes, count;
+	struct net_device *dev;
+	struct inet6_dev *idev;
+	struct list_head *head;
+	struct prefix_element *p_el;
+
+	/* variables for manipulating netlink */
+	int type =3D cb->nlh->nlmsg_type;
+	struct nlmsghdr  *nlh;
+	struct plist_user_info *pinfo;
+	unsigned char *b =3D skb->tail, *org_tail =3D skb->tail;
+
+	read_lock(&dev_base_lock);
+	for (dev =3D dev_base; dev; dev =3D dev->next) {
+		if (!(idev =3D __in6_dev_get(dev)))
+			continue;
+		read_lock_bh(&idev->lock);
+		if (!(nprefixes =3D idev->prefix_count)) {
+			read_unlock_bh(&idev->lock);
+			continue;
+		}
+		nlh =3D NLMSG_PUT(skb, NETLINK_CB(cb->skb).pid,
+				cb->nlh->nlmsg_seq, type, sizeof(*pinfo) +
+				nprefixes * sizeof(struct var_plist_user_info));
+		pinfo =3D NLMSG_DATA(nlh);
+		count =3D 0;
+		spin_lock_bh(&idev->prefix_lock);
+		list_for_each(head, &idev->prefix_list) {
+			p_el =3D list_entry(head, struct prefix_element, list);
+			if (!count) {	/* store stuff first time */
+				strcpy(pinfo->name, dev->name);
+				pinfo->ifindex =3D dev->ifindex;
+			}
+			pinfo->plist_vars[count].plen =3D p_el->pinfo.prefix_len;
+			pinfo->plist_vars[count].valid =3D p_el->pinfo.valid -
+				(jiffies - p_el->timestamp)/HZ;
+			if ((p_el->ra_flags & (ND_RA_FLAG_MANAGED |
+			    ND_RA_FLAG_OTHER))
+			    =3D=3D (ND_RA_FLAG_MANAGED|ND_RA_FLAG_OTHER))
+				strcpy(pinfo->plist_vars[count].flags, "MO");
+			else if (p_el->ra_flags & ND_RA_FLAG_MANAGED)
+				strcpy(pinfo->plist_vars[count].flags, "M");
+			else if (p_el->ra_flags & ND_RA_FLAG_OTHER)
+				strcpy(pinfo->plist_vars[count].flags, "O");
+			else
+				strcpy(pinfo->plist_vars[count].flags, "-");
+			ipv6_addr_copy(&pinfo->plist_vars[count].ra_addr,
+			    &p_el->ra_addr);
+			for (i =3D 0; i < 8; i++)
+				pinfo->plist_vars[count].ra_addr.s6_addr16[i] =3D
+				    __constant_ntohs(pinfo->plist_vars[count].ra_addr.s6_addr16[i]);
+			ipv6_addr_copy(&pinfo->plist_vars[count].prefix,
+			    &p_el->pinfo.prefix);
+			for (i =3D 0; i < p_el->pinfo.prefix_len/16; i++)
+				pinfo->plist_vars[count].prefix.s6_addr16[i] =3D
+				    __constant_ntohs(pinfo->plist_vars[count].prefix.s6_addr16[i]);
+			count++;
+		}
+		spin_unlock_bh(&idev->prefix_lock);
+		read_unlock_bh(&idev->lock);
+		BUG_TRAP(nprefixes =3D=3D count);
+		pinfo->nprefixes =3D count;
+		nlh->nlmsg_len =3D skb->tail - org_tail;
+		org_tail =3D skb->tail;
+	}
+	read_unlock(&dev_base_lock);
+	return skb->len;
+
+nlmsg_failure :
+	read_unlock_bh(&idev->lock);
+	read_unlock(&dev_base_lock);
+	skb_trim(skb, b - skb->data);
+        return -1;
+}
+
+/* Expire prefixes from the idev list periodically */
+static void ipv6_expire_prefixes(void)
+{
+	unsigned long		now =3D jiffies;
+	struct net_device	*dev;
+	struct inet6_dev	*idev;
+	struct list_head	*head, *next;
+	struct prefix_element	*p;
+	unsigned long		age;
+
+	read_lock(&dev_base_lock);
+	for (dev =3D dev_base; dev; dev =3D dev->next) {
+		if (!(idev =3D __in6_dev_get(dev))) {
+			continue;
+		}
+		read_lock_bh(&idev->lock);
+		if (!idev->prefix_count) {
+			read_unlock_bh(&idev->lock);
+			continue;
+		}
+		spin_lock_bh(&idev->prefix_lock);
+		list_for_each_safe(head, next, &idev->prefix_list) {
+			p =3D list_entry(head, struct prefix_element, list);
+			if (p->pinfo.valid !=3D INFINITE) {
+				age =3D (now - p->timestamp) / HZ;
+				if (age > p->pinfo.valid) {
+					idev->prefix_count--;
+					list_del(&p->list);
+					kfree(p);
+				}
+			}
+		}
+		spin_unlock_bh(&idev->prefix_lock);
+		read_unlock_bh(&idev->lock);
+	}
+	read_unlock(&dev_base_lock);
+}
+
+#ifdef CONFIG_PROC_FS
+
+/* OPTIONAL alternate interface to prefix list via /proc filesystem */
+static int prefix_list_proc_dump(char *buffer, char **start, off_t offse=
t,
+			   int length)
+{
+	int i;
+	int len =3D 0;
+	off_t pos=3D0;
+	off_t begin=3D0;
+
+	struct net_device *dev;
+	struct inet6_dev *idev;
+	struct list_head *head;
+	struct prefix_element *p;
+
+	read_lock(&dev_base_lock);
+	for (dev =3D dev_base; dev; dev =3D dev->next) {
+		if (!(idev =3D __in6_dev_get(dev))) {
+			continue;
+		}
+		read_lock_bh(&idev->lock);
+		spin_lock_bh(&idev->prefix_lock);
+		if (list_empty(&idev->prefix_list)) {
+			spin_unlock_bh(&idev->prefix_lock);
+			read_unlock_bh(&idev->lock);
+			continue;
+		}
+		list_for_each(head, &idev->prefix_list) {
+			p =3D list_entry(head, struct prefix_element, list);
+			len +=3D sprintf(buffer + len, "%-6s %-4d %-4d",
+				dev->name, dev->ifindex, p->pinfo.prefix_len);
+			if ((p->ra_flags & (ND_RA_FLAG_MANAGED |
+			    ND_RA_FLAG_OTHER))
+			    =3D=3D (ND_RA_FLAG_MANAGED|ND_RA_FLAG_OTHER))
+				len +=3D sprintf(buffer + len, "%-4s", "MO");
+			else if (p->ra_flags & ND_RA_FLAG_MANAGED)
+				len +=3D sprintf(buffer + len, "%-4s", "M");
+			else if (p->ra_flags & ND_RA_FLAG_OTHER)
+				len +=3D sprintf(buffer + len, "%-4s", "O");
+			else
+				len +=3D sprintf(buffer + len, "%-4s", "-");
+			for (i =3D 0; i < p->pinfo.prefix_len / 8; i++) {
+				sprintf(buffer + len, "%02x",
+					p->pinfo.prefix.s6_addr[i]);
+				len +=3D 2;
+			}
+			len +=3D sprintf(buffer + len, "%-4s", " ");
+			for (i =3D 0; i < 16; i++) {
+				sprintf(buffer + len, "%02x",
+					p->ra_addr.s6_addr[i]);
+				len +=3D 2;
+			}
+			len +=3D sprintf(buffer + len, "\n");
+			pos=3Dbegin+len;
+			if(pos<offset) {
+				len=3D0;
+				begin=3Dpos;
+			}
+			if(pos>offset+length) {
+				spin_unlock_bh(&idev->prefix_lock);
+				read_unlock_bh(&idev->lock);
+				goto done;
+			}
+		}
+		spin_unlock_bh(&idev->prefix_lock);
+		read_unlock_bh(&idev->lock);
+	}
+done:
+	read_unlock(&dev_base_lock);
+
+	*start=3Dbuffer+(offset-begin);
+	len-=3D(offset-begin);
+	if(len>length)
+		len=3Dlength;
+	if(len<0)
+		len=3D0;
+	return len;
+}
+
+#endif	/* CONFIG_PROC_FS */
+
+#endif	/* CONFIG_IPV6_PREFIXLIST */
+
  /*
   *	Choose an appropriate source address
   *	should do:
@@ -1281,7 +1606,8 @@
  	return idev;
  }

-void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len)
+void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len,
+	struct in6_addr *ra_addr, struct ra_msg *ra)
  {
  	struct prefix_info *pinfo;
  	struct rt6_info *rt;
@@ -1355,6 +1681,12 @@
  		addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
  				      dev, rt_expires, RTF_ADDRCONF|RTF_EXPIRES);
  	}
+#ifdef CONFIG_IPV6_PREFIXLIST
+	if (pinfo->onlink && valid_lft)
+		/* Add this prefix to the list of prefixes on this interface */
+		ipv6_add_prefix(in6_dev, pinfo, valid_lft, ra_addr, ra);
+#endif
+
  	if (rt)
  		dst_release(&rt->u.dst);

@@ -1851,6 +2183,10 @@
  	struct inet6_dev *idev;
  	struct inet6_ifaddr *ifa, **bifa;
  	int i;
+#ifdef CONFIG_IPV6_PREFIXLIST
+	struct list_head	*head, *next;
+	struct prefix_element	*p;
+#endif

  	ASSERT_RTNL();

@@ -1913,6 +2249,17 @@
  	else
  		ipv6_mc_down(idev);

+#ifdef CONFIG_IPV6_PREFIXLIST
+	/* Step 5: Free up Prefix List */
+	spin_lock_bh(&idev->prefix_lock);
+	list_for_each_safe(head, next, &idev->prefix_list) {
+		p =3D list_entry(head, struct prefix_element, list);
+		kfree(p);
+	}
+	INIT_LIST_HEAD(&idev->prefix_list);
+	spin_unlock_bh(&idev->prefix_lock);
+#endif
+
  	/* Shot the device (if unregistered) */

  	if (how =3D=3D 1) {
@@ -2141,6 +2488,7 @@
  	return len;
  }

+
  #endif	/* CONFIG_PROC_FS */

  /*
@@ -2241,6 +2589,15 @@
  		write_unlock(&addrconf_hash_lock);
  	}

+#ifdef CONFIG_IPV6_PREFIXLIST
+	/*
+	 * We need to expire prefixes even if no addresses are deleted in the
+	 * loop above, since autoconfiguration may not be set in all router
+	 * advertisements.
+	 */
+	ipv6_expire_prefixes();
+#endif
+
  	addr_chk_timer.expires =3D time_before(next, jiffies + HZ) ? jiffies +=
 HZ : next;
  	add_timer(&addr_chk_timer);
  	spin_unlock_bh(&addrconf_verify_lock);
@@ -2692,6 +3049,10 @@

  void __init addrconf_init(void)
  {
+#ifdef CONFIG_IPV6_PREFIXLIST
+	struct rtnetlink_link *link_p;
+#endif
+
  #ifdef MODULE
  	struct net_device *dev;
  #endif
@@ -2730,7 +3091,16 @@
  #ifdef CONFIG_PROC_FS
  	proc_net_create("if_inet6", 0, iface_proc_info);
  #endif
-=09
+
+#ifdef CONFIG_IPV6_PREFIXLIST
+	if ((link_p =3D rtnetlink_links[PF_UNSPEC]) !=3D NULL) /* PF_INET6 ? */
+		link_p[RTM_GETPLIST - RTM_BASE].dumpit =3D prefix_list_dump;
+#ifdef CONFIG_PROC_FS
+	/* OPTIONAL alternate interface to prefix list via /proc filesystem */
+	proc_net_create("ra6", 0, prefix_list_proc_dump);
+#endif
+#endif
+
  	addrconf_verify(0);
  	rtnetlink_links[PF_INET6] =3D inet6_rtnetlink_table;
  #ifdef CONFIG_SYSCTL
@@ -2798,6 +3168,9 @@

  #ifdef CONFIG_PROC_FS
  	proc_net_remove("if_inet6");
+#ifdef CONFIG_IPV6_PREFIXLIST
+	proc_net_remove("ra6");
+#endif
  #endif
  }
  #endif	/* MODULE */
diff -ruN linux-2.5.70.org/net/ipv6/ndisc.c linux-2.5.70/net/ipv6/ndisc.c
--- linux-2.5.70.org/net/ipv6/ndisc.c	2003-05-26 18:00:41.000000000 -0700
+++ linux-2.5.70/net/ipv6/ndisc.c	2003-05-30 15:14:46.000000000 -0700
@@ -1146,7 +1146,8 @@
  		for (p =3D ndopts.nd_opts_pi;
  		     p;
  		     p =3D ndisc_next_option(p, ndopts.nd_opts_pi_end)) {
-			addrconf_prefix_rcv(skb->dev, (u8*)p, (p->nd_opt_len) << 3);
+			addrconf_prefix_rcv(skb->dev, (u8*)p,
+			   (p->nd_opt_len) << 3, &skb->nh.ipv6h->saddr, ra_msg);
  		}
  	}
