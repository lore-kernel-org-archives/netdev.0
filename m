From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Thu, 11 Feb 2016 06:12:00 -0500 (EST)
Message-ID: <20160211.061200.2210033638803915336.davem@davemloft.net>
References: <8d2a6ece65b17ae61343dce27f3709d3cd249832.1455118911.git.pabeni@redhat.com>
	<20160211114124.17ae429a@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, pshelar@nicira.com,
	tgraf@suug.ch, jesse@kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbcBKLMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 06:12:07 -0500
In-Reply-To: <20160211114124.17ae429a@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 11 Feb 2016 11:41:24 +0100

> On Wed, 10 Feb 2016 16:47:21 +0100, Paolo Abeni wrote:
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>> @@ -1441,7 +1441,8 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
>>  		return dev;
>>  
>>  	err = geneve_configure(net, dev, &geneve_remote_unspec,
>> -			       0, 0, 0, htons(dst_port), true, 0);
>> +			       0, 0, 0, htons(dst_port), true,
>> +			       GENEVE_F_UDP_ZERO_CSUM6_RX);
>>  	if (err) {
>>  		free_netdev(dev);
>>  		return ERR_PTR(err);
>> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
>> index 1605691..d933cb8 100644
>> --- a/net/openvswitch/vport-vxlan.c
>> +++ b/net/openvswitch/vport-vxlan.c
>> @@ -90,7 +90,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
>>  	int err;
>>  	struct vxlan_config conf = {
>>  		.no_share = true,
>> -		.flags = VXLAN_F_COLLECT_METADATA,
>> +		.flags = VXLAN_F_COLLECT_METADATA | VXLAN_F_UDP_ZERO_CSUM6_RX,
> 
> I'm afraid this looks wrong, we should not default to zero UDP checksum
> over IPv6. See RFC 2460, section 8.1:
> 
>       o  Unlike IPv4, when UDP packets are originated by an IPv6 node,
>          the UDP checksum is not optional.  That is, whenever
>          originating a UDP packet, an IPv6 node must compute a UDP
>          checksum over the packet and the pseudo-header, and, if that
>          computation yields a result of zero, it must be changed to hex
>          FFFF for placement in the UDP header.  IPv6 receivers must
>          discard UDP packets containing a zero checksum, and should log
>          the error.
> 
> One may argue that with tunneling, the situation is different but
> that's the reason why we have the IPv6 checksum flag and why it has
> opposite meaning to the IPv4 one. We shouldn't default to non-RFC
> behavior by default.
> 
> What is the problem with the current code? Is the UDP checksum not
> calculated correctly?

Furthermore, we should be setting the checksum by default for ipv4 too.
It's faster.
