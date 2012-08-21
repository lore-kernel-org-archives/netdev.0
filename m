From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Bug with IPv6-UDP address binding
Date: Tue, 21 Aug 2012 23:51:26 +0200
Message-ID: <1345585886.3069.285.camel@localhost>
References: <1344458238.3069.13.camel@localhost>
	 <1344459591.28967.271.camel@edumazet-glaptop>
	 <1344505205.3069.55.camel@localhost>
	 <1344512634.28967.732.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758608Ab2HUVwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 17:52:02 -0400
In-Reply-To: <1344512634.28967.732.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-09 at 13:43 +0200, Eric Dumazet wrote:

> Here is an IPv4 sample UDP application, able to echo packets with the IP
> source set to original DST address of the ping packet.
> 
> Doing the same on IPv6 is probably trivial as well

I have implemented a combined IPv6 + IPv4 version of the udp echo code,
and placed it on github here:

https://github.com/netoptimizer/network-testing/blob/master/src/udp_echo.c

Comments and patches are welcome ;-)


> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <linux/udp.h>
> #include <string.h>
> #include <stdio.h>
> #include <unistd.h>
> #include <arpa/inet.h>
> 
> #define PORT 4040
> 
> int pktinfo_get(struct msghdr *my_hdr, struct in_pktinfo *pktinfo)
> {
> 	int res = -1;
> 
> 	if (my_hdr->msg_controllen > 0) {
> 		struct cmsghdr *get_cmsg;
> 		for (get_cmsg = CMSG_FIRSTHDR(my_hdr); get_cmsg;
> 			get_cmsg = CMSG_NXTHDR(my_hdr, get_cmsg)) {
> 			if (get_cmsg->cmsg_type == IP_PKTINFO) {
> 				struct in_pktinfo *get_pktinfo = (struct in_pktinfo *)CMSG_DATA(get_cmsg);
> 				memcpy(pktinfo, get_pktinfo, sizeof(*pktinfo));
> 				res = 0;
> 			}
> 		}
> 	}
> 	return res;
> }
> 
> int main(int argc, char *argv[])
> {
> 	int fd = socket(AF_INET, SOCK_DGRAM, 0);
> 	struct sockaddr_in addr, rem_addr;
> 	int res, on = 1;
> 	struct msghdr msghdr;
> 	struct iovec vec[1];
> 	char cbuf[512];
> 	char frame[4096];
> 	struct in_pktinfo pktinfo;
> 	int c, count = 1000000;
> 
> 	while ((c = getopt(argc, argv, "c:")) != -1) {
> 		if (c == 'c') count = atoi(optarg);
> 		}
> 	memset(&addr, 0, sizeof(addr));
> 	addr.sin_family = AF_INET;
> 	addr.sin_port = htons(PORT);
> 	if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
> 		perror("bind");
> 		return 1;
> 	}
> 	setsockopt(fd, SOL_IP, IP_PKTINFO, &on, sizeof(on));
> 
> 	while (1) {
> 		memset(&msghdr, 0, sizeof(msghdr));
> 		msghdr.msg_control = cbuf;
> 		msghdr.msg_controllen = sizeof(cbuf);
> 		msghdr.msg_iov = vec;
> 		msghdr.msg_iovlen = 1;
> 		vec[0].iov_base = frame;
> 		vec[0].iov_len = sizeof(frame);
> 		msghdr.msg_name = &rem_addr;
> 		msghdr.msg_namelen = sizeof(rem_addr);
> 		res = recvmsg(fd, &msghdr, 0);
> 		if (res == -1)
> 			break;
> 		if (pktinfo_get(&msghdr, &pktinfo) == 0)
> 			printf("Got IP_PKTINFO dst addr=%s\n", inet_ntoa(pktinfo.ipi_spec_dst));
> 
> 		/* ok, just echo reply this frame.
> 		 * Using sendmsg() will provide IP_PKTINFO back to kernel
> 		 * to let it use the 'right' source address
> 		 * (destination address of the incoming packet)
> 		 */
> 		vec[0].iov_len = res;
> 		sendmsg(fd, &msghdr, 0);
> 		if (--count == 0)
> 			break;
> 	}
> 	return 0;
> }
> 
> 
