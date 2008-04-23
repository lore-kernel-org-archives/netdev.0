From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [ROUTE]: FIB_RES_PREFSRC() selects wrong source in some cases
Date: Wed, 23 Apr 2008 10:09:10 +0000
Message-ID: <20080423100910.GA3994@ff.dom.local>
References: <480C889B.3060203@odu.neva.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:12740 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbYDWKGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 06:06:19 -0400
Received: by fg-out-1718.google.com with SMTP id l27so2564779fgb.17
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 03:06:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <480C889B.3060203@odu.neva.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21-04-2008 14:29, Dmitry Butskoy wrote:
> Consider an interface with two (or more) IP addresses, connected to a
> LAN segment with two (or more) networks. In such a case the source IP is
> not unique, it should be chosen depending on the destionation IP. Under
> some circumstances this choice is incorrect.
> 
> Consider the example (an interface in two networks, trying to reach
> "scope link" destinations):
> 
>> # ifdown eth0
>> # ip link set up dev eth0
>> # ip addr add 192.168.0.1/24 dev eth0
>> # ip addr add 172.18.0.1/24 dev eth0
>> # ip route show dev eth0
>> 172.18.0.0/24  proto kernel  scope link  src 172.18.0.1
>> 192.168.0.0/24  proto kernel  scope link  src 192.168.0.1
> 
> now we have two routes with preferred src specified
> 
>> # ip route get 192.168.0.2
>> 192.168.0.2 dev eth0  src 192.168.0.1
>>     cache  mtu 1500 advmss 1460 hoplimit 64
>> # ip route get 172.18.0.2
>> 172.18.0.2 dev eth0  src 172.18.0.1
>>     cache  mtu 1500 advmss 1460 hoplimit 64
> 
> Becasue of the preferred src, the actual source IP is chosen right.
> 
> Now let's flush all the routes, and then add them manually.
> (Certainly such a usage is a corner case, but sometimes some admins
> prefer to set all the routes explicitly, rather than implicitly by
> "proto kernel" etc.)
> 
>> # ip route flush dev eth0
>> #
>> # ip route add 192.168.0.0/24 dev eth0
>> # ip route add 172.18.0.0/24 dev eth0
>> # ip route show dev eth0
>> 172.18.0.0/24  scope link
>> 192.168.0.0/24  scope link
> 
> Now the same as above, but no more preferred src...

...So, why it can't be set explicitly too?:

# ip route add 172.18.0.0/24 dev eth0 src 172.18.0.1

...
> is called with "dst == 0", it chose just the first IP seen on the
> interface (i.e. 192.168.0.1 in the example) ...
> 
> 
> Whether it is possible (and applicable) to change the code someway, to
> call inet_select_addr() with the proper destination IP ?
> 
> Actually, it is a long standing issue (at least since 1999), probably
> it is even "feature" now :), but it seems strange that the kernel have
> all the data to make the right choice, but does not any attemptfor it...

IMHO it's a feature - I mean the way of thinking; low level tools
should do just what they are told to do - if it's possible (even let
you shoot your foot...). And chosing the first IP seems to show
problems faster - just for these admins who like it explicit!?

Regards,
Jarek P.
