From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH 6/6 v8] sctp: Add ASCONF operation on the single-homed host
Date: Thu, 28 Apr 2011 17:04:18 +0900
Message-ID: <5183C2C0-C377-4FF7-89A1-3F19D53FBBBF@sfc.wide.ad.jp>
References: <4947D5B3-9FCA-42AA-81D0-9D55594108F1@sfc.wide.ad.jp> <4DB8F287.2070000@cn.fujitsu.com> <8B2DF56A-11D6-41F6-85E5-01AA47C0F774@sfc.wide.ad.jp> <4DB915EF.8000003@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:55060 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754791Ab1D1IEV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 04:04:21 -0400
In-Reply-To: <4DB915EF.8000003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> 
>>>> +			/* reuse the parameter length from the same scope one */
>>>> +			totallen += paramlen;
>>>> +			totallen += addr_param_len;
>>>> +			del_pickup = 1;
>>>> +			asoc->src_out_of_asoc_ok = 1;
>>> src_out_of_asoc_ok should be marked when the last address is
>>> assigned to asoc->asconf_addr_del_pending?
>> I thought marking src_out_of_asoc_ok should be set when the candidate new address appears, rather than when the last address is being deleted.  
>> Because until such address appears, there is no situation to send any chunk from the address not in the association.  
> 
> The last address have been marked as DEL, will never using
> for sending chunks. At this time, there is no valid address in the
> host, chunk can not be send out by host.
I understand that, marking out_of_asoc_ok at the last address being deleted does same thing.  
However, out_of_asoc_ok state is not regular, so I think we should shorten that duration as much as possible.  
But this is my personal opinion, so if you don't think so, I will mark it when the last address being deleted.  
> 
>>>> +			SCTP_DEBUG_PRINTK("mkasconf_update_ip: picked same-scope del_pending addr, totallen for all addresses is %d\n", totallen);
>>>> +		}
>>>> 	}
>>>> 
>>>> 	/* Create an asconf chunk with the required length. */
>>>> @@ -2802,6 +2819,19 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>>>> 
>>>> 		addr_buf += af->sockaddr_len;
>>>> 	}
>>>> +	if (flags == SCTP_PARAM_ADD_IP && del_pickup) {
>>>> +		addr = asoc->asconf_addr_del_pending;
>>>> +		del_af = sctp_get_af_specific(addr->v4.sin_family);
>>>> +		del_addr_param_len = del_af->to_addr_param(addr,
>>>> +		    &del_addr_param);
>>>> +		del_param.param_hdr.type = SCTP_PARAM_DEL_IP;
>>>> +		del_param.param_hdr.length = htons(del_paramlen +
>>>> +		    del_addr_param_len);
>>>> +		del_param.crr_id = i;
>>>> +
>>>> +		sctp_addto_chunk(retval, del_paramlen, &del_param);
>>>> +		sctp_addto_chunk(retval, del_addr_param_len, &del_addr_param);
>>>> +	}
>>>> 	return retval;
>>>> }
>>> How about clean up this part as:
>>> 
>>> +       if (...) {
>>> +               addr = asoc->asconf_addr_del_pending;
>>> +               af = sctp_get_af_specific(addr->v4.sin_family);
>>> +               addr_param_len = af->to_addr_param(addr, &addr_param);
>>> +               totallen += paramlen;
>>> +               totallen += addr_param_len;
>>> +		...
>>> +       }
>>> +
>>>      /* Create an asconf chunk with the required length. */
>>>      retval = sctp_make_asconf(asoc, laddr, totallen);
>>>      if (!retval)
>>> @@ -2802,6 +2812,18 @@ struct sctp_chunk *sctp_make_asconf_update_ip(struct sctp_association *asoc,
>>> 
>>>              addr_buf += af->sockaddr_len;
>>>      }
>>> +
>>> +       if (...) {
>>> +               addr = asoc->asconf_addr_del_pending;
>>> +               af = sctp_get_af_specific(addr->v4.sin_family);
>>> +               addr_param_len = af->to_addr_param(addr, &addr_param);
>>> +               param.param_hdr.type = SCTP_PARAM_DEL_IP;
>>> +               param.param_hdr.length = htons(paramlen + addr_param_len);
>>> +               param.crr_id = i;
>>> +
>>> +               sctp_addto_chunk(retval, paramlen, &param);
>>> +               sctp_addto_chunk(retval, addr_param_len, &addr_param);
>>> +       }
>> agreed with reusing af instead of defining del_af.  
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 

