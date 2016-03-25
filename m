From: Ben Greear <greearb@candelatech.com>
Subject: Re: veth regression with =?UTF-8?B?ImRvbuKAmXQgbW9kaWZ5IGlwX3N1bQ==?=
 =?UTF-8?B?bWVkOyBkb2luZyBzbyB0cmVhdHMgcGFja2V0cyB3aXRoIGJhZCBjaGVja3N1bXM=?=
 =?UTF-8?B?IGFzIGdvb2QuIg==?=
Date: Fri, 25 Mar 2016 09:10:58 -0700
Message-ID: <56F56312.4080408@candelatech.com>
References: <56F463D6.7080406@candelatech.com>	<CAM_iQpWv_iP1ZtsRQT0YsztMrf6rdaXN2V57PUu5oBe5kR56AQ@mail.gmail.com>	<56F4810A.9060904@candelatech.com>	<56F49036.8050902@candelatech.com>	<56F490B2.3090603@candelatech.com>	<CAKUBDd9TjFTvXSEL=+J02PVndNG-gcrMOpRo_MFp4J-oOnLrvQ@mail.gmail.com>	<56F4BFF1.8010806@candelatech.com>	<CAM_iQpUaBD-HmHVAcEBCRw38PbecjYk2to+DO9TNkLY93u2_NA@mail.gmail.com>	<56F4C8FD.7030907@candelatech.com> <CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vijay Pandurangan <vijayp@vijayp.ca>,
	netdev <netdev@vger.kernel.org>, Evan Jones <ej@evanjones.ca>,
	Cong Wang <cwang@twopensource.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:37913 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbcCYQLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 12:11:00 -0400
In-Reply-To: <CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/24/2016 10:33 PM, Cong Wang wrote:
> On Thu, Mar 24, 2016 at 10:13 PM, Ben Greear <greearb@candelatech.com> wrote:
>>
>>
>> On 03/24/2016 10:06 PM, Cong Wang wrote:
>>>
>>> On Thu, Mar 24, 2016 at 9:34 PM, Ben Greear <greearb@candelatech.com>
>>> wrote:
>>>>
>>>>
>>>>
>>>> On 03/24/2016 06:44 PM, Vijay Pandurangan wrote:
>>>>>
>>>>>
>>>>> Oops, I think my last email didn't go through due to an inadvertent
>>>>> html attachment from my phone mail client.
>>>>>
>>>>> Can you send us a copy of a packet you're sending and/or confirm that
>>>>> the IP and UDP4 checksums are set correctly in the packet?
>>>>>
>>>>> If those are set right, I think we need to read through the networking
>>>>> code again to see why this is broken...
>>>>
>>>>
>>>>
>>>> Wireshark decodes the packet as having no checksum errors.
>>>>
>>>> I think the contents of the packet is correct, but the 'ip_summed'
>>>> field is set incorrectly to 'NONE' when transmitting on a raw packet
>>>> socket.
>>>
>>>
>>> Yeah, these bugs are all due to the different interpretations of
>>> ip_summed on TX path and RX path. I think the following patch
>>> should work, if the comments don't mislead me. Could you give
>>> it a try?
>>>
>>> For the long term, we need to unify the meaning of ip_summed
>>> on TX path and RX path, or at least translate it in skb_scrub_packet().
>>
>>
>> I can test this tomorrow, but I think it will not work.  I'm not sending raw
>> IP frames, I'm sending full ethernet frames.  Socket is PF_PACKET, SOCK_RAW.
>>
>> Your patch may still be useful for others though?
>
> Here we go:
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 1ecfa71..ab66080 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1925,6 +1925,7 @@ static int packet_sendmsg_spkt(struct socket
> *sock, struct msghdr *msg,
>                  goto out_unlock;
>          }
>
> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
>          skb->protocol = proto;
>          skb->dev = dev;
>          skb->priority = sk->sk_priority;
> @@ -2496,6 +2497,7 @@ static int tpacket_fill_skb(struct packet_sock
> *po, struct sk_buff *skb,
>
>          ph.raw = frame;
>
> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
>          skb->protocol = proto;
>          skb->dev = dev;
>          skb->priority = po->sk.sk_priority;
> @@ -2805,6 +2807,7 @@ static struct sk_buff *packet_alloc_skb(struct
> sock *sk, size_t prepad,
>          skb_put(skb, linear);
>          skb->data_len = len - linear;
>          skb->len += len - linear;
> +       skb->ip_summed = CHECKSUM_UNNECESSARY;
>
>          return skb;
>   }

I am suspicious that this will break at least some drivers.  I grepped around
for ip_summed, and found this, for instance:

davicom/dm9000.c

         /* The DM9000 is not smart enough to leave fragmented packets alone. */
         if (dm->ip_summed != ip_summed) {
                 if (ip_summed == CHECKSUM_NONE)
                         iow(dm, DM9000_TCCR, 0);
                 else
                         iow(dm, DM9000_TCCR, TCCR_IP | TCCR_UDP | TCCR_TCP);
                 dm->ip_summed = ip_summed;
         }


It is taking action based on ip_summed == CHECKSUM_NONE, and your change
will probably break that.

I would suggest that we try to make any fix specific only to veth,
at least for now.  A tree-wide audit of drivers is probably required
to safely make the kind of change you propose above.

So, unless you can explain why your change is safe, then I do not plan
to test it.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
