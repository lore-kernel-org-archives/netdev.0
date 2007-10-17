From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: multicast: bug or "feature"
Date: Wed, 17 Oct 2007 17:25:40 -0400
Message-ID: <47167DD4.3020108@hp.com>
References: <OF8C1D2DD7.B02D8047-ON88257377.00705A00-88257377.00707296@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040902090103050503050407"
Cc: Brian Haley <brian.haley@hp.com>, netdev <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:37565 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628AbXJQV0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 17:26:10 -0400
In-Reply-To: <OF8C1D2DD7.B02D8047-ON88257377.00705A00-88257377.00707296@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040902090103050503050407
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

David Stevens wrote:
> Can you send the contents of /proc/net/igmp and the packet trace,
> also? And the code?
> 
>                                         +-DLS
> 

# cat /proc/net/igmp
Idx     Device    : Count Querier       Group    Users Timer    Reporter
1       lo        :     0      V3
                                010000E0     1 0:00000000               0
2       eth0      :     3      V2
                                010000E0     1 0:00000000               0
3       eth1      :     4      V2
                                030100E0     1 0:00000000               1
                                010000E0     1 0:00000000               0



Source attached.  The trace only shows a single udp packet and you can
re-create it with the attached small apps.

-vlad

--------------040902090103050503050407
Content-Type: text/x-csrc;
 name="client.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="client.c"

#include <stdio.h>
#include <string.h>
#include <netinet/in.h>


int main(int argc, char **argv)
{
	struct sockaddr_storage dest;
	struct sockaddr_storage src;
	struct sockaddr_in *s = (struct sockaddr_in*) &src;
	struct sockaddr_in *d = (struct sockaddr_in *)&dest;
	int sock;
	char msg[] = "Hello Multicast";
	int off = 0;

	memset(&dest, 0, sizeof(dest));
	memset(&src, 0, sizeof(src));

	if (argc < 3) {
		printf("Usage: <src ip>  <mcast dest>\n");
		return 1;
	}


	d->sin_family = s->sin_family = AF_INET;
	d->sin_port = htons(2000);

	inet_aton(argv[1], &s->sin_addr);
	inet_aton(argv[2], &d->sin_addr);

	sock = socket(AF_INET, SOCK_DGRAM, 0);

	if (setsockopt(sock, IPPROTO_IP, IP_MULTICAST_LOOP, &off,
							sizeof(off))) {
		perror("setsockopt");
		return 1;
	}
	if (setsockopt(sock, IPPROTO_IP, IP_MULTICAST_IF, s, sizeof(*s))) {
		perror("setsockopt");
		return 1;
	}

	sendto(sock, msg, sizeof(msg), 0, (struct sockaddr *)d, sizeof(*d));

	close (socket);
	return 0;
}

--------------040902090103050503050407
Content-Type: text/x-csrc;
 name="server.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="server.c"

#include <stdio.h>
#include <string.h>
#include <netinet/in.h>


int main(int argc, char **argv)
{
	struct sockaddr_in addr;
	int addr_len;
	struct ip_mreq req;
	int sock;
	char msg[256];

	memset(&addr, 0, sizeof(addr));

	if (argc < 3) {
		printf("Usage: <interface ip> <mcast group>\n");
		return 1;
	}

	sock = socket(AF_INET, SOCK_DGRAM, 0);
	addr.sin_family = AF_INET;
	addr.sin_port = htons(2000);
	if (bind(sock, (struct sockaddr *)&addr, sizeof(addr))) {
		perror("bind");
		return 1;
	}

	inet_aton(argv[1], &req.imr_interface);
	inet_aton(argv[2], &req.imr_multiaddr);

	if (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, &req,
							    sizeof(req))) {
		perror("setsockopt");
		return 1;
	}

	recvfrom(sock, msg, sizeof(msg), 0, (struct sockaddr *)&addr, &addr_len);

	printf("Message recieved: %s", msg);

	close (socket);
	return 0;
}

--------------040902090103050503050407--
