From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation
 Needed message
Date: Mon, 04 Jun 2007 12:32:49 +0800
Message-ID: <466395F1.7060003@cn.fujitsu.com>
References: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au> <46635F39.2090009@cn.fujitsu.com> <20070604025528.GA27750@gondor.apana.org.au> <46638F2D.90608@cn.fujitsu.com> <20070604041406.GA28263@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:57711 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751471AbXFDEiy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 00:38:54 -0400
In-Reply-To: <20070604041406.GA28263@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Mon, Jun 04, 2007 at 12:03:57PM +0800, Wei Yongjun wrote:
>   
>> So I want to know how the route announce a MTU larger then 576, such as 
>> 1280? RFC says ICMP error message return as much as we can without 
>> exceeding 576 bytes.
>>     
>
> I think there is a misunderstanding here.  The RFC is talking about
> how much of the payload may be included in the ICMP packet.  It is
> not talking about the length field in the original IP header.  That
> must be left untouched.
>
>   
As you said, the RFC is talking about the payload of ICMP packet, it's 
not greater then 576, if router announce a MTU larger then 1280, the 
original IP header must be a size of 704? The format of ICMP message is 
like this:
  IPv4 header
  ICMP header
  payload
>> And ipv4 router alaways return as a packet size 576 because of this.
>> If MTU is greater then 576, HOST will used "mtu = guess_mtu(old_mtu)" to 
>> get a MTU. Method of send ICMP Fragmentation Needed message is 
>> difference from receive,
>>     
>
> Which router is doing that?
>
>
>   
The latest kernel 2.6.21.3 also doing so. The rule to send ICMP message 
limit this.
Ref to net/ipv4/icmp.c
line 433 void icmp_send(struct sk_buff *skb_in, int type, int code, 
__be32 info)
line 434 {
...
line 572    /* RFC says return as much as we can without exceeding 576 
bytes. */
line 573
line 574    room = dst_mtu(&rt->u.dst);
line 575    if (room > 576)
line 576        room = 576;
line 577    room -= sizeof(struct iphdr) + icmp_param.replyopts.optlen;
line 578    room -= sizeof(struct icmphdr);
line 579
line 560    icmp_param.data_len = skb_in->len - icmp_param.offset;
line 561    if (icmp_param.data_len > room)
line 562        icmp_param.data_len = room;
line 563    icmp_param.head_len = sizeof(struct icmphdr);

line 576 do this.

-- 

A new email address of FJWAN is launched from Apr.1 2007.
The updated address is: yjwei@cn.fujitsu.com 
--------------------------------------------------
Wei Yongjun
Development Dept.I
Nanjing Fujitsu Nanda Software Tech. Co., Ltd.(FNST)
8/F., Civil Defense Building, No.189 Guangzhou Road,
Nanjing, 210029, China
TEL: +86+25-86630523-858
COINS: 79955-858
FAX: +86+25-83317685
MAIL: yjwei@cn.fujitsu.com
--------------------------------------------------

