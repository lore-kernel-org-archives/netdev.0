From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: problem with IPoA (CLIP),  NAT, and VLANS
Date: Wed, 18 Feb 2009 18:47:57 +0100
Message-ID: <499C49CD.3000709@hiramoto.org>
References: <20090217231255.GA3389@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060407070905020601030105"
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20090217231255.GA3389@ami.dom.local>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060407070905020601030105
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote:
> Karl Hiramoto wrote, On 02/17/2009 01:53 PM:
>
>   
>> Jarek Poplawski wrote:
>>     
>>> On Tue, Feb 17, 2009 at 12:49:07PM +0100, Karl Hiramoto wrote:
>>> ...
>>>   
>>>       
>>>> A side note:  so far the original patch i sent works in all cases i have
>>>> tested, but fails with tcpdump.   I suspect its because the skb gets cloned.
>>>>     
>>>>         
>>> If there is something readable from this tcpdump, it should be helpful
>>> to see a packet for working and non-working case during such ping
>>> (with -nXX option).
>>> Jarek P.
>>>   
>>>       
>> Note:  I have the patches i sent applied,  plus the  "skb->mac_header -=
>> VLAN_HLEN;"   patch from Jarek on 2.6.28.4
>>
>> Doing a tcpdump simultaneously  on the atm and eth0.1 on the linux router.
>>     
>
> Nice job. Since tcpdump sees corrupted data, and we don't know if it's
> before or after hitting the driver I'd suggest to try full skb_copy()
> yet. So could you try if with your patch + the patch below tcpdump
> still breaks these things?
>
> BTW, I wonder what IXP400 config options do you use (especially
> CONFIG_IXP400_ETH_SKB_RECYCLE)?
>
> Jarek P.

Thanks for the replies.  Jarek, the last debugging patch you sent did
not work.  It did give me a good hint though.  The attached patch in for
AF_PACKET   receive in the when tcpdump is active and which calls
skb_clone() did fix my issue.


CONFIG_IXP400_ETH_SKB_RECYCLE does not exist in the code i have..  From
what i downloaded from intel,  i stripped out all the stuff that is not
having to do with ATM.  The functionalities of ixp4xx_qmgr ixp4xx_npe
and ixp4xx_eth  are now in the mainline kernel.    Ideally it would be
nice to get what this library does with the atm hardware into the
mainline, however the code in it's current state would not meet kernel
standards, and is quite a mess.


But yes,  the skb->data is   recycled  in a memory pool,   and i think i
noticed a few times packets that were corrupt, were really pointing to
old recycled packets.   I haven't confirmed this yet though.


I did eliminate the first  patch i sent 
http://lkml.org/lkml/2009/2/16/163    to  __vlan_put_tag()

And now only use the patch Jarek sent:  http://lkml.org/lkml/2009/2/17/104

Now i don't have any problems with the vlan tags after changing my atm
driver to do skb_reserve() like:

skb = dev_alloc_skb(size + NET_SKB_PAD);

skb_reserve(skb, NET_SKB_PAD);


So something with my driver causes skb_clone() to corrupt the packet
but  calling skb_copy() instead  keeps everything working.   There are
definitely other cases where skb_clone() is called so really have to fix
this in the atm_dev, but not really sure at the moment where to look next.


Thanks.
--
Karl



--------------060407070905020601030105
Content-Type: text/plain;
 name="tcpdump-fix-hack.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tcpdump-fix-hack.patch"

diff -Naurp linux-2.6.28.4.a/net/packet/af_packet.c linux-2.6.28.4.b/net/packet/af_packet.c
--- linux-2.6.28.4.a/net/packet/af_packet.c	2009-02-06 22:47:45.000000000 +0100
+++ linux-2.6.28.4.b/net/packet/af_packet.c	2009-02-18 16:10:08.000000000 +0100
@@ -524,7 +524,7 @@ static int packet_rcv(struct sk_buff *sk
 		goto drop_n_acct;
 
 	if (skb_shared(skb)) {
-		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
+		struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
 		if (nskb == NULL)
 			goto drop_n_acct;
 

--------------060407070905020601030105--
