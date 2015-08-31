From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Remove VRF change to udp_sendmsg
Date: Mon, 31 Aug 2015 14:44:46 -0600
Message-ID: <55E4BCBE.4070900@cumulusnetworks.com>
References: <1441038580-44164-1-git-send-email-dsa@cumulusnetworks.com>
 <20150831.124410.99199729741650263.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	tom@herbertland.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35741 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbbHaUo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 16:44:56 -0400
Received: by iog7 with SMTP id 7so48914716iog.2
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 13:44:55 -0700 (PDT)
In-Reply-To: <20150831.124410.99199729741650263.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/31/15 1:44 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Mon, 31 Aug 2015 09:29:40 -0700
>
>> Remove the VRF change in udp_sendmsg to set the source address. The VRF
>> driver already has access to the packet on the TX path via the dst. It
>> can be used to update the source address in the header.
>>
>> Update function based on OVS.
>>
>> Cc: Tom Herbert <tom@herbertland.com>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> This is worse.
>
> You have the source address in the VRF driver's output routine in
> fl4.saddr, just use it as-is.

The original saddr code in vrf_xmit was just wrong. It should not have 
been there and was a leftover from early development days.

The saddr needs to be set in the dst output function (vrf_output) as I 
did in this patch otherwise the packet hits the tcpdump tap with 
potentially no source address.

>
> You're adding even more route lookups, at least the existing code
> just walks the device address less which is often cheaper than
> a full-blown route lookup.
>

TCP (and connected sockets) do not hit this lookup in vrf_output.

If anything I should be going straight to fib_table_lookup in the VRF 
driver for this new lookup to get the source address. It knows the exact 
table that should be used and hence can avoid the rules walk + local 
table miss which happens using the ip_route_xxxxx functions as well as 
the rth lookup/create which is not needed here.

Opinions before I work on another version?

David
