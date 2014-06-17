From: James Ward <j.ward@acfr.usyd.edu.au>
Subject: Broken IPv6 multicast binding
Date: Tue, 17 Jun 2014 14:12:09 +1000
Message-ID: <539FC019.4010804@acfr.usyd.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080306020307060701040407"
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rosaceae.acfr.usyd.edu.au ([129.78.210.249]:60728 "EHLO
	smtp.acfr.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaFQEjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 00:39:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080306020307060701040407
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

My colleagues and I have uncovered what we believe is a bug around 
multicast IPv6 introduced to the kernel recently.

When more than one socket is bound to different multicast group 
addresses on the same interface and port, only the last bound socket 
will receive packets sent to it.

I have bisected the kernel and identified that commit efe4208f47f907  - 
https://github.com/torvalds/linux/commit/efe4208f47f907
was the one that introduced this behaviour. Prior commits behave as 
expected.

Attached are two demonstrations of the behaviour.

C:
Run "mcreceive6 ff15::1 14678 0"
Run "mcreceive6 ff15::2 14678 0"
Run "mcsend6 ff15::1 14678"
Run "mcsend6 ff15::2 14678"

Expected: all messages typed into both mcsend6 instances will be echoed 
to corresponding mcreceive6 instances.
Actual: only messages sent to ff15::2 are echoed. Messages sent to 
ff15::1 are not echoed.
Killing mcreceive6 on ff15::2 will mean messages on ff15::1 are received 
again.

Python:
Run "test_multicast.py"
Test involving subscription to multiple groups fails.

James

-- 
James Ward
Australian Centre for Field Robotics
The Rose Street Building J04
The University of Sydney, NSW 2006, Australia


--------------080306020307060701040407
Content-Type: text/x-csrc;
 name="mcreceive6.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mcreceive6.c"

#include <sys/types.h>  /* for type definitions */
#include <sys/socket.h> /* for socket API calls */
#include <netinet/in.h> /* for address structs */
#include <arpa/inet.h>  /* for sockaddr_in */
#include <net/if.h>
#include <stdio.h>      /* for printf() and fprintf() */
#include <stdlib.h>     /* for atoi() */
#include <string.h>     /* for strlen() */
#include <unistd.h>     /* for close() */

#define MAX_LEN  1024   /* maximum receive string size */
#define MIN_PORT 1024   /* minimum port allowed */
#define MAX_PORT 65535  /* maximum port allowed */

int main(int argc, char *argv[]) {

  int sock;                     /* socket descriptor */
  int flag_on = 1;              /* socket option flag */
  struct sockaddr_in6 mc_addr;   /* socket address structure */
  char recv_str[MAX_LEN+1];     /* buffer to receive string */
  int recv_len;                 /* length of string received */
  struct ipv6_mreq mc_req;        /* multicast request structure */
  char* mc_addr_str;            /* multicast IP address */
  unsigned short mc_port;       /* multicast port */
  struct sockaddr_in6 from_addr; /* packet source */
  unsigned int from_len;        /* source addr length */
  char *if_name;

  /* validate number of arguments */
  if (argc != 4) {
    fprintf(stderr, 
            "Usage: %s <Multicast IP> <Multicast Port> <Interface Name>\n", 
            argv[0]);
    exit(1);
  }

  mc_addr_str = argv[1];      /* arg 1: multicast ip address */
  mc_port = atoi(argv[2]);    /* arg 2: multicast port number */
  if_name = argv[3];          /* arg 3: interface name */

  /* validate the port range */
  if ((mc_port < MIN_PORT) || (mc_port > MAX_PORT)) {
    fprintf(stderr, "Invalid port number argument %d.\n",
            mc_port);
    fprintf(stderr, "Valid range is between %d and %d.\n",
            MIN_PORT, MAX_PORT);
    exit(1);
  }

  /* create socket to join multicast group on */
  if ((sock = socket(PF_INET6, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
    perror("socket() failed");
    exit(1);
  }
  
  /* set reuse port to on to allow multiple binds per host */
  if ((setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &flag_on,
       sizeof(flag_on))) < 0) {
    perror("setsockopt() 1 failed");
    exit(1);
  }

  /* construct a multicast address structure */
  memset(&mc_addr, 0, sizeof(mc_addr));
  mc_addr.sin6_family      = AF_INET6;
  inet_pton(AF_INET6, mc_addr_str, mc_addr.sin6_addr.s6_addr);
  mc_addr.sin6_port        = htons(mc_port);

  /* bind to multicast address to socket */
  if ((bind(sock, (struct sockaddr *) &mc_addr, 
       sizeof(mc_addr))) < 0) {
    perror("bind() failed");
    exit(1);
  }

  /* construct an IGMP join request structure */
  inet_pton(AF_INET6, mc_addr_str, mc_req.ipv6mr_multiaddr.s6_addr);
  mc_req.ipv6mr_interface = if_nametoindex(if_name);

  /* send an ADD MEMBERSHIP message via setsockopt */
  if ((setsockopt(sock, IPPROTO_IPV6, IPV6_ADD_MEMBERSHIP, 
       (void*) &mc_req, sizeof(mc_req))) < 0) {
    perror("setsockopt() 2 failed");
    exit(1);
  }

  for (;;) {          /* loop forever */
    char buffer[64];

    /* clear the receive buffers & structs */
    memset(recv_str, 0, sizeof(recv_str));
    from_len = sizeof(from_addr);
    memset(&from_addr, 0, from_len);

    /* block waiting to receive a packet */
    if ((recv_len = recvfrom(sock, recv_str, MAX_LEN, 0, 
         (struct sockaddr*)&from_addr, &from_len)) < 0) {
      perror("recvfrom() failed");
      exit(1);
    }

    /* output received string */
    printf("Received %d bytes from %s: ", recv_len, 
           inet_ntop(AF_INET6, &from_addr.sin6_addr, buffer, 64));
    printf("%s", recv_str);
  }

  /* send a DROP MEMBERSHIP message via setsockopt */
  if ((setsockopt(sock, IPPROTO_IPV6, IPV6_DROP_MEMBERSHIP, 
       (void*) &mc_req, sizeof(mc_req))) < 0) {
    perror("setsockopt() 3 failed");
    exit(1);
  }

  close(sock);  
}

--------------080306020307060701040407
Content-Type: text/x-csrc;
 name="mcsend6.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mcsend6.c"

#include <sys/types.h>   /* for type definitions */
#include <sys/socket.h>  /* for socket API function calls */
#include <netinet/in.h>  /* for address structs */
#include <arpa/inet.h>   /* for sockaddr_in */
#include <stdio.h>       /* for printf() */
#include <stdlib.h>      /* for atoi() */
#include <string.h>      /* for strlen() */
#include <unistd.h>      /* for close() */

#define MAX_LEN  1024    /* maximum string size to send */
#define MIN_PORT 1024    /* minimum port allowed */
#define MAX_PORT 65535   /* maximum port allowed */

static void show_socket_settings(int sock)
{
  int loop, ttl;
  size_t size;

  size = sizeof(loop);
  getsockopt(sock, IPPROTO_IPV6, IPV6_MULTICAST_LOOP, &loop, &size);
  printf("IPV6_MULTICAST_LOOP(%d) = %d\n", size, loop);

  size = sizeof(ttl);
  getsockopt(sock, IPPROTO_IPV6, IPV6_MULTICAST_HOPS, &ttl, &size);
  printf("IPV6_MULTICAST_HOPS(%d) = %d\n", size, ttl);
}

int main(int argc, char *argv[]) {

  int sock;                   /* socket descriptor */
  char send_str[MAX_LEN];     /* string to send */
  struct sockaddr_in6 mc_addr; /* socket address structure */
  unsigned int send_len;      /* length of string to send */
  char* mc_addr_str;          /* multicast IP address */
  unsigned short mc_port;     /* multicast port */
  int mc_ttl=1;     /* time to live (hop count) */

  /* validate number of arguments */
  if (argc != 3) {
    fprintf(stderr, 
            "Usage: %s <Multicast IP> <Multicast Port>\n", 
            argv[0]);
    exit(1);
  }

  mc_addr_str = argv[1];       /* arg 1: multicast IP address */
  mc_port     = atoi(argv[2]); /* arg 2: multicast port number */

  /* validate the port range */
  if ((mc_port < MIN_PORT) || (mc_port > MAX_PORT)) {
    fprintf(stderr, "Invalid port number argument %d.\n",
            mc_port);
    fprintf(stderr, "Valid range is between %d and %d.\n",
            MIN_PORT, MAX_PORT);
    exit(1);
  }

  /* create a socket for sending to the multicast address */
  if ((sock = socket(PF_INET6, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
    perror("socket() failed");
    exit(1);
  }

  show_socket_settings(sock);
  
  /* set the TTL (time to live/hop count) for the send */
  if ((setsockopt(sock, IPPROTO_IPV6, IPV6_MULTICAST_HOPS, 
       (void*) &mc_ttl, sizeof(mc_ttl))) < 0) {
    perror("setsockopt() failed");
    exit(1);
  } 
  
  /* construct a multicast address structure */
  memset(&mc_addr, 0, sizeof(mc_addr));
  mc_addr.sin6_family      = AF_INET6;
  inet_pton(AF_INET6, mc_addr_str, &mc_addr.sin6_addr.s6_addr);
  mc_addr.sin6_port        = htons(mc_port);

  printf("Begin typing (return to send, ctrl-C to quit):\n");

  /* clear send buffer */
  memset(send_str, 0, sizeof(send_str));

  while (fgets(send_str, MAX_LEN, stdin)) {
    send_len = strlen(send_str);

    /* send string to multicast address */
    if ((sendto(sock, send_str, send_len, 0, 
         (struct sockaddr *) &mc_addr, 
         sizeof(mc_addr))) != send_len) {
      perror("sendto() sent incorrect number of bytes");
      exit(1);
    }

    /* clear send buffer */
    memset(send_str, 0, sizeof(send_str));
  }

  show_socket_settings(sock);

  close(sock);  

  exit(0);
}


--------------080306020307060701040407
Content-Type: text/x-python;
 name="test_multicast.py"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="test_multicast.py"

#!/usr/bin/python

import unittest
import socket
import threading
import struct

class Sender(object):
    def __init__(self, group, port=43214):
        self.addr = group
        self.port = port

        self.sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
        
    def send(self, msg):
        self.sock.sendto(msg, (self.addr, self.port))

class Receiver(object):
    def __init__(self, group, port=43214):
        addr = socket.inet_pton(socket.AF_INET6, group)

        self.sock = socket.socket(socket.AF_INET6, socket.SOCK_DGRAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
        self.sock.bind((group, port))

        group_addr = addr + struct.pack('@I', 0)
        self.sock.setsockopt(socket.IPPROTO_IPV6, socket.IPV6_JOIN_GROUP, group_addr)

        self.data = None
        
    def recv(self):
        self.data = self.sock.recv(1024)

class TestMulticast(unittest.TestCase):
    def test_same_groups(self):
        msg = "foo"
        senders = [Sender("ff15::1")]
        receivers = [Receiver("ff15::1"), Receiver("ff15::1")]
        
        threads = [threading.Thread(target=r.recv) for r in receivers]
        for t in threads:
            t.daemon = True
            t.start()
        for s in senders:
            s.send(msg)
            
        for t in threads:
            t.join(1)
            
        for r in receivers:
            self.assertEqual(r.data, msg)
    
    def test_different_groups(self):
        msg = "foo"
        senders = [Sender("ff15::1"), Sender("ff15::2")]
        receivers = [Receiver("ff15::1"), Receiver("ff15::2")]
        
        threads = [threading.Thread(target=r.recv) for r in receivers]
        for t in threads:
            t.daemon = True
            t.start()
        for s in senders:
            s.send(msg)
            
        for t in threads:
            t.join(1)
        
        for r in receivers:
            self.assertEqual(r.data, msg)

if __name__ == "__main__":
    unittest.main()

--------------080306020307060701040407--
