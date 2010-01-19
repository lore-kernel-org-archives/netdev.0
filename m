From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Tue, 19 Jan 2010 00:46:24 -0500
Message-ID: <4B554730.6090000@majjas.com>
References: <4B53906B.2020608@majjas.com> <20100117230531.GC3161@del.dom.local>
 <4B539A0A.2000504@majjas.com> <20100118073018.GA6270@ff.dom.local>
 <4B548C6B.10607@majjas.com> <20100118204658.GC3157@del.dom.local>
 <4B54CB0D.5070604@majjas.com> <20100118212516.GE3157@del.dom.local>
 <4B54D50C.90608@majjas.com> <20100118220814.GG3157@del.dom.local>
 <20100118221747.GH3157@del.dom.local> <4B54E4EF.8080602@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752337Ab0ASFr1@vger.kernel.org>
In-reply-to: <4B54E4EF.8080602@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/18/2010 5:47 PM, Michael Breuer wrote:
> On 1/18/2010 5:17 PM, Jarek Poplawski wrote:
>> On Mon, Jan 18, 2010 at 11:08:14PM +0100, Jarek Poplawski wrote:
>>> Btw, I wonder if you could test it skipping the (HP?) switch?
>> If so, then of course don't forget to try tcpdump on the router.
>>
>> Jarek P.
> Well - no.... but I'm not sure that would show anything.
>
> Setup diagram:
>
> Server->gb switch-> (100mb) wifi router -> devices
>                     |
>               Win7 PC (gb)
>
> The problem does not occur (at least I haven't been able to recreate 
> it) at 100mb, and the wifi router doesn't do 1Gb. I drive the traffic 
> from the win7 PC to the server. I've seen the loss when the only 
> traffic going through the wifi router was ping & dhcp. I've also never 
> seen any loss on a device directly attached to the 1GB switch. I can 
> drive load through the wifi router while driving load from the Win7 
> box, but don't see TX packet loss at all when not doing DHCP 
> RELEASE/RENEW.
>
> As there is no packet loss to devices not involved in the DHCP 
> sequence through the same path, I'm not really sure that the GB switch 
> is implicated.
>
> As I don't have a standalone sniffer, I'm thinking that it might be 
> easier to instrument places where the TX packet could be dropped and 
> see at least whether it's getting to the card.
>
> Given the circumstances of the TX drop, and that it was DHCP traffic 
> while under load that caused the oops rectified with the two patches, 
> I'm thinking that the packet loss is the current manifestation of 
> whatever the underlying problem is. Given the extra hop required to 
> break things, and given that a dhcp release/renew seems to trigger 
> things, I keep coming back to arp logic as being somehow implicated.
>
> If arp is somehow involved, then I'd expect to see manifestations 
> under similar circumstances with other drivers. As the pskb_may_pull 
> patch stopped the crash, perhaps other drivers do suffer packet loss 
> and it's just not been widely noticed or attributed to the kernel - 
> especially if the network topology is a factor. I do know people at 
> large enterprises who have been complaining of what *could* be this 
> same issue, however they're currently blaming their switch vendors. As 
> most traffic is TCP, this is really only noticed by those few places 
> deeply concerned with latency. It's likely something altogether 
> different, but then again, maybe not.
Ok - one last update for a while ...not sure what's next... I put some 
printk's into sky2.c xmit logic - the packets are being sent to the 
card, and the i/o's are completing successfully. So it would seem either 
the switch is dropping the packets, or else the wifi router is. As 
tcpdump doesn't show the packets arriving on the wifi router, I'm 
leaning towards the switch. I ran wireshark on the win7 box to see what 
is coming off the switch. I did notice one thing that's visible to the 
win7 box but is not showing up on the linux wireshark - before every 
successful dhcpoffer, there's an XID message broadcast from the device. 
I'm wondering why I don't see this on the linux side:

The packet is from the mac of the device, dst ff:ff:ff:ff:ff:ff; 
protocol eth:llc... hex packet: ffffffffffff001cccf39ff600060001af810100.

Now I guess I've got some reading to do... I've got no idea what the 
correct application of llc messages would be given my topology :(. I do 
suspect that the llc stuff (or lack thereof under some conditions) is 
causing the switch to fail to forward the dhcpoffer message. As the 
dhcpoffer message is not broadcast, but directed to the remote mac 
address and as that address is not connected directly to the switch, I'm 
guessing that under some conditions whatever tells the switch how to 
find the mac is missing. I'd guess that the wifi router should be 
letting the switch know around the time it forwards the first arp and/or 
DHCP broadcast message from the client... or maybe the linux box should 
be doing something before the offer.

So net-net, as far as my TX packet loss issue, sky2 is in the clear. If 
something on the linux side should be informing the switch about 
something then there may still be an issue. If the wifi router should be 
doing something differently, then it's unfortunately likely a 2.4.37 
kernel issue (That's what dd-wrt is using).
