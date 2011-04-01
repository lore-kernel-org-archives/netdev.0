From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH net-next-2.6 v1] sctp: Add Auto-ASCONF support
Date: Fri, 1 Apr 2011 11:41:40 +0900
Message-ID: <93D0B4BF-3824-4D60-9143-10C00FAE62AD@sfc.wide.ad.jp>
References: <8484E05B-B474-4D3B-A192-7413FC6B9141@sfc.wide.ad.jp> <4D9422EF.2090007@cn.fujitsu.com> <5A16054A-EC79-4157-89E4-DC3BEE4124B4@sfc.wide.ad.jp> <4D95299C.6020507@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:49942 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753022Ab1DAClm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 22:41:42 -0400
In-Reply-To: <4D95299C.6020507@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 1, 2011, at 10:25 , Wei Yongjun wrote:

> 
>> Hi, 
>> 
>> Thanks for your comments.  
>> I would like to discuss some of them in-line before resubmission.  
>> 
>> Cheers,
>> - Michio
>> 
>> On Mar 31, 2011, at 15:45 , Wei Yongjun wrote:
>> 
>>> Hi Michio Honda
>>> 
>>> I try to understand what you are doing now, and some comments inline.
>>> 
>>> And
>>> 
>>> this patch is too big for review, you'd better to split it to a patchset:
>>> the improve on orig asconf code, the auto-asconf support, the socket
>>> option etc.
>>> 
>>>> @@ -599,6 +597,28 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>>>> 						    SCTP_ADDR_NEW, GFP_ATOMIC);
>>>> 			addr_buf += af->sockaddr_len;
>>>> 		}
>>>> +		list_for_each_entry(trans, &asoc->peer.transport_addr_list,
>>>> +		    transports) {
>>>> +			if (asoc->asconf_addr_del_pending != NULL)
>>>> +				/* This ADDIP ASCONF piggybacks DELIP for the
>>>> +				 * last address, so need to select src addr
>>>> +				 * from the out_of_asoc addrs
>>>> +				 */
>>>> +				asoc->src_out_of_asoc_ok = 1;
>>>> +			/* Clear the source and route cache in the path */
>>>> +			memset(&trans->saddr, 0, sizeof(union sctp_addr));
>>>> +			dst_release(trans->dst);
>>>> +			trans->cwnd = min(4*asoc->pathmtu, max_t(__u32,
>>>> +			    2*asoc->pathmtu, 4380));
>>>> +			trans->ssthresh = asoc->peer.i.a_rwnd;
>>>> +			trans->rto = asoc->rto_initial;
>>>> +			trans->rtt = 0;
>>>> +			trans->srtt = 0;
>>>> +			trans->rttvar = 0;
>>>> +			sctp_transport_route(trans, NULL,
>>>> +			    sctp_sk(asoc->base.sk));
>>>> +		}
>>>> +		retval = sctp_send_asconf(asoc, chunk);
>>> We need to do this really?
>> We have to reset path information before transmitting ASCONF from the new source address.  
>> Because when we obviously change the source address (i.e., deletion of the last local address), we don't know any information of the path (e.g., RTT) between the new source address and the existing destination address.  
> 
> Do you means we deleted all of the local address? This is prohibit
> by rfc5061. If we have other address, we can use it.
> 
>   F5)  An endpoint MUST NOT delete its last remaining IP address from
>        an association.  In other words, if an endpoint is NOT multi-
>        homed, it MUST NOT use the delete IP address without an Add IP
>        Address preceding the delete parameter in the ASCONF Chunk.  Or,
>        if an endpoint sends multiple requests to delete IP addresses,
>        it MUST NOT delete all of the IP addresses that the peer has
>        listed for the requester.
> 
> 
> But the rfc does not said what we should do if all of the local addresses
> are invalid.
Sorry for my bad description, I mean, suppose the host having one local IP address changes the IP address to new one.   
The host will remove the old address, and configure the new IP address.  
Then, I believe following steps in SCTP implementation could make sense.  
1. When the host removes the local address, SCTP implementation postpones to remove the local address from the association, because it is the last local address in the association.    
2. After the configuration of the new IP address, the SCTP implementation tries to send an ASCONF with ADD_IP_ADDRESS from the newly configured address.  This address can be used for ASCONF while it cannot be used for the other chunks.  This ASCONF also contains DELETE_IP_ADDRESS for the old address.  (This is allowed as Sec.5.3 F5 describes)
Then, the path where the ASCONF goes is obviously new path because of the new source address, thus we should reset old path parameters, otherwise the SCTP implementation might set wrong RTO and estimate wrong RTT for that ASCONF.    


> 
> 
>>>> @@ -3341,6 +3587,44 @@ static int sctp_setsockopt_del_key(struct sock *sk,
>>>> 
>>>> +static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
>>>> +					unsigned int optlen)
>>>> +{
>>>> +	int val;
>>>> +	struct sctp_ep_common *epb;
>>>> +
>>>> +	if (optlen < sizeof(int))
>>>> +		return -EINVAL;
>>>> +	if (get_user(val, (int __user *)optval))
>>>> +		return -EFAULT;
>>>> +	if (!sctp_is_ep_boundall(sk) && val)
>>>> +		return -EINVAL;
>>>> +	list_for_each_entry(epb, &sctp_auto_asconf_eplist, auto_asconf_list) {
>>>> +		if (epb->sk == sk) {
>>>> +			if (val == 0)
>>>> +				list_del(&epb->auto_asconf_list);
>>>> +			return 0;
>>>> +		}
>>>> +	}
>>>> +	if (val)
>>>> +		list_add_tail(&sctp_sk(sk)->ep->base.auto_asconf_list,
>>>> +		    &sctp_auto_asconf_eplist);
>>>> +	return 0;
>>>> +}
>>> The sctp_setsockopt_auto_asconf is not correct, if we enable this option
>>> twice, the list will be broken.
>> Oops, I fix, thanks!
>>> We'd better to introcude a auto_asconf flag to ep, and then, we do not
>>> need to scanf the asconf_list.
>>> If auto_asconf flag is true, it is exists in the list, otherwise, not.
>> Agreed, it's more simple.   
>>> All of the sctp sockets are added to sctp_auto_asconf_eplist.
>>> I think none of the sockets should exists in this list by default,
>>> only after we enable AUTO_ASCONF, we should add it to this list.
>> Sockets are added to auto_asconf_eplist only when the sysctl parameter is on.   
> 
> If so, the SCTP_AUTO_ASCONF will be broken.
> 
> I think before SCTP_AUTO_ASCONF be document, the sysctl parameter
> is used to enable/disable the auto asconf, but after SCTP_AUTO_ASCONF
> defined, sysctl parameter should be deprecated.
Mmm, not sure, we should ask Randy and Michael.  I'll send separate email soon.  
> 
>>> Is the sysctl parameter necessary, since auto_asconf is disabled
>>> by default, and we need to set the option to enabled it.
>> I believe auto_asconf should be enabled by both of sysctl and setsockopt as well as FreeBSD implementation does.  
>> Adopting the same methods could be helpful for applications concerning auto_asconf availability.  
>> I agree to set the sysctl parameter to 0 by default.    
>> 
>>> 
>>> 
>> 
>> 

