From: Russell Leighton <russ@elegant-software.com>
Subject: Re: Fw: F_SETSIG broken/changed in 2.6 for UDP and TCP sockets?
Date: Tue, 01 Jun 2004 19:08:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40BD0C80.7080607@elegant-software.com>
References: <OFAD1DE5B4.1A829EE7-ON88256EA6.006EE314-88256EA6.006F8B71@us.ibm.com> <40BD07BC.8030302@elegant-software.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <40BD07BC.8030302@elegant-software.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I forgot to answer your question, I confirmed via the proc interface 
that the group has been joined.

I am thinking the issue is related to F_SETSIG. I don't read() until I 
get a signal and I am not getting ANY signals for the multicast data.

Googling around a little I saw changes in the futex code around FUTEX_FD 
... perhaps there is a bug?

Cobbling together a small test piece of code is the next thing to do...


Russell Leighton wrote:

> Thanks for the suggestion.
>
> I tried using the interface itself and INADDR_ANY...the signals are 
> not being received under 2.6 (FedoraCore2) UNLESS tcpdump is 
> running...note this works fine under 2.4.
>
> Below is the code fragment that sets up the socket (the previous email 
> had the code fragment that sets up the posix rt signals on the fd), 
> any help would be greatly appreciated:
>
>   /* mc_fd */
>   {
>
>     /* make it */
>     if ( (h->state.mc_fd = socket(AF_INET, SOCK_DGRAM, 0)) == -1 ) {
>       aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL, 
> "mcrxhandler cannot create socket: %s", strerror(errno));
>       goto error;
>     }
>
>     /* set it to nonblocking so that this can be async */
>     if ( fcntl(h->state.mc_fd,  F_SETFL, O_NONBLOCK)  == -1) {
>       aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL, 
> "mcrxhandler cannot set socket nonblocking: %s", strerror(errno));
>       goto error;
>     }
>
>     /* set the mc interface */
>     if ( setsockopt(h->state.mc_fd, IPPROTO_IP, IP_MULTICAST_IF, 
> &(h->mcast_if_addr), sizeof(h->mcast_if_addr)) < 0 ) {
>       u_int8_t
>     *ip = (u_int8_t *)&(h->mcast_if_addr);
>
>       aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL,
>          "mcrxhandler cannot set socket IP_MULTICAST_IF for 
> %u.%u.%u.%u: %s",
>          ip[0],ip[1],ip[2],ip[4],
>          strerror(errno));
>       goto error;
>     }
>
>     { /* debugging where packets are going when you have many 
> interfaces is a pain, you want to log this! */
>       u_int8_t
>     *ip = (u_int8_t *)&(h->mcast_if_addr);
>       aw_log(h->handler_header.logger,  AW_INFO_LOG_LEVEL, 
> "mcrxhandler running multicast on interface %u.%u.%u.%u",
>          ip[0],ip[1],ip[2],ip[3]);
>     }
>
>     /* use setsockopt() to request that the kernel join a multicast 
> group */
>     {
>       struct ip_mreq
>     mreq;
>
>       /* set up */
>       memset(&mreq, 0 , sizeof(mreq));
>       mreq.imr_multiaddr.s_addr= h->mcast_grp_addr.sin_addr.s_addr;
>       mreq.imr_interface.s_addr= h->mcast_if_addr.s_addr;
>
>       if (setsockopt(h->state.mc_fd, IPPROTO_IP,IP_ADD_MEMBERSHIP, 
> (char *)&mreq, sizeof(mreq)) < 0) {
>     aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL,
>            "mcrxhandler cannot set socket 
> IPPROTO_IP,IP_ADD_MEMBERSHIP: %s", strerror(errno));
>     goto error;
>       }
>     }
>
>     /* so we can have many processes listening to mcast */
>     {
>       int32_t
>     itmp = 1;
>       if ( setsockopt(h->state.mc_fd, SOL_SOCKET, SO_REUSEADDR , (char 
> *)&itmp, sizeof(itmp)) < 0 ) {
>     aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL, "mcrxhandler 
> cannot set socket SO_REUSEADDR: %s", strerror(errno));
>       }
>     }
>
>     /* bind to receive messages */
>     if (bind(h->state.mc_fd, (struct sockaddr *)&(h->mcast_grp_addr), 
> sizeof(h->mcast_grp_addr)) < 0) {
>       aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL, 
> "mcrxhandler cannot bind to multicast socket", strerror(errno));
>       goto error ;
>     }
>
>     /* add callback to handle packets on mc_fd */
>     aw_add_handler_fdcallback(mon, (aw_handler_t *)h, h->state.mc_fd, 
> do_read);
>
>   } /* end mc_fd */
>
>
>
>
> David Stevens wrote:
>
>>>In the udp case, I when I listen for multicast packets my app only
>>>receives them when I am running a tcpdump (bizarre!).
>>>    
>>>
>>
>>Russ,
>>        This piece (which I expect has nothing to do with the other
>>problems you mentioned) sounds like you haven't joined the groups on
>>the interface on which you're receiving the multicast packets.
>>"tcpdump" will place the interface in "promiscuous mode" which will
>>receive all packets, and ordinary packet delivery will allow
>>the application to receive them, even if you haven't joined the group
>>on the relevant interface.
>>        To verify if the group joins is broken, you can look at
>>/proc/net/igmp. If the groups you're joining are not listed on the
>>interface you want, the program isn't joining the groups correctly.
>>Group membership is per-interface, so joining a group on one interface
>>does not join it on another.
>>        Feel free to contact me if you need some help debugging the
>>multicast problem.
>>
>>                                                        +-DLS
>>
>>
>>
>>  
>>
>
