From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v4 4/5] sctp: Add ASCONF operation on the
 single-homed host
Date: Mon, 25 Apr 2011 09:44:57 +0800
Message-ID: <4DB4D219.6030001@cn.fujitsu.com>
References: <3BDA3586-6A7C-4305-9D41-F146575AC951@sfc.wide.ad.jp> <4DB0FD45.2050709@cn.fujitsu.com> <8121C67C-2543-42DF-88B4-463BAFBA8A0C@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52400 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757598Ab1DYBpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2011 21:45:09 -0400
In-Reply-To: <8121C67C-2543-42DF-88B4-463BAFBA8A0C@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> Hi Wei, thanks for your feedback, I'd like to ask about some points that I have a bit of hesitations before fix.  
> Please see in-line.  
>
>>>  * ADDIP 3.1.1 Address Configuration Change Chunk (ASCONF)
>>>  *      0                   1                   2                   3
>>> @@ -2744,11 +2799,24 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>>> 	int			addr_param_len = 0;
>>> 	int 			totallen = 0;
>>> 	int 			i;
>>> +	sctp_addip_param_t del_param; /* 8 Bytes (Type 0xC002, Len and CrrID) */
>>> +	struct sctp_af *del_af;
>>> +	int del_addr_param_len = 0;
>>> +	int del_paramlen = sizeof(sctp_addip_param_t);
>>> +	union sctp_addr_param del_addr_param; /* (v4) 8 Bytes, (v6) 20 Bytes */
>>> +	int			v4 = 0;
>>> +	int			v6 = 0;
>> you can reuse the af, param_len etc, no need to define new variables.
> This is for the situation that the application adds a new IPv4 and a new IPv6 address simultaneously, although it never happen in the auto_asconf process.  
> Since the af is overwritten to the last seen address in addrs, defining these variables is useful.  
> (Extracting existence of v4 and v6 parameters is possible, but I think it's overkill.  )
> So, how about remaining them?

I means why your need this check?

+        if ((asoc->asconf_addr_del_pending->sa.sa_family == AF_INET
+            && v4) ||
+            (asoc->asconf_addr_del_pending->sa.sa_family == AF_INET6
+            && v6)) {


Add IPv4 and Del IPv6 is possible if socket is AF_INET6 base.


>>> @@ -3361,6 +3486,35 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
>>> 		asconf_len -= length;
>>> 	}
>>>
>>> +	/* When the source address obviously changes to newly added one, we
>>> +	   reset the cwnd to re-probe the path condition
>> Since we do not do this when the host/peer add/del ip addresses,
>> remain the peer's cwnd etc. to what it is maybe better.
> What do you mean "host/peer add/del ip addresses" ?

I means if we delete the other address other than the last one
address, we do not reset the peer's information.

>> and this is unnecessary when you just change the address of
>> the interface.
> Yes, however, it is mostly impossible to distinguish that situation from change of the physical path.  
> So considering change of source address as change of path could make sense or fine-grain metric to reset congestion control parameter.    
> As one example, in FreeBSD implementation, congestion control parameter is reset when the last remaining address is changed. 

I got what your said. Can you split the peer reset part to an new patch?

This part:

+void
+sctp_path_check_and_react(struct sctp_association *asoc, struct sockaddr *sa)
+{
+	struct sctp_transport *trans;
+	int addrnum, family;
+	struct sctp_sockaddr_entry *saddr;
+	struct sctp_bind_addr *bp;
+	union sctp_addr *tmpaddr;
+
+	family = sa->sa_family;
+	bp = &asoc->base.bind_addr;
+	addrnum = 0;
+	/* count up the number of local addresses in the same family */
+	list_for_each_entry(saddr, &bp->address_list, list) {
+		if (saddr->a.sa.sa_family == family) {
+			tmpaddr = &saddr->a;
+			if (family == AF_INET6 &&
+			    ipv6_addr_type(&tmpaddr->v6.sin6_addr) &
+			    IPV6_ADDR_LINKLOCAL) {
+				continue;
+			}
+			addrnum++;
+		}
+	}


the address be added to the asoc should in the scope, refer to
sctp_in_scope(). So we may not mix link local with global
addresses.
If so, we may simply this patch to reset peer only when we recv
the asconf-ack and the asoc->src_out_of_asoc_ok == true.




