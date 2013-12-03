From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 23:09:39 +0200
Message-ID: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com>
References: <529DF340.70602@mellanox.com>
	<1386084620.30495.28.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJZOPZJ9WM1H9zKNzT5MvQ2UH7RxkTLk2Rhzsk9vdvKz6d2uAw@mail.gmail.com>
	<alpine.LFD.2.03.1312031310140.23893@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:47071 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab3LCVJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 16:09:40 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so21006210pde.27
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 13:09:40 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1312031310140.23893@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 3, 2013 at 11:11 PM, Joseph Gasparakis
<joseph.gasparakis@intel.com> wrote:

>>> lack of GRO : receiver seems to not be able to receive as fast as you want.
>>>>      TCPOFOQueue: 3167879
>>> So many packets are received out of order (because of losses)

>> I see that there's no GRO also for the non-veth tests which involve
>> vxlan, and over there the receiving side is capable to consume the
>> packets, do you have rough explaination why adding veth to the chain
>> is such game changer which makes things to start falling out?

> I have seen this before. Here are my findings:
>
> The gso_type is different if the skb comes from veth or not. From veth,
> you will see the SKB_GSO_DODGY set. This breaks things as when the
> skb with DODGY set moves from vxlan to the driver through dev_xmit_hard,
> the stack drops it silently. I never got the time to find the root cause
> for this, but I know it causes re-transmissions and big performance
> degregation.
>
> I went as far as just quickly hacking a one liner unsetting the DODGY bit
> in vxlan.c and that bypassed the issue and recovered the performance
> problem, but obviously this is not a real fix.

thanks for the heads up, few quick questions/clafications --

-- you are talking on drops done @ the sender side, correct? Eric was
saying we have evidences that the drops happen on the receiver.

-- without the hack you did, still packets are sent/received, so what
makes the stack to drop only some of them?

-- why packets coming from veth would have the SKB_GSO_DODGY bit set?

-- so where is now (say net.git or 3.12.x) this one line you commented
out? I don't see in vxlan.c or in ip_tunnel_core.c / ip_tunnel.c
explicit setting of SKB_GSO_DODGY

Also, I am pretty sure the problem exists also when sending/receiving
guest traffic through tap/macvtap <--> vhost/virtio-net and friends, I
just sticked to the veth flavour b/c its one (== the hypervisor)
network stack to debug and not two (+ the guest one).
