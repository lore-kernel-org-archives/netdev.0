From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 7/7] vxlan: Add support for UDP checksums (v4 TX, v6 zero csums)
Date: Fri, 30 May 2014 13:30:05 -0700
Message-ID: <CAEP_g=9A-K=1UfXouS6X8CCq7gw1LR5wgJAO3v+7r6FJ0ZmWgw@mail.gmail.com>
References: <alpine.DEB.2.02.1405282114100.7294@tomh.mtv.corp.google.com>
 <CAEP_g=9tvWCZ32HKsN0bpn-qxTcgPS8PupSRi5S0h665VDpEoQ@mail.gmail.com> <CA+mtBx84sivSJ8P_rFoA=ijT1U1_sd61C+V-JJwMdYyQhbVHig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:45975 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932699AbaE3Ua0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 16:30:26 -0400
Received: by mail-qg0-f44.google.com with SMTP id i50so6960932qgf.31
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 13:30:25 -0700 (PDT)
In-Reply-To: <CA+mtBx84sivSJ8P_rFoA=ijT1U1_sd61C+V-JJwMdYyQhbVHig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 4:38 PM, Tom Herbert <therbert@google.com> wrote:
> On Thu, May 29, 2014 at 3:45 PM, Jesse Gross <jesse@nicira.com> wrote:
>> On Wed, May 28, 2014 at 9:24 PM, Tom Herbert <therbert@google.com> wrote:
>>> diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
>>> index a93efa3..0edbd95 100644
>>> --- a/net/openvswitch/vport-vxlan.c
>>> +++ b/net/openvswitch/vport-vxlan.c
>>> @@ -122,7 +122,7 @@ static struct vport *vxlan_tnl_create(const struct vport_parms *parms)
>>>         vxlan_port = vxlan_vport(vport);
>>>         strncpy(vxlan_port->name, parms->name, IFNAMSIZ);
>>>
>>> -       vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, false);
>>> +       vs = vxlan_sock_add(net, htons(dst_port), vxlan_rcv, vport, true, 0);
>>
>> OVS actually already has support for specifying that checksums should
>> be calculated/verified plumbed down to the kernel. This is used
>> already with GRE (via the TUNNEL_CSUM flag). If we modeled VXLAN
>> similarly then it might make the two protocols more similar and give
>> us OVS support for free.
>
> I tend to agree, it would be nice if vxlan would be configured like
> GRE, use tnl_ptk_info, etc. But, it looks like vxlan is pretty
> divergent, so I'd like to decouple doing that from this patch set.
>
> For setting use of csums in vxlan-ovs it should be a matter of adding
> IFLA_VXLAN_UDP_CSUM (IFLA_VXLAN_UDP_ZERO_CSUM6_TX for IPv6) flags
> argument to vxlan_sock_add. Do you see any issues with that?

The problem is that OVS actually does this on a per-flow basis, on
transmit specifying whether the checksum should be computed and
recording the presence of the checksum on receive. All of the policy,
such as whether checksums are required, is handled in userspace in a
tunnel-independent manner. I don't think that we need to restructure
VXLAN in this patch (although I agree it would be nice) but OVS needs
a little bit more granularity than configuring the socket.
