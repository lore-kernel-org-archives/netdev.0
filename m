From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: sh_eth.c::sh_eth_rx(): mdp->rx_skbuff[entry] can be NULL
Date: Fri, 23 Oct 2015 14:05:45 +0300
Message-ID: <562A1489.70804@cogentembedded.com>
References: <87oafusy11.wl@dns1.atmark-techno.com>
 <5626A881.2080701@cogentembedded.com> <87eggosmvk.wl@dns1.atmark-techno.com>
 <56295282.7070202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yasushi SHOJI <yashi@atmark-techno.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34019 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbbJWLFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 07:05:47 -0400
Received: by lfaz124 with SMTP id z124so79414202lfa.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 04:05:46 -0700 (PDT)
In-Reply-To: <56295282.7070202@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2015 12:17 AM, Sergei Shtylyov wrote:

[...]

>> If memory is not yet available
>> when the controller is trying to use the invalid descriptor, the
>> controller will see it and DMA will stop.
>
>     That means leaving RACT=0 and that's what the driver is even doing...
>     Hm, then I don't understand how the error you've described can occur,
> unless we encounter OOM during sh_eth_ring_format()...
>
>> Is it acceptable path to go?
>
>     I'm not seeing a bug in this function, perhaps I'm missing something?

    Nevermind, I'm seeing the bug now -- occurred to me before I went to bed 
yesterday.

>> To achieve zero copy, the driver push the sk_buffs filled with
>> received packet to the netdev core with netif_receive_skb() then
>> netdev_alloc_skb() sk_buffs in the sh_eth_rx(), the poll method of the
>> driver, and update the corresponding descriptor.
>
>> If the allocation failed, it just leave the function, leaving old
>> pointer in the descriptor as is.
>
>     Yes, but note that it also leaves RACT=0, which basically means an invalid
> descriptor, encountering which the reception should just stop.

    The problem is that the first loop has no way of identifying the bad 
descriptors. Looks like we only can fix that by checking rx_skbuff[entry] for 
NULL.

MBR, Sergei
