From: vdb128@stargate.kotnet.org
Subject: [patch] icmp ipip relay
Date: Sun, 7 Dec 2003 18:42:00 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312071742.hB7Hg0Kt010463@stargate.kotnet.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dear ipv4/ipip.c maintainers,

The patch here below relays ICMP IPIP errors to the originating 
host.  This is attempted if in addition to the IPIP header length 
(hlen) more then 20+8 bytes data remain.  Otherwise, it defaults to 
the current code and increments the error count.

Yours sincerely,
Servaas Vandenberghe

----------------------------- at local host 172.24.105.1 ----------------------
stargate:~$ tracepath 195.162.196.2
 1?: [LOCALHOST]     pmtu 1500
 1:  be-bru02a-ra2-vl-201.aorta.net (195.162.209.253)       6.817ms (0) 
 2:  rubicon.chello.be (195.162.196.2)                      5.986ms reached
     Resume: pmtu 1500 hops 2 back 2 

10: tunl1@NONE: <POINTOPOINT,NOARP,UP> mtu 1480 qdisc noqueue 
    link/ipip 195.162.202.41 peer 195.162.196.2
    inet 172.24.105.24 peer 172.24.10.24/32 scope global tunl1

stargate:~$ tracepath 172.24.10.24
 1?: [LOCALHOST]     pmtu 1480
 1:  no reply
 2:  tkstar.picaros.org (172.24.105.24)                     6.409ms asym  1 !H
     Resume: pmtu 1480 

==> /var/log/debug <==
Dec  7 02:56:34 stargate kernel: ipip_err: icmp 195.162.209.253>195.162.202.41 11 0 simple 
Dec  7 02:56:36 stargate last message repeated 2 times
Dec  7 02:56:37 stargate kernel: ipip_err: icmp 195.162.196.2>195.162.202.41 3 2 full 
Dec  7 02:56:37 stargate kernel: ipip_err: ipip 195.162.202.41>195.162.196.2 172.24.105.24>172.24.10.24 


----------------------- at firewalled host 172.24.105.1 ---------------------
reddwarf:~$ tracepath 195.162.196.2
 1?: [LOCALHOST]     pmtu 1500
 1:  stargate.picaros.org (172.24.105.14)                   4.021ms 
 2:  be-bru02a-ra2-vl-201.aorta.net (195.162.209.253)      12.948ms (0) 
 3:  rubicon.chello.be (195.162.196.2)                     10.130ms reached
     Resume: pmtu 1500 hops 3 back 3 

reddwarf:~$ tracepath 172.24.10.24
 1?: [LOCALHOST]     pmtu 1500
 1:  stargate.picaros.org (172.24.105.14)                   3.902ms 
 2:  stargate.picaros.org (172.24.105.14)                   3.771ms asym  1 pmtu 1480
 3:  stargate.picaros.org (172.24.105.14)                  20.500ms asym  1 !H
     Resume: pmtu 1480 

==> /var/log/debug <==
Dec  7 03:03:39 stargate kernel: ipip_err: icmp 195.162.196.2>195.162.202.41 3 2 full 
Dec  7 03:03:39 stargate kernel: ipip_err: ip_route_input non local pkt
Dec  7 03:03:39 stargate kernel: ipip_err: ipip 195.162.202.41>195.162.196.2 172.24.105.1>172.24.10.24 

reddwarf:~$ tracepath -m 40 172.24.10.24
 1:  stargate.picaros.org (172.24.105.14)                   1.335ms 
 2:  no reply
 3:  stargate.picaros.org (172.24.105.14)                   3.172ms asym  1 !H
     Resume: pmtu 40 

==> /var/log/debug <==
Dec  7 03:52:41 stargate kernel: ipip_err: icmp 195.162.209.253>195.162.202.41 11 0 simple 
Dec  7 03:52:43 stargate last message repeated 2 times
Dec  7 03:52:44 stargate kernel: ipip_err: icmp 195.162.196.2>195.162.202.41 3 2 full 
Dec  7 03:52:44 stargate kernel: ipip_err: ip_route_input non local pkt
Dec  7 03:52:44 stargate kernel: ipip_err: ipip 195.162.202.41>195.162.196.2 172.24.105.1>172.24.10.24 

stargate:~# tcpdump -i eth1 -s 1024 -v host 195.162.196.2 or host 195.162.202.41
tcpdump: listening on eth1
03:52:41.658061 ns1.picaros.org > rubicon.chello.be: reddwarf.picaros.org.1028 > 172.24.10.24.44445: [udp sum ok] udp 12 (DF) [ttl 1] (id 0, len 40) (DF) [ttl 1] (id 0, len 60)
03:52:41.659947 be-bru02a-ra2-vl-201.aorta.net > ns1.picaros.org: icmp 28: time exceeded in-transit [tos 0xc0]  (ttl 255, id 58562, len 56)
03:52:42.659757 ns1.picaros.org > rubicon.chello.be: reddwarf.picaros.org.1028 > 172.24.10.24.44446: [udp sum ok] udp 12 (DF) [ttl 1] (id 0, len 40) (DF) [ttl 1] (id 0, len 60)
03:52:42.665514 be-bru02a-ra2-vl-201.aorta.net > ns1.picaros.org: icmp 28: time exceeded in-transit [tos 0xc0]  (ttl 255, id 58594, len 56)
03:52:43.669749 ns1.picaros.org > rubicon.chello.be: reddwarf.picaros.org.1028 > 172.24.10.24.44447: [udp sum ok] udp 12 (DF) [ttl 1] (id 0, len 40) (DF) [ttl 1] (id 0, len 60)
03:52:43.671649 be-bru02a-ra2-vl-201.aorta.net > ns1.picaros.org: icmp 28: time exceeded in-transit [tos 0xc0]  (ttl 255, id 58632, len 56)
03:52:44.686199 ns1.picaros.org > rubicon.chello.be: reddwarf.picaros.org.1028 > 172.24.10.24.44448: [udp sum ok] udp 12 (DF) (ttl 2, id 0, len 40) (DF) (ttl 2, id 0, len 60)
03:52:44.688177 rubicon.chello.be > ns1.picaros.org: icmp 60: rubicon.chello.be protocol 4 unreachable (DF) (ttl 254, id 14625, len 88)

#############################################################################
--- linux-2.4.23/net/ipv4/ipip-dist.c	Fri Nov 28 19:26:21 2003
+++ linux-2.4.23/net/ipv4/ipip.c	Sun Dec  7 02:01:13 2003
@@ -289,19 +290,29 @@
 	dev_put(dev);
 }
 
+#define IPIP_DEBUG 0
 void ipip_err(struct sk_buff *skb, u32 info)
 {
-#ifndef I_WISH_WORLD_WERE_PERFECT
+  struct iphdr *iph = (struct iphdr*)skb->data;
+  int hlen = iph->ihl<<2;
+  unsigned int len = skb->len;
+  int type = skb->h.icmph->type;
+  int code = skb->h.icmph->code;
+
+  if (len < hlen+sizeof(struct iphdr)+8) { 
+    /*#ifndef I_WISH_WORLD_WERE_PERFECT*/
 
 /* It is not :-( All the routers (except for Linux) return only
    8 bytes of packet payload. It means, that precise relaying of
    ICMP in the real Internet is absolutely infeasible.
  */
-	struct iphdr *iph = (struct iphdr*)skb->data;
-	int type = skb->h.icmph->type;
-	int code = skb->h.icmph->code;
 	struct ip_tunnel *t;
-
+#if IPIP_DEBUG
+	if (net_ratelimit())
+	  printk(KERN_DEBUG "ipip_err: icmp %u.%u.%u.%u>%u.%u.%u.%u %d %d "
+		 "simple \n", NIPQUAD(skb->nh.iph->saddr),
+		 NIPQUAD(skb->nh.iph->daddr), type,code);
+#endif
 	switch (type) {
 	default:
 	case ICMP_PARAMETERPROB:
@@ -344,22 +355,21 @@
 	t->err_time = jiffies;
 out:
 	read_unlock(&ipip_lock);
-	return;
-#else
-	struct iphdr *iph = (struct iphdr*)dp;
-	int hlen = iph->ihl<<2;
-	struct iphdr *eiph;
-	int type = skb->h.icmph->type;
-	int code = skb->h.icmph->code;
-	int rel_type = 0;
-	int rel_code = 0;
+  } else { /* #else */
+	struct iphdr *eiph = (struct iphdr*)(skb->data + hlen);
+	int rel_type = type;
+	int rel_code = code;
 	int rel_info = 0;
-	struct sk_buff *skb2;
-	struct rtable *rt;
-
-	if (len < hlen + sizeof(struct iphdr))
-		return;
-	eiph = (struct iphdr*)(dp + hlen);
+	struct ip_tunnel *tlook, *troute;
+	struct sk_buff *skb2=NULL;
+	struct rtable *rt=NULL;
+
+#if IPIP_DEBUG
+	if (net_ratelimit())
+	  printk(KERN_DEBUG "ipip_err: icmp %u.%u.%u.%u>%u.%u.%u.%u %d %d "
+		 "full \n", NIPQUAD(skb->nh.iph->saddr),
+		 NIPQUAD(skb->nh.iph->daddr), type,code);
+#endif
 
 	switch (type) {
 	default:
@@ -407,62 +417,90 @@
 		break;
 	}
 
+	tlook = ipip_tunnel_lookup(iph->daddr, iph->saddr);
+	if (tlook == NULL || tlook->parms.iph.daddr == 0) {
+#if IPIP_DEBUG
+	  if (net_ratelimit())
+	    printk(KERN_DEBUG "ipip_err: %u.%u.%u.%u>%u.%u.%u.%u "
+		   "no tunnel ! \n", NIPQUAD(iph->saddr), NIPQUAD(iph->daddr));
+#endif
+	  return;
+	}
+
 	/* Prepare fake skb to feed it to icmp_send */
 	skb2 = skb_clone(skb, GFP_ATOMIC);
 	if (skb2 == NULL)
 		return;
 	dst_release(skb2->dst);
-	skb2->dst = NULL;
-	skb_pull(skb2, skb->data - (u8*)eiph);
+	skb2->dst = NULL; 
+	skb_pull(skb2, hlen);
 	skb2->nh.raw = skb2->data;
 
-	/* Try to guess incoming interface */
+	/* Try to guess original incoming interface before encapsulation */
 	if (ip_route_output(&rt, eiph->saddr, 0, RT_TOS(eiph->tos), 0)) {
-		kfree_skb(skb2);
-		return;
+	  kfree_skb(skb2);
+	  return;
 	}
 	skb2->dev = rt->u.dst.dev;
 
 	/* route "incoming" packet */
 	if (rt->rt_flags&RTCF_LOCAL) {
-		ip_rt_put(rt);
-		rt = NULL;
-		if (ip_route_output(&rt, eiph->daddr, eiph->saddr, eiph->tos, 0) ||
-		    rt->u.dst.dev->type != ARPHRD_IPGRE) {
-			ip_rt_put(rt);
-			kfree_skb(skb2);
-			return;
-		}
+	  struct rtable *rtout=NULL;
+	  if (ip_route_output(&rtout, eiph->daddr, eiph->saddr, eiph->tos, 0) 
+	      || rtout->u.dst.dev->type != ARPHRD_TUNNEL) {
+	    ip_rt_put(rtout); 
+	    goto end_error;
+	  }
+	  skb2->dst = &rtout->u.dst;   /* needed by icmp_send() */
 	} else {
-		ip_rt_put(rt);
-		if (ip_route_input(skb2, eiph->daddr, eiph->saddr, eiph->tos, skb2->dev) ||
-		    skb2->dst->dev->type != ARPHRD_IPGRE) {
-			kfree_skb(skb2);
-			return;
-		}
+#if IPIP_DEBUG
+	  if (net_ratelimit())
+	    printk(KERN_DEBUG "ipip_err: ip_route_input non local pkt\n");
+#endif
+	  if (ip_route_input(skb2, eiph->daddr, eiph->saddr, eiph->tos, skb2->dev) ||
+	      skb2->dst->dev->type != ARPHRD_TUNNEL) {
+	    goto end_error;
+	  }
+	}
+
+#if IPIP_DEBUG
+	if (net_ratelimit())
+	  printk(KERN_DEBUG "ipip_err: ipip %u.%u.%u.%u>%u.%u.%u.%u "
+		 "%u.%u.%u.%u>%u.%u.%u.%u \n", 
+		 NIPQUAD(iph->saddr), NIPQUAD(iph->daddr),
+		 NIPQUAD(eiph->saddr), NIPQUAD(eiph->daddr));
+#endif
+	troute = (struct ip_tunnel*)skb2->dst->dev->priv;
+	if (troute != tlook) {
+	  if (net_ratelimit())
+	    printk(KERN_INFO "ipip_err: %u.%u.%u.%u>%u.%u.%u.%u "
+		   "%u.%u.%u.%u>%u.%u.%u.%u different tunnel ! \n", 
+		   NIPQUAD(iph->saddr), NIPQUAD(iph->daddr),
+		   NIPQUAD(eiph->saddr), NIPQUAD(eiph->daddr));
+	  goto end_error;
 	}
 
 	/* change mtu on this route */
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		if (rel_info > skb2->dst->pmtu) {
-			kfree_skb(skb2);
-			return;
-		}
+		if (rel_info > skb2->dst->pmtu) 
+		  goto end_error;
 		skb2->dst->pmtu = rel_info;
 		rel_info = htonl(rel_info);
 	} else if (type == ICMP_TIME_EXCEEDED) {
-		struct ip_tunnel *t = (struct ip_tunnel*)skb2->dev->priv;
-		if (t->parms.iph.ttl) {
+		if (troute->parms.iph.ttl) {
 			rel_type = ICMP_DEST_UNREACH;
 			rel_code = ICMP_HOST_UNREACH;
 		}
 	}
 
 	icmp_send(skb2, rel_type, rel_code, rel_info);
+  end_error:
+	ip_rt_put(rt);
 	kfree_skb(skb2);
-	return;
-#endif
+  } /* if len< min length */
+  return;
 }
+#undef IPIP_DEBUG
 
 static inline void ipip_ecn_decapsulate(struct iphdr *outer_iph, struct sk_buff *skb)
 {

######################### informative: traceroute patch #####################
--- iputils-ss020927/tracepath-dist.c	Sat Feb 23 01:10:59 2002
+++ iputils-ss020927/tracepath.c	Sun Dec  7 04:44:09 2003
@@ -23,30 +23,22 @@
 #include <sys/uio.h>
 #include <arpa/inet.h>
 
-struct hhistory
-{
-	int	hops;
-	struct timeval sendtime;
+struct probehdr {
+	__u32 ttl;
+	struct timeval tv;
 };
 
-struct hhistory his[64];
-int hisptr;
-
-struct sockaddr_in target;
-__u16 base_port;
-
-const int overhead = 28;
-int mtu = 65535;
-int hops_to = -1;
-int hops_from = -1;
-int no_resolve = 0;
+struct hhistory {
+  int ptr;
+  struct probehdr hdr[64];
+};
 
-struct probehdr
-{
-	__u32 ttl;
-	struct timeval tv;
+struct hopslist {
+  int to, from;
 };
 
+const static int overhead=28, maxttl=255;
+
 void data_wait(int fd)
 {
 	fd_set fds;
@@ -54,11 +46,11 @@
 	FD_ZERO(&fds);
 	FD_SET(fd, &fds);
 	tv.tv_sec = 1;
-	tv.tv_usec = 0;
+	tv.tv_usec = 10000;     /* ARP timeout is 3s */
 	select(fd+1, &fds, NULL, NULL, &tv);
 }
 
-int recverr(int fd, int ttl)
+int recverr(int fd, unsigned base_port, int ttl, int no_resolve, int *mtu, struct hhistory *his, struct hopslist *hops)
 {
 	int res;
 	struct probehdr rcvbuf;
@@ -70,11 +62,8 @@
 	struct sockaddr_in addr;
 	struct timeval tv;
 	struct timeval *rettv;
-	int slot;
-	int rethops;
-	int sndhops;
+	int slot, rethops, sndhops, broken_router;
 	int progress = -1;
-	int broken_router;
 	
 restart:
 	memset(&rcvbuf, -1, sizeof(rcvbuf));
@@ -91,32 +80,35 @@
 	gettimeofday(&tv, NULL);
 	res = recvmsg(fd, &msg, MSG_ERRQUEUE);
 	if (res < 0) {
-		if (errno == EAGAIN)
+		if (errno == EAGAIN || errno == EBADF || errno == ENOTSOCK 
+		    || errno == EINVAL)
 			return progress;
 		goto restart;
 	}
 
-	progress = mtu;
+	progress = *mtu;
 
 	rethops = -1;
 	sndhops = -1;
 	e = NULL;
 	rettv = NULL;
 	slot = ntohs(addr.sin_port) - base_port;
-	if (slot>=0 && slot < 63 && his[slot].hops) {
-		sndhops = his[slot].hops;
-		rettv = &his[slot].sendtime;
-		his[slot].hops = 0;
+	if (slot>=0 && slot<(maxttl+1)*3 && his->hdr[slot=(slot & 63)].ttl) {
+		sndhops = his->hdr[slot].ttl;
+		rettv = &his->hdr[slot].tv;
+		his->hdr[slot].ttl = 0;
 	}
 	broken_router = 0;
 	if (res == sizeof(rcvbuf)) {
-		if (rcvbuf.ttl == 0 || rcvbuf.tv.tv_sec == 0) {
+		if (rcvbuf.ttl==0 || rcvbuf.ttl>maxttl 
+		    || rcvbuf.tv.tv_sec==0) {
 			broken_router = 1;
 		} else {
 			sndhops = rcvbuf.ttl;
 			rettv = &rcvbuf.tv;
 		}
-	}
+	} else
+	  broken_router = -1;
 
 	for (cmsg = CMSG_FIRSTHDR(&msg); cmsg; cmsg = CMSG_NXTHDR(&msg, cmsg)) {
 		if (cmsg->cmsg_level == SOL_IP) {
@@ -158,6 +150,11 @@
 		}
 	}
 
+	if (rettv) {
+		int diff = (tv.tv_sec-rettv->tv_sec)*1000000+(tv.tv_usec-rettv->tv_usec);
+		printf("%3d.%03dms ", diff/1000, diff%1000);
+	}
+
 	if (rethops>=0) {
 		if (rethops<=64)
 			rethops = 65-rethops;
@@ -166,16 +163,16 @@
 		else
 			rethops = 256-rethops;
 		if (sndhops>=0 && rethops != sndhops)
-			printf("asymm %2d ", rethops);
+			printf("asym %2d ", rethops);
 		else if (sndhops<0 && rethops != ttl)
-			printf("asymm %2d ", rethops);
+			printf("asym %2d ", rethops);
 	}
 
 	if (rettv) {
-		int diff = (tv.tv_sec-rettv->tv_sec)*1000000+(tv.tv_usec-rettv->tv_usec);
-		printf("%3d.%03dms ", diff/1000, diff%1000);
-		if (broken_router)
+		if (broken_router>0)
 			printf("(This broken router returned corrupted payload) ");
+		else if(broken_router<0)
+		  printf("(%i) ",res);
 	}
 
 	switch (e->ee_errno) {
@@ -184,13 +181,12 @@
 		break;
 	case EMSGSIZE:
 		printf("pmtu %d\n", e->ee_info);
-		mtu = e->ee_info;
-		progress = mtu;
+		progress = *mtu = e->ee_info;
 		break;
 	case ECONNREFUSED:
 		printf("reached\n");
-		hops_to = sndhops<0 ? ttl : sndhops;
-		hops_from = rethops;
+		hops->to = sndhops<0 ? ttl : sndhops;
+		hops->from = rethops;
 		return 0;
 	case EPROTO:
 		printf("!P\n");
@@ -219,69 +215,110 @@
 	goto restart;
 }
 
-int probe_ttl(int fd, int ttl)
+int probe_ttl(int fd, struct sockaddr_in *target, __u16 base_port, int ttl, int no_resolve, int *mtu, struct hhistory *his, struct hopslist *hops)
 {
-	int i;
-	char sndbuf[mtu];
+	int i, all= *mtu<sizeof(struct probehdr)? sizeof(struct probehdr):*mtu;
+	char sndbuf[all];
 	struct probehdr *hdr = (struct probehdr*)sndbuf;
 
-	memset(sndbuf,0,mtu);
+	memset(sndbuf,0, all);
 
-restart:
-	for (i=0; i<10; i++) {
+	for (i=0; i<256; i++) {  /* max 256 mtu changes supported */
 		int res;
 
-		hdr->ttl = ttl;
-		target.sin_port = htons(base_port + hisptr);
+		hdr->ttl= ttl;
+		target->sin_port = htons(base_port + his->ptr);
 		gettimeofday(&hdr->tv, NULL);
-		his[hisptr].hops = ttl;
-		his[hisptr].sendtime = hdr->tv;
-		if (sendto(fd, sndbuf, mtu-overhead, 0, (struct sockaddr*)&target, sizeof(target)) > 0)
+		his->hdr[his->ptr]= *hdr;
+		if (sendto(fd, sndbuf, *mtu-overhead, 0, 
+			   (struct sockaddr*)target, sizeof(*target)) >= 0)
 			break;
-		res = recverr(fd, ttl);
-		his[hisptr].hops = 0;
+
+		res = recverr(fd, base_port, ttl, no_resolve, mtu, his, hops);
+		his->hdr[his->ptr].ttl = 0;
 		if (res==0)
 			return 0;
-		if (res > 0)
-			goto restart;
+		if (res<0)      /* no error info in queue */
+			i+=25;
 	}
-	hisptr = (hisptr + 1)&63;
+	his->ptr = (his->ptr + 1)&63;
 
-	if (i<10) {
+	if (i<256) {
 		data_wait(fd);
 		if (recv(fd, sndbuf, sizeof(sndbuf), MSG_DONTWAIT) > 0) {
 			printf("%2d?: reply received 8)\n", ttl);
 			return 0;
 		}
-		return recverr(fd, ttl);
+		return recverr(fd, base_port, ttl, no_resolve, mtu, his, hops);
 	}
 
-	printf("%2d:  send failed\n", ttl);
+	{ char abuf[128];
+	  inet_ntop(target->sin_family, &target->sin_addr, abuf, sizeof(abuf));
+	  printf("%2d:  send failed dest %s/%u\n", ttl, abuf, 
+		 (unsigned )ntohs(target->sin_port));
+	}
 	return 0;
 }
 
-static void usage(void) __attribute((noreturn));
-
 static void usage(void)
 {
-	fprintf(stderr, "Usage: tracepath [-n] <destination>[/<port>]\n");
-	exit(-1);
+	fprintf(stderr, "Use: tracepath [-Q tos] [-b src[/port]] [-m mtu] [-n] [-t ttli[/f]] dest[/port]\n");
+	return;
 }
 
-int
-main(int argc, char **argv)
+int div_string(char *argin, long *valout) 
+{
+  int err=0;
+  char *p;
+
+  if((p = strrchr(argin, '/'))) {
+    *p = 0;
+    *valout = strtol(&p[1], NULL,0);
+  } else {
+    err=1;
+  } 
+
+  return(err);
+}
+
+int main(int argc, char **argv)
 {
-	struct hostent *he;
 	int fd;
+	struct hostent *he;
+	struct sockaddr_in target;
+	__u16 base_port=44444;
+	struct hopslist hops={ -1, -1};
+	char *tos_ini=NULL, *bind_ini=NULL, *mtu_ini=NULL, *ttl_ini=NULL;
+	int no_resolve = 0;
 	int on;
-	int ttl;
-	char *p;
-	int ch;
+	int ttli=1, ttlf=31, ttl, tos=0;
+	int ch, res=0, err=0;
+	int mtu = 65535;
+	struct hhistory his={ .ptr=0, .hdr={ {.ttl=0}, } };
+
+	extern char *optarg;   
+	extern int optind;     /*, opterr, optopt; */
+
+	optarg=NULL;  /* init getopt */
+	optind=0;
 
-	while ((ch = getopt(argc, argv, "nh?")) != EOF) {
+	while ((ch = getopt(argc, argv, "Q:b:m:nt:s:h")) != EOF) {
 		switch(ch) {
+		case 'Q':
+		  tos_ini=optarg;
+		  break;
+		case 'b':
+		case 's':
+		  bind_ini=optarg;
+		  break;
+		case 'm':
+		  mtu_ini=optarg;
+		  break;
 		case 'n':	
-			no_resolve = 1;
+		  no_resolve ^= 1;
+		  break;
+		case 't':
+		  ttl_ini=optarg;
 			break;
 		default: ;	
 		}
@@ -290,57 +327,104 @@
 	argc -= optind;
 	argv += optind;
 
-	if (argc != 1)
+	if (argc != 1) {
 		usage();
-
+	  err=-1; goto end_error;
+	}
 
 	fd = socket(AF_INET, SOCK_DGRAM, 0);
 	if (fd < 0) {
 		perror("socket");
-		exit(1);
+		err=1; goto end_error;
 	}
 	target.sin_family = AF_INET;
 
-	p = strchr(argv[0], '/');
-	if (p) {
-		*p = 0;
-		base_port = atoi(p+1);
-	} else
-		base_port = 44444;
+	{ long li;
+	  if(!div_string(argv[0], &li)) 
+	    base_port = li;
+	}
 	he = gethostbyname(argv[0]);
 	if (he == NULL) {
 		herror("gethostbyname");
-		exit(1);
+		err=2; goto end_error;
 	}
 	memcpy(&target.sin_addr, he->h_addr, 4);
 
+	if(bind_ini) {
+	  long li;
+	  __u16 sport=0;
+	  struct hostent *she;
+	  struct sockaddr_in saddr;
+
+	  memset(&saddr, 0, sizeof(saddr));
+	  saddr.sin_family = AF_INET;
+
+	  if(!div_string(bind_ini, &li)) 
+	    sport = li;
+	  saddr.sin_port = htons(sport);
+
+	  she = gethostbyname(bind_ini);
+	  if (she == NULL) {
+	    herror("gethostbyname");
+	    err=3; goto end_error;
+	  }
+	  memcpy(&saddr.sin_addr, she->h_addr, 4);
+
+	  if(bind(fd, (struct sockaddr*)&saddr, sizeof(saddr))<0) {
+	    perror("bind");
+	    err=4; goto end_error;
+	  }
+	}
+
+	if(mtu_ini) {
+	  mtu=(int )strtol(mtu_ini, NULL,0);
+	  if(mtu<overhead) {
+	    fprintf(stderr,"Error: bad mtu=%i<%i\n", mtu, overhead);
+	    err=5; goto end_error;
+	  }
+	}
+
+	if(ttl_ini) {
+	  long li;
+	  if(!div_string(ttl_ini, &li))
+	    ttlf=(int )li;
+	  ttli=(int )strtol(ttl_ini, NULL,0);
+	}
+
+	if(tos_ini) 
+	  tos=(int )strtol(tos_ini, NULL,0);
+
 	on = IP_PMTUDISC_DO;
 	if (setsockopt(fd, SOL_IP, IP_MTU_DISCOVER, &on, sizeof(on))) {
 		perror("IP_MTU_DISCOVER");
-		exit(1);
+		err=6; goto end_error;
 	}
 	on = 1;
 	if (setsockopt(fd, SOL_IP, IP_RECVERR, &on, sizeof(on))) {
 		perror("IP_RECVERR");
-		exit(1);
+		err=7; goto end_error;
 	}
 	if (setsockopt(fd, SOL_IP, IP_RECVTTL, &on, sizeof(on))) {
 		perror("IP_RECVTTL");
-		exit(1);
+		err=8; goto end_error;
+	}
+	if (tos_ini && setsockopt(fd, SOL_IP, IP_TOS, &tos, sizeof(tos))) {
+		perror("IP_TOS");
+		err=9; goto end_error;
 	}
 
-	for (ttl=1; ttl<32; ttl++) {
-		int res;
+	for (ttl=ttli; ttl<=ttlf; ttl++) {
 		int i;
 
 		on = ttl;
 		if (setsockopt(fd, SOL_IP, IP_TTL, &on, sizeof(on))) {
 			perror("IP_TTL");
-			exit(1);
+			err=10; goto end_error;
 		}
 
 		for (i=0; i<3; i++) {
-			res = probe_ttl(fd, ttl);
+			res = probe_ttl(fd, &target, base_port, ttl, 
+					no_resolve, &mtu, &his, &hops);
 			if (res == 0)
 				goto done;
 			if (res > 0)
@@ -351,12 +435,14 @@
 			printf("%2d:  no reply\n", ttl);
 	}
 	printf("     Too many hops: pmtu %d\n", mtu);
+	err= res<0 ? 16 : 17;
 done:
 	printf("     Resume: pmtu %d ", mtu);
-	if (hops_to>=0)
-		printf("hops %d ", hops_to);
-	if (hops_from>=0)
-		printf("back %d ", hops_from);
+	if (hops.to>=0)
+		printf("hops %d ", hops.to);
+	if (hops.from>=0)
+		printf("back %d ", hops.from);
 	printf("\n");
-	exit(0);
+end_error:
+	return(err);
 }
