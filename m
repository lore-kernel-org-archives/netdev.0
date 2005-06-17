From: =?ISO-8859-2?Q?Tom=E1=B9_Macek?= <maca02@atlas.cz>
Subject: receive only one record from the routing table
Date: Fri, 17 Jun 2005 14:51:28 +0100 (BST)
Message-ID: <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, I have this program (see below), and I want him to find a certain route record in the kernel routing table. I copied this somewhere from the internet and add the NetlinkAddAttr() function, that should add an request on the destination address. But the program prints always the WHOLE routing table.

But I would like to have a program, that would RECEIVE only one route from the kernel routing table for certain destination address only. Is it possible to do in rtnetlink?
I wasn't able to find the answer on google and my tries all failed.

Any help will be very appreciated!

Tomas


==================================================================================

#include <asm/types.h>
#include <netinet/ether.h>
#include <netinet/in.h>
#include <net/if.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <linux/netlink.h>
#include <linux/rtnetlink.h>
#include <sys/types.h>

#define BUFSIZE 8192

struct route_info {
     u_int dstAddr;
     u_int dstMask;
     u_int srcAddr;
     u_int gateWay;
     char ifName[IF_NAMESIZE];
};

int NetlinkAddAttr(struct nlmsghdr *n, int maxlen, int type, void *data, int alen) {
         int len = RTA_LENGTH(alen);
         struct rtattr *rta;

         if (NLMSG_ALIGN(n->nlmsg_len) + len > maxlen)
                 return -1;
         rta = (struct rtattr *)(((char *)n) + NLMSG_ALIGN(n->nlmsg_len));
         rta->rta_type = type;
         rta->rta_len = len;
         memcpy(RTA_DATA(rta), data, alen);
         n->nlmsg_len = NLMSG_ALIGN(n->nlmsg_len) + len;
         return 0;
}

int readNlSock(int sockFd, char *bufPtr, int seqNum, int pId) {
     struct nlmsghdr *nlHdr;
     int readLen = 0, msgLen = 0;

     do {
         /* Recieve response from the kernel */
         if((readLen = recv(sockFd, bufPtr, BUFSIZE - msgLen, 0)) < 0){
             perror("SOCK READ: ");
             return -1;
         }
         nlHdr = (struct nlmsghdr *)bufPtr;

         /* Check if the header is valid */
         if((NLMSG_OK(nlHdr, readLen) == 0) || (nlHdr->nlmsg_type == NLMSG_ERROR)) {
             perror("Error in recieved packet");
             return -1;
         }

         /* Check if the its the last message */
         if(nlHdr->nlmsg_type == NLMSG_DONE){
             break;
         } else{
             /* Else move the pointer to buffer appropriately */
             bufPtr += readLen;
             msgLen += readLen;
         }

         /* Check if its a multi part message */
         if((nlHdr->nlmsg_flags & NLM_F_MULTI) == 0){
             /* return if its not */
             break;
         }
     } while((nlHdr->nlmsg_seq != seqNum) || (nlHdr->nlmsg_pid != pId));

     return msgLen;
}

unsigned long netmask_from_bitcount(unsigned int bits) {
     return 0xffffffff << (32 - bits);
}

/* For printing the routes. */
void printRoute(struct route_info *rtInfo) {
     char tempBuf[512];

     /* Print Destination address */
     if(rtInfo->dstAddr != 0)
         strcpy(tempBuf, (char *)inet_ntoa(rtInfo->dstAddr));
     else
         sprintf(tempBuf,"*.*.*.*\t\t");
     fprintf(stdout,"%s\t\t", tempBuf);

     /* Print Gateway address */
     if(rtInfo->gateWay != 0)
         strcpy(tempBuf, (char *)inet_ntoa(rtInfo->gateWay));
     else
         sprintf(tempBuf,"*.*.*.*\t\t");
     fprintf(stdout,"%s\t\t", tempBuf);

     /* Print Interface Name*/
     fprintf(stdout,"%s\t\t", rtInfo->ifName);

     /* Print Source address */
     if (rtInfo->srcAddr != 0)
         strcpy(tempBuf, (char *)inet_ntoa(rtInfo->srcAddr));
     else
         sprintf(tempBuf,"*.*.*.*\t\t");

     if (rtInfo->dstMask != 0) {
         struct in_addr ia;
         ia.s_addr = htonl(netmask_from_bitcount(rtInfo->dstMask));
         sprintf(tempBuf, "%s\t", inet_ntoa(ia));
     } else {
         sprintf(tempBuf, "0.0.0.0\t");
     }

     fprintf(stdout,"%s\n", tempBuf);
}

void parseRoutes(struct nlmsghdr *nlHdr, struct route_info *rtInfo, char *find) {
     struct rtmsg *rtMsg;
     struct rtattr *rtAttr;
     int rtLen;
     char *tempBuf = NULL;
     struct in_addr ai;

     if (!inet_aton(find, &ai)) {
         return;
     }

     tempBuf = (char *)malloc(100);
     rtMsg = (struct rtmsg *)NLMSG_DATA(nlHdr);

     /* If the route is not for AF_INET or does not belong to main routing table
     then return. */
     if((rtMsg->rtm_family != AF_INET) || (rtMsg->rtm_table != RT_TABLE_MAIN))
         return;

     /* get the rtattr field */
     rtAttr = (struct rtattr *)RTM_RTA(rtMsg);
     rtLen = RTM_PAYLOAD(nlHdr);

     rtInfo->dstMask = rtMsg->rtm_dst_len; /* Netmask */

     for( ; RTA_OK(rtAttr,rtLen);rtAttr = RTA_NEXT(rtAttr,rtLen)) {
         switch(rtAttr->rta_type){
             case RTA_OIF:
                 if_indextoname(*(int *)RTA_DATA(rtAttr), rtInfo->ifName);
                 break;
             case RTA_GATEWAY:
                 rtInfo->gateWay = *(u_int *)RTA_DATA(rtAttr);
                 break;
             case RTA_PREFSRC:
                 rtInfo->srcAddr = *(u_int *)RTA_DATA(rtAttr);
                 break;
             case RTA_DST:
                 rtInfo->dstAddr = *(u_int *)RTA_DATA(rtAttr);
                 break;
         }
     }

/*
     if (rtInfo->dstAddr == ai.s_addr) {
         printf("match %s\n", inet_ntoa(rtInfo->dstAddr));
         return;
     }
*/
     printRoute(rtInfo);

     free(tempBuf);
     return;
}

int main(int argc, char *argv[]) {
     struct nlmsghdr *nlMsg;
     struct rtmsg *rtMsg;
     struct route_info *rtInfo;
     char msgBuf[BUFSIZE];

     int sock, len, msgSeq = 0;
     char buff[1024];

     /* Create Socket */
     if((sock = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_ROUTE)) < 0)
         perror("Socket Creation: ");

     /* Initialize the buffer */
     memset(msgBuf, 0, BUFSIZE);

     /* point the header and the msg structure pointers into the buffer */
     nlMsg = (struct nlmsghdr *)msgBuf;
     rtMsg = (struct rtmsg *)NLMSG_DATA(nlMsg);

     /* Fill in the nlmsg header*/
     nlMsg->nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg)); // Length of message.
     nlMsg->nlmsg_type = RTM_GETROUTE;   // Get the routes from kernel routing table .

     nlMsg->nlmsg_flags = NLM_F_REQUEST | NLM_F_DUMP;   // The message is a request for dump.
     nlMsg->nlmsg_seq = msgSeq++;   // Sequence of the message packet.
     nlMsg->nlmsg_pid = getpid();   // PID of process sending the request.

     char *cp;
     unsigned int xx[4]; int i = 0;
     unsigned char *ap = (unsigned char *)xx;
     for (cp = argv[1], i = 0; *cp; cp++) {
         if (*cp <= '9' && *cp >= '0') {
             ap[i] = 10*ap[i] + (*cp-'0');
             continue;
         }
         if (*cp == '.' && ++i <= 3)
             continue;
         return -1;
     }

     NetlinkAddAttr(nlMsg, sizeof(nlMsg), RTA_DST, &xx, 4);

     /* Send the request */
     if(send(sock, nlMsg, nlMsg->nlmsg_len, 0) < 0){
         printf("Write To Socket Failed...\n");
         return -1;
     }

     /* Read the response */
     if((len = readNlSock(sock, msgBuf, msgSeq, getpid())) < 0) {
         printf("Read From Socket Failed...\n");
         return -1;
     }

/* Parse and print the response */
     rtInfo = (struct route_info *)malloc(sizeof(struct route_info));
     fprintf(stdout, "Destination\t\tGateway\t\tInterface\t\tSource\t\tNetmask\n");

     for( ; NLMSG_OK(nlMsg,len); nlMsg = NLMSG_NEXT(nlMsg,len)) {
         memset(rtInfo, 0, sizeof(struct route_info));
         parseRoutes(nlMsg, rtInfo, argv[1]);
     }

     free(rtInfo);
     close(sock);
     return 0;
}
