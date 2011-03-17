From: David Woodhouse <dwmw2@infradead.org>
Subject: SO_BINDTODEVICE inconsistency between IPv4 and IPv6
Date: Thu, 17 Mar 2011 10:29:10 +0000
Message-ID: <1300357750.2589.46.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-OaT7X0tpYq3WAMI1A/ER"
Cc: "Yuniverg, Michael" <michael.yuniverg@intel.com>,
	"Yedvab, Nadav" <nadav.yedvab@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:55992 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752881Ab1CQK3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 06:29:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OaT7X0tpYq3WAMI1A/ER
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

We've discovered strange behaviour when we listen on in6addr_any and use
SO_BINDTODEVICE to bind to the lo device.

We can connect to any IPv4 address that is local to the machine, on any
interface. (This is true whether we listen on AF_INET6/in6addr_any and
accept IPv4 connections on the IPv6 socket, or whether we just listen on
AF_INET/INADDR_ANY).

The IPv6 behaviour is different — the only IPv6 address that we can
connect to is ::1.

See attached test case, which listens with SO_BINDTODEVICE as described.
Note that it needs to be run as root because SO_BINDTODEVICE is a
privileged operation.

Why this difference? Ideally, we want the Legacy IP behaviour to happen
for IPv6 too; we want local clients to be able to connect to *any* local
IP address to talk to our service, but we don't want to accept
connections from the outside.

[root@macbook dwmw2]# uname -a
Linux macbook.infradead.org 2.6.35.11-83.fc14.x86_64 #1 SMP Mon Feb 7 07:06:44 UTC 2011 x86_64 x86_64 x86_64 GNU/Linux
[root@macbook dwmw2]# ./port -port  9999 &
Attempt to listening at port: 9999 ...successfully binded local
Block until interrupted by a signal (Ctrl+C or kill) ...
[1] 26839
[root@macbook dwmw2]# host macbook
macbook.infradead.org has address 90.155.92.212
macbook.infradead.org has IPv6 address 2001:8b0:10b:1:216:eaff:fe05:bbb8
[root@macbook dwmw2]# telnet 90.155.92.212 9999
Trying 90.155.92.212...
Connected to macbook.infradead.org (90.155.92.212).
Escape character is '^]'.
^]close

telnet> close
Connection closed.
[root@macbook dwmw2]# telnet 127.0.0.1 9999
Trying 127.0.0.1...
Connected to macbook.infradead.org (127.0.0.1).
Escape character is '^]'.
^]close

telnet> close
Connection closed.
[root@macbook dwmw2]# telnet ::1 9999
Trying ::1...
Connected to macbook.infradead.org (::1).
Escape character is '^]'.
^]close

telnet> close
Connection closed.
[root@macbook dwmw2]# telnet 2001:8b0:10b:1:216:eaff:fe05:bbb8 9999
Trying 2001:8b0:10b:1:216:eaff:fe05:bbb8...
telnet: connect to address 2001:8b0:10b:1:216:eaff:fe05:bbb8: Connection refused
telnet: Unable to connect to remote host: Connection refused
[root@macbook dwmw2]# ip -6 route list table local
local ::1 via :: dev lo  proto none  metric 0  mtu 16436 rtt 10ms rttvar 10ms cwnd 3 advmss 16376 hoplimit 0
local 2001:8b0:10b:1:216:eaff:fe05:bbb8 via :: dev lo  proto none  metric 0  mtu 16436 advmss 16376 hoplimit 0
local fe80::216:eaff:fe05:bbb8 via :: dev lo  proto none  metric 0  mtu 16436 advmss 16376 hoplimit 0
ff02::1 via ff02::1 dev wlan0  metric 0 
    cache  mtu 1500 advmss 1440 hoplimit 0
ff00::/8 dev wlan0  metric 256  mtu 1500 advmss 1440 hoplimit 0
[root@macbook dwmw2]# ip addr list
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
    link/ether 00:22:41:2d:31:0a brd ff:ff:ff:ff:ff:ff
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:16:ea:05:bb:b8 brd ff:ff:ff:ff:ff:ff
    inet 90.155.92.212/26 brd 90.155.92.255 scope global wlan0
    inet6 2001:8b0:10b:1:216:eaff:fe05:bbb8/64 scope global dynamic 
       valid_lft 294sec preferred_lft 114sec
    inet6 fe80::216:eaff:fe05:bbb8/64 scope link 
       valid_lft forever preferred_lft forever
4: virbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN 
    link/ether b2:5e:9d:17:67:ce brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
5: virbr1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN 
    link/ether 16:7e:11:12:43:09 brd ff:ff:ff:ff:ff:ff
    inet 192.168.100.1/24 brd 192.168.100.255 scope global virbr1
7: vpn0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1266 qdisc pfifo_fast state UNKNOWN qlen 500
    link/none 
    inet 10.255.16.41/22 brd 10.255.19.255 scope global vpn0

-- 
dwmw2

--=-OaT7X0tpYq3WAMI1A/ER
Content-Disposition: inline; filename="port.c"
Content-Type: text/x-csrc; name="port.c"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

/*! @file  port.c
 *  @brief Test socket with/without setsockopt(..,SO_BINDTODEVICE,..)
 *
 * 
 * 
 * @b Usage: ./port -port portNum
 *
 *
 * @b Author/Date: Michael Yuniverg, 17 March 2011
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>
#include <ifaddrs.h>
#include <string.h>
#include <signal.h>
#include <sys/file.h>
#include <net/if.h>


static char *pid_file = NULL;
static int s = -1;
struct addrinfo *paddrp = NULL;

void exitcleanup()
{
	if (pid_file) {
		unlink(pid_file);
	}
	if (paddrp) {
		freeaddrinfo(paddrp);
	}
}

void terminationHandler(int signum, siginfo_t *sinfo, void *dummy)
{
    //printf("Received termination signal:%d   Err:(%d) Code:(%d)\n", signum, sinfo->si_errno, sinfo->si_code);
	if (-1 != s) {
		close(s);
	}
	exit(EXIT_SUCCESS);
}

void setTerminationHandler()
{
	int sigSet = 0;
	// Termination signal handler.
	struct sigaction terminateAction;
	// Set up the structure to specify the termination action.
	terminateAction.sa_sigaction = terminationHandler;
	sigemptyset(&terminateAction.sa_mask);
	terminateAction.sa_flags = SA_SIGINFO;
	sigSet &= sigaction(SIGTERM, &terminateAction, NULL);
	sigSet &= sigaction(SIGQUIT, &terminateAction, NULL);
	sigSet &= sigaction(SIGINT,  &terminateAction, NULL);
	sigSet &= sigaction(SIGHUP,  &terminateAction, NULL);
	sigSet &= sigaction(SIGPIPE, &terminateAction, NULL);
	sigSet &= sigaction(SIGALRM, &terminateAction, NULL);
	sigSet &= sigaction(SIGUSR1, &terminateAction, NULL);
	sigSet &= sigaction(SIGUSR2, &terminateAction, NULL);

	if (sigSet != 0) {
		printf("Failed to register terminate signal handler\n");
	}
}

void Usage() {
        printf ("usage: port [options]\n");
        printf ("   -port <port_num> : indicate which port to listen at\n");
}

int main(int argc, char* argv[])
{
        char *port = NULL;
		struct addrinfo hints, *paddr;
        int backlog = 5;
        int i, err;
	int res = -1;

        // ---------------- Parse Options -----------------------------

        if (argc < 2) {
                Usage();
                return -1;
        }

        for (i = 1; i < argc; i++) {
                if (!strcmp(argv[i], "-port")) {
                        port = argv[++i];
                } else if (!strcmp(argv[i], "-file")) {
                        pid_file = argv[++i];
                } else {
                        Usage();
                        return -1;
                }
        }

        if (port == NULL) {
                Usage();
                return -1;
        }

        
		setTerminationHandler();

       
        atexit(exitcleanup);

        memset(&hints, 0, sizeof(hints));
        hints.ai_family = PF_INET6;
        hints.ai_socktype = SOCK_STREAM;
	hints.ai_protocol = 0;
#ifdef AI_NUMERICSERV
	hints.ai_flags   |= AI_NUMERICSERV;
#endif
        hints.ai_flags |= AI_PASSIVE;

	if (getaddrinfo(NULL, port, &hints, &paddrp) != 0) {
		goto error;
	}
	for (paddr = paddrp; paddr != NULL; paddr = paddr->ai_next) {

                struct sockaddr_in *sinp;
                sinp = (struct sockaddr_in *)paddr->ai_addr;
                printf ("Attempt to listening at port: %d ...", ntohs(sinp->sin_port));
                 
                s= socket(paddr->ai_family, paddr->ai_socktype, paddr->ai_protocol);
                if (s < 0) {
                        goto error;
                }
				
				/* the problematic system call */
				const char *device = "lo";
				struct ifreq ifr;
				strcpy(ifr.ifr_name, device);
				if(setsockopt(s,SOL_SOCKET,SO_BINDTODEVICE, &ifr,sizeof(ifr)) == -1)
				{
				  //error = errno;
					perror("SO_BINDTODEVICE");
					close(s);
					return -1;
				}
				printf("successfully binded local\n");
				/* end of problematic system call */

				if (bind(s, paddr->ai_addr, paddr->ai_addrlen) == -1) {
                        close(s);
                        printf ("bind failed. Exiting\n");
                        return -1;
                }

                if (listen(s, backlog) == -1) {
                        close(s);
                        goto error;
                }

                printf ("Block until interrupted by a signal (Ctrl+C or kill) ...\n");
                select(1, NULL, NULL, NULL, NULL);
        }

        close(s);
        return 0;
error:
        //err = GetLastError();
        //printf ("FAIL (0x%x)\n", err);
        //DisplayError(err) ;
        return -1;
}

--=-OaT7X0tpYq3WAMI1A/ER--

