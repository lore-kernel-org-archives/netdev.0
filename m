From: Jeff Barnhill <0xeffeff@gmail.com>
Subject: Re: v6/sit tunnels and VRFs
Date: Fri, 27 Oct 2017 22:43:58 -0400
Message-ID: <CAL6e_pcL3DF1J1-+w0pw0CZ=Zm_BRfKtz=5jML_GcZBZFW1JVA@mail.gmail.com>
References: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
 <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com> <CAL6e_pdBDWBO796tfCnygj0e-c7S81O1y3hvZz3rgbMgxUobOg@mail.gmail.com>
 <9cade21c-5d92-d435-386f-6d854e6b6d55@gmail.com> <CAL6e_pc=Z03obL1U_+EY1t2EQ3Q7pmmcfU72tuO-hPzqqgPgig@mail.gmail.com>
 <aa76d6b7-dbb1-5275-09f6-a4450aeceeb2@gmail.com> <CAL6e_pfAtUAFRmm_2Ykn43jk-0mQn7f9FAt+CgHV4nFHT-PdPQ@mail.gmail.com>
 <609f2e30-3e9d-f317-e2b4-ba3fb7d20532@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:53434 "EHLO
        mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751025AbdJ1Cn7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 22:43:59 -0400
Received: by mail-oi0-f47.google.com with SMTP id h6so13560970oia.10
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 19:43:59 -0700 (PDT)
In-Reply-To: <609f2e30-3e9d-f317-e2b4-ba3fb7d20532@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Your comments on the tunnel VRF and underlay VRF being different make
sense and is more flexible.  I think assigning the dev/link to the
same VRF as the tunnel master accomplishes the same thing that I
originally had in mind.

ping v4 loopback...

jeff@VM2:~$ ip route list vrf myvrf
127.0.0.0/8 dev myvrf proto kernel scope link src 127.0.0.1
192.168.200.0/24 via 192.168.210.3 dev enp0s8
192.168.210.0/24 dev enp0s8 proto kernel scope link src 192.168.210.2

Lookups shown in perf script were for table 255.  Is it necessary to
put the l3mdev table first?  If I re-order the tables, it starts
working:

jeff@VM2:~$ ip rule list
0:      from all lookup local
1000:   from all lookup [l3mdev-table]
32766:  from all lookup main
32767:  from all lookup default

jeff@VM2:~$ sudo ip rule del pref 0
jeff@VM2:~$ sudo ip rule add pref 32765 table 255

jeff@VM2:~$ ip rule list
1000:   from all lookup [l3mdev-table]
32765:  from all lookup local
32766:  from all lookup main
32767:  from all lookup default

jeff@VM2:~$ ping -c1 -I myvrf 127.0.0.1
PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 myvrf: 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.029 ms

--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.029/0.029/0.029/0.000 ms


On Fri, Oct 27, 2017 at 6:53 PM, David Ahern <dsahern@gmail.com> wrote:
> On 10/27/17 2:59 PM, Jeff Barnhill wrote:
>> w/regards to this comment:
>>    You have a remote address with no qualification about which VRF to
>> use for the lookup.
>>
>> I was using this to enslave the tunnel:
>> sudo ip link set jtun vrf myvrf
>>
>> and assumed this would be enough to cause all tunnel traffic to be
>> part of this VRF.
>>
>> You are right about the tunnel link/dev configuration. (re-stating to
>> be sure we are saying the same thing)  I can use either the VRF device
>> or the v4 device and the packet will get sent.  If I use the VRF
>> device, when the reply packet is received, the tunnel is found
>> successfully.  If I use the v4 device, then I need the patch you
>> provided earlier to successfully look up the tunnel.  You mentioned
>> that both should be supported...Back to my previous comment about
>> enslaving the tunnel...shouldn't a tunnel being enslaved to a VRF also
>> be enough to allow sending and receiving on any device in that VRF
>> (that is, not having to configure the link/dev on the tunnel) ?
>
> Sure, it could be done that way. I guess the question is whether we want
> to allow the tunnel device and the underlying device to be in separate VRFs.
>
> I have always taken the approach that every device with an address can
> be in a separate routing domain. Here, that means the tunnel devices can
> be in 1 VRF, and the underlying connection in a separate VRF (or no VRF).
>
>>
>> Fyi...with regards to the v4 ping, adding the loopback address/network
>> didn't work for me.  I'll see if I can get anymore info on this and
>> maybe start a new thread.
>>
>> Thanks,
>> Jeff
>>
>>
>> jeff@VM2:~$ ping -I myvrf 127.0.0.1
>> ping: Warning: source address might be selected on device other than myvrf.
>> PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 myvrf: 56(84) bytes of data.
>> ^C
>> --- 127.0.0.1 ping statistics ---
>> 3 packets transmitted, 0 received, 100% packet loss, time 2051ms
>>
>> jeff@VM2:~$ sudo ip addr add dev myvrf 127.0.0.1/8
>> jeff@VM2:~$ ping -I myvrf 127.0.0.1
>> PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 myvrf: 56(84) bytes of data.
>> ^C
>> --- 127.0.0.1 ping statistics ---
>> 7 packets transmitted, 0 received, 100% packet loss, time 6149ms
>>
>> jeff@VM2:~$ ip addr list myvrf
>> 4: myvrf: <NOARP,MASTER,UP,LOWER_UP> mtu 65536 qdisc noqueue state UP
>> group default qlen 1000
>>     link/ether 82:2b:08:8f:a9:f3 brd ff:ff:ff:ff:ff:ff
>>     inet 127.0.0.1/8 scope host myvrf
>>        valid_lft forever preferred_lft forever
>
> This is v4.14 kernel? Something else? The 127.0.0.1 address on vrf
> device has been supported since the v4.9 kernel.
>
> ip ro ls vrf myvrf?
>
>
> perf record -e fib:* -a -g -- ping -I myvrf -c1 -w1 127.0.0.1
> perf script
> --> does it show lookups in the correct table for this address?
