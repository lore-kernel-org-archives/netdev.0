From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC net-next 0/6] net: reducing memory footprint of
 network devices
Date: Tue, 9 May 2017 11:50:23 +0200
Message-ID: <1be60a5e-da39-5657-b1fe-c91266800046@6wind.com>
References: <20170506160734.47084-1-dsahern@gmail.com>
 <89333e30-0a5d-0f05-4d14-d75dc157d6ba@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: roopa@cumulusnetworks.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:35580 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdEIJu0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 05:50:26 -0400
Received: by mail-wr0-f177.google.com with SMTP id z52so65099900wrc.2
        for <netdev@vger.kernel.org>; Tue, 09 May 2017 02:50:25 -0700 (PDT)
In-Reply-To: <89333e30-0a5d-0f05-4d14-d75dc157d6ba@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/05/2017 à 19:35, Florian Fainelli a écrit :
> On 05/06/2017 09:07 AM, David Ahern wrote:
>> As I have mentioned many times[1], at ~43+kB per instance the use of
>> net_devices does not scale for deployments needing 10,000+ devices. At
>> netconf 1.2 there was a discussion about using a net_device_common for
>> the minimal set of common attributes with other structs built on top of
>> that one for "full" devices. It provided a means for the code to know
>> "non-standard" net_devices. Conceptually, that approach has its merits
>> but it is not practical given the sweeping changes required to the code
>> base. More importantly though struct net_device is not the problem; it
>> weighs in at less than 2kB so reorganizing the code base around a
>> refactored net_device is not going to solve the problem. The primary
>> issue is all of the initializations done *because* it is a struct
>> net_device -- kobject and sysfs and the protocols (e.g., ipv4, ipv6,
>> mpls, neighbors).
>>
>> So, how do you keep the desired attributes of a net device -- network
>> addresses, xmit function, qdisc, netfilter rules, tcpdump -- while
>> lowering the overhead of a net_device instance and without sweeping
>> changes across net/ and drivers/net/?
>>
>> This patch set introduces the concept of labeling net_devices as
>> "lightweight", first mentioned at netdev 1.1 [1]. Users have to opt
>> in to lightweight devices by passing a new attribute, IFLA_LWT_NETDEV,
>> in the new link request. This lightweight tag is meant for virtual
>> devices such as vlan, vrf, vti, and dummy where the user expects to
>> create a lot of them and does not want the duplication of resources.
>> Each device type can always opt out of a lightweight label if necessary
>> by failing device creates.
>>
>> Labeling a virtual device as "lightweight" reduces the footprint for
>> device creation from ~43kB to ~6kB. That reduction in memory is obtained
>> by:
>> 1. no entry in sysfs
>>    - kobject in net_device.device is not initialized
>>
>> 2. no entry in procfs
>>    - no sysctl option for these devices
>>
>> 3. deferred ipv4, ipv6, mpls initialization
>>    - network layer must be enabled before an address can be assigned
>>      or mpls labels can be processed
>>    - enables what Florian called L2 only devices [2]
>>
>> Once the core premise of a lightweight device is accepted, follow on
>> patches can reduce the overhead of network initializations. e.g.,
>>
>> 1. remove devconf per device (ipv4 and ipv6)
>>    - lightweight devices use the default settings rather than replicate
>>      the same data for each device
>>
>> 2. reduce / remove / opt out of snmp mibs
>>    - snmp6_alloc_dev and icmpv6msg_mib_device specifically is a heavy
>>      hitter
>>
>> Patches can also be found here:
>>     https://github.com/dsahern/linux lwt-dev-rfc
>>
>> And iproute2 here:
>>     https://github.com/dsahern/iproute2 lwt-dev
>>
>> Example:
>>     ip li add foo lwd type vrf table 123
>>
>> - creates VRF device 'foo' as a lightweight netdevice.
> 
> This is really looking nice, thanks for posting this patch series! The
> only submission wide comment I have is that the flag is named
> IFF_LWT_NETDEV whereas the helper that checks for it is named
> netif_is_lwd() so we should reconcile the two. Since there is an
> existing lightweight tunnel infrastructure already, maybe using
> IFF_LWD_NETDEV (or just IFF_LWD) would be good enough here?

Yep, thank you for the series, it also looks good to me.
I also vote for the IFF_LWD_NETDEV or IFF_LWD to avoid confusion with
lightweight tunnel and to be consistent with it (lightweight was abbreviated lw,
not lwt ;-)).

Your initial patch tried to make those interfaces transparent, this is not the
case anymore here. It would probably be useful to be able to filter those
interfaces in the kernel during a dump.

Regards,
Nicolas
