From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next v2 2/3] bonding: support QinQ for bond arp
 interval
Date: Tue, 18 Mar 2014 20:27:42 +0100
Message-ID: <20140318192742.GB6430@redhat.com>
References: <1395139433-19576-1-git-send-email-dingtianhong@huawei.com>
 <1395139433-19576-3-git-send-email-dingtianhong@huawei.com>
 <20140318120558.GA6430@redhat.com>
 <7072.1395165598@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Ding Tianhong <dingtianhong@huawei.com>, andy@greyhouse.net,
	kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757861AbaCRT2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 15:28:00 -0400
Content-Disposition: inline
In-Reply-To: <7072.1395165598@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 18, 2014 at 10:59:58AM -0700, Jay Vosburgh wrote:
>Veaceslav Falico <vfalico@redhat.com> wrote:
>
>>On Tue, Mar 18, 2014 at 06:43:52PM +0800, Ding Tianhong wrote:
>>...snip...
>>>-	if (vlan_id) {
>>>-		skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
>>>+	if (outer->vlan_id) {
>>>+		if (inner->vlan_id) {
>>>+			pr_debug("inner tag: proto %X vid %X\n",
>>>+				 ntohs(inner->vlan_proto), inner->vlan_id);
>>>+			skb = __vlan_put_tag(skb, inner->vlan_proto, inner->vlan_id);
>>>+			if (!skb) {
>>>+				pr_err("failed to insert inner VLAN tag\n");
>>>+				return;
>>>+			}
>>>+		}
>>>+
>>>+		pr_debug("outer reg: proto %X vid %X\n",
>>>+			 ntohs(outer->vlan_proto), outer->vlan_id);
>>>+		skb = vlan_put_tag(skb, outer->vlan_proto, outer->vlan_id);
>>
>>If I read correctly then the inner->vlan_proto will always be ETH_P_8021AD,
>>whilst the outer will also always be ETH_P_8021Q. So I think it'd be a lot
>>easier (and more readable) to just pass 2 vlan ids, and set those protos
>>statically - that will save you from adding that new function to vlan core,
>>fro madding a new struct that you've added here and make it several lines
>>less.
>
>	Do you mean that the outer will always be 8021AD and the inner
>8021Q?  The inner/outer terminology is making my brain hurt, since the
>ip commands to configure them look backwards to me.  I think of it as
>the outer tag is the first one sequentially in the ethernet header, and
>the inner tag is second in the header.

Yep, like that. You're right, the outer is the first, the inner is the
second. I always thought about vlans as some type of "encapsulation", with
vlan over vlan over packet meaning "packet encapsulated in an vlan,
encapsulated in a vlan", so the outer and inner vlans make sense for me :).
Though I understand this example isn't technically completely correct.

>
>	Anyway, in the past, I've seen configurations with 802.1q VLANs
>nested such that the inner and outer tags were both 802.1q 0x8100
>ethertype, so I'm not sure that hard-coding these is necessarily a good
>idea.

Yeah, you're right, seems like there are a lot of non-IEEE hacks out there,
so it's definitely better to use the proto specified by the user.

>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
>
