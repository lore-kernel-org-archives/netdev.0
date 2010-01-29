From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH] skbuff: align sk_buff::cb to 64 bit
Date: Sat, 30 Jan 2010 00:14:02 +0100
Message-ID: <4B636BBA.8050300@openwrt.org>
References: <4B635CA1.8070803@openwrt.org> <4B63643B.3070400@caviumnetworks.com> <20100129225404.GA12440@laped.iglesias.mooo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Daney <ddaney@caviumnetworks.com>, netdev@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:39288 "EHLO ds10.nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752903Ab0A2XOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 18:14:06 -0500
In-Reply-To: <20100129225404.GA12440@laped.iglesias.mooo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-01-29 11:54 PM, Edgar E. Iglesias wrote:
> On Fri, Jan 29, 2010 at 02:42:03PM -0800, David Daney wrote:
>> Felix Fietkau wrote:
>> > The alignment requirement for 64-bit load/store instructions on ARM is
>> > implementation defined. Some CPUs (such as Marvell Feroceon) do not
>> > generate an exception, if such an instruction is executed with an
>> > address that is not 64 bit aligned. 
>> > In such a case, the Feroceon corrupts adjacent memory, which showed up
>> > in my tests as a crash in the rx path of ath9k that only occured with
>> > CONFIG_XFRM set. This crash happened, because the first field of the
>> > mac80211 rx status info in the cb is an u64, and changing it corrupted
>> > the skb->sp field.
>> > 
>> > Signed-off-by: Felix Fietkau <nbd@openwrt.org>
>> > Cc: stable@kernel.org
>> > ---
>> > --- a/include/linux/skbuff.h
>> > +++ b/include/linux/skbuff.h
>> > @@ -329,7 +329,7 @@ struct sk_buff {
>> >  	 * want to keep them across layers you have to do a skb_clone()
>> >  	 * first. This is owned by whoever has the skb queued ATM.
>> >  	 */
>> > -	char			cb[48];
>> > +	char			cb[48] __attribute__((aligned(8)));
>> >  
> I'd guess the problem is with the accessor to the thing.
> something in the opaque cb ptr its beeing accessed wroingly causing
> overwrites.
Nope, the problem is not with the accessor, I verified that. The start
address of the datastructure that gets put into skb->cb correctly points
at the start of the cb, and it is only aligned to 4 byte, not 8. Also,
this issue only happens on CPUs that do not throw an unaligned exception
for this instruction.

- Felix
