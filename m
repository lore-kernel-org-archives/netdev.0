From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [net-next] af_packet: Use virtio_net_hdr_to_skb().
Date: Fri, 18 Nov 2016 14:58:14 -0800
Message-ID: <9BDB4BB5-F93E-4097-9607-5F28F96BA61E@ovn.org>
References: <1479348402-126248-1-git-send-email-jarno@ovn.org> <20161118.113527.2164504813195182869.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35210 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752301AbcKRW6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 17:58:18 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so21795562pga.2
        for <netdev@vger.kernel.org>; Fri, 18 Nov 2016 14:58:18 -0800 (PST)
In-Reply-To: <20161118.113527.2164504813195182869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for my transgressions and wasting your time. I’ll send a v2 in a moment.

  Jarno
 
> On Nov 18, 2016, at 8:35 AM, David Miller <davem@davemloft.net> wrote:
> 
> From: Jarno Rajahalme <jarno@ovn.org>
> Date: Wed, 16 Nov 2016 18:06:42 -0800
> 
>> Use the common virtio_net_hdr_to_skb() instead of open coding it.
>> Other call sites were changed by commit fd2a0437dc, but this one was
>> missed, maybe because it is split in two parts of the source code.
>> 
>> Also fix other call sites to be more uniform.
>> 
>> Fixes: fd2a0437dc ("virtio_net: introduce virtio_net_hdr_{from,to}_skb")
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> 
> This patch is doing many more things that just this.
> 
> Do not mix unrelated changes together:
> 
>> @@ -821,9 +821,8 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>> 		if (iov_iter_count(iter) < vnet_hdr_len)
>> 			return -EINVAL;
>> 
>> -		ret = virtio_net_hdr_from_skb(skb, &vnet_hdr,
>> -					      macvtap_is_little_endian(q));
>> -		if (ret)
>> +		if (virtio_net_hdr_from_skb(skb, &vnet_hdr,
>> +					    macvtap_is_little_endian(q)))
>> 			BUG();
>> 
>> 		if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter) !=
> 
> This has nothing to do with modifying code to use vrtio_net_hdr_to_skb(), it
> doesn't belong in this patch.
> 
>> @@ -1361,15 +1360,12 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>> 	}
>> 
>> 	if (vnet_hdr_sz) {
>> -		struct virtio_net_hdr gso = { 0 }; /* no info leak */
>> -		int ret;
>> -
>> +		struct virtio_net_hdr gso;
> 
> This is _extremely_ opaque.  The initializer is trying to prevent kernel memory
> info leaks onto the network or into user space.
> 
> Maybe this transformation is valid but:
> 
> 1) YOU DON'T EVEN MENTION IT IN YOUR COMMIT MESSAGE.
> 
> 2) It's unrelated to this specific change, therefore it belongs in
>   a separate change.
> 
> 3) You don't explain that it is a valid transformation, not why.
> 
> It is extremely disappointing to catch unrelated, potentially far
> reaching things embedded in a patch when I review it.
> 
> Please do not ever do this.
> 
>> @@ -98,4 +98,4 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
>> 	return 0;
>> }
>> 
>> -#endif /* _LINUX_VIRTIO_BYTEORDER */
>> +#endif /* _LINUX_VIRTIO_NET_H */
> 
> Another unrelated change.
> 
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 11db0d6..09abb88 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1971,8 +1971,6 @@ static unsigned int run_filter(struct sk_buff *skb,
>> static int __packet_rcv_vnet(const struct sk_buff *skb,
>> 			     struct virtio_net_hdr *vnet_hdr)
>> {
>> -	*vnet_hdr = (const struct virtio_net_hdr) { 0 };
>> -
> 
> There is no way this belongs in this patch, and again you do not explain
> why removing this initializer is valid.
