From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] packet: fix panic in __packet_set_timestamp
 on tpacket_v3 in tx mode
Date: Thu, 05 Jan 2017 20:10:07 +0100
Message-ID: <586E9A0F.1020002@iogearbox.net>
References: <1483580068-13854-1-git-send-email-daniel@iogearbox.net> <1483640872.9712.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        willemb@google.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49047 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763543AbdAETKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 14:10:40 -0500
In-Reply-To: <1483640872.9712.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2017 07:27 PM, Eric Dumazet wrote:
> On Thu, 2017-01-05 at 02:34 +0100, Daniel Borkmann wrote:
[...]
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 7e39087..ddbda25 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -481,6 +481,9 @@ static __u32 __packet_set_timestamp(struct packet_sock *po, void *frame,
>>   		h.h2->tp_nsec = ts.tv_nsec;
>>   		break;
>>   	case TPACKET_V3:
>> +		h.h3->tp_sec = ts.tv_sec;
>> +		h.h3->tp_nsec = ts.tv_nsec;
>> +		break;
>>   	default:
>>   		WARN(1, "TPACKET version not supported.\n");
>>   		BUG();
>
> Gosh. Can we also replace this BUG() into something less aggressive ?

There are currently 5 of these WARN() + BUG() constructs and 1 BUG()-only
for the 'default' TPACKET version spread all over af_packet, so probably
makes sense to rather make all of them less aggressive.

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index b9e1a13b4ba36a0bc7edf6a8c2c116c7d48c970c..0c0d268544787dcbef6601c5014e7d3836d16f96 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -476,9 +476,11 @@ static __u32 __packet_set_timestamp(struct packet_sock *po, void *frame,
>   		h.h2->tp_nsec = ts.tv_nsec;
>   		break;
>   	case TPACKET_V3:
> +		h.h3->tp_sec = ts.tv_sec;
> +		h.h3->tp_nsec = ts.tv_nsec;
> +		break;
>   	default:
> -		WARN(1, "TPACKET version not supported.\n");
> -		BUG();
> +		pr_err_once("TPACKET version %u not supported.\n", po->tp_version);
>   	}
>
>   	/* one flush is safe, as both fields always lie on the same cacheline */
>
>
