From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC PATCH 0/8] l2tp: introduce L2TPv3 support
Date: Tue, 24 Feb 2009 09:55:05 +0000
Message-ID: <49A3C3F9.6020409@katalix.com>
References: <20090224063908.GA20652@gondor.apana.org.au> <49A3BB1E.8040005@katalix.com> <49A3BCCF.9040203@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:32902 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754320AbZBXJzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 04:55:17 -0500
In-Reply-To: <49A3BCCF.9040203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> James Chapman wrote:
>> Herbert Xu wrote:
>>> James Chapman <jchapman@katalix.com> wrote:
>>>> This patch series implements L2TPv3. It replaces the existing pppol2tp
>>>> driver with a number of separate drivers, namely:-
>>>>
>>>> l2tp_core    - L2TP driver core. Always required.
>>>> l2tp_ppp     - L2TP PPP
>>>> l2tp_eth     - L2TPv3 ethernet pseudowire
>>>> l2tp_ip      - L2TPv3 IP encapsulation
>>>> l2tp_netlink - L2TPv3 netlink API
>>> Have you thought by using the rtnl_link_ops interface instead
>>> of your own netlink API?
>>
>> I did, yes. I decided against it only because I didn't want to cause
>> confusion with what I perhaps wrongly perceive as an API for managing
>> net devices. In the L2TPv3 case, there might not be a netdev directly
>> associated with a newlink API call, for example. I've no problem with
>> switching the code to use it if it is preferred.
> 
> From a quick look, it seems you're (also) managing sessions, for
> which rtnl_link might not be the best choice. Could you give a
> short overview of the operations you need to be able to perform?

Sure.

Userspace needs to create, delete, modify and query L2TP tunnel and
session contexts in the kernel. Tunnels are associated with a tunnel
socket (UDP or L2TPIP) and can carry multiple sessions. Session contexts
differ according to type; they are associated with a pppol2tp socket and
implicit ppp netdev in the case of PPP pseudowires, or an ethernet
netdev in the case of ethernet pseudowires. Other pseudowires may be
added in the future for ATM, Frame Relay etc.

In the existing L2TPv2 driver, only PPP is supported by L2TPv2 so the
management of session contexts is done through [gs]etsockopt and ioctl
on the pppol2tp socket. Since in L2TPv3, there might not be a socket for
a session (i.e. in the case of ethernet), we need a new API to manage
the tunnel and session contexts in the kernel.

The extra L2TPv3 configuration parameters of tunnels also required a
more extensive API for creating tunnel contexts. In L2TPv2, tunnel
contexts were automatically created when the first session on that
tunnel was created. In L2TPv3, this isn't possible because the tunnel
creation parameters aren't known by the session. Therefore, the API was
changed to require that userspace create an L2TPv3 tunnel context in the
kernel separately, before creating sessions on it.

Is that enough detail?

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

