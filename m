From: Russell Leighton <russ@elegant-software.com>
Subject: Re: Fw: F_SETSIG broken/changed in 2.6 for UDP and TCP sockets?
Date: Tue, 01 Jun 2004 18:48:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40BD07BC.8030302@elegant-software.com>
References: <OFAD1DE5B4.1A829EE7-ON88256EA6.006EE314-88256EA6.006F8B71@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------040609040703050508040004"
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFAD1DE5B4.1A829EE7-ON88256EA6.006EE314-88256EA6.006F8B71@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040609040703050508040004
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Thanks for the suggestion.

I tried using the interface itself and INADDR_ANY...the signals are not 
being received under 2.6 (FedoraCore2) UNLESS tcpdump is running...note 
this works fine under 2.4.

Below is the code fragment that sets up the socket (the previous email 
had the code fragment that sets up the posix rt signals on the fd), any 
help would be greatly appreciated:

  /* mc_fd */
  {

    /* make it */
    if ( (h->state.mc_fd = socket(AF_INET, SOCK_DGRAM, 0)) == -1 ) {
      aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL, "mcrxhandler 
cannot create socket: %s", strerror(errno));
      goto error;
    }

    /* set it to nonblocking so that this can be async */
    if ( fcntl(h->state.mc_fd,  F_SETFL, O_NONBLOCK)  == -1) {
      aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL, "mcrxhandler 
cannot set socket nonblocking: %s", strerror(errno));
      goto error;
    }

    /* set the mc interface */
    if ( setsockopt(h->state.mc_fd, IPPROTO_IP, IP_MULTICAST_IF, 
&(h->mcast_if_addr), sizeof(h->mcast_if_addr)) < 0 ) {
      u_int8_t
    *ip = (u_int8_t *)&(h->mcast_if_addr);

      aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL,
         "mcrxhandler cannot set socket IP_MULTICAST_IF for %u.%u.%u.%u: 
%s",
         ip[0],ip[1],ip[2],ip[4],
         strerror(errno));
      goto error;
    }

    { /* debugging where packets are going when you have many interfaces 
is a pain, you want to log this! */
      u_int8_t
    *ip = (u_int8_t *)&(h->mcast_if_addr);
      aw_log(h->handler_header.logger,  AW_INFO_LOG_LEVEL, "mcrxhandler 
running multicast on interface %u.%u.%u.%u",
         ip[0],ip[1],ip[2],ip[3]);
    }

    /* use setsockopt() to request that the kernel join a multicast group */
    {
      struct ip_mreq
    mreq;

      /* set up */
      memset(&mreq, 0 , sizeof(mreq));
      mreq.imr_multiaddr.s_addr= h->mcast_grp_addr.sin_addr.s_addr;
      mreq.imr_interface.s_addr= h->mcast_if_addr.s_addr;

      if (setsockopt(h->state.mc_fd, IPPROTO_IP,IP_ADD_MEMBERSHIP, (char 
*)&mreq, sizeof(mreq)) < 0) {
    aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL,
           "mcrxhandler cannot set socket IPPROTO_IP,IP_ADD_MEMBERSHIP: 
%s", strerror(errno));
    goto error;
      }
    }

    /* so we can have many processes listening to mcast */
    {
      int32_t
    itmp = 1;
      if ( setsockopt(h->state.mc_fd, SOL_SOCKET, SO_REUSEADDR , (char 
*)&itmp, sizeof(itmp)) < 0 ) {
    aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL, "mcrxhandler 
cannot set socket SO_REUSEADDR: %s", strerror(errno));
      }
    }

    /* bind to receive messages */
    if (bind(h->state.mc_fd, (struct sockaddr *)&(h->mcast_grp_addr), 
sizeof(h->mcast_grp_addr)) < 0) {
      aw_log(h->handler_header.logger, AW_ERROR_LOG_LEVEL, "mcrxhandler 
cannot bind to multicast socket", strerror(errno));
      goto error ;
    }

    /* add callback to handle packets on mc_fd */
    aw_add_handler_fdcallback(mon, (aw_handler_t *)h, h->state.mc_fd, 
do_read);

  } /* end mc_fd */




David Stevens wrote:

>>In the udp case, I when I listen for multicast packets my app only
>>receives them when I am running a tcpdump (bizarre!).
>>    
>>
>
>Russ,
>        This piece (which I expect has nothing to do with the other
>problems you mentioned) sounds like you haven't joined the groups on
>the interface on which you're receiving the multicast packets.
>"tcpdump" will place the interface in "promiscuous mode" which will
>receive all packets, and ordinary packet delivery will allow
>the application to receive them, even if you haven't joined the group
>on the relevant interface.
>        To verify if the group joins is broken, you can look at
>/proc/net/igmp. If the groups you're joining are not listed on the
>interface you want, the program isn't joining the groups correctly.
>Group membership is per-interface, so joining a group on one interface
>does not join it on another.
>        Feel free to contact me if you need some help debugging the
>multicast problem.
>
>                                                        +-DLS
>
>
>
>  
>


--------------040609040703050508040004
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
Thanks for the suggestion.<br>
<br>
I tried using the interface itself and INADDR_ANY...the signals are not
being received under 2.6 (FedoraCore2) UNLESS tcpdump is running...note
this works fine under 2.4.<br>
<br>
Below is the code fragment that sets up the socket (the previous email
had the code fragment that sets up the posix rt signals on the fd), any
help would be greatly appreciated:<br>
<br>
&nbsp; /* mc_fd */<br>
&nbsp; {<br>
<br>
&nbsp;&nbsp;&nbsp; /* make it */<br>
&nbsp;&nbsp;&nbsp; if ( (h-&gt;state.mc_fd = socket(AF_INET, SOCK_DGRAM, 0)) == -1 ) {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; aw_log(h-&gt;handler_header.logger, AW_ERROR_LOG_LEVEL,
"mcrxhandler cannot create socket: %s", strerror(errno));<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto error;<br>
&nbsp;&nbsp;&nbsp; }<br>
<br>
&nbsp;&nbsp;&nbsp; /* set it to nonblocking so that this can be async */<br>
&nbsp;&nbsp;&nbsp; if ( fcntl(h-&gt;state.mc_fd,&nbsp; F_SETFL, O_NONBLOCK)&nbsp; == -1) {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; aw_log(h-&gt;handler_header.logger, AW_ERROR_LOG_LEVEL,
"mcrxhandler cannot set socket nonblocking: %s", strerror(errno));<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto error;<br>
&nbsp;&nbsp;&nbsp; }<br>
<br>
&nbsp;&nbsp;&nbsp; /* set the mc interface */<br>
&nbsp;&nbsp;&nbsp; if ( setsockopt(h-&gt;state.mc_fd, IPPROTO_IP, IP_MULTICAST_IF,
&amp;(h-&gt;mcast_if_addr), sizeof(h-&gt;mcast_if_addr)) &lt; 0 ) {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; u_int8_t<br>
&nbsp;&nbsp;&nbsp; *ip = (u_int8_t *)&amp;(h-&gt;mcast_if_addr);<br>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; aw_log(h-&gt;handler_header.logger, AW_ERROR_LOG_LEVEL, <br>
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; "mcrxhandler cannot set socket IP_MULTICAST_IF for
%u.%u.%u.%u: %s", <br>
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; ip[0],ip[1],ip[2],ip[4],<br>
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; strerror(errno));<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto error;<br>
&nbsp;&nbsp;&nbsp; }<br>
<br>
&nbsp;&nbsp;&nbsp; { /* debugging where packets are going when you have many
interfaces is a pain, you want to log this! */<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; u_int8_t<br>
&nbsp;&nbsp;&nbsp; *ip = (u_int8_t *)&amp;(h-&gt;mcast_if_addr);<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; aw_log(h-&gt;handler_header.logger,&nbsp; AW_INFO_LOG_LEVEL,
"mcrxhandler running multicast on interface %u.%u.%u.%u",<br>
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp; ip[0],ip[1],ip[2],ip[3]);<br>
&nbsp;&nbsp;&nbsp; }<br>
<br>
&nbsp;&nbsp;&nbsp; /* use setsockopt() to request that the kernel join a multicast
group */<br>
&nbsp;&nbsp;&nbsp; {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct ip_mreq <br>
&nbsp;&nbsp;&nbsp; mreq;<br>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* set up */<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset(&amp;mreq, 0 , sizeof(mreq));<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mreq.imr_multiaddr.s_addr= h-&gt;mcast_grp_addr.sin_addr.s_addr;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mreq.imr_interface.s_addr= h-&gt;mcast_if_addr.s_addr;<br>
<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (setsockopt(h-&gt;state.mc_fd, IPPROTO_IP,IP_ADD_MEMBERSHIP,
(char *)&amp;mreq, sizeof(mreq)) &lt; 0) {<br>
&nbsp;&nbsp;&nbsp; aw_log(h-&gt;handler_header.logger, AW_ERROR_LOG_LEVEL, <br>
&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; "mcrxhandler cannot set socket IPPROTO_IP,IP_ADD_MEMBERSHIP:
%s", strerror(errno));<br>
&nbsp;&nbsp;&nbsp; goto error;<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>
&nbsp;&nbsp;&nbsp; }<br>
<br>
&nbsp;&nbsp;&nbsp; /* so we can have many processes listening to mcast */<br>
&nbsp;&nbsp;&nbsp; {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int32_t<br>
&nbsp;&nbsp;&nbsp; itmp = 1; <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if ( setsockopt(h-&gt;state.mc_fd, SOL_SOCKET, SO_REUSEADDR ,
(char *)&amp;itmp, sizeof(itmp)) &lt; 0 ) {<br>
&nbsp;&nbsp;&nbsp; aw_log(h-&gt;handler_header.logger, AW_ERROR_LOG_LEVEL,
"mcrxhandler cannot set socket SO_REUSEADDR: %s", strerror(errno));<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>
&nbsp;&nbsp;&nbsp; }<br>
<br>
&nbsp;&nbsp;&nbsp; /* bind to receive messages */<br>
&nbsp;&nbsp;&nbsp; if (bind(h-&gt;state.mc_fd, (struct sockaddr
*)&amp;(h-&gt;mcast_grp_addr), sizeof(h-&gt;mcast_grp_addr)) &lt; 0) {<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; aw_log(h-&gt;handler_header.logger, AW_ERROR_LOG_LEVEL,
"mcrxhandler cannot bind to multicast socket", strerror(errno));<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto error ;<br>
&nbsp;&nbsp;&nbsp; }<br>
<br>
&nbsp;&nbsp;&nbsp; /* add callback to handle packets on mc_fd */<br>
&nbsp;&nbsp;&nbsp; aw_add_handler_fdcallback(mon, (aw_handler_t *)h,
h-&gt;state.mc_fd, do_read);<br>
<br>
&nbsp; } /* end mc_fd */<br>
<br>
<br>
<br>
<br>
David Stevens wrote:
<blockquote
 cite="midOFAD1DE5B4.1A829EE7-ON88256EA6.006EE314-88256EA6.006F8B71@us.ibm.com"
 type="cite">
  <blockquote type="cite">
    <pre wrap="">In the udp case, I when I listen for multicast packets my app only
receives them when I am running a tcpdump (bizarre!).
    </pre>
  </blockquote>
  <pre wrap=""><!---->
Russ,
        This piece (which I expect has nothing to do with the other
problems you mentioned) sounds like you haven't joined the groups on
the interface on which you're receiving the multicast packets.
"tcpdump" will place the interface in "promiscuous mode" which will
receive all packets, and ordinary packet delivery will allow
the application to receive them, even if you haven't joined the group
on the relevant interface.
        To verify if the group joins is broken, you can look at
/proc/net/igmp. If the groups you're joining are not listed on the
interface you want, the program isn't joining the groups correctly.
Group membership is per-interface, so joining a group on one interface
does not join it on another.
        Feel free to contact me if you need some help debugging the
multicast problem.

                                                        +-DLS



  </pre>
</blockquote>
<br>
</body>
</html>

--------------040609040703050508040004--
