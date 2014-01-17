From: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>
Subject: Multicast packets receiving problem on linux since version 3.10.1
Date: Fri, 17 Jan 2014 19:10:59 +0400
Message-ID: <52D94803.1040406@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040006000305050301090702"
Cc: Konstantin Ushakov <Konstantin.Ushakov@oktetlabs.ru>,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>,
	Yurij Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([195.131.132.186]:58226 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752032AbaAQPRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 10:17:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040006000305050301090702
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Greetings,

there is a problem with receiving multicast packets on linux-3.10.1 and
newer. It's reproducible with two hosts (host_A, host_B), with eth3@host_A
directly connected to eth3@host_B. Two VLANs and one multicast group are 
used.
Each side opens two sockets and binds them to different VLAN interfaces.
host_A arranges both sockets to receive multicast packets of the group.
Then the first socket is removed from the group. After this the second 
socket
can no longer receive multicast packets of the group, which sent by the
second host. See the example below.

host_A:
Two VLANs 999 and 1001 are added on eth3:
eth3.999      10.208.14.1
eth3.1001     10.208.15.1

1. socket(SOCK_DGRAM) -> 3
2. setsockopt(3, SOL_SOCKET, SO_REUSEADDR, 1) -> 0
3. setsockopt(3, IPPROTO_IP, MCAST_JOIN_GROUP, {229.17.88.168, 
eth3.999}) -> 0
4. setsockopt(3, SOL_SOCKET, SO_BINDTODEVICE, eth3.999) -> 0
5. bind(3, 0.0.0.0:29214)->0
6. socket(SOCK_DGRAM) -> 4
7. setsockopt(4, SOL_SOCKET, SO_REUSEADDR, 1) -> 0
8. setsockopt(4, IPPROTO_IP, MCAST_JOIN_GROUP, {229.17.88.168, 
eth3.1001}) -> 0
9. setsockopt(4, SOL_SOCKET, SO_BINDTODEVICE, eth3.1001) -> 0
10. bind(4, 0.0.0.0:29214) -> 0

11. poll({{3, POLLIN}, {4, POLLIN}}, 2, 30000) -> 2
12. recv(3, buf, 100) -> 100
13. recv(4, buf, 99) -> 99
14. setsockopt(3, IPPROTO_IP, MCAST_LEAVE_GROUP, {229.17.88.168, 
eth3.999}) -> 0
15. poll({{3, POLLIN}, {4, POLLIN}}, 2, 30000) -> 0

Socket 4 does not receive the multicast packet on linux 3.10 and newer. But
it receives the packet with older linux versions. Probably the packet is
filtered by NIC, tcpdump does not see it.


host_B:
Two VLANs 999 and 1001 are added on eth3:
eth3.999      10.208.14.2
eth3.1001     10.208.15.2

16. socket(SOCK_DGRAM) -> 3
17. bind(3, 10.208.14.2:29219) -> 0
18. socket(SOCK_DGRAM) -> 4
19. bind(4, 10.208.15.2:29219) -> 0
20. sendto(3, 229.17.88.168:29214, buf, 100) -> 100
21. sendto(4, 229.17.88.168:29214, buf, 99) -> 99
Continue when socket 3 on host_A will leave the group (line 14).
22. sendto(3, 229.17.88.168:29214, buf, 100) -> 100
23. sendto(4, 229.17.88.168:29214, buf, 99) -> 99


Note, that if I replace step #14 with:
 > setsockopt(4, IPPROTO_IP, MCAST_LEAVE_GROUP, {229.17.88.168, 
eth3.1001}) -> 0
and remove the second socket from the group (instead of the first one) - 
then
the first socket will receive it's packet.

Find client and server C programs that reproduce the problem attached. 
The client
logs received packets. As stated above in good case it will log 3 
packets and in
bad one - only 2. Use the following command lines to start the client 
and server:
host_A:
sudo ip link add link eth3 name eth3.999 type vlan id 999
sudo ifconfig eth3.999 10.208.14.1/24
sudo ip link add link eth3 name eth3.1001 type vlan id 1001
sudo ifconfig eth3.1001 10.208.15.1/24

gcc mcast_client.c -o cl
sudo ./cl

host_B:
sudo ip link add link eth3 name eth3.999 type vlan id 999
sudo ifconfig eth3.999 10.208.14.2/24
sudo ip link add link eth3 name eth3.1001 type vlan id 1001
sudo ifconfig eth3.1001 10.208.15.2/24

gcc mcast_serv.c -o serv
./serv

Thanks in advance,
Andrey Dmitrov

--------------040006000305050301090702
Content-Type: text/x-csrc;
 name="mcast_client.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mcast_client.c"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <net/if.h> 

#define ERROR(_line...) \
do { \
    fprintf(stderr, _line); \
    fprintf(stderr, "\n"); \
    assert(0); \
} while (0)

#define ERROR_CL(_line...) \
do { \
    close(sock); \
    ERROR(_line); \
} while (0)

#define WARN(_line...) \
do { \
    printf(_line); \
    printf("\n"); \
} while (0)

#define MCAST_GROUP "229.17.88.168"
#define PORT 12345

#define VLAN1 "999"
#define VLAN2 "1001"
#define VLAN_IF_STR(_vlan) "eth3." _vlan
#define VLAN_IF1 VLAN_IF_STR(VLAN1)
#define VLAN_IF2 VLAN_IF_STR(VLAN2)

static int
init_socket(const char *ifname)
{
    int                 sock;
    int                 val = 1;
    struct group_req    req;
    struct sockaddr_in  addr;
    struct ifreq        ifr;

    if ((sock = socket(PF_INET, SOCK_DGRAM, 0)) < 0)
        ERROR("Can't open socket: %s", strerror(errno));

    if (setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(val)) != 0)
        ERROR_CL("Can't set SO_REUSEADDR for socket: %s", strerror(errno));

    memset(&req, 0, sizeof(req));
    if ((req.gr_interface = if_nametoindex(ifname)) <= 0)
        ERROR_CL("Wrong interface index: %s", strerror(errno));

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    if (inet_pton(AF_INET, MCAST_GROUP, &addr.sin_addr) != 1)
        ERROR_CL("Can't convert mcast group address: %s", strerror(errno));

    memcpy(&req.gr_group, &addr, sizeof(addr));
    if (setsockopt(sock, IPPROTO_IP, MCAST_JOIN_GROUP, &req,
                   sizeof(req)) != 0)
        ERROR_CL("Can't set SO_REUSEADDR for socket: %s", strerror(errno));

    memset(&ifr, 0, sizeof(struct ifreq));
    snprintf(ifr.ifr_name, sizeof(ifr.ifr_name), ifname);
    if (ioctl(sock, SIOCGIFINDEX, &ifr) != 0)
        ERROR_CL("Can't get interface index with ioctl: %s", strerror(errno));

    if (setsockopt(sock, SOL_SOCKET, SO_BINDTODEVICE, &ifr, sizeof(struct ifreq)) != 0)
        ERROR_CL("SO_BINDTODEVICE failed: %s", strerror(errno));

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(PORT);
    if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) != 0)
        ERROR_CL("bind failed: %s", strerror(errno));

    return sock;
}

static int
leave_group(int sock, const char *ifname)
{
    struct group_req    req;
    struct sockaddr_in  addr;

    memset(&req, 0, sizeof(req));
    if ((req.gr_interface = if_nametoindex(ifname)) <= 0)
    {
        WARN("Wrong interface index: %s", strerror(errno));
        return -1;
    }

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    if (inet_pton(AF_INET, MCAST_GROUP, &addr.sin_addr) != 1)
    {
        WARN("Can't convert mcast group address: %s", strerror(errno));
        return -1;
    }

    memcpy(&req.gr_group, &addr, sizeof(addr));
    if (setsockopt(sock, IPPROTO_IP, MCAST_LEAVE_GROUP, &req, sizeof(req)) != 0)
    {
        WARN("Can't set SO_REUSEADDR for socket: %s", strerror(errno));
        return -1;
    }

    return 0;
}

int
main(void)
{
    int     sock1;
    int     sock2;
    char    buf[100];
    int     len;
    int     rc = EXIT_SUCCESS;

    sock1 = init_socket(VLAN_IF1);
    sock2 = init_socket(VLAN_IF2);

    if ((len = recv(sock1, buf, sizeof(buf), 0)) < 0)
        WARN("Failed to receive packets: %s", strerror(errno));
    WARN("packet length %d", len);
    if ((len = recv(sock2, buf, sizeof(buf), 0)) < 0)
        WARN("Failed to receive packets: %s", strerror(errno));
    WARN("packet length %d", len);

    if (leave_group(sock1, VLAN_IF1) != 0)
    {
        WARN("Failed to leave group");
        rc = EXIT_FAILURE;
        goto cleanup;
    }

    if ((len = recv(sock2, buf, sizeof(buf), 0)) < 0)
        WARN("Failed to receive packets: %s", strerror(errno));
    WARN("packet length %d", len);
    if ((len = recv(sock1, buf, sizeof(buf), 0)) < 0)
        WARN("Failed to receive packets: %s", strerror(errno));
    WARN("packet length %d", len);

cleanup:
    close(sock1);
    close(sock2);

    return rc;
}

--------------040006000305050301090702
Content-Type: text/x-csrc;
 name="mcast_serv.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mcast_serv.c"

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <arpa/inet.h>

#define ERROR(_line...) \
do { \
    fprintf(stderr, _line); \
    fprintf(stderr, "\n"); \
    assert(0); \
} while (0)

#define ERROR_CL(_line...) \
do { \
    close(sock); \
    ERROR(_line); \
} while (0)

#define WARN(_line...) \
do { \
    printf(_line); \
    printf("\n"); \
} while (0)

#define MCAST_GROUP "229.17.88.168"
#define GROUP_PORT 12345

#define LOCAL_PORT 23456
#define LOCAL_ADDR1 "10.208.14.2"
#define LOCAL_ADDR2 "10.208.15.2"

#define VLAN1 "999"
#define VLAN2 "1001"
#define VLAN_IF_STR(_vlan) "eth3." _vlan
#define VLAN_IF1 VLAN_IF_STR(VLAN1)
#define VLAN_IF2 VLAN_IF_STR(VLAN2)

static int
init_socket_send(const char *ifname, const char *local_addr)
{
    int                 sock;
    struct sockaddr_in  addr;
    struct in_addr      ifaddr;

    if ((sock = socket(PF_INET, SOCK_DGRAM, 0)) < 0)
        ERROR("Can't open socket: %s", strerror(errno));

    WARN("if %s, addr %s", ifname, local_addr);
    if (inet_aton(local_addr, &ifaddr) == 0)
        ERROR_CL("inet_aton failed: %s", strerror(errno));

    if (setsockopt(sock, SOL_IP, IP_MULTICAST_IF, &ifaddr, sizeof(ifaddr)) != 0)
        ERROR_CL("IP_MULTICAST_IF failed: %s", strerror(errno));

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(LOCAL_PORT);
    if (inet_pton(AF_INET, local_addr, &addr.sin_addr) != 1)
        ERROR_CL("Can't convert mcast group address: %s", strerror(errno));

    if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) != 0)
        ERROR_CL("bind failed: %s", strerror(errno));

    return sock;
}

int
main(void)
{
    int     sock1;
    int     sock2;
    char    buf[100];

    struct sockaddr_in addr;

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(GROUP_PORT);
    if (inet_pton(AF_INET, MCAST_GROUP, &addr.sin_addr) != 1)
        ERROR("Can't convert mcast group address: %s", strerror(errno));

    sock1 = init_socket_send(VLAN_IF1, LOCAL_ADDR1);
    sock2 = init_socket_send(VLAN_IF2, LOCAL_ADDR2);

    if (sendto(sock1, buf, 99, 0, (struct sockaddr *)&addr, sizeof(addr)) != 99 ||
        sendto(sock2, buf, 98, 0, (struct sockaddr *)&addr, sizeof(addr)) != 98)
        WARN("send failed: %s", strerror(errno));

    sleep(1);

    if (sendto(sock1, buf, 97, 0, (struct sockaddr *)&addr, sizeof(addr)) != 97 ||
        sendto(sock2, buf, 96, 0, (struct sockaddr *)&addr, sizeof(addr)) != 96)
        WARN("send failed: %s", strerror(errno));


    close(sock1);
    close(sock2);

    return EXIT_SUCCESS;
}

--------------040006000305050301090702--
