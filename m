From: "matteo.fortini@sadel.it" <matteo.fortini@sadel.it>
Subject: [RFC PATCH] Bug on AT91 macb driver rx with high network traffic
Date: Wed, 05 Dec 2012 16:48:44 +0100
Message-ID: <assp.0686b43733.50BF6CDC.6060609@sadel.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcapone.vm.bytemark.co.uk ([89.16.173.107]:48000 "EHLO
	alcapone.vm.bytemark.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751676Ab2LEPsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 10:48:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are testing the robustness of the driver with UDP packets of 
increasing length, up to the maximum allowed.

We have an UDP echo server listening on an port on the AT91 board, and 
we send to it increasing length UDP packets, waiting for the echo reply 
before sending the next one.
When packets get larghish, in the >40000 bytes range, we see that the 
server is not receiving packets anymore, so the client does not receive 
the reply and the test stops. Pinging the interface once resumes the 
test, meaning that the packet has been actually received, but the driver 
is waiting for an interrupt that is not coming.

We traced this down to slow/missing IRQ response, and we fixed it as in 
the following patch, which calls napi_reschedule() before leaving the 
polling loop if the loop condition is still valid at the end of the 
polling loop, as other net drivers appear to do.

We don't know if this is the perfectly right way to do it, and we'd like 
your opinion on this before submitting a proper patch.

I added the udp_server.c and udp_client.c softwares which may be useful.

Thank you in advance,
Matteo Fortini

===================================================================

 From 2d8895022a0668f6a3c1112f15ebe471db1a471e Mon Sep 17 00:00:00 2001
From: Matteo Fortini <matteo.fortini@sadel.it>
Date: Thu, 8 Nov 2012 16:12:10 +0100
Subject: [PATCH] AT91 macb: Fix lost rx packets on high rx traffic

---
  drivers/net/ethernet/cadence/macb.c |    8 ++++++++
  1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.c 
b/drivers/net/ethernet/cadence/macb.c
index 033064b..348a20f 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -522,8 +522,16 @@ static int macb_poll(struct napi_struct *napi, int 
budget)

         work_done = macb_rx(bp, budget);
         if (work_done < budget) {
+               u32 addr;
+
                 napi_complete(napi);

+               addr = bp->rx_ring[bp->rx_tail].addr;
+
+               if ((addr & MACB_BIT(RX_USED))) {
+                       netdev_warn(bp->dev, "poll: reschedule");
+                       napi_reschedule(napi);
+               }
                 /*
                  * We've done what we can to clean the buffers. Make 
sure we
                  * get notified when new packets arrive.
-- 
1.7.10.4

====================================================

TEST PROGRAMS:

/*
  * UDP client
  * Copyright 2012 SADEL SpA
  * Castel Maggiore
  * Bologna
  * Italy
  */

#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define BUFFER_LEN      70000   ///< Lenght of buffer
#define LISTEN_PORT     32000   ///< Listen port
#define MIN_PACKET_LEN      8   ///< Min lenght of a packet
#define MAX_PACKET_LEN  65499   ///< Min lenght of a packet
#define TIMEOUT             0   ///< Default wait_time between each 
packet send

static int port         = LISTEN_PORT;
static int minPacketLen = MIN_PACKET_LEN;
static int maxPacketLen = MAX_PACKET_LEN;
static int packetLen    = 0;
static int wait_time    = TIMEOUT;
static char *server     = NULL;

static void usage(const char *program)
{
     fprintf(stderr,"usage: %s [options]\n",program);
     fprintf(stderr,"          -c <ipaddr>   Server IP address\n");
     fprintf(stderr,"          -p <port>     Specify port number 
(default: %d)\n", LISTEN_PORT);
     fprintf(stderr,"          -t <waittime> wait time between each send 
actions in usec\n");
     fprintf(stderr,"          -m <min_len>  Min packet length (default: 
%d)\n",MIN_PACKET_LEN);
     fprintf(stderr,"          -M <max_len>  Mam packet length (default: 
%d)\n",MAX_PACKET_LEN);
     fprintf(stderr,"          -l <lenght>   Lengh of packet [%d < 
<length> < %d). If no specified, variable packet is sent\n");
     fprintf(stderr,"          -h            Show this help and exit\n");
}

static void check_parameter(int argc, char **argv)
{
     int opt;
     while ((opt = getopt(argc, argv, "c:l:t:p:m:M:h")) != -1) {
         switch (opt) {
             case 'c':
                 server = optarg;
                 break;
             case 'p':
                 port = atoi(optarg);
                 if( port <= 0 ) {
                     fprintf(stderr, "Wrong parameter -p");
                     usage(argv[0]);
                     exit(EXIT_FAILURE);
                 }
                 break;
             case 't':
                 wait_time = atoi(optarg);
                 break;
             case 'm':
                 minPacketLen = atoi(optarg);
                 if( minPacketLen < MIN_PACKET_LEN ) {
                     fprintf(stderr, "Min packet length too low. Set to: 
%d\n", MIN_PACKET_LEN);
                     minPacketLen = MIN_PACKET_LEN;
                 }
                 break;
             case 'M':
                 maxPacketLen = atoi(optarg);
                 if( maxPacketLen > MAX_PACKET_LEN ) {
                     fprintf(stderr, "Max packet length too high. Set 
to: %d\n", MAX_PACKET_LEN);
                     maxPacketLen = MAX_PACKET_LEN;
                 }
                 break;
             case 'l':
                 packetLen = atoi(optarg);
                 break;
             case 'h':
                 usage(argv[0]);
                 exit(0);
             default: /* '?' */
                 fprintf(stderr, "Unrecognized parameter '%c'\n", opt);
                 usage(argv[0]);
                 exit(EXIT_FAILURE);
         }
     }

     if( server == NULL ) {
         fprintf(stderr, "Wrong or missing -c parameter\n");
         usage(argv[0]);
         exit(EXIT_FAILURE);
     }
     if( minPacketLen > maxPacketLen ) {
         fprintf(stderr, "minPacketLen could not be greather than 
maxPacketLen: %d, %d\n", minPacketLen, maxPacketLen);
         usage(argv[0]);
         exit(EXIT_FAILURE);
     }

     fprintf(stderr, "UDP Client - server: %s, port: %d, wait_time: %d", 
server, port, wait_time);
     if( packetLen > 0 ) {
         fprintf(stderr, " - fixed packet len: %d bytes\n", packetLen);
     } else {
         fprintf(stderr, " - variable packet len from %d to %d bytes\n", 
minPacketLen, maxPacketLen);
     }
}

static int sendAndCheck(int sockfd, struct sockaddr_in *servaddr, const 
char *msg_tx, size_t msg_len) {
     int t, n, iRetVal = 0;
     char msg_rx[BUFFER_LEN];
     socklen_t len = sizeof(*servaddr);

     t = sendto(sockfd, msg_tx, msg_len, 0, (struct sockaddr *)servaddr, 
len);
     fprintf(stderr, "TX [%d] bytes, ", msg_len, t);

     n = recvfrom(sockfd,msg_rx,BUFFER_LEN,0,(struct sockaddr 
*)servaddr,&len);
     fprintf(stderr, "RX [%d] bytes - ",n);

     if( t != n ) {
         fprintf(stderr, "size differs!!!\n");
         iRetVal = 0;
     }

     if( memcmp(msg_tx, msg_rx, msg_len) != 0 ) {
         fprintf(stderr, "data = ko\n");
         iRetVal = -1;
     } else {
         fprintf(stderr, "data = ok\n");
     }


     return iRetVal;
}

static int fixed_send(int sockfd, struct sockaddr_in *servaddr)
{
     int i = 0, iRetVal = 0;
     char msg_tx[BUFFER_LEN];

     memset(msg_tx,sizeof(msg_tx),'a');

     while(1) {
         fprintf(stderr, "[%d] - ",i);
         if( sendAndCheck(sockfd, servaddr, msg_tx, packetLen) != 0 ) {
             break;
         }

         usleep(wait_time);
         i++;
     }
     return iRetVal;
}

static int variable_send(int sockfd, struct sockaddr_in *servaddr)
{
     int i, iRetVal = 0;
     char msg_tx[BUFFER_LEN];

     memset(msg_tx,sizeof(msg_tx),'a');

     for ( i = 0; i <= maxPacketLen - minPacketLen; i++) {
         fprintf(stderr, "[%d] - ",i);
         if( sendAndCheck(sockfd, servaddr, msg_tx, minPacketLen+i) != 0 ) {
             break;
         }

         usleep(wait_time);
     }
     return iRetVal;
}

int main(int argc, char**argv)
{
     int sockfd;
     struct sockaddr_in servaddr;

     check_parameter(argc,argv);

     bzero(&servaddr,sizeof(servaddr));
     servaddr.sin_family = AF_INET;
     servaddr.sin_addr.s_addr=inet_addr(server);
     servaddr.sin_port=htons(port);

     sockfd = socket(AF_INET,SOCK_DGRAM,0);

     //Opzionale
     if( connect(sockfd,(struct sockaddr *)&servaddr,sizeof(servaddr)) 
!= 0 ) {
         fprintf(stderr, "Failed to connect\n");
         exit(1);
     }

     if ( packetLen > 0 ) {
         fixed_send(sockfd,&servaddr);
     } else {
         variable_send(sockfd,&servaddr);
     }


     return 0;
}

=================================================================
/*
  * UDP server
  * Copyright 2012 SADEL SpA
  * Castel Maggiore
  * Bologna
  * Italy
  */

#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define BUFFER_LEN      70000   ///< Lenght of buffer
#define LISTEN_PORT     32000   ///< Listen port
#define TIMEOUT             0   ///< Default wait_time between each 
packet send

static int port         = LISTEN_PORT;
static int wait_time    = TIMEOUT;

static void usage(const char *program)
{
     fprintf(stderr,"usage: %s [options]\n",program);
     fprintf(stderr,"          -p <port>     Specify port number 
(default: %d)\n", LISTEN_PORT);
     fprintf(stderr,"          -t <waittime> wait time between each send 
actions in usec\n");
     fprintf(stderr,"          -h            Show this help and exit\n");
}

static void check_parameter(int argc, char **argv)
{
     int opt;
     while ((opt = getopt(argc, argv, "t:p:h")) != -1) {
         switch (opt) {
             case 'p':
                 port = atoi(optarg);
                 if( port <= 0 ) {
                     fprintf(stderr, "Wrong parameter -p");
                     usage(argv[0]);
                     exit(EXIT_FAILURE);
                 }
                 break;
             case 't':
                 wait_time = atoi(optarg);
                 break;
             case 'h':
                 usage(argv[0]);
                 exit(0);
             default: /* '?' */
                 fprintf(stderr, "Unrecognized parameter '%c'\n", opt);
                 usage(argv[0]);
                 exit(EXIT_FAILURE);
         }
     }

     fprintf(stderr, "UDP Server - port: %d, wait_time: %d\n", port, 
wait_time);
}

int main(int argc, char**argv)
{
     int sockfd,n;
     struct sockaddr_in servaddr,cliaddr;
     socklen_t len;
     char mesg[BUFFER_LEN];
     int i = 1;
     int t;

     check_parameter(argc, argv);

     sockfd=socket(AF_INET,SOCK_DGRAM,0);

     bzero(&servaddr,sizeof(servaddr));
     servaddr.sin_family = AF_INET;
     servaddr.sin_addr.s_addr=htonl(INADDR_ANY);
     servaddr.sin_port=htons(port);
     bind(sockfd,(struct sockaddr *)&servaddr,sizeof(servaddr));

     for (;;)
     {
         len = sizeof(cliaddr);
         n = recvfrom(sockfd,mesg,BUFFER_LEN,0,(struct sockaddr 
*)&cliaddr,&len);
         fprintf(stderr, "[%d] - RX [%d] bytes ",i, n);
         usleep(wait_time);
         t = sendto(sockfd,mesg,n,0,(struct sockaddr 
*)&cliaddr,sizeof(cliaddr));
         fprintf(stderr, "- TX [%d] bytes\n",t);
         mesg[n] = 0;
         i++;
     }
}


