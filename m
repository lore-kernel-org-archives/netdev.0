From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net: pktgen: support injecting packets for qdisc testing
Date: Fri, 08 Jan 2016 07:38:36 -0800
Message-ID: <568FD7FC.8020005@gmail.com>
References: <20160108020908.5940.89612.stgit@john-Precision-Tower-5810> <568FD5B7.2060602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33798 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754094AbcAHPiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 10:38:51 -0500
Received: by mail-pa0-f53.google.com with SMTP id uo6so266046490pac.1
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 07:38:51 -0800 (PST)
In-Reply-To: <568FD5B7.2060602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-08 07:28 AM, John Fastabend wrote:
> On 16-01-07 06:09 PM, John Fastabend wrote:
>> Add another xmit_mode to pktgen to allow testing xmit functionality
>> of qdiscs. The new mode "queue_xmit" injects packets at
>> __dev_queue_xmit() so that qdisc is called.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
> 
> 
> [...]
> 
>>  		} while (--burst > 0);
>>  		goto out; /* Skips xmit_mode M_START_XMIT */
>> +	} else if (pkt_dev->xmit_mode == M_QUEUE_XMIT) {
>> +		atomic_add(burst, &pkt_dev->skb->users);
>> +		local_bh_disable();
>> +
>> +		do {
>> +			ret = dev_queue_xmit(pkt_dev->skb);
>> +			switch (ret) {
>> +			case NET_XMIT_SUCCESS:
>> +			case NET_XMIT_DROP:
>> +			case NET_XMIT_CN:
>> +			case NET_XMIT_POLICED:
>> +			/* These are all valid return codes for a qdisc so
>> +			 * unlike start_xmit report this as successful
>> +			 * transactions. I expect testers will be also be
>> +			 * reviewing qdisc stats for more details.
>> +			 */
>> +				pkt_dev->last_ok = 1;
>> +				pkt_dev->sofar++;
>> +				pkt_dev->seq_num++;
>> +				pkt_dev->tx_bytes += pkt_dev->last_pkt_size;
>> +				break;
>> +			case NETDEV_TX_LOCKED:
>> +			case NETDEV_TX_BUSY:
>> +			/* qdisc may call dev_hard_start_xmit directly in cases
>> +			 * where no queues exist e.g. loopback device, virtual
>> +			 * devices, etc. In this case we need to handle
>> +			 * NETDEV_TX_ codes.
>> +			 */
>> +				pkt_dev->errors++;
>> +				break;
>> +			default:
>> +				net_info_ratelimited("%s xmit error: %d\n",
>> +						     pkt_dev->odevname, ret);
>> +				pkt_dev->errors++;
>> +				break;
>> +			}
>> +		} while (--burst > 0);
> 
> 
> oops missed the case where burst != 0 here and we need to do an
> atomic_sub on skb->users.
> 
> .John
> 

Also I'll respin this with a change so xmit_{drop|cn|policed} are not
counted as tx_bytes and pkts sent (idea from Jamal). However I won't
abort the burst because I do like this stressing the entry point of my
qdisc.

.John
