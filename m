From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 6646] New: UDP socket doesn't return to bound
 state after association is dissolved by connect(..AF_UNSPEC)
Date: Mon, 5 Jun 2006 00:07:51 -0700
Message-ID: <20060605000751.f3bc7ed3.akpm@osdl.org>
References: <200606050658.k556wJ8X032608@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54407 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932434AbWFEHH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 03:07:58 -0400
To: netdev@vger.kernel.org, yujiang.wang@sun.com
In-Reply-To: <200606050658.k556wJ8X032608@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 4 Jun 2006 23:58:19 -0700
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=6646
> 
>            Summary: UDP socket doesn't return to bound state after
>                     association is dissolved by connect(..AF_UNSPEC)
>     Kernel Version: 2.6.12
>             Status: NEW
>           Severity: high
>              Owner: shemminger@osdl.org
>          Submitter: yujiang.wang@sun.com
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution:
> Hardware Environment:
> Software Environment:
> Problem Description:
> When disconnect a UDP socket, Linux kernel set local port to zero if the port
> number comes from a implicit bind. Linux connect(2) man page reads:
> "Generally, connection-based protocol sockets may successfully *connect* only
> once; connectionless protocol sockets may use *connect* multiple times to change
> their association. Connectionless sockets may dissolve the association by
> connecting to an address with the /sa_family/ member of *sockaddr* set to
> *AF_UNSPEC*."
> But dissolve the association should not impact the local binding, while
> currently it does. In contrast, Unix variants like Solaris don't alter local
> binding when disconnecting a UDP socket. 
> 
> Steps to reproduce:
> Compile attached c file, and run it. You'll see local port number changed after
> a UDP socket disconnected.
> 
> #include <errno.h>
> #include <string.h>
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <netinet/in.h>
> #include <net/if.h>
> #include <netdb.h>
> #include <arpa/inet.h>
> #include <stdio.h>
> #include <stdlib.h>
> 
> #define SERV_PORT 12345
> 
> void print_local_addr(int s);
> 
> int main(int argc, char** argv)
> {
>     int sockfd;
>     struct sockaddr_in servaddr, cliaddr;
> 
>     if (argc != 2) {
>         printf("Usage: disconnect_udp <ipaddress>");
>         exit(0);
>     }
>     
>     // creat a UDP socket which binds to a local address
>     sockfd = socket(AF_INET, SOCK_DGRAM, 0);
>     bzero(&cliaddr, sizeof(cliaddr));
>     cliaddr.sin_family = AF_INET;
>     if (inet_pton(AF_INET, argv[1], &cliaddr.sin_addr) != 1) {
>         perror("inet_pton failed");
>     }
>     bind(sockfd, (struct sockaddr *)&cliaddr, sizeof(cliaddr));
>     
>     // connect this UDP socket
>     bzero(&servaddr, sizeof(servaddr));
>     servaddr.sin_family = AF_INET;
>     servaddr.sin_port = htons(SERV_PORT);
>     if (inet_pton(AF_INET, argv[1], &servaddr.sin_addr) != 1) {
>         perror("inet_pton failed");
>     }
>     if (connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) != 0) {
>         perror("connect failed");
>     }
>     print_local_addr(sockfd);
>     
>     // disconnect it
>     servaddr.sin_family = AF_UNSPEC;
>     if (connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) != 0) {
>         perror("connect failed");
>     }
>     print_local_addr(sockfd);
>     
>     close(sockfd);
> }
> 
> void print_local_addr(int s)
> {
>     struct sockaddr_in localaddr;
>     socklen_t len = 0;
>     char temp[INET_ADDRSTRLEN];
>     
>     len = sizeof(localaddr);
>     if (getsockname(s, (struct sockaddr *)&localaddr, &len) != 0) {
>         perror("getsockname failed");
>     }
>     
>     inet_ntop(AF_INET, &localaddr.sin_addr, temp, INET_ADDRSTRLEN);
>     printf("Local binding: address=%s, port=%d\n",
>            temp, ntohs(localaddr.sin_port));
> }
> 
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
