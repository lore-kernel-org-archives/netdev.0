From: Yan Zheng <yzcorp@gmail.com>
Subject: Re: [PATCH][MCAST]IPv6: small fix for ip6_mc_msfilter(...)
Date: Tue, 1 Nov 2005 18:37:43 +0800
Message-ID: <7e77d27c0511010237x775529b8h@mail.gmail.com>
References: <436586F0.9080101@21cn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750734AbVKAKhp@vger.kernel.org>
To: netdev@vger.kernel.org
In-Reply-To: <436586F0.9080101@21cn.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You can reproduce this bug by follow codes. This program will cause a
change to include report even though the first socket's filter mode is
exclude.

Please adjust IFINDEX first.
========================================
#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/types.h>
#define IFINDEX 6

int main(int argc, char argv[])
{
	int i, sockfds[3];
	struct ipv6_mreq req;
	struct group_filter filter;
	struct sockaddr_in6 *psin6;
	req.ipv6mr_interface = IFINDEX;
	inet_pton(PF_INET6, "FF02::2", &req.ipv6mr_multiaddr);

	for (i = 0; i < 3; ++i) {
		sockfds[i] = socket(PF_INET6, SOCK_DGRAM, 0);
		setsockopt(sockfds[i], SOL_IPV6, IPV6_ADD_MEMBERSHIP, &req, sizeof(req));
	}
	
	filter.gf_interface = IFINDEX;
	filter.gf_fmode = MCAST_INCLUDE;
	filter.gf_numsrc = 1;
	psin6 = (struct sockaddr_in6 *)&filter.gf_group;
	psin6->sin6_family = AF_INET6;
	inet_pton(PF_INET6, "FF02::2", &psin6->sin6_addr);
	psin6 = (struct sockaddr_in6 *)&filter.gf_slist[0];
	psin6->sin6_family = AF_INET6;
	inet_pton(PF_INET6, "2002:de12:1780::1", &psin6->sin6_addr);
	setsockopt(sockfds[1], SOL_IPV6, MCAST_MSFILTER, &filter, sizeof(filter));
	
	filter.gf_fmode = MCAST_EXCLUDE;
	filter.gf_numsrc = 0;
	setsockopt(sockfds[2], SOL_IPV6, MCAST_MSFILTER, &filter, sizeof(filter));
	setsockopt(sockfds[2], SOL_IPV6, MCAST_MSFILTER, &filter, sizeof(filter));

	pause();
}
