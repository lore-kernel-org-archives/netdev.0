From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Fix 'addr flush secondary' logic.
Date: Wed, 11 Aug 2010 15:48:08 -0700
Message-ID: <4C6328A8.4070703@candelatech.com>
References: <1281547182-1252-1-git-send-email-greearb@candelatech.com> <4C630B0A.9010304@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090201000505010504090008"
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56619 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756581Ab0HKWsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 18:48:11 -0400
In-Reply-To: <4C630B0A.9010304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090201000505010504090008
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 08/11/2010 01:41 PM, Brian Haley wrote:
> On 08/11/2010 01:19 PM, Ben Greear wrote:
>> @@ -648,7 +648,7 @@ int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
>>   {
>>   	struct ifaddrmsg *ifa = NLMSG_DATA(n);
>>
>> -	if (ifa->ifa_flags&  IFA_F_SECONDARY)
>> +	if (!ifa->ifa_flags&  IFA_F_SECONDARY)
>>   		return 0;
>
> Shouldn't this be:
>
> 	if (!(ifa->ifa_flags&  IFA_F_SECONDARY))
>
> -Brian

Looks like the code was broken in several different places.

* It ran only a single filter if there were multiple.
* Don't want to flush in a loop if you are doing primary
   because otherwise promoted seconaries will get deleted
   for each additional loop (10 in upstream code).
* No idea what a while (0); statement at the end of a for
   loop does, but I don't think it needed to be there!

The attached patch makes it work for me, supporting
flushing primary or secondary addresses.

It could certainly use some review, however.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------090201000505010504090008
Content-Type: text/plain;
 name="iproute_flush.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="iproute_flush.patch"

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5f0789c..803df17 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -637,7 +637,7 @@ int print_addrinfo_primary(const struct sockaddr_nl *who, struct nlmsghdr *n,
 {
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
-	if (!ifa->ifa_flags & IFA_F_SECONDARY)
+	if (ifa->ifa_flags & IFA_F_SECONDARY)
 		return 0;
 
 	return print_addrinfo(who, n, arg);
@@ -648,7 +648,7 @@ int print_addrinfo_secondary(const struct sockaddr_nl *who, struct nlmsghdr *n,
 {
 	struct ifaddrmsg *ifa = NLMSG_DATA(n);
 
-	if (ifa->ifa_flags & IFA_F_SECONDARY)
+	if (!(ifa->ifa_flags & IFA_F_SECONDARY))
 		return 0;
 
 	return print_addrinfo(who, n, arg);
@@ -865,6 +865,13 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
 				fflush(stdout);
 			}
+
+			/* If we are flushing, and specifying primary, then we want to flush only a single round.
+			 * Otherwise, we'll start flushing secondaries that were promoted to primaries
+			 */
+			if (!(filter.flags & IFA_F_SECONDARY) && (filter.flagmask & IFA_F_SECONDARY)) {
+				return 0;
+			}
 		}
 		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", max_flush_loops);
 		fflush(stderr);
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index cfeb894..d18e8a0 100644
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
@@ -242,14 +247,18 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
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
+		if (msglen) {
 			fprintf(stderr, "!!!Remnant of size %d\n", status);
 			exit(1);
 		}

--------------090201000505010504090008--
