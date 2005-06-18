From: Thomas Graf <tgraf@suug.ch>
Subject: Re: receive only one record from the routing table
Date: Sat, 18 Jun 2005 22:23:59 +0200
Message-ID: <20050618202359.GP22463@postel.suug.ch>
References: <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain> <20050617141527.GN22463@postel.suug.ch> <Pine.LNX.4.61.0506172057240.26739@localhost.localdomain> <20050617191340.GO22463@postel.suug.ch> <Pine.LNX.4.61.0506182042540.29813@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?iso-8859-1?B?VG9t4T8=?= Macek <maca02@atlas.cz>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0506182042540.29813@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Tom?? Macek <Pine.LNX.4.61.0506182042540.29813@localhost.localdomain> 2005-06-18 20:55
> The 'rtm_dst_len = 16' should mean the mask of the route I'm looking for, correct?

Yes.

> The whole code before sending the packet is below:
> 
> 
>      /* Create Socket */
>      if((sock = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_ROUTE)) < 0)
>          perror("Socket Creation: ");
> 
>      /* Initialize the buffer */
>      memset(msgBuf, 0, BUFSIZE);
> 
>      /* point the header and the msg structure pointers into the buffer */
>      nlMsg = (struct nlmsghdr *)msgBuf;
>      rtMsg = (struct rtmsg *)NLMSG_DATA(nlMsg);
>      rtMsg->rtm_family = AF_INET;
>      rtMsg->rtm_dst_len = 16;
> 
>      /* Fill in the nlmsg header*/
>      nlMsg->nlmsg_len = NLMSG_LENGTH(sizeof(struct rtmsg)); // Length of message.
>      nlMsg->nlmsg_type = RTM_GETROUTE;   // Get the routes from kernel routing table .
>      nlMsg->nlmsg_flags = NLM_F_REQUEST;   // The message is a request for dump.
>      nlMsg->nlmsg_seq = msgSeq++;   // Sequence of the message packet.
>      nlMsg->nlmsg_pid = getpid();   // PID of process sending the request.
> 
>      char *cp;
>      unsigned int xx[4]; int i = 0;
>      unsigned char *ap = (unsigned char *)xx;
>      for (cp = argv[1], i = 0; *cp; cp++) {
>          if (*cp <= '9' && *cp >= '0') {
>              ap[i] = 10*ap[i] + (*cp-'0');
>              continue;
>          }
>          if (*cp == '.' && ++i <= 3)
>              continue;
>          return -1;
>      }
> 
>      NetlinkAddAttr(nlMsg, sizeof(nlMsg), RTA_DST, &xx, 4);

This looks good but your NetlinkAddAttr is bogus, it should
be something like this:

int nl_msg_append_tlv(struct nlmsghdr *n, int type, void *data, size_t len)
{
	int tlen;
	struct rtattr *rta;
	
	tlen = NLMSG_ALIGN(n->nlmsg_len) + RTA_LENGTH(NLMSG_ALIGN(len));

	rta = (struct rtattr *) NLMSG_TAIL(n);
	rta->rta_type = type;
	rta->rta_len = RTA_LENGTH(NLMSG_ALIGN(len));
	memcpy(RTA_DATA(rta), data, len);
	n->nlmsg_len = tlen;
	
	return 0;
}

Your code is missing various alignment requirements. I can't tell
whether this is the last bug. I recommend you to read ip/iproute.c
in the iproute2 source or give libnl a second chance.
