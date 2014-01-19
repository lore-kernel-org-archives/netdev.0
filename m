From: "gregory hoggarth" <gregory.hoggarth@alliedtelesis.co.nz>
Subject: Re: Linux kernel patch: elide fib_validate_source() completely
 when possible - bad side effect?
Date: Mon, 20 Jan 2014 09:49:56 +1300
Message-ID: <52DCF1440200005D000477FD@gwia2.atlnz.lc>
References: <52D945400200005D00047758@gwia2.atlnz.lc>
 <alpine.LFD.2.11.1401170953370.1827@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Julian Anastasov" <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.alliedtelesis.co.nz ([202.36.163.21]:44277 "EHLO
	gate.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbaASUuI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 15:50:08 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	by gate.alliedtelesis.co.nz (Postfix) with ESMTPS id 24D6E6110C
	for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 09:50:03 +1300 (NZDT)
In-Reply-To: <alpine.LFD.2.11.1401170953370.1827@ja.home.ssi.bg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian,
 
>>> Julian Anastasov <ja@ssi.bg> 17/1/14 09:24 PM >>> 
> 
> 	Hello,
> 
> On Fri, 17 Jan 2014, gregory hoggarth wrote:
> 
>> Hi,
>> 
>> I work for Allied Telesis, a company that manufactures and sells routers and 
>> switches.
>> 
>> Earlier in the year we upgraded the linux kernel on our L3 switch firmware to 
>> v3.6.2 which includes this patch. Our testers have picked up a change in 
>> behaviour which I have traced back to this patch and I'd like to get comments 
>> on whether this is a bug or not.
>> 
>> We found that in a configuration with a device under test (DUT) that has an 
>> IP address 192.168.0.1 / 24, sending an ICMP echo request with a source IP 
>> address of 192.168.0.255 will now be accepted by the DUT, which will send an 
>> ICMP echo reply back to the 192.168.0.255 address with a broadcast MAC 
>> address of FFFF.FFFF.FFFF, meaning any other devices in the L2 domain will 
>> pick up and process the ICMP reply.
> 
> ...
> 
>> Initially we were thinking that a device configured with 192.168.0.255 / 23 
>> sending a ping to 192.168.0.1 / 24 should expect to get a reply, even 
>> though this is somewhat of a misconfiguration in that the subnets aren't 
>> matching and that some things may not work properly. For example ping from 
>> a device with IP address 192.168.0.254 would behave correctly, so it seemed 
>> correct that a ping from 192.168.0.255 should also work properly. However 
>> it appears that some other part of the kernel is detecting that the echo 
>> reply packet sent by the DUT has a destination IP address of the subnet 
>> broadcast, so instead of sending it with a unicast MAC address it sends it 
>> with the broadcast MAC address, which means all other devices on the subnet 
>> would process the ICMP echo reply. This therefore makes it seem like the 
>> ICMP echo request should have been dropped in the first place.
>>
>> The patch added the "if (!r && !fib_num_tclassid_users)" check to 
>> fib_validate_source, which for our devices evaluates to true, hence 
>> returning early and the source address check inside __fib_validate_source 
>> is not carried out.
>> 
>> 
>> Does anyone have comments as to what the correct behaviour should be in 
>> this case, and whether this is an unexpected side-effect from the patch or 
>> not?
>
>	It seems only __fib_validate_source can reject all kind
> of broadcast addresses in saddr. ip_route_input_slow() rejects
> only the well known broadcasts. Without rp_filter may be we
> can at least drop attempts to send replies back to broadcast
> addresses? For example, checking result of ip_route_output_key() in
> icmp_reply():
>
>	if (rt->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
>		=> ip_rt_put()
>
>	For icmp_send() in icmp_route_lookup() ?
>
>	For TCP in inet_csk_route_req() ?
>
>	I did not checked all places...
>
> Regards
>
> --
> Julian Anastasov <ja@ssi.bg>

Thank you for your reply.

While I think your solution may work, isn't the proper approach to drop these 
rogue packets, rather than wasting CPU and other resources processing them, 
and then beginning to craft responses which are in turn dropped?

Also seems better to drop the initial rogue packet, as that should cover all 
(?) different types of packets, rather than having to add small patches into 
ICMP, TCP and any other places that may need it.


So my question really is was the original patch correct and there's something
wrong with our device configuration, or is this an overlooked / untested side-
effect from that patch that as a result means the patch should be re-worked?


Thanks,
Greg
