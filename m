From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Fri, 12 Apr 2013 16:07:41 -0700
Message-ID: <516893BD.20303@us.ibm.com>
References: <516641CF.4020101@us.ibm.com> <1937058599.2214531.1365659704193.JavaMail.root@redhat.com> <1365724799.3563.5.camel@sridhar.usor.ibm.com> <20130412.151916.63924835658790088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:43284 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290Ab3DLXHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Apr 2013 19:07:38 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <sri@us.ibm.com>;
	Fri, 12 Apr 2013 19:07:37 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 21468C9001A
	for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 19:07:35 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3CN7Y5i341322
	for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 19:07:35 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3CNAMES012567
	for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 17:10:22 -0600
In-Reply-To: <20130412.151916.63924835658790088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/12/2013 12:19 PM, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Thu, 11 Apr 2013 16:59:59 -0700
>
>> @@ -1013,7 +1013,7 @@ static netdev_tx_t vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
>>   	}
>>   
>>   	/* Bypass encapsulation if the destination is local */
>> -	if (rt->rt_flags & RTCF_LOCAL) {
>> +	if (rt->dst.dev->flags & IFF_LOOPBACK) {
>>   		struct vxlan_dev *dst_vxlan;
> This looks terrible, and ad-hoc.  You need to find a cleaner
> way to express exactly what you're trying to do otherwise I'm
> reverting your change.
The idea is to bypass encap if the destination vxlan endpoint is on the same
host. To do this, i thought it is good enough to check if the route to reach
the destination ip is a local route.(RTCF_LOCAL is set).
This works fine for all the cases where destination ip is assigned to a
normal ethernet device. rt->dst.dev points to loopback device.

In case of veth(veth0,veth1), where the peer(veth1) and the destination 
vxlan
endpoint are on a different netns, ip_route_output for veth1's ipis 
returning
a route entry that has RTCF_LOCAL set and rt->dst.dev pointing to veth0.
Is it a bug that RTCF_LOCAL is set here when veth0's peer is moved to a
different netns?
We don't want to bypass encap in this scenario.

To address this behavior seen with veth, i had to change the if 
condition to
check for rt->dst.dev->flags rather than rt->rt_flags.

Thanks
Sridhar
