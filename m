From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net-next v4 1/2] New kernel function to get IP overhead on
 a socket.
Date: Fri, 24 Mar 2017 13:13:33 +0000
Message-ID: <14517769-bf88-a541-4948-1504a6d7acac@katalix.com>
References: <alpine.DEB.2.11.1703221554000.9002@vera100.eng.brocade.com>
 <20170323.150500.1211908608737471263.davem@davemloft.net>
 <alpine.DEB.2.11.1703231809410.19388@vera100.eng.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: kleptog@svana.org, davem@redhat.com, nprachan@brocade.com,
        rshearma@brocade.com, stephen@networkplumber.org,
        sdietric@brocade.com, ciwillia@brocade.com, lboccass@brocade.com,
        dfawcus@brocade.com, bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "R. Parameswaran" <parameswaran.r7@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.katalix.com ([82.103.140.233]:39033 "EHLO mail.katalix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751793AbdCXNNi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 09:13:38 -0400
In-Reply-To: <alpine.DEB.2.11.1703231809410.19388@vera100.eng.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/03/17 01:51, R. Parameswaran wrote:
> Hi Dave,
>
> Please see inline:
>
> On Thu, 23 Mar 2017, David Miller wrote:
>
>> From: "R. Parameswaran" <parameswaran.r7@gmail.com>
>> Date: Wed, 22 Mar 2017 15:59:13 -0700 (PDT)
>>
>>> A new function, kernel_sock_ip_overhead(), is provided
>>> to calculate the cumulative overhead imposed by the IP
>>> Header and IP options, if any, on a socket's payload.
>>> The new function returns an overhead of zero for sockets
>>> that do not belong to the IPv4 or IPv6 address families.
>>>
>>> Signed-off-by: R. Parameswaran <rparames@brocade.com>
>> Just use the IPv4/IPv6 header size for now, just like the VXLAN
>> driver does.
>>
> Actually, that's how the original posting was - it was changed in 
> response to a review comment from James Chapman requesting the IP
> Options overhead to be factored in and for this to be calculated in
> a new standalone function that can be reused in other situations. 
> The review comment makes sense to me - the kernel seems to do a 
> good job of accounting for the cumulative size of IP Options and
> if the information is available, it may make sense to factor it in.
>
> I guess you are concerned about compatibility between vxlan and
> L2TP? There may be one difference  - the socket for vxlan
> appears to be opened/controlled entirely within kernel code (seems
> to call udp_sock_create() which does not appear to turn on any options), 
> but in the case of L2TP, it is possible for the tunnel socket to be 
> opened from user space, if a user space control plane daemon is running.
> Regardless of how user space daemons are written right now, it is 
> possible in theory for the user space code to turn on options on the 
> L2TP tunnel socket. So it seems that IP options might be enabled on the 
> L2TP socket, but are probably unlikely on the vxlan socket? 
>
> I'd suggest giving this a few days for James to respond. 
> At that time if there is agreement that we don't need to factor options, 
> I can rework it.

The reason I suggested factoring in IP options here is because L2TP
tunnel sockets can be opened by userspace daemons. When an L2TP control
plane is used, the L2TP daemon opens the tunnel socket. When no control
plane is used, L2TP connections are manually configured, usually by ip
l2tp commands, and the tunnel socket is created by the kernel.

For sockets created by userspace, the L2TP daemon could derive the
cumulative size of all IP options that it sets and use that to set the
L2TP session's MTU. Setting an MTU when establishing L2TP connections
overrides the kernel's own default MTU calculations anyway. But the L2TP
packet header overhead depends on several other L2TP-specific options,
e.g. cookie size and the kernel already takes these into account when
calculating MTU. If IP options are ignored, we'd have the situation
where the default MTU value avoids fragmentation but only if certain IP
options are not enabled on the tunnel socket.

For L2TP, I'd prefer that the kernel takes IP options into account. If a
function were added to the kernel to return the IP header overhead of an
IP socket, initially for L2TP, I figured it might be useful for other
tunnel protocols too, hence I suggested it was added as a generic
function. Maybe that was a mistake. If instead this function is renamed
and made L2TP-private, that would be ok for me.

James
