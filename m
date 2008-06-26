From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH 4/4] lguest: Use GSO/IFF_VNET_HDR extensions on tun/tap
Date: Thu, 26 Jun 2008 13:16:25 -0500
Message-ID: <4863DCF9.20100@codemonkey.ws>
References: <200806260028.07883.rusty@rustcorp.com.au> <200806260032.12359.rusty__46755.7742762894$1214404667$gmane$org@rustcorp.com.au> <48629766.4040905@codemonkey.ws> <200806261440.43984.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>, markmc@redhat.com,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:32949 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977AbYFZSQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 14:16:51 -0400
Received: by wx-out-0506.google.com with SMTP id h29so119582wxd.4
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 11:16:48 -0700 (PDT)
In-Reply-To: <200806261440.43984.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Thursday 26 June 2008 05:07:18 Anthony Liguori wrote:
>   
>> Rusty Russell wrote:
>>     
>>> @@ -1563,6 +1561,16 @@ static void setup_tun_net(char *arg)
>>>  	/* Tell Guest what MAC address to use. */
>>>  	add_feature(dev, VIRTIO_NET_F_MAC);
>>>  	add_feature(dev, VIRTIO_F_NOTIFY_ON_EMPTY);
>>> +	/* Expect Guest to handle everything except UFO */
>>> +	add_feature(dev, VIRTIO_NET_F_CSUM);
>>>       
>> You're setting this feature twice.
>>     
>
> Hmm, not in the version here?
>   

Sorry, misread apparently.

>>> +	add_feature(dev, VIRTIO_NET_F_GUEST_CSUM);
>>>       
>> You set this feature, but I never see the virtio-net driver acknowledge
>> the feature.

I still don't see GUEST_CSUM ever get referenced in virtio_net.c.  
What's the intention of this feature bit?  Could I be missing a 
virtio_net patch?  I'm using the latest bits in Linus' tree.

>>   Curiously, my implementation with KVM is struggling
>> because UDP packet checksums are not correct so the DHCP client is
>> ignoring them.  If I disable CSUM offload, things it works fine (using
>> the virtio-net header).  The problem is only host=>guest, guest=>host is
>> fine.
>>     
>
> OK, found this: wrong args to skb_partial_csum_set.  It was found by Mark 
> McLoughlin before, I just lost the fix when I extracted this into a separate 
> patch.  I chose to move the call to skb_partial_csum_set(), rather than use 
> his fix (which assumed a tap not tun device).
>   

This still doesn't fix the problem.  I can manually assign an IP address 
and even do netperf runs but I cannot get a dhcp address (dhclient is 
picky about the udp csum).  Also, the RX performance is so low that I'm 
sure a ton of packets are getting dropped.  However, this patchset is 
extremely promising, here are the results with KVM for TX:

w/o gso
[  3]  0.0-10.0 sec    593 MBytes    498 Mbits/sec

w/gso
[  5]  0.0-10.0 sec  1.86 GBytes  1.60 Gbits/sec

So that's a huge increase.  Unfortunately, RX drops from 1.04 Gbits/sec 
to only a few hundred Kbit/sec.  I'm pretty sure this is the 
checksumming issue.

Also, when I exit KVM, QEMU zombies and I notice:

Message from syslogd@squirrel at Jun 26 13:02:07 ...
 kernel: unregister_netdevice: waiting for tap0 to become free. Usage 
count = 3

Message from syslogd@squirrel at Jun 26 13:02:17 ...
 kernel: unregister_netdevice: waiting for tap0 to become free. Usage 
count = 0

Once the refcount drops to 0, the process exits.  It looks fishy to me 
though.

Regards,

Anthony Liguori

> Here's two fixes on top of previous patch:
>
> diff -u b/drivers/net/tun.c b/drivers/net/tun.c
> --- b/drivers/net/tun.c	Thu Jun 26 00:21:59 2008 +1000
> +++ b/drivers/net/tun.c	Thu Jun 26 14:35:03 2008 +1000
> @@ -298,11 +298,11 @@
>  		if ((len -= sizeof(gso)) > count)
>  			return -EINVAL;
>  
> -		if (gso.hdr_len > len)
> -			return -EINVAL;
> -
>  		if (memcpy_fromiovec((void *)&gso, iv, sizeof(gso)))
>  			return -EFAULT;
> +
> +		if (gso.hdr_len > len)
> +			return -EINVAL;
>  	}
>  
>  	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
> @@ -324,6 +324,16 @@
>  		return -EFAULT;
>  	}
>  
> +	if (gso.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
> +		if (!skb_partial_csum_set(skb, gso.csum_start,
> +					  gso.csum_offset)) {
> +			tun->dev->stats.rx_dropped++;
> +			kfree_skb(skb);
> +			return -EINVAL;
> +		}
> +	} else if (tun->flags & TUN_NOCHECKSUM)
> +		skb->ip_summed = CHECKSUM_UNNECESSARY;
> +
>  	switch (tun->flags & TUN_TYPE_MASK) {
>  	case TUN_TUN_DEV:
>  		skb_reset_mac_header(skb);
> @@ -335,16 +345,6 @@
>  		break;
>  	};
>  
> -	if (gso.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
> -		if (!skb_partial_csum_set(skb, gso.csum_start,
> -					  gso.csum_offset)) {
> -			tun->dev->stats.rx_dropped++;
> -			kfree_skb(skb);
> -			return -EINVAL;
> -		}
> -	} else if (tun->flags & TUN_NOCHECKSUM)
> -		skb->ip_summed = CHECKSUM_UNNECESSARY;
> -
>  	if (gso.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
>  		pr_debug("GSO!\n");
>  		switch (gso.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
>   

