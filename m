From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] vxlan: synchronously and race-free destruction of
 vxlan sockets
Date: Fri, 8 Apr 2016 22:30:39 +0200
Message-ID: <570814EF.8060308@stressinduktion.org>
References: <1460041060-8619-1-git-send-email-hannes@stressinduktion.org>
 <20160408185114.GA1920@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:36620 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751360AbcDHUap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 16:30:45 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 7DF8F21A4A
	for <netdev@vger.kernel.org>; Fri,  8 Apr 2016 16:30:42 -0400 (EDT)
In-Reply-To: <20160408185114.GA1920@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcelo,


On 08.04.2016 20:51, Marcelo Ricardo Leitner wrote:
> On Thu, Apr 07, 2016 at 04:57:40PM +0200, Hannes Frederic Sowa wrote:
>> Due to the fact that the udp socket is destructed asynchronously in a
>> work queue, we have some nondeterministic behavior during shutdown of
>> vxlan tunnels and creating new ones. Fix this by keeping the destruction
>> process synchronous in regards to the user space process so IFF_UP can
>> be reliably set.
>>
>> udp_tunnel_sock_release destroys vs->sock->sk if reference counter
>> indicates so. We expect to have the same lifetime of vxlan_sock and
>> vxlan_sock->sock->sk even in fast paths with only rcu locks held. So
>> only destruct the whole socket after we can be sure it cannot be found
>> by searching vxlan_net->sock_list.
>>
>> Cc: Jiri Benc <jbenc@redhat.com>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>>   drivers/net/vxlan.c | 20 +++-----------------
>>   include/net/vxlan.h |  2 --
>>   2 files changed, 3 insertions(+), 19 deletions(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 1c0fa364323e28..487e48b7a53090 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -98,7 +98,6 @@ struct vxlan_fdb {
>>
>>   /* salt for hash table */
>>   static u32 vxlan_salt __read_mostly;
>> -static struct workqueue_struct *vxlan_wq;
>>
>>   static inline bool vxlan_collect_metadata(struct vxlan_sock *vs)
>>   {
>> @@ -1065,7 +1064,9 @@ static void __vxlan_sock_release(struct vxlan_sock *vs)
>>   	vxlan_notify_del_rx_port(vs);
>>   	spin_unlock(&vn->sock_lock);
>>
>> -	queue_work(vxlan_wq, &vs->del_work);
>> +	synchronize_rcu();
>
> __vxlan_sock_release is called by vxlan_sock_release which is called by
> vxlan_open/stop. Do we really want to have synchronize_rcu() while
> holding rtnl?

I thought about that and try not to use synchronize_rcu, but I don't see 
any other way. Anyway, ndo_stop isn't really fast path and is used to 
shut the interface down. Also since we have lwtunnels we don't really 
need a lot of interfaces created and torn down.

But I could switch to synchronize_rcu_expedited here.

Also we have another synchronize_rcu during device dismantling, maybe we 
can split ndo_stop into two callbacks, one preparing for stopping and 
the other one after the synchronize_rcu when we safely can free resources.

I will investigate this but for the mean time I think this patch is 
already improving things as user space can bind the socket again when 
the dellink command returned.

Thanks,
Hannes
