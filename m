From: Kengo Sakai <kengo.sakai@atr.jp>
Subject: [QUESTION] About IPv6 flowlabel in a TCP IPv6 Server
Date: Tue, 16 Jun 2009 10:37:21 +0900
Message-ID: <4A36F751.6070306@atr.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2w.atr.jp ([133.186.1.11]:53925 "EHLO mailgw2.atr.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbZFPBw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2009 21:52:58 -0400
Received: from vcms2.atr.jp (beta.atr.jp [133.186.254.11])
	by mailgw2.atr.jp (Postfix) with ESMTP id 12D6617025
	for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 10:39:34 +0900 (JST)
Received: from [133.186.51.154] (unknown [133.186.51.154])
	by vcms2.atr.jp (Postfix) with ESMTP id D3C446879C
	for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 10:39:33 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm really interested in using IPv6 flowlabel in Linux.
But, there seems to be no documentation available about it.
So I have some questions.
Could you help me if you have a time to answer them?

1) Are there any documents about IPv6 flowlabel usage in Linux?
I couldn't find it.

2) Can a flowlabel be set to a sending packet in a TCP IPv6 Server?
I'm trying to set a flowlabel in a TCP IPv6 Server.
I expected that I should call setsockopt(2) to accpeted descripter,
like attached my simple TCP server, but failed.

so I read net/ipv6/ip6_flowlabel.c, net/ipv6/tcp_ipv6.c, and so on.
I guess that it have not been implemented yet.
My understanding is
  * In inet6_csk_xmit(), struct ipv6_pinfo.flow_label is set to
    the IP header.
  * When setsockopt(2) is called, the flowlabel is set to
    struct ip6_flowlabel.label.
  * If client, when connect(2) or sendto(2) is called,
    struct ip6_flowlabel.label is set to struct ipv6_pinfo.flow_label.
    but, if TCP server, there is no such code.

I am unused to reading kernel code, I might misunderstand it.

or what, are there any way to set a flowlabel without setsockopt(2) ?


Attached you can find is my simple TCP server program.
Of course I don't expect you to debug my code,
but I suppose it may be helpful.

Thanks,
Kengo SAKAI


// tcpserver6.c
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

#define BACKLOG 5
#define PORT "12345"

int tcp_listen(const char* service) {
   int err;
   struct addrinfo hints;
   struct addrinfo* res = NULL;
   struct addrinfo* ai;
   int sockfd;

   memset(&hints, 0, sizeof(hints));
   hints.ai_family = AF_INET6;
   hints.ai_socktype = SOCK_STREAM;
   hints.ai_flags = AI_PASSIVE;

   err = getaddrinfo(NULL, service, &hints, &res);
   if (err != 0) {
       printf("getaddrinfo(): %s\n", gai_strerror(err));
       return -1;
   }

   ai = res;
   sockfd = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
   if (sockfd < 0)
       return -1;

   if (bind(sockfd, ai->ai_addr, ai->ai_addrlen) < 0)
       return -1;

   if (listen(sockfd, BACKLOG) < 0)
       return -1;

   freeaddrinfo(res);
   return sockfd;
}

int main() {
   int sockfd;

   sockfd = tcp_listen(PORT);
   if (sockfd < 0) {
       perror("server");
       exit(1);
   }

   printf("wait...\n");

   while (1) {
       int cs;
       struct sockaddr_storage sa;
       socklen_t len = sizeof(sa);
       cs = accept(sockfd, (struct sockaddr*) &sa, &len);
       if (cs < 0) {
           if (errno == EINTR)
               continue;
           perror("accept");
           exit(1);
       }

       printf("accepted.\n");

       char ch;

       (void)set_flow_label(cs, &sa);
       read(cs, &ch, 1);
       write(cs, &ch, 1); // I expected that the flowlabel is set to the
packet, but failed...

       close(cs);
   }
   return 0;
}
// tcpserver6.c end

// flowlabel.c
#include <sys/socket.h>
#include <linux/in.h>
#include <linux/in6.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

int set_flow_label(int sock, struct sockaddr_in6 *addr)
{
   char freq_buf[sizeof(struct in6_flowlabel_req)];
   struct in6_flowlabel_req *freq = (struct in6_flowlabel_req *)freq_buf;
   int freq_len = sizeof(*freq);
   int on = 1;

   if (setsockopt(sock, IPPROTO_IPV6, IPV6_FLOWINFO_SEND,
              &on, sizeof(on)) == -1) {
       printf("setsockopt: %s\n", strerror(errno));
       return 1;
   }

   memset(freq, 0, sizeof(*freq));
   freq->flr_label = 0;
   freq->flr_action = IPV6_FL_A_GET;
   freq->flr_flags = IPV6_FL_F_CREATE;
   freq->flr_share = IPV6_FL_S_EXCL;
   memcpy(&freq->flr_dst, &addr->sin6_addr, 16);
   if (setsockopt(sock, IPPROTO_IPV6, IPV6_FLOWLABEL_MGR, freq, freq_len)
           == -1) {
       printf("setsockopt: %s\n", strerror(errno));
       return 1;
   }
   return 0;
}
// flowlabel.c end

