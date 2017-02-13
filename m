From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Linux HSR driver question
Date: Mon, 13 Feb 2017 13:05:57 -0500
Message-ID: <58A1F585.8080508@ti.com>
References: <589CD1F5.1060104@ti.com> <58A1D312.2030003@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
To: Arvid Brodin <arvid.brodin@alten.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:36944 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752127AbdBMSGF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 13:06:05 -0500
In-Reply-To: <58A1D312.2030003@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2017 10:38 AM, Arvid Brodin wrote:
> On 2017-02-09 21:32, Murali Karicheri wrote:
>> Hi Arvid,
>>
>> While I work to add PRP support to the existing Linux HSR driver, I came across
>> a piece of code related to prune node function. The hsr_device.c adds the 
>> prune timer in hsr_dev_finalize() by calling
>>
>> add_timer(&hsr->prune_timer);
>>
>> But it is never restarted in hsr_prune_nodes(). Is that intentional or a bug?
>> I tried adding add_timer(&hsr->prune_timer) at the end of  hsr_prune_nodes(),
>> but then a iperf test stops with no traffic across the hsr interface and it
>> never recovers. I have to delete the interface and create it again to recover.
>> Is that the reason, it is currently disabled?
>>
> 
> Hi Murali,
> 
> Sorry I don't remember the details here. I do know I tested that a node that had
> been unplugged for two minutes was forgotten by the other nodes, so this has 
> worked at some time in the past, at least. :)
> 
> 
Arvid,

Thanks for the response!

But from the code point of view, I understand that the hsr_prune_nodes() is the
function responsible for checking the timein of nodes from the node list and 
removing nodes where no frames received over last HSR_NODE_FORGET_TIME. Right?
I don't see how that can work without the prune timer running? Am I correct? 

Also the node list is protected by an RCU lock. However, I don't see synchronization
call to provide exclusive access to updater (add/delete) inside hsr_add_node(), 
hsr_prune_nodes() and hsr_handle_sup_frame(). Am I missing something?

I am running into an issue in my code that have added support for PRP handling
where the SKB destination MAC address (from Master node to remote node packet)
gets corrupted with Remote Node's MAC B address while the code is inside
hsr_forward_do(). I see this when I do an iperf for about 5 minutes. I plan
to do a long term iperf test on the original code as well. From my debug
so far, this address is correctly pointing to Remote Node's A address when the 
SKB is received at hsr_dev_xmit(), but inside, hsr_forward_do(), the SKB 
MAC h_dest changes to Node's B address and when SKB gets forwarded to slave's
interface in hsr_xmit() I see a WARN_ONCE

	node_dst = find_node_by_AddrA(&port->hsr->node_db, eth_hdr(skb)->h_dest);
	if (!node_dst) {
		WARN_ONCE(1, "%s: Unknown node\n", __func__);
		return;
	}

My understanding is that, the code replaces Remote Node's B address in SKB mac
h_source with that of A address before SKB is delivered to masters interface and
to the stack. When SKB is received from the stack for remote node, in hsr_xmit(),
h_dest in replaced to match the remote node's interface MAC B address. So the
above WARN_ONCE should never appear. Is the understanding right?

Also have you ever tested the HSR driver with same MAC address configured on slave A
and B's interfaces? AFAIK, That is how this is expected to be used on industrial
networks. I haven't tried this, but just want to check with you if the driver is
tested with same MAC address configured on both slave's interfaces. Could you 
repond please?

-- 
Murali Karicheri
Linux Kernel
