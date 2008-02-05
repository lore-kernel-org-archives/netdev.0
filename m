From: Kostya B <bkostya@hotmail.com>
Subject: RE: LRO ip_summed
Date: Tue, 5 Feb 2008 08:56:17 +0000
Message-ID: <BAY121-W3321045858D4A665892759B62C0@phx.gbl>
References: <BAY121-W366A043ECDC160494B1EFAB6320@phx.gbl>
 <200802041014.23989.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s41.bay0.hotmail.com ([65.54.246.177]:1758 "EHLO
	bay0-omc2-s41.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755852AbYBEI4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 03:56:20 -0500
In-Reply-To: <200802041014.23989.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1. Let's assume a driver which has a HW csum capability, however it has a privilege to assign any value for ip_summed.
For example the driver assigns "unnecessary" for most of the packets, however it fails to verify the packets less than 96 bytes ("checksum_none").
Now, the LRO will aggregate all of them and assign the value "used for all aggregated packets" - that is wrong, 

Of course, it is possible to avoid that situation in driver, however [proposal] from the point of view of the *generic* LRO it could be better to check each newly aggregated skb whether it has the same ip_summed as the first one (preserve coherency). Thus, there is no need to keep ip_summed field in the  struct net_lro_mgr.

2. Now, when a skb could not be aggregated (modes: aggregating SKBs) I think where's no need to override its original ip_summed (see "out" label of __lro_proc_skb()) The comment says  "Original SKB has to be posted to stack". I would be wrong, but I don't get the reason to possible change of ip_summed.

Regards,
- Kostya

----------------------------------------
> From: ossthema@de.ibm.com
> To: bkostya@hotmail.com
> Subject: Re: LRO ip_summed
> Date: Mon, 4 Feb 2008 10:14:23 +0100
> CC: netdev@vger.kernel.org
> 
> On Sunday 03 February 2008 10:48, Kostya B wrote:
>> 
>> Hi,
>> 
>> The mail is related to the way LRO manipulates the ip_summed value. Could anybody (author) explain why to overwrite the original value of skb->ip_summed, when it's processing by __lro_proc_skb ?
>> E.g. in out: label
>> 
>> Why not to preserve the coherency of csum status of each incoming to LRO packet, the same way the IP defragmentation does? That means - all skb in descriptor have the same value of ip_summed.
>> 
> 
> Hi,
> 
> I'm not sure if I understand your proposal correctly.
> Currently the driver decides via the struct net_lro_mgr
> a) which ip_summed value will be used for all aggregated packets
> b) which one to use for those packets that can not be aggregated
> 
> to a) this one should always be the same. The driver knows whether its HW is
>       capable of performing ip checksum checking for this kind of traffic (TCP)
> 
> There are two modes: aggregating SKBs or aggregating fragments. 
> When fragments are aggregated, there is no SKB with a filled ip_summed available.
> 
> Please outline which parts of which mode you suggest to change.
> 
> Regards,
> Jan-Bernd
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today it's FREE!
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/
