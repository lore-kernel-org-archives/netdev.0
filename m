From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Tue, 16 Feb 2016 10:22:38 -0800
Message-ID: <CAEh+42jyFVjM4A5HzJQ94xW+XZOTG5iBEFu2VHKCJU0sRwNgWA@mail.gmail.com>
References: <8d2a6ece65b17ae61343dce27f3709d3cd249832.1455118911.git.pabeni@redhat.com>
 <20160211114124.17ae429a@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paolo Abeni <pabeni@redhat.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pravin Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55644 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755862AbcBPSW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 13:22:56 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 05A58202A1
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:22:55 +0000 (UTC)
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 78DBA202B8
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:22:53 +0000 (UTC)
Received: by mail-qg0-f42.google.com with SMTP id b67so139877236qgb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 10:22:53 -0800 (PST)
In-Reply-To: <20160211114124.17ae429a@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 11, 2016 at 2:41 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Wed, 10 Feb 2016 16:47:21 +0100, Paolo Abeni wrote:
>> --- a/drivers/net/geneve.c
>> +++ b/drivers/net/geneve.c
>> @@ -1441,7 +1441,8 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
>>               return dev;
>>
>>       err = geneve_configure(net, dev, &geneve_remote_unspec,
>> -                            0, 0, 0, htons(dst_port), true, 0);
>> +                            0, 0, 0, htons(dst_port), true,
>> +                            GENEVE_F_UDP_ZERO_CSUM6_RX);
>>       if (err) {
>>               free_netdev(dev);
>>               return ERR_PTR(err);
>> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
>> index 1605691..d933cb8 100644
>> --- a/net/openvswitch/vport-vxlan.c
>> +++ b/net/openvswitch/vport-vxlan.c
>> @@ -90,7 +90,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
>>       int err;
>>       struct vxlan_config conf = {
>>               .no_share = true,
>> -             .flags = VXLAN_F_COLLECT_METADATA,
>> +             .flags = VXLAN_F_COLLECT_METADATA | VXLAN_F_UDP_ZERO_CSUM6_RX,
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

There's a bigger problem here, not really related to lightweight tunnels or OVS.

The VXLAN RFC says (referring to the UDP checksum and not specific to IPv4/v6):
"It SHOULD be transmitted as zero. When a packet is received with a
UDP checksum of zero, it MUST be accepted for decapsulation."

We can debate whether this is correct or whether it conflicts with RFC
2460 but this is what essentially everyone is going to implement. With
the default settings of the flags in IPv6, we are violating both
statements. With the second one in particular, the result is that
Linux will not be able to communicate with any non-Linux VXLAN
endpoint over IPv6 with default settings.
