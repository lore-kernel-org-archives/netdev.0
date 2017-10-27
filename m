From: David Ahern <dsahern@gmail.com>
Subject: Re: v6/sit tunnels and VRFs
Date: Fri, 27 Oct 2017 10:25:08 -0600
Message-ID: <aa76d6b7-dbb1-5275-09f6-a4450aeceeb2@gmail.com>
References: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
 <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com>
 <CAL6e_pdBDWBO796tfCnygj0e-c7S81O1y3hvZz3rgbMgxUobOg@mail.gmail.com>
 <9cade21c-5d92-d435-386f-6d854e6b6d55@gmail.com>
 <CAL6e_pc=Z03obL1U_+EY1t2EQ3Q7pmmcfU72tuO-hPzqqgPgig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Barnhill <0xeffeff@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:53036 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752141AbdJ0QZH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 12:25:07 -0400
Received: by mail-pg0-f48.google.com with SMTP id a192so5651041pge.9
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 09:25:07 -0700 (PDT)
In-Reply-To: <CAL6e_pc=Z03obL1U_+EY1t2EQ3Q7pmmcfU72tuO-hPzqqgPgig@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/26/17 11:19 PM, Jeff Barnhill wrote:
> Thanks, David.
> 
> I corrected the static route, applied the patch, and set the
> link/output dev on the tunnel and it works now.  Is it required to set
> the link/output dev?  I was thinking that this should not be required
> for cases where the outgoing device is not known, for instance on a
> router or device with multiple interfaces.

In a VRF environment, addresses have to be qualified with a VRF. Running
the command:

ip tunnel add jtun mode sit remote 192.168.200.1 local 192.168.210.2

You have a remote address with no qualification about which VRF to use
for the lookup.

Digging into the sit code and how the link parameter is used, the
existing code works just fine if you use:

sudo ip tunnel add jtun mode sit remote 192.168.200.1 local
192.168.210.2 dev myvrf

The tunnel link parameter is myvrf and it is used for tunnel lookups and
route lookups to forward the packet. So, really I should allow both
cases -- dev is a VRF and dev is a link that could be in a vrf.

> 
> Also, what is the expected behavior of loopback addresses in a VRF
> context?  For instance, if an application were being run under "ip vrf
> exec" and it tried to use these addresses.

The 127.0.0.1 address needs to exist in the VRF. The one on 'lo' is in
the default VRF only. VRF devices act as the VRF-local loopback, so you
can put the IPv4 loopback address on it.

> 
> jeff@VM2:~$ ping -I myvrf 127.0.0.1
> PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 myvrf: 56(84) bytes of data.
> ^C
> --- 127.0.0.1 ping statistics ---
> 3 packets transmitted, 0 received, 100% packet loss, time 2033ms

If you add the loopback address to the
    ip addr add dev myvrf 127.0.0.1/8

root@kenny-jessie3:~# ip addr add dev myvrf 127.0.0.1/8
root@kenny-jessie3:~# ping -I myvrf 127.0.0.1
PING 127.0.0.1 (127.0.0.1) from 127.0.0.1 myvrf: 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.045 ms
^C
--- 127.0.0.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.045/0.045/0.045/0.000 ms


> 
> jeff@VM2:~$ ping -I myvrf ::1
> connect: Network is unreachable

I need to add support for ::1/128 on a VRF device.
