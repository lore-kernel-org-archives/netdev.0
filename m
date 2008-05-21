From: Patrick McHardy <kaber@trash.net>
Subject: Re: [iproute2] get_hz() with CONFIG_HIGH_RES_TIMERS
Date: Wed, 21 May 2008 18:56:42 +0200
Message-ID: <4834544A.4010706@trash.net>
References: <20080521163815.GA5028@sc.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
To: Stephane Chazelas <Stephane_Chazelas@yahoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46256 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753836AbYEUQ4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 12:56:44 -0400
In-Reply-To: <20080521163815.GA5028@sc.homeunix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephane Chazelas wrote:
> Hi Stephen,
> 
> there seems to be something wrong with the timer values as
> processed by at least the "ss" and "ip" commands when
> CONFIG_HIGH_RES_TIMERS is on.
> 
> $ zgrep -e HZ= -e HIGH_RES /proc/config.gz
> CONFIG_HIGH_RES_TIMERS=y
> CONFIG_HZ=250
> 
> For instance, the "ip route rtt <time>" and 
> rto values returned by PROC_NET_TCP=/proc/net/tcp ss -i
> look incorrect:
> 
> $ PROC_NET_TCP=/proc/net/tcp ss -i
> State       Recv-Q Send-Q  Local Address:Port      Peer Address:Port
> ESTAB       0      0           127.0.0.1:35466        127.0.0.1:10198    rto:5.5e-08
> [...]
> 
> $ ss -i
> State       Recv-Q Send-Q  Local Address:Port      Peer Address:Port
> ESTAB       0      0           127.0.0.1:35466        127.0.0.1:10198
>         bic wscale:7,7 rto:220 rtt:23.5/19 send 11.2Mbps rcv_space:32792
> 
> 
> $ ip route show
> 10.95.131.111 via 10.95.128.1 dev eth0  rtt 5ms
> 
> $ netstat -rn
> Kernel IP routing table
> Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
> 10.95.131.111   10.95.128.1     255.255.255.255 UGH       0 0     5000000 eth0
> 
> I think this is because get_hz gets the HZ value from the fourth
> field in /proc/net/psched. That's 1e9 in my case, because that's
> meant to be the frequency of CLOCK_MONOTONIC and when
> CONFIG_HIGH_RES_TIMERS is on, the CLOCK_MONOTONIC resolution is
> 1ns. So get_hz returns 1,000,000,000 instead of 250 in my case.
> 
> I don't know how to get the right value, clock_getres return 1ns
> as well.
> 
> That's with 2.6.24.2, iproute-20080108 from debian (but the GIT
> head code looks the same).


Both ss and ip route shouldn't be using get_hz(). inet_diag
is using fixed units anyway, the routing metrics should to.

/proc/net/psched is *only* for packet schedulers and they
want to know the real clock resolution.
