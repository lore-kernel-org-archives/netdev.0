From: Thomas Graf <tgraf@suug.ch>
Subject: iproute2 patch introducing mtu/txqlen/weight via rtnetlink
Date: Thu, 9 Sep 2004 18:48:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909164834.GB18994@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi Salim <hadi@cyberus.ca>,
        Stephen Hemminger <shemminger@osdl.org>,
        Eric Lemoine <eric.lemoine@gmail.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

- Convert mtu and txqlen to use rtnetlink instead of ioctl.
- Introduces weight.
- Updates local copy of rtnetlink.h.

Against iproute2-2.6.9-jamal, tested and working.
Will look into remaining ioctls later.


diff -urN iproute2-2.6.9-jamal.orig/include/linux/rtnetlink.h iproute2-2.6.9-jamal/include/linux/rtnetlink.h
--- iproute2-2.6.9-jamal.orig/include/linux/rtnetlink.h	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/include/linux/rtnetlink.h	2004-09-08 19:41:36.000000000 +0200
@@ -561,6 +561,12 @@
 #define IFLA_WIRELESS IFLA_WIRELESS
 	IFLA_PROTINFO,		/* Protocol specific information for a link */
 #define IFLA_PROTINFO IFLA_PROTINFO
+	IFLA_TXQLEN,
+#define IFLA_TXQLEN IFLA_TXQLEN
+	IFLA_MAP,
+#define IFLA_MAP IFLA_MAP
+	IFLA_WEIGHT,
+#define IFLA_WEIGHT IFLA_WEIGHT
 	__IFLA_MAX
 };
 
@@ -693,6 +699,88 @@
 
 /* End of information exported to user level */
 
+#ifdef __KERNEL__
+
+#include <linux/config.h>
+
+static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
+{
+	int len = strlen(str) + 1;
+	return len > rta->rta_len || memcmp(RTA_DATA(rta), str, len);
+}
+
+extern int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len);
+
+extern struct sock *rtnl;
+
+struct rtnetlink_link
+{
+	int (*doit)(struct sk_buff *, struct nlmsghdr*, void *attr);
+	int (*dumpit)(struct sk_buff *, struct netlink_callback *cb);
+};
+
+extern struct rtnetlink_link * rtnetlink_links[NPROTO];
+extern int rtnetlink_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb);
+extern int rtnetlink_send(struct sk_buff *skb, u32 pid, u32 group, int echo);
+extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
+
+extern void __rta_fill(struct sk_buff *skb, int attrtype, int attrlen, const void *data);
+
+#define RTA_PUT(skb, attrtype, attrlen, data) \
+({	if (unlikely(skb_tailroom(skb) < (int)RTA_SPACE(attrlen))) \
+		 goto rtattr_failure; \
+   	__rta_fill(skb, attrtype, attrlen, data); }) 
+
+static inline struct rtattr *
+__rta_reserve(struct sk_buff *skb, int attrtype, int attrlen)
+{
+	struct rtattr *rta;
+	int size = RTA_LENGTH(attrlen);
+
+	rta = (struct rtattr*)skb_put(skb, RTA_ALIGN(size));
+	rta->rta_type = attrtype;
+	rta->rta_len = size;
+	return rta;
+}
+
+#define __RTA_PUT(skb, attrtype, attrlen) \
+({ 	if (unlikely(skb_tailroom(skb) < (int)RTA_SPACE(attrlen))) \
+		goto rtattr_failure; \
+   	__rta_reserve(skb, attrtype, attrlen); })
+
+extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
+
+extern struct semaphore rtnl_sem;
+
+#define rtnl_shlock()		down(&rtnl_sem)
+#define rtnl_shlock_nowait()	down_trylock(&rtnl_sem)
+
+#define rtnl_shunlock()	do { up(&rtnl_sem); \
+		             if (rtnl && rtnl->sk_receive_queue.qlen) \
+				     rtnl->sk_data_ready(rtnl, 0); \
+		        } while(0)
+
+extern void rtnl_lock(void);
+extern void rtnl_unlock(void);
+extern void rtnetlink_init(void);
+
+#define ASSERT_RTNL() do { \
+	if (unlikely(down_trylock(&rtnl_sem) == 0)) { \
+		up(&rtnl_sem); \
+		printk(KERN_ERR "RTNL: assertion failed at %s (%d)\n", \
+		       __FILE__,  __LINE__); \
+		dump_stack(); \
+	} \
+} while(0)
+
+#define BUG_TRAP(x) do { \
+	if (unlikely(!(x))) { \
+		printk(KERN_ERR "KERNEL: assertion (%s) failed at %s (%d)\n", \
+			#x,  __FILE__ , __LINE__); \
+	} \
+} while(0)
+
+#endif /* __KERNEL__ */
 
 
 #endif	/* __LINUX_RTNETLINK_H */
diff -urN iproute2-2.6.9-jamal.orig/ip/ipaddress.c iproute2-2.6.9-jamal/ip/ipaddress.c
--- iproute2-2.6.9-jamal.orig/ip/ipaddress.c	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/ip/ipaddress.c	2004-09-08 19:57:30.000000000 +0200
@@ -182,6 +182,8 @@
 		fprintf(fp, "mtu %u ", *(int*)RTA_DATA(tb[IFLA_MTU]));
 	if (tb[IFLA_QDISC])
 		fprintf(fp, "qdisc %s ", (char*)RTA_DATA(tb[IFLA_QDISC]));
+	if (tb[IFLA_WEIGHT])
+		fprintf(fp, "weight %u ", *(uint32_t*)RTA_DATA(tb[IFLA_WEIGHT]));
 #ifdef IFLA_MASTER
 	if (tb[IFLA_MASTER]) {
 		SPRINT_BUF(b1);
diff -urN iproute2-2.6.9-jamal.orig/ip/iplink.c iproute2-2.6.9-jamal/ip/iplink.c
--- iproute2-2.6.9-jamal.orig/ip/iplink.c	2004-09-08 19:23:18.000000000 +0200
+++ iproute2-2.6.9-jamal/ip/iplink.c	2004-09-08 19:51:33.000000000 +0200
@@ -21,6 +21,7 @@
 #include <linux/if_packet.h>
 #include <linux/if_ether.h>
 #include <linux/sockios.h>
+#include <linux/rtnetlink.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
@@ -46,7 +47,8 @@
 	fprintf(stderr, "	                     txqueuelen PACKETS |\n");
 	fprintf(stderr, "	                     name NEWNAME |\n");
 	fprintf(stderr, "	                     address LLADDR | broadcast LLADDR |\n");
-	fprintf(stderr, "	                     mtu MTU }\n");
+	fprintf(stderr, "	                     mtu MTU |\n");
+	fprintf(stderr, "	                     weight WEIGHT }\n");
 	fprintf(stderr, "       ip link show [ DEVICE ]\n");
 	exit(-1);
 }
@@ -130,50 +132,6 @@
 	return err;
 }
 
-static int set_qlen(char *dev, int qlen)
-{
-	struct ifreq ifr;
-	int s;
-
-	s = get_ctl_fd();
-	if (s < 0)
-		return -1;
-
-	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, dev); 
-	ifr.ifr_qlen = qlen; 
-	if (ioctl(s, SIOCSIFTXQLEN, &ifr) < 0) {
-		perror("SIOCSIFXQLEN");
-		close(s);
-		return -1;
-	}
-	close(s);
-
-	return 0; 
-}
-
-static int set_mtu(char *dev, int mtu)
-{
-	struct ifreq ifr;
-	int s;
-
-	s = get_ctl_fd();
-	if (s < 0)
-		return -1;
-
-	memset(&ifr, 0, sizeof(ifr));
-	strcpy(ifr.ifr_name, dev); 
-	ifr.ifr_mtu = mtu; 
-	if (ioctl(s, SIOCSIFMTU, &ifr) < 0) {
-		perror("SIOCSIFMTU");
-		close(s);
-		return -1;
-	}
-	close(s);
-
-	return 0; 
-}
-
 static int get_address(char *dev, int *htype)
 {
 	struct ifreq ifr;
@@ -249,19 +207,36 @@
 	return 0; 
 }
 
+struct link_request
+{
+	struct nlmsghdr     nl_msg;
+	struct ifinfomsg    ifi;
+	char buf[256];
+};
+
 
 static int do_set(int argc, char **argv)
 {
 	char *dev = NULL;
 	__u32 mask = 0;
 	__u32 flags = 0;
-	int qlen = -1;
-	int mtu = -1;
+	int32_t qlen = -1;
+	int32_t mtu = -1;
+	int32_t weight = -1;
 	char *newaddr = NULL;
 	char *newbrd = NULL;
 	struct ifreq ifr0, ifr1;
 	char *newname = NULL;
 	int htype, halen;
+	struct rtnl_handle rth;
+
+	struct link_request req = {
+		.nl_msg = {
+			.nlmsg_type = RTM_SETLINK,
+			.nlmsg_flags = NLM_F_REQUEST,
+			.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
+		},
+	};
 
 	while (argc > 0) {
 		if (strcmp(*argv, "up") == 0) {
@@ -288,12 +263,14 @@
 				duparg("txqueuelen", *argv);
 			if (get_integer(&qlen,  *argv, 0))
 				invarg("Invalid \"txqueuelen\" value\n", *argv);
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_TXQLEN, &qlen, sizeof(qlen));
 		} else if (strcmp(*argv, "mtu") == 0) {
 			NEXT_ARG();
 			if (mtu != -1)
 				duparg("mtu", *argv);
 			if (get_integer(&mtu, *argv, 0))
 				invarg("Invalid \"mtu\" value\n", *argv);
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_MTU, &mtu, sizeof(mtu));
 		} else if (strcmp(*argv, "multicast") == 0) {
 			NEXT_ARG();
 			mask |= IFF_MULTICAST;
@@ -339,6 +316,13 @@
 				flags |= IFF_NOARP;
 			} else
 				return on_off("noarp");
+		} else if (matches(*argv, "weight") == 0) {
+			NEXT_ARG();
+			if (weight != -1)
+				duparg("weight", *argv);
+			if (get_integer(&weight,  *argv, 0))
+				invarg("Invalid \"weight\" value\n", *argv);
+			addattr_l(&req.nl_msg, sizeof(req), IFLA_WEIGHT, &weight, sizeof(weight));
 #ifdef IFF_DYNAMIC
 		} else if (matches(*argv, "dynamic") == 0) {
 			NEXT_ARG();
@@ -387,14 +371,6 @@
 			return -1;
 		dev = newname;
 	}
-	if (qlen != -1) { 
-		if (set_qlen(dev, qlen) < 0)
-			return -1; 
-	}
-	if (mtu != -1) { 
-		if (set_mtu(dev, mtu) < 0)
-			return -1; 
-	}
 	if (newaddr || newbrd) {
 		if (newbrd) {
 			if (set_address(&ifr1, 1) < 0)
@@ -407,6 +383,20 @@
 	}
 	if (mask)
 		return do_chflags(dev, flags, mask);
+
+	if (rtnl_open(&rth, 0) < 0)
+		exit(1);
+
+	ll_init_map(&rth);
+
+	if ((req.ifi.ifi_index = ll_name_to_index(dev)) == 0) {
+		fprintf(stderr, "Cannot find device \"%s\"\n", dev);
+		return -1;
+	}
+
+	if (rtnl_talk(&rth, &req.nl_msg, 0, 0, NULL, NULL, NULL) < 0)
+		exit(2);
+
 	return 0;
 }
 
