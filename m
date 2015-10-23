From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ip_no_pmtu_disc and UDP
Date: Sat, 24 Oct 2015 00:34:22 +0200
Message-ID: <1445639662.2872263.418778169.006CB827@webmail.messagingengine.com>
References: <CAK3+h2wFfh+HE78kHoWwgc9vyTCLWM90C4RQ=uTRk8551-jQ7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Vincent Li <vincent.mc.li@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:40496 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751301AbbJWWeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 18:34:23 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id CDCAC20753
	for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 18:34:22 -0400 (EDT)
In-Reply-To: <CAK3+h2wFfh+HE78kHoWwgc9vyTCLWM90C4RQ=uTRk8551-jQ7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Fri, Oct 23, 2015, at 18:45, Vincent Li wrote:
> It looks ip_no_pmtu_disc setting does not affect UDP IP packet DF bit
> setting, is that intended behavior? echo 0, 1, 2, 3 respectively to
> ip_no_pmtu_disc, UDP IP packet always have DF bit cleared, unless use
> IP_PMTUDISC_DO on IP_MTU_DISCOVER as ip man page says.

Which size do the UDP packets have and what is your MTU? inet_create
also creates udp sockets and thus the setting does have effect.

> 
> in inet_create, seems to prove that.
> 
>        if (net->ipv4.sysctl_ip_no_pmtu_disc)
>                 inet->pmtudisc = IP_PMTUDISC_DONT;
>         else
>                 inet->pmtudisc = IP_PMTUDISC_WANT;
> 
> so I am wondering why UDP is excluded by ip_no_pmtu_disc, why in
> inet_create, not assign each individual ip_no_pmtu_disc setting to
> inet->pmtudisc but only check true and assign IP_PMTUDISC_DONT or
> IP_PMTUDISC_WANT only.

ip_no_pmtu_disc sysctl != IP_MTU_DISCOVER setsockopt. Also we cannot
change this as it would disrupt communication easily relying on this
established behavior.

See Documentation/ip-sysctl.txt:

ip_no_pmtu_disc - INTEGER
        Disable Path MTU Discovery. If enabled in mode 1 and a
        fragmentation-required ICMP is received, the PMTU to this
        destination will be set to min_pmtu (see below). You will need
        to raise min_pmtu to the smallest interface MTU on your system
        manually if you want to avoid locally generated fragments.

        In mode 2 incoming Path MTU Discovery messages will be
        discarded. Outgoing frames are handled the same as in mode 1,
        implicitly setting IP_PMTUDISC_DONT on every created socket.

        Mode 3 is a hardend pmtu discover mode. The kernel will only
        accept fragmentation-needed errors if the underlying protocol
        can verify them besides a plain socket lookup. Current
        protocols for which pmtu events will be honored are TCP, SCTP
        and DCCP as they verify e.g. the sequence number or the
        association. This mode should not be enabled globally but is
        only intended to secure e.g. name servers in namespaces where
        TCP path mtu must still work but path MTU information of other
        protocols should be discarded. If enabled globally this mode
        could break other protocols.

        Possible values: 0-3
        Default: FALSE

Bye,
Hannes
