From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH net-next-2.6 v4 4/5] sctp: Add ASCONF operation on the single-homed host
Date: Sat, 23 Apr 2011 19:22:18 +0900
Message-ID: <8121C67C-2543-42DF-88B4-463BAFBA8A0C@sfc.wide.ad.jp>
References: <3BDA3586-6A7C-4305-9D41-F146575AC951@sfc.wide.ad.jp> <4DB0FD45.2050709@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:53924 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753041Ab1DWKWV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2011 06:22:21 -0400
In-Reply-To: <4DB0FD45.2050709@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wei, thanks for your feedback, I'd like to ask about some points that I have a bit of hesitations before fix.  
Please see in-line.  

>> 
>>  * ADDIP 3.1.1 Address Configuration Change Chunk (ASCONF)
>>  *      0                   1                   2                   3
>> @@ -2744,11 +2799,24 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>> 	int			addr_param_len = 0;
>> 	int 			totallen = 0;
>> 	int 			i;
>> +	sctp_addip_param_t del_param; /* 8 Bytes (Type 0xC002, Len and CrrID) */
>> +	struct sctp_af *del_af;
>> +	int del_addr_param_len = 0;
>> +	int del_paramlen = sizeof(sctp_addip_param_t);
>> +	union sctp_addr_param del_addr_param; /* (v4) 8 Bytes, (v6) 20 Bytes */
>> +	int			v4 = 0;
>> +	int			v6 = 0;
> 
> you can reuse the af, param_len etc, no need to define new variables.
This is for the situation that the application adds a new IPv4 and a new IPv6 address simultaneously, although it never happen in the auto_asconf process.  
Since the af is overwritten to the last seen address in addrs, defining these variables is useful.  
(Extracting existence of v4 and v6 parameters is possible, but I think it's overkill.  )
So, how about remaining them?
>> 
>> @@ -3361,6 +3486,35 @@ int sctp_process_asconf_ack(struct sctp_association *asoc,
>> 		asconf_len -= length;
>> 	}
>> 
>> +	/* When the source address obviously changes to newly added one, we
>> +	   reset the cwnd to re-probe the path condition
> 
> Since we do not do this when the host/peer add/del ip addresses,
> remain the peer's cwnd etc. to what it is maybe better.
What do you mean "host/peer add/del ip addresses" ?

> and this is unnecessary when you just change the address of
> the interface.
Yes, however, it is mostly impossible to distinguish that situation from change of the physical path.  
So considering change of source address as change of path could make sense or fine-grain metric to reset congestion control parameter.    
As one example, in FreeBSD implementation, congestion control parameter is reset when the last remaining address is changed.  

>> 
>> @@ -599,6 +597,28 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>> 						    SCTP_ADDR_NEW, GFP_ATOMIC);
>> 			addr_buf += af->sockaddr_len;
>> 		}
>> +		list_for_each_entry(trans, &asoc->peer.transport_addr_list,
>> +		    transports) {
>> +			if (asoc->asconf_addr_del_pending != NULL)
>> +				/* This ADDIP ASCONF piggybacks DELIP for the
>> +				 * last address, so need to select src addr
>> +				 * from the out_of_asoc addrs
>> +				 */
>> +				asoc->src_out_of_asoc_ok = 1;
>> +			/* Clear the source and route cache in the path */
>> +			memset(&trans->saddr, 0, sizeof(union sctp_addr));
>> +			dst_release(trans->dst);
>> +			trans->cwnd = min(4*asoc->pathmtu, max_t(__u32,
>> +			    2*asoc->pathmtu, 4380));
>> +			trans->ssthresh = asoc->peer.i.a_rwnd;
>> +			trans->rto = asoc->rto_initial;
>> +			trans->rtt = 0;
>> +			trans->srtt = 0;
>> +			trans->rttvar = 0;
>> +			sctp_transport_route(trans, NULL,
>> +			    sctp_sk(asoc->base.sk));
>> +		}
> 
> We should and have done update the route after the ASCONF
> be ACKed. So it is unnecessary.
ASCONF is also set the retransmission timer.  
Adopting the old RTO value and route cache for this ASCONF doesn't make sense, because it traverses different path.  


Thanks,
- Michio