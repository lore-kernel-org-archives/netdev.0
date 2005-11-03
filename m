From: Yan Zheng <yzcorp@gmail.com>
Subject: Re: [PATCH][MCAST]Two fix for implementation of MLDv2 .
Date: Thu, 3 Nov 2005 21:26:29 +0800
Message-ID: <7e77d27c0511030526g45d8f6e6l@mail.gmail.com>
References: <436878E7.3030303@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932481AbVKCN0b@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <436878E7.3030303@21cn.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You can test change in add_grec(...) by follow codes. without the
change no change to exclude report will be sent.

please adjust IFINDEX and make sure initial state for FF02::2 is idle
===================================================
#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>
#define IFINDEX 6

int main(int argc, char argv[])
{
	int sockfds[2];
	struct ipv6_mreq req;
	struct group_filter filter;
	struct sockaddr_in6 *psin6;
	req.ipv6mr_interface = IFINDEX;
	inet_pton(PF_INET6, "FF02::2", &req.ipv6mr_multiaddr);

	sockfds[0] = socket(PF_INET6, SOCK_DGRAM, 0);
	sockfds[1] = socket(PF_INET6, SOCK_DGRAM, 0);

	filter.gf_interface = IFINDEX;
	filter.gf_fmode = MCAST_INCLUDE;
	filter.gf_numsrc = 1;
	psin6 = (struct sockaddr_in6 *)&filter.gf_group;
	psin6->sin6_family = AF_INET6;
	inet_pton(PF_INET6, "FF02::2", &psin6->sin6_addr);
	psin6 = (struct sockaddr_in6 *)&filter.gf_slist[0];
	psin6->sin6_family = AF_INET6;
	inet_pton(PF_INET6, "2002:de12:1780::1", &psin6->sin6_addr);

	setsockopt(sockfds[0], SOL_IPV6, IPV6_ADD_MEMBERSHIP, &req, sizeof(req));
	setsockopt(sockfds[0], SOL_IPV6, MCAST_MSFILTER, &filter, sizeof(filter));

	sleep(5);
	setsockopt(sockfds[1], SOL_IPV6, IPV6_ADD_MEMBERSHIP, &req, sizeof(req));

	pause();
	return 0;
}
