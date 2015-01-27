From: Tom Herbert <therbert@google.com>
Subject: Re: Interaction between GSO and TSQ for single TCP stream
Date: Tue, 27 Jan 2015 12:08:33 -0800
Message-ID: <CA+mtBx_HhKGHLy_FfgpeepMJsV-JShZ0xKphT2j-3RDS5M+cMw@mail.gmail.com>
References: <CA+mtBx8QSg+3VSiDgY6iqiJaQgScSd9FP-uxH8S5zGGv7tN1Yw@mail.gmail.com>
	<CANn89iJCOuQfixdSp6TsPxpyvTxQSTLBJLgnsvbrbG2Am_p0-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:55147 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754246AbbA0UIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:08:34 -0500
Received: by mail-ig0-f182.google.com with SMTP id r10so6949019igi.3
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 12:08:33 -0800 (PST)
In-Reply-To: <CANn89iJCOuQfixdSp6TsPxpyvTxQSTLBJLgnsvbrbG2Am_p0-Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 12:02 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Tue, Jan 27, 2015 at 11:57 AM, Tom Herbert <therbert@google.com> wrote:
>> Eric,
>>
>> I am looking at why we are unable to achieve line rate throughput with
>> a single connection using UDP encapsulation that supports GSO/GRO. I
>> discovered that even for a non-encpasulated TCP connection I'm not
>> able to get line rate using GSO/GRO (but do with TSO/LRO). There seems
>> to be some interaction between TSQ and GSO. Setting
>> tcp_limit_output_bytes to 1000000 gets single connection up to line
>> rate for both native and encapsulated TCP.
>>
>> Some data:
>>
>> - netperf TCP_STREAM for a single connection no encapsulation
>>   Using TSO/LRO
>>     9412.44 Gbps
>>   Using GSO/GRO (ethtool -K eth0 gso on gro on tso off lro off)
>>     9286.08 Gbps
>>   Using GSO/GRO with larger limit (echo 1000000 >
>> /proc/sys/net/ipv4/tcp_limit_output_bytes)
>>     9412.75
>>
>> - netperf TCP_STREAM for a single connection for GUE-IPIP encapsulation with RCO
>>   Using GSO/GRO
>>     8842.89 Gbps
>>   Using GSO/GRO with larger limit (echo 1000000 >
>> /proc/sys/net/ipv4/tcp_limit_output_bytes)
>>     9143.99 Gbps
>>
>> Any ideas on how to address this?
>>
>> Thanks,
>> Tom
>
> Hi Tom.
>
> Yes, Eyal Perry  reported the issue a while back, we plan to send
> upstream patches to fix the issue today.
>
Awesome, looking forward to seeing them!

> Make sure you tweaked coalescing parameters if you use mlx4 :
>
> ethtool -C eth0 tx-usecs 4 tx-frames 4
>
It's bnx2x.

> Otherwise, the NIC accumulates too many packets before sending an
> interrupt for TX completion.
>
> Then you can either wait the patches, or try the one I sent :
> http://permalink.gmane.org/gmane.linux.network/347023
