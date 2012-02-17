From: Ben Greear <greearb@candelatech.com>
Subject: Program to test/use the 'low level Ethernet debugging features'
Date: Fri, 17 Feb 2012 10:12:10 -0800
Message-ID: <4F3E987A.8000906@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080103020507050000090707"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52962 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab2BQSMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 13:12:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080103020507050000090707
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I'm attaching a small program I wrote to test the 'send custom fcs'
patches.  You can also test the rx-fcs and rx-all logic by making
sure that the NIC properly handles the packets with bad FCS.

For those that might have seen a previous version of this, I added
the ability to specify the dest mac address which means you don't
have to put the receiving NIC into PROMISC mode now.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------080103020507050000090707
Content-Type: text/plain;
 name="nofcs.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nofcs.c"

/**  This tool can be used to send packets with custom (ie, bad) Ethernet
 * Frame Checksum.
 *
 * This requires the 'Low-level Ethernet debugging features.' patch series,
 * which supports e100, e1000, and e1000e drivers.  Support for igb and
 * hopefully ixgbe will be added soon.
 *
 * To compile:  gcc -Wall nofcs.c -o nofcs
 *
 * Usage:
 *  Send 10 packets out eth0 with bad FCS:
 *    ./nofcs -i eth0 -dm 00:11:22:33:44:55
 *
 * To receive the packets, you could use a version of ethtool that supports
 * the feature strings logic posted by Michal Miroslaw and enable 'rx-all'
 * and optionally: 'rx-fcs'.
 *
 * The patch for ethtool is posted here:
 *    http://patchwork.ozlabs.org/patch/96374/
 *
 * This code was written by Ben Greear <greearb@candelatech.com>
 * and is hereby released into the public domain with no restrictions.
 * February 17, 2012.
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <linux/if_packet.h>
#include <ctype.h>
#include <arpa/inet.h>
#include <net/if.h>


static char* dev = NULL;
static int count = 10;
static int bytes = 128; // not counting fcs
static unsigned int fcs = 0xdeadbeef;
static char* dst_mac = NULL;

static void print_usage() {
   printf("usage: -i [dev-name] -b [byte-count] -c [packet-count] -f [fcs] -dm [dest-mac]\n"
          "Example: nofcs -i eth0 -b 128 -c 10 -dm 00:11:22:33:44:55 -f 0xdeadbeef\n\n");
}


int createPacketSocket(const char* dev_name, int ether_type) {
   int s = socket(PF_PACKET, SOCK_RAW, htons(ether_type));
   int r; //retval
   struct sockaddr_ll myaddr;

   if (s < 0) {
      perror("socket(PF_PACKET)");
      exit(1);
   }

   memset(&myaddr, '\0', sizeof(myaddr));
   myaddr.sll_family = AF_PACKET;
   myaddr.sll_protocol = htons(ether_type);
   myaddr.sll_ifindex = if_nametoindex(dev_name);
   if (myaddr.sll_ifindex == 0) {
      perror("if_nametoindex");
      exit(1);
   }
      
   r = bind(s, (struct sockaddr*)(&myaddr), sizeof(myaddr));
   if (r < 0) {
      perror("bind");
      exit(1);
   }
   return s;
}

static int toMacString(unsigned char* rslt_mac, const char* raw_mac) {
   /* Turn HEX into bytes.  First, gather all the useful HEX */
   char tmp[12]; /* More than 12 is useless, at least right now */
   char c;
   int j = 0; /* tmp's index. */
   int i;
   char tmp_bt[3];

   for (i = 0; i<strlen(raw_mac); i++) {
      c = toupper(raw_mac[i]);
      if (((c >= '0') && (c <= '9')) || ((c >= 'A') && (c <= 'F'))) {
         tmp[j] = c;
         if (j == 11) {
            break; /* done */
         }
         j++;
      }
      else {
         if ((c == ':') || (c == ' ') || (c == '.')) {
            /* Ok, valid divider */
         }
         else {
            printf("ERROR:  Invalid characters found in the MAC input string: %s index: %i  character: %c\n",
                   raw_mac, i, c);
            exit(1);
         }
      }
   }

   if (j != 11) {
      printf("ERROR:  Not enough HEX values in the input string.\n");
      exit(1);
   }

   for (i = 0; i<6; i++) {
      tmp_bt[0] = tmp[i*2];
      tmp_bt[1] = tmp[i*2 +1];
      tmp_bt[2] = 0;
      rslt_mac[i] = (char)(strtol(tmp_bt, NULL, 16) & 0xFF); /* base 16 (HEX) */
   }
   return 0;
}//toMacString

int main(int argc, char **argv) {
   int i;
   int s;
   unsigned char* buf;
   unsigned int opt = 1;

   dev = strdup("eth0");
   dst_mac = strdup("00:11:22:33:44:55");

   for (i = 1; i<argc; i++) {

      /* Each argument requires a value */
      if (argc < i+1) {
         printf("ERROR:  Not enough arguments, argc: %i  i: %i\n",
                argc, i);
         print_usage();
         exit(1);
      }
      
      if (strcasecmp(argv[i], "-i") == 0) {
         free(dev);
         dev = strdup(argv[i + 1]);
      }
      else if (strcasecmp(argv[i], "-c") == 0) {
         count = strtoll(argv[i + 1], NULL, 0);
      }
      else if (strcasecmp(argv[i], "-b") == 0) {
         bytes = strtoll(argv[i + 1], NULL, 0);
      }
      else if (strcasecmp(argv[i], "-f") == 0) {
         fcs = strtoll(argv[i + 1], NULL, 0);
      }
      else if (strcasecmp(argv[i], "-dm") == 0) {
         free(dst_mac);
         dst_mac = strdup(argv[i + 1]);
      }
      else {
         printf("Unknown argument: %s\n", argv[i]);
         print_usage();
         exit(1);
      }
      i++;
   }

   if (bytes < 14) {
      printf("ERROR: Need at least 14 bytes of payload for ether header.\n");
      exit(1);
   }

   if (bytes < 60) {
      printf("WARNING: Most drivers require Ethernet frame of at least 60 bytes.\n");
   }

   /* Just use some made-up eth type */
   s = createPacketSocket(dev, 0x1111);

   if (setsockopt(s, SOL_SOCKET, 42 /* SO_NOFCS, see asm-x86/socket.h in linux kernel*/,
                  (char*)&opt, sizeof(opt)) < 0) {
      perror("setsockopt SO_NOFCS");
      printf("Kernel doesn't support the NO_FCS feature it seems.\n");
      exit(2);
   }

   buf = malloc(bytes + 4);

   /* mostly hard-code an ether header */
   toMacString(buf, dst_mac);

   /* src 00:22:22:22:22:22 */
   buf[6] = 0;
   for (i = 7; i<11; i++)
      buf[i] = 0x22;

   /* ether type */
   buf[12] = 0x11;
   buf[13] = 0x11;

   for (i = 14; i<bytes; i++) {
      buf[i] = i;
   }

   /* append our FCS */
   buf[bytes] = (fcs >> 24) & 0xff;
   buf[bytes + 1] = (fcs >> 16) & 0xff;
   buf[bytes + 2] = (fcs >> 8) & 0xff;
   buf[bytes + 3] = fcs & 0xff;

   for (i = 0; i<count; i++) {
      if (sendto(s, buf, bytes + 4, 0, NULL, 0) < 0) {
         perror("sendto");
         exit(1);
      }
   }
   
   printf("Sent %i packets.\n", count);

   /* Clean up, just to be nice */
   free(dst_mac);
   free(dev);
   free(buf);
   close(s);
   
   exit(0);
}

--------------080103020507050000090707--
