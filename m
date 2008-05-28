From: "Dmitry Petukhov" <dmgenp@gmail.com>
Subject: Re: [PATCH 2.6.26-rc4] fix double call of kfree_skb in net/llc/llc_sap.c
Date: Wed, 28 May 2008 16:59:45 +0600
Message-ID: <84ee89da0805280359mcbc43f0q33f29960af20fba1@mail.gmail.com>
References: <84ee89da0805270009xe92f7e1l959fa9161c976db2@mail.gmail.com>
	 <483BB8EF.4090904@cn.fujitsu.com>
	 <84ee89da0805270047v1c76b4f3k5768fe853f2cea1d@mail.gmail.com>
	 <483BC1B0.2090600@cn.fujitsu.com>
	 <84ee89da0805270235t7ae75356la2ffbb5244de2f74@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	acme@ghostprotocols.net
To: "Wei Yongjun" <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:60944 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbYE1K7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 06:59:51 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1924475ywe.1
        for <netdev@vger.kernel.org>; Wed, 28 May 2008 03:59:45 -0700 (PDT)
In-Reply-To: <84ee89da0805270235t7ae75356la2ffbb5244de2f74@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/5/27 Dmitry Petukhov <dmgenp@gmail.com>:
> 2008/5/27 Wei Yongjun <yjwei@cn.fujitsu.com>:
>
>> Normally,
>>
>> skb_get()         (**return )
>> kfree_skb()
>>
>> will do nothing. If you return with no kfree_skb(), it will let that skb can
>> not be free.
>>
>> skb_get()
>> kfree_skb()
>> kfree_skb()
>>
>> do the real free.
>
> Yeah, you're right. Looks like we mislocated the root of our problem
> (llc socket hangs on receive). Will debug further .
> Thanks for explanation.
>

Looks like we found the real root of our problem.
file net/llc/llc_sap.c:

skb_set_owner_r is called before llc_sap_rcv in two places (lines 363, 384)
skb_set_owner_r do this:
atomic_add(skb->truesize, &sk->sk_rmem_alloc);

and in llc_sap_state_process, on line 223 sock_queue_rcv_skb is
called, which also calls set_owner_r,
which in turn adds skb->truesize to sk->sk_rmem_alloc once more.
This double-addition results in sk_mem_alloc growth to exceed sk_rcvbuf.
We can observe this in  /proc/net/llc/socket, rx_queue field.
after this value exceeds sk_rcvbuf, sock_queue_rcv_skb always return
-ENOMEM, and
socket stops receiving.

//note: please CC me on reply, i'm not subscribed to the list.
