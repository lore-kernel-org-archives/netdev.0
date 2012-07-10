From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC PATCH] ppp: add support for L2 multihop / tunnel switching
Date: Tue, 10 Jul 2012 10:32:09 +0100
Message-ID: <4FFBF699.8020900@katalix.com>
References: <20120708214930.GI19462@kvack.org> <4FFAC5EF.6030003@katalix.com> <20120709141511.GL19462@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20120709141511.GL19462@kvack.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/07/12 15:15, Benjamin LaHaise wrote:
> On Mon, Jul 09, 2012 at 12:52:15PM +0100, James Chapman wrote:
>> As a mechanism for switching PPP interfaces together, this patch is
>> good. For L2TP though, I prefer an approach that would be applicable for
>> all L2TP traffic types, not just PPP.
> 
> *nod*  This seems like a reasonable consideration.
> 
>> L2TP supports many different pseudowire types, and this patch will only
>> be useful for tunnel switching between PPP pseudowires. Whereas if we
>> implement it within the L2TP core, rather than in the PPP code, we would
>> get switching between all pseudowire types. If we add this patch and
>> then subsequently add switching between other pseudowires in the L2TP
>> core (which we're likely to want to do), then we're left with two
>> different interfaces for doing L2TP tunnel switching in the kernel.
> 
> At least for ethernet pseudowires, it can already be implemented by using 
> an ethernet bridge device.  Besides PPP and ethernet pseudowires, what 
> other types are supported at present by the L2TP core?

Only those two at the moment, but others (ATM etc) can be added if and
when there is demand. To do this at an L2TP level avoids using two
linked PPP interfaces in the case of PPP and two bridged l2tpeth
interfaces in the case of ethernet. I envisage a new L2TP netlink API to
join the datapaths of two L2TP sessions together with no devices being
needed. It would work for all L2TP session types, now and in the future.

>>> The reasoning behind using dev_queue_xmit() rather than outputting directly 
>>> to another PPP channel is to enable the use of the traffic shaping and 
>>> queuing features of the kernel on multihop sessions.
>>
>> I'm not sure about using a pseudo packet type to do this. For L2TP, it
>> would seem better to add netfilter/tc support for L2TP data packets,
>> which would let people add rules for, say, traffic in L2TP tunnel x /
>> session y. This would avoid the need for ETH_P_PPP and you could then
>> output directly to the ppp channel.
> 
> The downside of an L2TP specific method is that all the mechanisms need to 
> be duplicated, resulting in a much higher maintenance overhead for the 
> code and functionality, not to mention all the tool changes to go along 
> with that.

Could the same argument be applied to other protocols which have
netfilter/tc support already? Adding support for L2TP would seem
consistent with other protocol implementations. It would also mean that
the same rules would work for all L2TP session types.

> As for the pseudo packet type, it may indeed be better to avoid the pseudo 
> packet type for known PPP packet types.  One of the benefits of going the 
> network device route is that it makes it much easier to implement additional 
> functionality like lawful intercept, which would be yet more functionality 
> that would have to be implemented if the mechanism is L2TP specific.  The 
> pseudo packet type would still be needed for forwarding PPP frames that the 
> kernel doesn't know about (all the *CP packet types and MLPPP come to mind)
> 
> I had thought about doing the packet forwarding in a manner similar to the 
> bridging code -- that is, as a pseudowire bridge in the network core that 
> only works between 2 devices.  That approach might work better for L2TP, as 
> it would be able to pass packets of any type between the 2 endpoints.

For L2TP, I think it should be possible to avoid having devices for
switched L2TP sessions.

> 
> 		-ben
> 
-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development


