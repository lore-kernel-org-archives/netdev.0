From: Nivedita Singhvi <niveditasinghvi@gmail.com>
Subject: Re: [PATCH] [PATCH] tcp: Increment of LINUX_MIB_LISTENOVERFLOWS in
 tcp_v4_conn_request() (updated)
Date: Mon, 28 Jan 2013 19:27:48 -0800
Message-ID: <510741B4.9000101@gmail.com>
References: <1359337550-3958-1-git-send-email-niveditasinghvi@gmail.com> <CAGK4HS9_xZSWVHBQX3DwvR7swnGqqccdD8mvL-i20a2dnOvK1A@mail.gmail.com> <CAGK4HS-h77PGp--hvFOPEPJu0ru5uz_K_Aqjo8k2hO=VWBr7Eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Nivedita Singhvi <niv@us.ibm.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:53170 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab3A2DfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 22:35:07 -0500
Received: by mail-ye0-f174.google.com with SMTP id m3so537490yen.19
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2013 19:35:06 -0800 (PST)
In-Reply-To: <CAGK4HS-h77PGp--hvFOPEPJu0ru5uz_K_Aqjo8k2hO=VWBr7Eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2013 09:02 PM, Vijay Subramanian wrote:

>>> We drop a connection request if the accept backlog is full and there are
>>> sufficient packets in the syn queue to warrant starting drops. Increment the
>>> appropriate counter so this isn't silent, for accurate stats and help in
>>> debugging.
>>>
>>> Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>
>>
> 
> The patch is ok but I think we missed something. Please consider the
> following in
> tcp_v4_syn_recv_sock()
> 
> exit_overflow:
>         NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
> exit_nonewsk:
>         dst_release(dst);
> exit:
>         NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
>         return NULL;
> put_and_exit:
>         inet_csk_prepare_forced_close(newsk);
>         tcp_done(newsk);
>         goto exit;
> 
> 
> When ListenOverflows is incremented, so is ListenDrops. This is
> because overflows is one of  several reasons why a SYN can be dropped
> by a socket in LISTEN state. When we increment ListenOverflows, we
> should also increment ListenDrops.
> 
> So we also need
> NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
> 
> Would you mind updating this?  (If you want me to do it as I acked the
> patch, let me know.)

Firstly, before my verbosity here, I'll definitely send in an updated 
version with LISTENDROPS incremented as well as you suggest, separately. 
It gets us towards (1) option I outline below. 

However,  I was in the middle of a broader set of changes that I was going 
to send in once I got back (pushed that one partial change as it would
have helped Leandro at the time).  Makes sense to break this out here, 
though. 

I was actually going to send in a broader patch that differentiated the 
two counters. Note that at the moment, we only increment LISTENDROPS 
in that one instance when we increment OVERFLOWS. So, at moment, these
are duplicate and one is redundant, so to speak. That I could find, at
any rate. 

The right way to fix that is to agree to what the counters should hold
and then add the remaining instances where they should be incremented 
(which is what I was sort of half way through). I ran into this while
debugging a problem of missing packets. 

We can:

1. Consider LISTENDROPS a count of all drops prior to the connection
   getting ESTABLISHED.  Increment LISTENDROPS everywhere OVERFLOWS 
   is, but also add the increments to LISTENDROPS where we drop the 
   pkt for other reasons. 

2. Remove LISTENDROPS if we don't want to count any other drops, keep
   only LISTENOVERFLOWS. 

3. Minimally : add the missing OVERFLOWS count in tcp_v4_conn_request()
   and also increment LISTENDROPS. (only makes sense to me as a incremental
   patch and continue with (1). 
   

Makes sense to me to do (1). Also, just to beat this to death..

*. Each protocol layer should maintain its own statistics. This is not just
   to be pedantic about layering, it helps immensely with debugging, of course.

*. When a tcp pkt comes into tcp_v4_rcv, as long as it's a pkt intended for
   this host, we count it as received, even if the pkt is corrupt/misformed.
   This is the TCP MIB (snmp std) segments rcvd parameter.

        tcp_v4_rcv()
                if (skb->pkt_type != PACKET_HOST)
                        goto discard_it;

                /* Count it even if it's bad */
                TCP_INC_STATS_BH(net, TCP_MIB_INSEGS);

   This means (I feel) that we should account for any drop that occurs after 
   this stage in TCP statistics somewhere (in the extended LINUX MIB, if not
   counted for some reason in the std snmp INERR count).

*. If you'll pardon my ascii:

        OUTGOING                        INCOMING
        ===========================================
        1.SEND SYN      ----
                            \ ---->     2. RCV SYN
                                -----   3. SEND SYN/ACK
                              /
        4. RCV SYN/ACK  <-----
        5. SEND ACK     ----
                            \----->     6. RCV ACK


   The rcving host is in LISTEN prior to event (2) and reaches ESTABLISHED
   after (6). The outgoing host should really be in ESTABLISHED once (5)
   occurs. 
  
   We could/should count any/all drops of a packet between (2) and (6) 
   as LISTENDROPS.
   
   We should count LISTENOVERFLOWS only when the acceptq is full and
   we're dropping the connection request at that point. 


   Although this would insert a lot more MIB increments, they are all 
   mostly rare circumstances.

   

Is there anything I'm not seeing here and being a dufus about (likely)? 
Any reason not to do (1)?


thanks,
Nivedita
