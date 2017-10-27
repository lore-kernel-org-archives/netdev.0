From: David Ahern <dsahern@gmail.com>
Subject: Re: v6/sit tunnels and VRFs
Date: Fri, 27 Oct 2017 16:53:44 -0600
Message-ID: <609f2e30-3e9d-f317-e2b4-ba3fb7d20532@gmail.com>
References: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
 <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com>
 <CAL6e_pdBDWBO796tfCnygj0e-c7S81O1y3hvZz3rgbMgxUobOg@mail.gmail.com>
 <9cade21c-5d92-d435-386f-6d854e6b6d55@gmail.com>
 <CAL6e_pc=Z03obL1U_+EY1t2EQ3Q7pmmcfU72tuO-hPzqqgPgig@mail.gmail.com>
 <aa76d6b7-dbb1-5275-09f6-a4450aeceeb2@gmail.com>
 <CAL6e_pfAtUAFRmm_2Ykn43jk-0mQn7f9FAt+CgHV4nFHT-PdPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Barnhill <0xeffeff@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:56440 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932276AbdJ0Wxr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 18:53:47 -0400
Received: by mail-pg0-f41.google.com with SMTP id m18so6301268pgd.13
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 15:53:47 -0700 (PDT)
In-Reply-To: <CAL6e_pfAtUAFRmm_2Ykn43jk-0mQn7f9FAt+CgHV4nFHT-PdPQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/17 2:59 PM, Jeff Barnhill wrote:
> w/regards to this comment:
>    You have a remote address with no qualification about which VRF to
> use for the lookup.
> 
> I was using this to enslave the tunnel:
> sudo ip link set jtun vrf myvrf
> 
> and assumed this would be enough to cause all tunnel traffic to be
> part of this VRF.
> 
> You are right about the tunnel link/dev configuration. (re-stating to
> be sure we are saying the same thing)  I can use either the VRF device
> or the v4 device and the packet will get sent.  If I use the VRF
> device, when the reply packet is received, the tunnel is found
> successfully.  If I use the v4 device, then I need the patch you
> provided earlier to successfully look up the tunnel.  You mentioned
> that both should be supported...Back to my previous comment about
> enslaving the tunnel...shouldn't a tunnel being enslaved to a VRF also
> be enough to allow sending and receiving on any device in that VRF
> (that is, not having to configure the link/dev on the tunnel) ?

Sure, it could be done that way. I guess the question is whether we want
to allow the tunnel device and the underlying device to be in separate VRFs.

I have always taken the approach that every device with an address can
be in a separate routing domain. Here, that means the tunnel devices can
be in 1 VRF, and the underlying connection in a separate VRF (or no VRF).

> 
> Fyi...with regards to the v4 ping, adding the loopback address/network
> didn't work for me.  I'll see if I can get anymore info on this and
> maybe start a new thread.
> 
> Thanks,
> Jeff
> 
> 
> jeff@VM2:~$ ping -I myvrf 127.0.0.1
> ping: Warning: source address might be selected on device other than myvrf.
> PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 myvrf: 56(84) bytes of data.
> ^C
> --- 127.0.0.1 ping statistics ---
> 3 packets transmitted, 0 received, 100% packet loss, time 2051ms
> 
> jeff@VM2:~$ sudo ip addr add dev myvrf 127.0.0.1/8
> jeff@VM2:~$ ping -I myvrf 127.0.0.1
> PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 myvrf: 56(84) bytes of data.
> ^C
> --- 127.0.0.1 ping statistics ---
> 7 packets transmitted, 0 received, 100% packet loss, time 6149ms
> 
> jeff@VM2:~$ ip addr list myvrf
> 4: myvrf: <NOARP,MASTER,UP,LOWER_UP> mtu 65536 qdisc noqueue state UP
> group default qlen 1000
>     link/ether 82:2b:08:8f:a9:f3 brd ff:ff:ff:ff:ff:ff
>     inet 127.0.0.1/8 scope host myvrf
>        valid_lft forever preferred_lft forever

This is v4.14 kernel? Something else? The 127.0.0.1 address on vrf
device has been supported since the v4.9 kernel.

ip ro ls vrf myvrf?


perf record -e fib:* -a -g -- ping -I myvrf -c1 -w1 127.0.0.1
perf script
--> does it show lookups in the correct table for this address?
