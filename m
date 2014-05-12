From: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Subject: Socket receives packet to multicast group to which it was not joined
 since kernel 3.13.10-1
Date: Mon, 12 May 2014 20:38:03 +0400
Message-ID: <5370F8EB.2070009@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040606050806040304000203"
Cc: "Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([84.52.89.53]:35903 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbaELQrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 12:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040606050806040304000203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On kernel 3.13.10-1 I see that socket joined to one multicast group 
receives packets to another multicast address. That can be reproduced by 
the following example:

1. socket(DGRAM) -> 3
2. bind(3, 0.0.0.0:12345) -> 0
3. setsockopt(3, IP_MULTICAST_IF, {224.168.2.9, 7}) -> 0
// "7" is correct interface index

4. Send packet from peer host to 224.168.2.9:12345
5. poll({3, POLLIN}) -> 1
6. recv(3) -> <data_length>

5. Send packet from peer host to 225.168.2.9:12345
// Note that the address is not the same!
6. poll({3, POLLIN}) -> 1
7. recv(3) -> <data_length>

I checked kernel 3.12.6-2, there is no such problem. I have placed 
simple C-program in attachment to reproduce the behaviour. It should be 
called:
./mult_recv <mcast_address> <interface index> i.e. in example above:
./mult_recv 224.168.2.9 7

--------------040606050806040304000203
Content-Type: text/x-csrc;
 name="mult_recv.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mult_recv.c"

#include <stdio.h>
#include <netinet/in.h>
#include <errno.h>
#include <string.h>
#include <poll.h>

int
main(int argc, char *argv[])
{
    int sock;
    int rc;
    struct sockaddr_in addr;
    struct ip_mreqn req;
    char buf[256];
    struct pollfd fds;

    if (argc < 2)
    {
        printf("\nToo few arguments\n");
        return 1;
    }

    sock = socket(PF_INET, SOCK_DGRAM, 0);
    printf("socket() -> %d(%d)\n", sock, errno);

    addr.sin_family = AF_INET;
    addr.sin_port = htons(12345);
    addr.sin_addr.s_addr = INADDR_ANY;
    rc = bind(sock, (struct sockaddr*)&addr, sizeof(addr));
    printf("bind() -> %d(%d)\n", rc, errno);

    memset((void *)&req, 0, sizeof(req));
    rc = inet_aton(argv[1], &req.imr_multiaddr);
    printf("inet_aton() -> %d(%d)\n", rc, errno);
    req.imr_ifindex = atoi(argv[2]);

    rc = setsockopt(sock, SOL_IP, IP_ADD_MEMBERSHIP, &req, sizeof(req));
    printf("setsockopt() -> %d(%d)\n", rc, errno);

    printf("Send packet to %s:12345 address...", argv[1]);
    getchar();

    fds.fd = sock;
    fds.events = POLLIN;
    rc = poll(&fds, 1, 1000);
    printf("poll() -> %d(%d)\n", rc, errno);

    if (rc != 1)
    {
        printf("The packet was not received.\n");
        return 1;
    }

    rc = recv(sock, buf, sizeof(buf), 0);
    printf("recv() -> %d(%d)\n", rc, errno);

    printf("Send packet to different multicast address(with 12345 port)...");
    getchar();

    rc = poll(&fds, 1, 1000);
    printf("poll() -> %d(%d)\n", rc, errno);

    if (rc != 0)
    {
        printf("The packet to different multicast address was received.\n");
        rc = recv(sock, buf, sizeof(buf), 0);
        printf("recv() -> %d(%d)\n", rc, errno);
        return 1;
    }
    printf("The behaviour is correct\n");

    return 0;
}

--------------040606050806040304000203--
