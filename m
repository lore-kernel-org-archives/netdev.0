From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] vxlan: synchronously and race-free
 destruction of vxlan sockets
Date: Fri, 15 Apr 2016 23:50:31 +0200
Message-ID: <57116227.9060205@stressinduktion.org>
References: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
 <20160415.163644.1883719564658558438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jbenc@redhat.com,
	marcelo.leitner@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:38035 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750862AbcDOVuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 17:50:35 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id EEA4720C90
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 17:50:34 -0400 (EDT)
In-Reply-To: <20160415.163644.1883719564658558438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.04.2016 22:36, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri,  8 Apr 2016 22:55:01 +0200
>
>> @@ -1053,7 +1052,9 @@ static void __vxlan_sock_release(struct vxlan_sock *vs)
>>   	vxlan_notify_del_rx_port(vs);
>>   	spin_unlock(&vn->sock_lock);
>>
>> -	queue_work(vxlan_wq, &vs->del_work);
>> +	synchronize_net();
>> +	udp_tunnel_sock_release(vs->sock);
>> +	kfree(vs);
>>   }
>>
>>   static void vxlan_sock_release(struct vxlan_dev *vxlan)
>
> I just want to make sure you saw this change in net-next:
>
> ====================
> commit ca065d0cf80fa547724440a8bf37f1e674d917c0
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Fri Apr 1 08:52:13 2016 -0700
>
>      udp: no longer use SLAB_DESTROY_BY_RCU
> ====================
>
> Does that effect your change?

I have seen this patch and it does not affect this patch:

The socket is matched from the net->vxlan_net->hlist in fast path. I 
don't want to destruct (kern_sock_shutdown) the socket while packets 
could be in flight through the vxlan stack. We clean up socket memory 
and destruct after rcu again, but given that we only do this during 
ifdown of a vxlan interface I don't see that we need to optimize this again.

All other tunneling protocols don't look up sockets in fast path, so 
they don't need to protect against this.

Bye,
Hannes
