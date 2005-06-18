From: =?ISO-8859-2?Q?Tom=E1=B9_Macek?= <maca02@atlas.cz>
Subject: Re: receive only one record from the routing table
Date: Sat, 18 Jun 2005 20:55:35 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0506182042540.29813@localhost.localdomain>
References: <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain>
 <20050617141527.GN22463@postel.suug.ch> <Pine.LNX.4.61.0506172057240.26739@localhost.localdomain>
 <20050617191340.GO22463@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050617191340.GO22463@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks for your answers.
I just tried to compile the libnl, but some errors occured, so I'm just continuing without it.
But I've looked at the html documentation and it seems to be very good.

I repaired the main() function by adding the

rtMsg->rtm_family = AF_INET;
rtMsg->rtm_dst_len = 16;

but every request on any dst address in the routing table gives me this output:
Destination             Gateway         Interface               Source          Netmask
127.0.0.1               *.*.*.*                         lo              255.255.255.255

The 'rtm_dst_len = 16' should mean the mask of the route I'm looking for, correct? The whole code before sending the packet is below:


     /* Create Socket */
     if((sock = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_ROUTE)) < 0)
         perror("Socket Creation: ");

     /* Initialize the buffer */
     memset(msgBuf, 0, BUFSIZE);

     /* point the header and the msg structure pointers into the buffer */
     nlMsg = (struct nlmsghdr *)msgBuf;
     rtMsg = (struct rtmsg *)NLMSG_DATA(nlMsg);
     rtMsg->rtm_family = AF_INET;
     rtMsg->rtm_dst_len = 16;

     /* Fill in the nlmsg header*/
     nlMsg->nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg)); // Length of message.
     nlMsg->nlmsg_type = RTM_GETROUTE;   // Get the routes from kernel routing table .
     nlMsg->nlmsg_flags = NLM_F_REQUEST;   // The message is a request for dump.
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




On Fri, 17 Jun 2005, Thomas Graf wrote:

> * Tom?? Macek <Pine.LNX.4.61.0506172057240.26739@localhost.localdomain> 2005-06-17 20:57
>> Part of my routing table is here:
>>
>> 3.3.0.0         *               255.255.0.0     U     0      0        0 eth1
>> default         meric           0.0.0.0         UG    0      0        0 eth0
>>
>> Ommiting NLM_F_DUMP and typing './a.out 3.3.0.0' gives
>>
>> Error in recieved packet: Success
>> Read From Socket Failed...
>
> Bcause you don't set rtm_dst_len to the prefix length or 32,
> and rtm_family (AF_INET). You could also use libnl, probably
> easier to use.
>
>
>
>
>
