From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH 6/6 v8] sctp: Add ASCONF operation on the single-homed host
Date: Thu, 28 Apr 2011 16:04:33 +0900
Message-ID: <8B2DF56A-11D6-41F6-85E5-01AA47C0F774@sfc.wide.ad.jp>
References: <4947D5B3-9FCA-42AA-81D0-9D55594108F1@sfc.wide.ad.jp> <4DB8F287.2070000@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:42114 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753740Ab1D1HEi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 03:04:38 -0400
In-Reply-To: <4DB8F287.2070000@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

>> 
>> 
>> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>> index 3740603..6363c46 100644
>> --- a/net/sctp/sm_make_chunk.c
>> +++ b/net/sctp/sm_make_chunk.c
>> @@ -2768,6 +2768,12 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>> 	int			addr_param_len = 0;
>> 	int 			totallen = 0;
>> 	int 			i;
>> +	sctp_addip_param_t del_param; /* 8 Bytes (Type 0xC002, Len and CrrID) */
>> +	struct sctp_af *del_af;
>> +	int del_addr_param_len = 0;
>> +	int del_paramlen = sizeof(sctp_addip_param_t);
>> +	union sctp_addr_param del_addr_param; /* (v4) 8 Bytes, (v6) 20 Bytes */
>> +	int			del_pickup = 0;
>> 
>> 	/* Get total length of all the address parameters. */
>> 	addr_buf = addrs;
>> @@ -2780,6 +2786,17 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>> 		totallen += addr_param_len;
>> 
>> 		addr_buf += af->sockaddr_len;
>> +		if (asoc->asconf_addr_del_pending && !del_pickup) {
>> +			if (!sctp_in_scope(asoc->asconf_addr_del_pending,
>> +			    sctp_scope(addr)))
>> +				continue;
> 
> scope should olny be check before address is added to the asoc.
> delete does not need this, since we have checked that the address
> be deleted is existed in the asoc.
Exactly, I remove this check and add the code to check scope for adding address in sctp_asconf_mgmt().  
> 
> You can test with the last test commands I send to your, instead,
> ifdown/up the lo device.
> $ ifdown lo && ifup lo
Ah, I see, I try.  
> 
>> +			/* reuse the parameter length from the same scope one */
>> +			totallen += paramlen;
>> +			totallen += addr_param_len;
>> +			del_pickup = 1;
>> +			asoc->src_out_of_asoc_ok = 1;
> 
> src_out_of_asoc_ok should be marked when the last address is
> assigned to asoc->asconf_addr_del_pending?
I thought marking src_out_of_asoc_ok should be set when the candidate new address appears, rather than when the last address is being deleted.  
Because until such address appears, there is no situation to send any chunk from the address not in the association.  
> 
>> +			SCTP_DEBUG_PRINTK("mkasconf_update_ip: picked same-scope del_pending addr, totallen for all addresses is %d\n", totallen);
>> +		}
>> 	}
>> 
>> 	/* Create an asconf chunk with the required length. */
>> @@ -2802,6 +2819,19 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>> 
>> 		addr_buf += af->sockaddr_len;
>> 	}
>> +	if (flags == SCTP_PARAM_ADD_IP && del_pickup) {
>> +		addr = asoc->asconf_addr_del_pending;
>> +		del_af = sctp_get_af_specific(addr->v4.sin_family);
>> +		del_addr_param_len = del_af->to_addr_param(addr,
>> +		    &del_addr_param);
>> +		del_param.param_hdr.type = SCTP_PARAM_DEL_IP;
>> +		del_param.param_hdr.length = htons(del_paramlen +
>> +		    del_addr_param_len);
>> +		del_param.crr_id = i;
>> +
>> +		sctp_addto_chunk(retval, del_paramlen, &del_param);
>> +		sctp_addto_chunk(retval, del_addr_param_len, &del_addr_param);
>> +	}
>> 	return retval;
>> }
> 
> How about clean up this part as:
> 
> +       if (...) {
> +               addr = asoc->asconf_addr_del_pending;
> +               af = sctp_get_af_specific(addr->v4.sin_family);
> +               addr_param_len = af->to_addr_param(addr, &addr_param);
> +               totallen += paramlen;
> +               totallen += addr_param_len;
> +		...
> +       }
> +
>       /* Create an asconf chunk with the required length. */
>       retval = sctp_make_asconf(asoc, laddr, totallen);
>       if (!retval)
> @@ -2802,6 +2812,18 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
> 
>               addr_buf += af->sockaddr_len;
>       }
> +
> +       if (...) {
> +               addr = asoc->asconf_addr_del_pending;
> +               af = sctp_get_af_specific(addr->v4.sin_family);
> +               addr_param_len = af->to_addr_param(addr, &addr_param);
> +               param.param_hdr.type = SCTP_PARAM_DEL_IP;
> +               param.param_hdr.length = htons(paramlen + addr_param_len);
> +               param.crr_id = i;
> +
> +               sctp_addto_chunk(retval, paramlen, &param);
> +               sctp_addto_chunk(retval, addr_param_len, &addr_param);
> +       }
agreed with reusing af instead of defining del_af.  
> 

