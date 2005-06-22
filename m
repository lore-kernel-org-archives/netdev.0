From: =?ISO-8859-2?Q?Tom=E1=B9_Macek?= <maca02@atlas.cz>
Subject: Print one record only - addition
Date: Wed, 22 Jun 2005 15:53:54 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0506221531290.716@localhost.localdomain>
References: <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain>
 <20050617141527.GN22463@postel.suug.ch> <Pine.LNX.4.61.0506172057240.26739@localhost.localdomain>
 <20050617191340.GO22463@postel.suug.ch> <Pine.LNX.4.61.0506182042540.29813@localhost.localdomain>
 <20050618202359.GP22463@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050618202359.GP22463@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sat, 18 Jun 2005, Thomas Graf wrote:

> * Tom?? Macek <Pine.LNX.4.61.0506182042540.29813@localhost.localdomain> 2005-06-18 20:55
>> The 'rtm_dst_len = 16' should mean the mask of the route I'm looking for, correct?
>
> Yes.
>
>> The whole code before sending the packet is below:
>>
>>
>>      /* Create Socket */
>>      if((sock = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_ROUTE)) < 0)
>>          perror("Socket Creation: ");
>>
>>      /* Initialize the buffer */
>>      memset(msgBuf, 0, BUFSIZE);
>>
>>      /* point the header and the msg structure pointers into the buffer */
>>      nlMsg = (struct nlmsghdr *)msgBuf;
>>      rtMsg = (struct rtmsg *)NLMSG_DATA(nlMsg);
>>      rtMsg->rtm_family = AF_INET;
>>      rtMsg->rtm_dst_len = 16;
>>
>>      /* Fill in the nlmsg header*/
>>      nlMsg->nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg)); // Length of message.
>>      nlMsg->nlmsg_type = RTM_GETROUTE;   // Get the routes from kernel routing table .
>>      nlMsg->nlmsg_flags = NLM_F_REQUEST;   // The message is a request for dump.
>>      nlMsg->nlmsg_seq = msgSeq++;   // Sequence of the message packet.
>>      nlMsg->nlmsg_pid = getpid();   // PID of process sending the request.
>>
>>      char *cp;
>>      unsigned int xx[4]; int i = 0;
>>      unsigned char *ap = (unsigned char *)xx;
>>      for (cp = argv[1], i = 0; *cp; cp++) {
>>          if (*cp <= '9' && *cp >= '0') {
>>              ap[i] = 10*ap[i] + (*cp-'0');
>>              continue;
>>          }
>>          if (*cp == '.' && ++i <= 3)
>>              continue;
>>          return -1;
>>      }
>>
>>      NetlinkAddAttr(nlMsg, sizeof(nlMsg), RTA_DST, &xx, 4);
>
> This looks good but your NetlinkAddAttr is bogus, it should
> be something like this:
>
> int nl_msg_append_tlv(struct nlmsghdr *n, int type, void *data, size_t len)
> {
> 	int tlen;
> 	struct rtattr *rta;
>
> 	tlen = NLMSG_ALIGN(n->nlmsg_len) + RTA_LENGTH(NLMSG_ALIGN(len));
>
> 	rta = (struct rtattr *) NLMSG_TAIL(n);
> 	rta->rta_type = type;
> 	rta->rta_len = RTA_LENGTH(NLMSG_ALIGN(len));
> 	memcpy(RTA_DATA(rta), data, len);
> 	n->nlmsg_len = tlen;
>
> 	return 0;
> }
>
> Your code is missing various alignment requirements. I can't tell
> whether this is the last bug. I recommend you to read ip/iproute.c
> in the iproute2 source or give libnl a second chance.
>

The code now works this way:
[root@localhost route]# route
1.1.1.0         *               255.255.255.0   U     0      0        0 eth0
3.3.0.0         *               255.255.0.0     U     0      0        0 eth1
default         meric           0.0.0.0         UG    0      0        0 eth0

[root@localhost route]# ./a.out 2.2.2.2 16
Destination             Gateway         Interface               Source          Netmask
2.2.2.2         213.250.192.33          eth0            255.255.255.255

[root@localhost route]# ./a.out 1.1.1.2 16
Destination             Gateway         Interface               Source          Netmask
1.1.1.2         *.*.*.*                         eth0            255.255.255.255

[root@localhost route]# ./a.out 3.3.3.2 16
Destination             Gateway         Interface               Source          Netmask
3.3.3.2         *.*.*.*                         eth1            255.255.255.255

so it returns the route, where the data would go, if their DST address would be the one given by the argv[1] with mask argv[2].
I don't know now, if we understood to each other and if this is you thought it should be. 
If I will write on the command line './a.out 3.3.0.0 16', it should print the line like this if the record is present:
3.3.0.0         *               255.255.0.0     U     0      0        0 eth1

if I would write './a.out 3.3.3.1 32' it MUST print nothing! :)

Thank you for help
