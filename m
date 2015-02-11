From: Radu Benea <radu.benea@evozon.com>
Subject: under certain conditions netlink will not report adding a new ipv6
 address
Date: Wed, 11 Feb 2015 12:50:33 +0200 (EET)
Message-ID: <1143006151.25025.1423651833494.JavaMail.zimbra@evozon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.evozon.com ([91.195.44.4]:59668 "EHLO mail.evozon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751914AbbBKK6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2015 05:58:17 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.evozon.com (Postfix) with ESMTP id EF7A0408419
	for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 12:50:33 +0200 (EET)
Received: from mail.evozon.com ([127.0.0.1])
	by localhost (mail.evozon.com [127.0.0.1]) (amavisd-new, port 10032)
	with ESMTP id WUgB_NUejSF3 for <netdev@vger.kernel.org>;
	Wed, 11 Feb 2015 12:50:33 +0200 (EET)
Received: from localhost (localhost [127.0.0.1])
	by mail.evozon.com (Postfix) with ESMTP id B722A4084B6
	for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 12:50:33 +0200 (EET)
Received: from mail.evozon.com ([127.0.0.1])
	by localhost (mail.evozon.com [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id pJY3EyymoeTL for <netdev@vger.kernel.org>;
	Wed, 11 Feb 2015 12:50:33 +0200 (EET)
Received: from mail.evozon.com (localhost [127.0.0.1])
	by mail.evozon.com (Postfix) with ESMTP id 93355408419
	for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 12:50:33 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

I found that the netlink monitoring interface does not report adding a new ipv6 address unless:
 - the interface is up
 - the network cable is plugged in

Deleting the ipv6 address is reported even in these conditions.

Only tested this with e1000e since it's the only network adapter I have.

To test this just turn the network interface down, add an ipv6 address, then remove it... you will only see the deladdr message.

Example test commands:
ip link set dev devname down
ip -6 addr add 2001::5 dev devname
ip -6 addr del 2001::5 dev devname

Sample test code below.
#include <string.h>
#include <sys/socket.h>
#include <linux/netlink.h>
#include <linux/rtnetlink.h>

#include <stdio.h>
#include <unistd.h>

int main(int, char * [])
{
	struct sockaddr_nl sa;
	int fd;
	int len;
	char buf[4096];
	struct iovec iov = { buf, sizeof(buf) };
	struct msghdr msg;
	struct nlmsghdr *nh;

	memset(&sa, 0, sizeof(sa));
	sa.nl_family = AF_NETLINK;
	sa.nl_pid = getpid();
	sa.nl_groups = RTMGRP_IPV6_IFADDR;

	fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
	bind(fd, (struct sockaddr *)&sa, sizeof(sa));


	while (1) {
		msg = {&sa, sizeof(sa), &iov, 1, NULL, 0, 0};
		len = recvmsg(fd, &msg, 0);

		for (nh = (struct nlmsghdr *)buf; NLMSG_OK(nh, len); nh = NLMSG_NEXT(nh, len)) {
			/* The end of multipart message. */
			switch (nh->nlmsg_type) {
				case RTM_NEWADDR:
					printf("Received newaddr from netlink monitor\n");
					break;
				case RTM_DELADDR:
					printf("Received deladdr from netlink monitor\n");
					break;
				default:
					printf("Received unexpected message type %d from netlink monitor\n", nh->nlmsg_type);
					break;
			}
		}
	}
}
