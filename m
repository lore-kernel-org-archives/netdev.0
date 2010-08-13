From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Fix 'addr flush secondary' logic.
Date: Fri, 13 Aug 2010 12:49:33 -0700
Message-ID: <4C65A1CD.5090800@candelatech.com>
References: <1281547182-1252-1-git-send-email-greearb@candelatech.com> <4C630B0A.9010304@hp.com> <4C6328A8.4070703@candelatech.com> <4C6444EA.1070704@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010302080502070507000206"
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35720 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433Ab0HMTth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Aug 2010 15:49:37 -0400
In-Reply-To: <4C6444EA.1070704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010302080502070507000206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 08/12/2010 12:00 PM, Brian Haley wrote:
> On 08/11/2010 06:48 PM, Ben Greear wrote:
>> Looks like the code was broken in several different places.
>>
>> * It ran only a single filter if there were multiple.
>> * Don't want to flush in a loop if you are doing primary
>>    because otherwise promoted seconaries will get deleted
>>    for each additional loop (10 in upstream code).
>> * No idea what a while (0); statement at the end of a for
>>    loop does, but I don't think it needed to be there!

Attached is an updated patch to fix some of the errors you
mentioned.  It also fixes a bug when '-s -s' is used:  The old
code modified the ifa flags, which made it not handle the check
for primary v/s secondary correctly in the next filter.


Here are my testing commands:

Another thing you might find interesting is to run 'ip monitor'
in another window.  It should show the secondaries getting deleted
before the primaries if you flush all (with my modification).  Without
my patch, you should see only the primary being deleted in each
round.

[root@ct503-10G-09 lanforge]# cat /proc/sys/net/ipv4/conf/all/promote_secondaries
1

[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.101/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.102/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.103/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip -s -s addr flush dev eth3
5: eth3    inet 172.16.223.102/16 scope global secondary eth3
5: eth3    inet 172.16.223.103/16 scope global secondary eth3
5: eth3    inet 172.16.223.101/16 scope global eth3

*** Round 1, deleting 3 addresses ***
*** Flush is complete after 1 round ***

[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.101/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.102/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.103/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip -s  addr flush dev eth3

*** Round 1, deleting 3 addresses ***
*** Flush is complete after 1 round ***

[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.101/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.102/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.103/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr show dev eth3
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:0c:bd:00:9b:1b brd ff:ff:ff:ff:ff:ff
     inet 172.16.223.101/16 scope global eth3
     inet 172.16.223.102/16 scope global secondary eth3
     inet 172.16.223.103/16 scope global secondary eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr flush dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr show dev eth3
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:0c:bd:00:9b:1b brd ff:ff:ff:ff:ff:ff


[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.101/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.102/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr add 172.16.223.103/16 dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr show dev eth3
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:0c:bd:00:9b:1b brd ff:ff:ff:ff:ff:ff
     inet 172.16.223.101/16 scope global eth3
     inet 172.16.223.102/16 scope global secondary eth3
     inet 172.16.223.103/16 scope global secondary eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr flush dev eth3 primary
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr show dev eth3
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:0c:bd:00:9b:1b brd ff:ff:ff:ff:ff:ff
     inet 172.16.223.102/16 scope global eth3
     inet 172.16.223.103/16 scope global secondary eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr flush dev eth3 secondary
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr show dev eth3
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:0c:bd:00:9b:1b brd ff:ff:ff:ff:ff:ff
     inet 172.16.223.102/16 scope global eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr flush dev eth3 secondary
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr show dev eth3
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:0c:bd:00:9b:1b brd ff:ff:ff:ff:ff:ff
     inet 172.16.223.102/16 scope global eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr flush dev eth3
[root@ct503-10G-09 lanforge]# ./local/sbin/ip addr show dev eth3
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
     link/ether 00:0c:bd:00:9b:1b brd ff:ff:ff:ff:ff:ff


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------010302080502070507000206
Content-Type: text/plain;
 name="iproute_flush.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="iproute_flush.patch"

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5f0789c..51b59b4 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -452,6 +452,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	int deprecated = 0;
+	unsigned int ifa_flags;
 	struct rtattr * rta_tb[IFA_MAX+1];
 	char abuf[256];
 	SPRINT_BUF(b1);
@@ -571,40 +572,41 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 				    abuf, sizeof(abuf)));
 	}
 	fprintf(fp, "scope %s ", rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
+	ifa_flags = ifa->ifa_flags;
 	if (ifa->ifa_flags&IFA_F_SECONDARY) {
-		ifa->ifa_flags &= ~IFA_F_SECONDARY;
+		ifa_flags &= ~IFA_F_SECONDARY;
 		if (ifa->ifa_family == AF_INET6)
 			fprintf(fp, "temporary ");
 		else
 			fprintf(fp, "secondary ");
 	}
 	if (ifa->ifa_flags&IFA_F_TENTATIVE) {
-		ifa->ifa_flags &= ~IFA_F_TENTATIVE;
+		ifa_flags &= ~IFA_F_TENTATIVE;
 		fprintf(fp, "tentative ");
 	}
 	if (ifa->ifa_flags&IFA_F_DEPRECATED) {
-		ifa->ifa_flags &= ~IFA_F_DEPRECATED;
+		ifa_flags &= ~IFA_F_DEPRECATED;
 		deprecated = 1;
 		fprintf(fp, "deprecated ");
 	}
 	if (ifa->ifa_flags&IFA_F_HOMEADDRESS) {
-		ifa->ifa_flags &= ~IFA_F_HOMEADDRESS;
+		ifa_flags &= ~IFA_F_HOMEADDRESS;
 		fprintf(fp, "home ");
 	}
 	if (ifa->ifa_flags&IFA_F_NODAD) {
-		ifa->ifa_flags &= ~IFA_F_NODAD;
+		ifa_flags &= ~IFA_F_NODAD;
 		fprintf(fp, "nodad ");
 	}
 	if (!(ifa->ifa_flags&IFA_F_PERMANENT)) {
 		fprintf(fp, "dynamic ");
 	} else
-		ifa->ifa_flags &= ~IFA_F_PERMANENT;
+		ifa_flags &= ~IFA_F_PERMANENT;
 	if (ifa->ifa_flags&IFA_F_DADFAILED) {
-		ifa->ifa_flags &= ~IFA_F_DADFAILED;
+		ifa_flags &= ~IFA_F_DADFAILED;
 		fprintf(fp, "dadfailed ");
 	}
-	if (ifa->ifa_flags)
-		fprintf(fp, "flags %02x ", ifa->ifa_flags);
+	if (ifa_flags)
+		fprintf(fp, "flags %02x ", ifa_flags);
 	if (rta_tb[IFA_LABEL])
 		fprintf(fp, "%s", (char*)RTA_DATA(rta_tb[IFA_LABEL]));
 	if (rta_tb[IFA_CACHEINFO]) {
@@ -637,7 +639,7 @@ int print_addrinfo_primary(const struct sockaddr_nl *who, struct nlmsghdr *n,
 {
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
-	if (!ifa->ifa_flags & IFA_F_SECONDARY)
+	if (ifa->ifa_flags & IFA_F_SECONDARY)
 		return 0;
 
 	return print_addrinfo(who, n, arg);
@@ -648,7 +650,7 @@ int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
 {
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
-	if (ifa->ifa_flags & IFA_F_SECONDARY)
+	if (!(ifa->ifa_flags & IFA_F_SECONDARY))
 		return 0;
 
 	return print_addrinfo(who, n, arg);
@@ -848,6 +850,7 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				exit(1);
 			}
 			if (filter.flushed == 0) {
+			flush_done:
 				if (show_stats) {
 					if (round == 0)
 						printf("Nothing to flush.\n");
@@ -865,6 +868,13 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
 				fflush(stdout);
 			}
+
+			/* If we are flushing, and specifying primary, then we want to flush only a single round.
+			 * Otherwise, we'll start flushing secondaries that were promoted to primaries
+			 */
+			if (!(filter.flags & IFA_F_SECONDARY) && (filter.flagmask & IFA_F_SECONDARY)) {
+				goto flush_done;
+			}
 		}
 		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", max_flush_loops);
 		fflush(stderr);
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index cfeb894..ee4f045 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -189,6 +189,8 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 	while (1) {
 		int status;
 		const struct rtnl_dump_filter_arg *a;
+		int found_done = 0;
+		int msglen = 0;
 
 		iov.iov_len = sizeof(buf);
 		status = recvmsg(rth->fd, &msg, 0);
@@ -208,8 +210,9 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 
 		for (a = arg; a->filter; a++) {
 			struct nlmsghdr *h = (struct nlmsghdr*)buf;
+			msglen = status;
 
-			while (NLMSG_OK(h, status)) {
+			while (NLMSG_OK(h, msglen)) {
 				int err;
 
 				if (nladdr.nl_pid != 0 ||
@@ -224,8 +227,10 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 					goto skip_it;
 				}
 
-				if (h->nlmsg_type == NLMSG_DONE)
-					return 0;
+				if (h->nlmsg_type == NLMSG_DONE) {
+					found_done = 1;
+					break; /* process next filter */
+				}
 				if (h->nlmsg_type == NLMSG_ERROR) {
 					struct nlmsgerr *err = (struct nlmsgerr*)NLMSG_DATA(h);
 					if (h->nlmsg_len < NLMSG_LENGTH(sizeof(struct nlmsgerr))) {
@@ -242,15 +247,19 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 					return err;
 
 skip_it:
-				h = NLMSG_NEXT(h, status);
+				h = NLMSG_NEXT(h, msglen);
 			}
-		} while (0);
+		}
+
+		if (found_done)
+			return 0;
+
 		if (msg.msg_flags & MSG_TRUNC) {
 			fprintf(stderr, "Message truncated\n");
 			continue;
 		}
-		if (status) {
-			fprintf(stderr, "!!!Remnant of size %d\n", status);
+		if (msglen) {
+			fprintf(stderr, "!!!Remnant of size %d\n", msglen);
 			exit(1);
 		}
 	}

--------------010302080502070507000206--
