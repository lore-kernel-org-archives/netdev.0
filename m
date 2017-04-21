From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 0/3] l3mdev: Improve use with main table
Date: Fri, 21 Apr 2017 18:44:36 +0100
Message-ID: <a4360e77-4386-2760-0b7e-72a21b3aad99@brocade.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
 <3bdb570e-4d7d-6e5c-3270-0bf0064ef73a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:46858 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1041556AbdDUSmB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:42:01 -0400
In-Reply-To: <3bdb570e-4d7d-6e5c-3270-0bf0064ef73a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/04/17 23:36, David Ahern wrote:
> On 4/10/17 8:21 AM, Robert Shearman wrote:
>> Attempting to create a TCP socket not bound to a VRF device when a TCP
>> socket bound to a VRF device with the same port exists (and vice
>> versa) fails with EADDRINUSE. This limits the ability to use programs
>> in selected mixed VRF/non-VRF contexts.
>>
>> This patch series solves the problem by extending the l3mdev be aware
>> of the special semantics of the main table and fixing issues arising
>> from the split local/main tables. A VRF master device created linking
>> to the main table and used for these programs in the same way as those
>> created for VRF tables can.
>>
>> Robert Shearman (3):
>>   ipv6: Fix route handling when using l3mdev set to main table
>>   ipv4: Fix route handling when using l3mdev set to main table
>>   l3mdev: Fix lookup in local table when using main table
>>
>>  net/ipv4/af_inet.c      |  4 +++-
>>  net/ipv4/fib_frontend.c | 14 +++++++++-----
>>  net/ipv4/raw.c          |  5 ++++-
>>  net/ipv6/addrconf.c     | 12 +++++++++---
>>  net/ipv6/route.c        | 23 ++++++++++++++++++-----
>>  net/l3mdev/l3mdev.c     | 26 ++++++++++++++++++++------
>>  6 files changed, 63 insertions(+), 21 deletions(-)
>>
>
> With the change I mentioned earlier to fix the refcnt issue on top of
> this patch set I see a number of failures:
> - local IPv4 with 127.0.0.1 address - ping, tcp, udp tests fail
> - all of the IPv4 multicast tests fail
> - IPv6 linklocal and mcast addresses generally fail
> - IPv6 global address on vrf device

Can you send me some more details of your testing?

These work for me:

$ ping -c1 -I vrf-default 127.0.0.1
PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 vrf-default: 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.141 ms

--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.141/0.141/0.141/0.000 ms
$ ping6 -c1 -I vrf-default 2001::1
PING 2001::1(2001::1) from 2001::1 vrf-default: 56 data bytes
64 bytes from 2001::1: icmp_seq=1 ttl=64 time=0.069 ms

--- 2001::1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.069/0.069/0.069/0.000 ms
$ sudo ip vrf exec vrf-default nc -l -p 4013
TEST
$ sudo ip vrf exec vrf-default nc -l -u -p 4013
TEST
^C

(with a neighbouring host using nc to send the TEST string for the udp 
and tcp cases)

Thanks,
Rob
