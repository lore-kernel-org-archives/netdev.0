From: Ben Greear <greearb@candelatech.com>
Subject: =?UTF-8?Q?Re:_[PATCH_3.2_085/115]_veth:_don=e2=80=99t_modify_ip=5fs?=
 =?UTF-8?Q?ummed;_doing_so_treats_packets_with_bad_checksums_as_good.?=
Date: Wed, 27 Apr 2016 17:14:44 -0700
Message-ID: <572155F4.10405@candelatech.com>
References: <lsq.1461711744.699003961@decadent.org.uk>
 <5720E1F0.9010203@candelatech.com> <1461780469.5102.0.camel@decadent.org.uk>
 <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Cong Wang <cwang@twopensource.com>, netdev@vger.kernel.org,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	xiyou.wangcong@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/27/2016 05:00 PM, Hannes Frederic Sowa wrote:
> Hi Ben,
>
> On Wed, Apr 27, 2016, at 20:07, Ben Hutchings wrote:
>> On Wed, 2016-04-27 at 08:59 -0700, Ben Greear wrote:
>>> On 04/26/2016 04:02 PM, Ben Hutchings wrote:
>>>>
>>>> 3.2.80-rc1 review patch.  If anyone has any objections, please let me know.
>>> I would be careful about this.  It causes regressions when sending
>>> PACKET_SOCKET buffers from user-space to veth devices.
>>>
>>> There was a proposed upstream fix for the regression, but it has not gone
>>> into the tree as far as I know.
>>>
>>> http://www.spinics.net/lists/netdev/msg370436.html
>> [...]
>>
>> OK, I'll drop this for now.
>
> The fall out from not having this patch is in my opinion a bigger
> fallout than not having this patch. This patch fixes silent data
> corruption vs. the problem Ben Greear is talking about, which might not
> be that a common usage.
>
> What do others think?
>
> Bye,
> Hannes
>

This patch from Cong Wang seems to fix the regression for me, I think it should be added and
tested in the main tree, and then apply them to stable as a pair.

http://dmz2.candelatech.com/?p=linux-4.4.dev.y/.git;a=commitdiff;h=8153e983c0e5eba1aafe1fc296248ed2a553f1ac;hp=454b07405d694dad52e7f41af5816eed0190da8a



diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index da1ae0e..f8cc758 100644 (file)
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1926,6 +1926,7 @@ retry:
                 goto out_unlock;
         }

+       skb->ip_summed = CHECKSUM_UNNECESSARY;
         skb->protocol = proto;
         skb->dev = dev;
         skb->priority = sk->sk_priority;
@@ -2352,6 +2353,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,

         ph.raw = frame;

+       skb->ip_summed = CHECKSUM_UNNECESSARY;
         skb->protocol = proto;
         skb->dev = dev;
         skb->priority = po->sk.sk_priority;
@@ -2776,6 +2778,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
                 goto out_free;
         }

+       skb->ip_summed = CHECKSUM_UNNECESSARY;
         skb->protocol = proto;
         skb->dev = dev;
         skb->priority = sk->sk_priority;

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
