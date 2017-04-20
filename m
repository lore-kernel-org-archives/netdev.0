From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net] ipv4: Avoid caching dsts when lookup skipped nh oif
 check
Date: Thu, 20 Apr 2017 16:05:41 +0100
Message-ID: <277d8c4b-5a18-cda2-6edc-66837cae6469@brocade.com>
References: <1492693132-4708-1-git-send-email-rshearma@brocade.com>
 <bed3d38c-dc00-1f98-371c-852170af0a0e@cumulusnetworks.com>
 <ec8e470e-73d0-b357-4f65-a4f7e020db7f@brocade.com>
 <8dcaa797-c566-a9dc-d9a1-99e8d1acfe15@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:53650 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S942445AbdDTPGE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 11:06:04 -0400
In-Reply-To: <8dcaa797-c566-a9dc-d9a1-99e8d1acfe15@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/04/17 15:59, David Ahern wrote:
> On 4/20/17 8:39 AM, Robert Shearman wrote:
>> On 20/04/17 15:21, David Ahern wrote:
>>> On 4/20/17 6:58 AM, Robert Shearman wrote:
>>>> David reported that doing the following:
>>>>
>>>>     ip li add red type vrf table 10
>>>>     ip link set dev eth1 vrf red
>>>>     ip addr add 127.0.0.1/8 dev red
>>>>     ip link set dev eth1 up
>>>>     ip li set red up
>>>>     ping -c1 -w1 -I red 127.0.0.1
>>>>     ip li del red
>>>>
>>>> results in a hang with this message:
>>>>
>>>>     unregister_netdevice: waiting for red to become free. Usage count
>>>> = 1
>>>
>>> I think you misunderstood my comment. The above works fine today. There
>>> is no bug with refcnts.
>>>
>>> It breaks with your patches wanting to use a VRF device with the main
>>> table (254).
>>
>> That doesn't seem to match with my experience. I can reproduce this on
>> the net tree with the listed commands and the behaviour matches what I
>> see in the code.
>
> Our mileage varies:
>
> root@kenny-jessie3:~# ip li add red type vrf table 10
> root@kenny-jessie3:~#     ip link set dev eth1 vrf red
> root@kenny-jessie3:~#     ip addr add 127.0.0.1/8 dev red
> root@kenny-jessie3:~#     ip link set dev eth1 up
> root@kenny-jessie3:~#     ip li set red up
> root@kenny-jessie3:~#     ping -c1 -w1 -I red 127.0.0.1
> PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 red: 56(84) bytes of data.
> 64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.059 ms
>
> --- 127.0.0.1 ping statistics ---
> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> rtt min/avg/max/mdev = 0.059/0.059/0.059/0.000 ms
> root@kenny-jessie3:~#     ip li del red
> root@kenny-jessie3:~# uname -a
> Linux kenny-jessie3 4.11.0-rc6+ #8 SMP Wed Apr 19 11:53:48 PDT 2017
> x86_64 GNU/Linux
>
> The above is one of many tests I run and never hit a problem deleting a
> VRF device. dst's attached to fnhe_rth_output and fnhe_rth_input appear
> to be properly flushed and device references released when the device is
> deleted (NETDEV_DOWN and then NETDEV_UNREGISTER).
>
> Can you send me your kernel config and "sysctl -a --pattern 'net.ipv4'"?
> Perhaps you have something enabled I don't.

The key thing I think is the ip rules:

$ ip rule
0:	from all lookup local
1000:	from all lookup [l3mdev-table]
32766:	from all lookup main
32767:	from all lookup default

Maybe you have the local rule moved down at startup?

I'll send you the requested information if not.

Thanks,
Rob
