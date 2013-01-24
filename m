From: Leandro Lucarella <leandro.lucarella@sociomantic.com>
Subject: Re: Doubts about listen backlog and tcp_max_syn_backlog
Date: Thu, 24 Jan 2013 20:21:26 +0100
Message-ID: <20130124192125.GD4608@sociomantic.com>
References: <1358873142.3464.3964.camel@edumazet-glaptop>
 <20130122165929.GH4608@sociomantic.com>
 <1358874800.3464.4002.camel@edumazet-glaptop>
 <50FED7CE.1030008@hp.com>
 <20130122184245.GJ4608@sociomantic.com>
 <50FF0C25.9000300@hp.com>
 <20130123104736.GK4608@sociomantic.com>
 <510039C8.7040401@hp.com>
 <20130124122223.GQ4608@sociomantic.com>
 <51018110.1070403@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:55675 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657Ab3AXTVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 14:21:32 -0500
Content-Disposition: inline
In-Reply-To: <51018110.1070403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 10:44:32AM -0800, Rick Jones wrote:
> On 01/24/2013 04:22 AM, Leandro Lucarella wrote:
> >On Wed, Jan 23, 2013 at 11:28:08AM -0800, Rick Jones wrote:
> >>>Then if syncookies are enabled, the time spent in connect() shouldn't be
> >>>bigger than 3 seconds even if SYNs are being "dropped" by listen, right?
> >>
> >>Do you mean if "ESTABLISHED" connections are dropped because the
> >>listen queue is full?  I don't think I would put that as "SYNs being
> >>dropped by listen" - too easy to confuse that with an actual
> >>dropping of a SYN segment.
> >
> >I was just kind of quoting the name given by netstat: "SYNs to LISTEN
> >sockets dropped" (for kernel 3.0, I noticed newer kernels don't have
> >this stat anymore, or the name was changed). I still don't know if we
> >are talking about the same thing.
> 
> Are you sure those stats are not present in 3.X kernels?  I just
> looked at /proc/net/netstat on a 3.7 system and noticed both the
> ListenMumble stats and the three cookie stats.  And I see the code
> for them in the tree:
> 
> aj@tardy:~/net-next/net/ipv4$ grep MIB_LISTEN *.c
> proc.c:	SNMP_MIB_ITEM("ListenOverflows", LINUX_MIB_LISTENOVERFLOWS),
> proc.c:	SNMP_MIB_ITEM("ListenDrops", LINUX_MIB_LISTENDROPS),
> tcp_ipv4.c:	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
> tcp_ipv4.c:	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
> 
> raj@tardy:~/net-next/net/ipv4$ grep MIB_SYN *.c
> proc.c:	SNMP_MIB_ITEM("SyncookiesSent", LINUX_MIB_SYNCOOKIESSENT),
> proc.c:	SNMP_MIB_ITEM("SyncookiesRecv", LINUX_MIB_SYNCOOKIESRECV),
> proc.c:	SNMP_MIB_ITEM("SyncookiesFailed", LINUX_MIB_SYNCOOKIESFAILED),
> syncookies.c:	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
> syncookies.c:		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
> syncookies.c:	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESRECV);
> 
> I will sometimes be tripped-up by netstat's not showing a statistic
> with a zero value...

This is what I'm talking about:

pc1 $ uname -a
Linux labs09 3.5.0-18-generic #29~precise1-Ubuntu SMP Mon Oct 22 16:31:46 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
pc1 $ netstat --version | head -n2
net-tools 1.60
netstat 1.42 (2001-04-15)
pc1 $ netstat -s | grep -i syn
    4 invalid SYN cookies received

pc2 $ uname -a
Linux eu-21 3.0.0-19-server #33-Ubuntu SMP Thu Apr 19 20:32:48 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
pc2 $ netstat --version | head -n2
net-tools 1.60
netstat 1.42 (2001-04-15)
pc2 $ netstat -s | grep -i syn
    1996450 SYN cookies sent
    2899079 SYN cookies received
    410573 invalid SYN cookies received
    10012473 resets received for embryonic SYN_RECV sockets
    5659740 SYNs to LISTEN sockets dropped
    1 connections reset due to unexpected SYN

I didn't take a look at the kernel or netstat sources about this, so I
don't know exactly how are they connected.

> >>But yes, I would not expect a connect() call to remain incomplete
> >>for any longer than it took to receive an SYN|ACK from the other
> >>end.
> >
> >So the only reason to experience these high times spent in connect()
> >should be because a SYN or SYN|ACK was actually loss in a lower layer,
> >like an error in the network device or a transmission error?
> 
> Modulo the/some other drop-without-stat point such as Vijay
> mentioned yesterday.

So, in this cases a syncookie is not sent back? I had the impression
they were sent always...

> You might consider taking some packet traces.  If you can I would
> start with a trace taken on the system(s) on which the long
> connect() calls are happening.   I think the tcpdump manpage has an
> example of a tcpdump command with a filter expression that catches
> just SYNchronize and FINished segments which I suppose you could
> extend to include ReSeT segments.  Such a filter expression would be
> missing the client's ACK of the SYN|ACK but unless you see
> incrementing stats relating to say checksum failures or other drops
> on the "client" side I suppose you could assume that the client
> ACKed the server's SYN|ACK.

Yes, I already did captures and we are definitely loosing packets
(including SYNs), but it looks like the amount of SYNs I'm loosing is
lower than the amount of long connect() times I observe. This is not
confirmed yet, I'm still investigating.

Thanks!

-- 
Leandro Lucarella
sociomantic labs GmbH
http://www.sociomantic.com
