From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with ICMP rate limiting and redirects
Date: Wed, 30 Sep 2015 09:42:54 -0700
Message-ID: <1443631374.32531.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACOGZ=uKqPpNBWuuJox1JTCC5e0G_j4KG+zFA_Ykr8wHj4jPgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hugo Vasconcelos Saldanha <hugovs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33696 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbbI3Qm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 12:42:56 -0400
Received: by pacex6 with SMTP id ex6so45599630pac.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 09:42:56 -0700 (PDT)
In-Reply-To: <CACOGZ=uKqPpNBWuuJox1JTCC5e0G_j4KG+zFA_Ykr8wHj4jPgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-30 at 13:10 -0300, Hugo Vasconcelos Saldanha wrote:
> Hi,
> 
> While updating the kernel from v3.2 to v3.14, I started to see a
> different behavior concerning ICMP redirects sent by this updated
> server. The network is somewhat configured like this:
> 
>                ---|firewall|----{Internet}
> |client|------|
>               |
>                ---|router|------|172.16/12 network|
> 
> The client's default gateway is 'firewall', which is the updated
> server. It has a static route to 172.16 network by 'router'. If
> 'client' wants to talk to a server in that network, 'firewall' sends a
> ICMP redirect pointing to router as the gateway.
> 
> This worked fine with v3.2. But after the upgrade, if an ICMP message
> that is rate-limited (by the sysctl_icmp_ratelimit mask) is sent to
> 'client', ICMP redirects stop being sent to the same client. This
> happens, for example, when traceroute'ing from the client to the
> server inside the mentioned network. In this situation, a ICMP Time
> Exceeded message is sent in response to traceroute's first packet, but
> then the following packets never generate any ICMP redirect messages
> in 'firewall'.
> 
> Debugging the code, I was able to see that the problem is being caused
> by the fact that ip_rt_send_redirect() started to use the inetpeer
> cache and the fields used to rate limit ICMP redirects (rate_tokens
> and rate_last) are now being shared with the algorithm applied in
> inet_peer_xrlim_allow(). This never happened with v3.2 because
> apparently inet_peer_xrlim_allow() and ip_rt_send_redirect() used
> different inetpeer objects.
> 
> The reason why this breaks the functionality is that, while
> inet_peer_xrlim_allow() uses a time bucket, ip_rt_send_redirect() uses
> rate_tokens as a packet counter. Not to mention the fact that these
> are two completely different policies which should be controlled by
> different buckets, counters, flags, etc. Because of this,
> ip_rt_redirect_silence, ip_rt_redirect_number and ip_rt_redirect_load
> /proc files are broken also.
> 
> The easiest solution would be to create new fields in 'struct
> inetpeer' to control ICMP redirects only, but I'm not able to measure
> its convenience.
> 
> Any thoughts?
> 
> PS: Apparently, a similar problem was reported here:
> http://marc.info/?l=linux-netdev&m=139696540600985
> 
> PS2: I could try to reproduce the problem with the latest code if this
> is really necessary.

Hmm... Do you have commit

4cdf507d54525842dfd9f6313fdafba039084046
("icmp: add a global rate limitation")
in your kernel ?
