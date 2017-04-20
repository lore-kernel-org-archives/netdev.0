From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: Avoid caching dsts when lookup skipped nh oif
 check
Date: Thu, 20 Apr 2017 08:59:30 -0600
Message-ID: <8dcaa797-c566-a9dc-d9a1-99e8d1acfe15@cumulusnetworks.com>
References: <1492693132-4708-1-git-send-email-rshearma@brocade.com>
 <bed3d38c-dc00-1f98-371c-852170af0a0e@cumulusnetworks.com>
 <ec8e470e-73d0-b357-4f65-a4f7e020db7f@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f179.google.com ([209.85.213.179]:34249 "EHLO
        mail-yb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S970233AbdDTO7c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 10:59:32 -0400
Received: by mail-yb0-f179.google.com with SMTP id 11so25824137ybw.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 07:59:32 -0700 (PDT)
In-Reply-To: <ec8e470e-73d0-b357-4f65-a4f7e020db7f@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/20/17 8:39 AM, Robert Shearman wrote:
> On 20/04/17 15:21, David Ahern wrote:
>> On 4/20/17 6:58 AM, Robert Shearman wrote:
>>> David reported that doing the following:
>>>
>>>     ip li add red type vrf table 10
>>>     ip link set dev eth1 vrf red
>>>     ip addr add 127.0.0.1/8 dev red
>>>     ip link set dev eth1 up
>>>     ip li set red up
>>>     ping -c1 -w1 -I red 127.0.0.1
>>>     ip li del red
>>>
>>> results in a hang with this message:
>>>
>>>     unregister_netdevice: waiting for red to become free. Usage count
>>> = 1
>>
>> I think you misunderstood my comment. The above works fine today. There
>> is no bug with refcnts.
>>
>> It breaks with your patches wanting to use a VRF device with the main
>> table (254).
> 
> That doesn't seem to match with my experience. I can reproduce this on
> the net tree with the listed commands and the behaviour matches what I
> see in the code.

Our mileage varies:

root@kenny-jessie3:~# ip li add red type vrf table 10
root@kenny-jessie3:~#     ip link set dev eth1 vrf red
root@kenny-jessie3:~#     ip addr add 127.0.0.1/8 dev red
root@kenny-jessie3:~#     ip link set dev eth1 up
root@kenny-jessie3:~#     ip li set red up
root@kenny-jessie3:~#     ping -c1 -w1 -I red 127.0.0.1
PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 red: 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.059 ms

--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.059/0.059/0.059/0.000 ms
root@kenny-jessie3:~#     ip li del red
root@kenny-jessie3:~# uname -a
Linux kenny-jessie3 4.11.0-rc6+ #8 SMP Wed Apr 19 11:53:48 PDT 2017
x86_64 GNU/Linux

The above is one of many tests I run and never hit a problem deleting a
VRF device. dst's attached to fnhe_rth_output and fnhe_rth_input appear
to be properly flushed and device references released when the device is
deleted (NETDEV_DOWN and then NETDEV_UNREGISTER).

Can you send me your kernel config and "sysctl -a --pattern 'net.ipv4'"?
Perhaps you have something enabled I don't.
