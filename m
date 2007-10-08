From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: raw PF_PACKET protocol selection
Date: Mon, 08 Oct 2007 20:36:09 +0200
Message-ID: <1191868569.6682.67.camel@gentoo-jocke.transmode.se>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:28964 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754011AbXJHSgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 14:36:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi List

I trying to open my own raw PF_PACKET socket to receive 
pkgs sent to this socket. I can only make ETH_P_ALL protocol
work, but then I receive all pkgs and I want pkgs with a specific
protocol type. I have tried lots of ETH_P types and none of them work.
Naturally I make sure the sender is using the same protocol as my test
program below. I guess I must be doing something wrong???


Here is the test program:

#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <linux/in.h>
#include <linux/if_ether.h>

int main(int argc, char **argv) {
  int sock, n;
  char buffer[2048];
  unsigned char *iphead, *ethhead;

  if ( (sock=socket(PF_PACKET, SOCK_RAW,
                    htons(ETH_P_IP)))<0) { // ETH_P_IP is just an example
    perror("socket");
    exit(1);
  }

  while (1) {
    printf("----------\n");
    n = recvfrom(sock,buffer,2048,0,NULL,NULL);
    printf("%d bytes read\n",n);

    /* Check to see if the packet contains at least
     * complete Ethernet (14), IP (20) and TCP/UDP
     * (8) headers.
     */
    if (n<42) {
      perror("recvfrom():");
      printf("Incomplete packet (errno is %d)\n",
             errno);
      close(sock);
      exit(0);
    }

    ethhead = buffer;
    printf("Source MAC address: "
           "%02x:%02x:%02x:%02x:%02x:%02x\n",
           ethhead[0],ethhead[1],ethhead[2],
           ethhead[3],ethhead[4],ethhead[5]);
    printf("Destination MAC address: "
           "%02x:%02x:%02x:%02x:%02x:%02x\n",
           ethhead[6],ethhead[7],ethhead[8],
           ethhead[9],ethhead[10],ethhead[11]);

    iphead = buffer+14; /* Skip Ethernet header */
    if (*iphead==0x45) { /* Double check for IPv4
                          * and no options present */
      printf("Source host %d.%d.%d.%d\n",
             iphead[12],iphead[13],
             iphead[14],iphead[15]);
      printf("Dest host %d.%d.%d.%d\n",
             iphead[16],iphead[17],
             iphead[18],iphead[19]);
      printf("Source,Dest ports %d,%d\n",
             (iphead[20]<<8)+iphead[21],
             (iphead[22]<<8)+iphead[23]);
      printf("Layer-4 protocol %d\n",iphead[9]);
    } else {
       int i;
       iphead = buffer+12;
       for(i=0; i<n-12; i++)
	  printf(" pkt:%x, %c\n",
	      iphead[i],iphead[i]);
    }
  }

}


