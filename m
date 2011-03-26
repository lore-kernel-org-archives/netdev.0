From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/2] socket: add minimum listen queue length sysctl
Date: Fri, 25 Mar 2011 17:21:43 -0700
Message-ID: <1301098903.13505.92.camel@tardy>
References: <1301077899-16482-1-git-send-email-hagen@jauu.net>
	 <1301077899-16482-2-git-send-email-hagen@jauu.net>
	 <1301084677.13505.26.camel@tardy>  <20110325235101.GA2641@hell>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:5868 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932395Ab1CZAVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 20:21:45 -0400
In-Reply-To: <20110325235101.GA2641@hell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-03-26 at 00:51 +0100, Hagen Paul Pfeifer wrote:
> * Rick Jones | 2011-03-25 13:24:37 [-0700]:
> 
> Hello Rick
> 
> >Well, one could LD_PRELOAD something that intercepted listen() calls no?
> 
> Noes, for dynamically linked programs yes, for statically linked ones no.
> 
> Furthermore, for distribution shipped programs an administrator would not
> alter the init script or something. Editing /etc/sysctl.conf is as simple
> as ...
> 
> 
> >Is there already a similar minimum the admin can configure when the
> >applications makes "too small" an explicit setsockopt() call against
> >SO_SNDBUF or SO_RCVBUF?
> 
> net.ipv4.tcp_rmem, net.ipv4.tcp_mem, net.core.rmem_default, ...?

I believe (based on my netperf experience) tcp_rmem and tcp_wmem aren't
consulted when one makes an explicit setsockopt() call against the
SO_*BUF sizes. and the net.core.[rw]mem_default are used by UDP sockets:

raj@tardy:~/netperf2_trunk$ uname -a
Linux tardy 2.6.35-28-generic #49-Ubuntu SMP Tue Mar 1 14:39:03 UTC 2011
x86_64 GNU/Linux
raj@tardy:~/netperf2_trunk$ sysctl net.ipv4.tcp_rmem
net.ipv4.tcp_rmem = 4096 87380 4194304
raj@tardy:~/netperf2_trunk$ sysctl net.ipv4.tcp_wmem
net.ipv4.tcp_wmem = 4096 16384 4194304
raj@tardy:~/netperf2_trunk$ sysctl net.core.wmem_default
net.core.wmem_default = 126976
raj@tardy:~/netperf2_trunk$ sysctl net.core.rmem_default
net.core.rmem_default = 126976

(lss == local socket send; rsr == remote socket receive) 

src/netperf -t omni -- -k lss_size,lss_size_end,rsr_size,rsr_size_end
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain
(127.0.0.1) port 0 AF_INET : demo
LSS_SIZE=16384
LSS_SIZE_END=2679048
RSR_SIZE=87380
RSR_SIZE_END=4194304

raj@tardy:~/netperf2_trunk$ src/netperf -t omni -- -k
lss_size,lss_size_end,rsr_size,rsr_size_end -T udp -m 1024
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain
(127.0.0.1) port 0 AF_INET : demo
LSS_SIZE=126976
LSS_SIZE_END=126976
RSR_SIZE=126976
RSR_SIZE_END=126976

I believe that net.core.[rw]mem_max are the upper limits (modulo the
2X?) applied when making explicit setsockopt() calls:

raj@tardy:~/netperf2_trunk$ sysctl net.core.rmem_max
net.core.rmem_max = 131071
raj@tardy:~/netperf2_trunk$ sysctl net.core.wmem_max
net.core.wmem_max = 131071
raj@tardy:~/netperf2_trunk$ src/netperf -t omni -- -k
lss_size,lss_size_end,rsr_size,rsr_size_end -T udp -m 1024 -s 1M -S 1M
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain
(127.0.0.1) port 0 AF_INET : demo
LSS_SIZE=262142
LSS_SIZE_END=262142
RSR_SIZE=262142
RSR_SIZE_END=262142
raj@tardy:~/netperf2_trunk$ src/netperf -t omni -- -k
lss_size,lss_size_end,rsr_size,rsr_size_end -s 1M -S 1M
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain
(127.0.0.1) port 0 AF_INET : demo
LSS_SIZE=262142
LSS_SIZE_END=262142
RSR_SIZE=262142
RSR_SIZE_END=262142

When though one asks for single-byte socket buffers:

raj@tardy:~/netperf2_trunk$ src/netperf -t omni -- -k
lss_size,lss_size_end,rsr_size,rsr_size_end -s 1 -S 1
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain
(127.0.0.1) port 0 AF_INET : demo
LSS_SIZE=2048
LSS_SIZE_END=2048
RSR_SIZE=256
RSR_SIZE_END=256

One gets values that at face value don't seem to be related to sysctl
settings. Although perhaps the receive socket size comes from the min
mss:

raj@tardy:~/netperf2_trunk$ sysctl -a | grep 256
error: permission denied on key 'kernel.cad_pid'
error: permission denied on key 'fs.binfmt_misc.register'
vm.lowmem_reserve_ratio = 256	256	32
fs.mqueue.queues_max = 256
error: permission denied on key 'net.ipv4.route.flush'
net.ipv4.route.min_adv_mss = 256
error: permission denied on key 'net.ipv6.route.flush'
raj@tardy:~/netperf2_trunk$ sysctl -a | grep 2048
error: permission denied on key 'kernel.cad_pid'
error: permission denied on key 'fs.binfmt_misc.register'
error: permission denied on key 'net.ipv4.route.flush'
net.core.optmem_max = 20480
net.ipv4.route.redirect_silence = 2048
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv6.xfrm6_gc_thresh = 2048
error: permission denied on key 'net.ipv6.route.flush'


> IMHO, _if_ a programmer modifies the send or receive buffer he _knows_ exactly
> why. 

I admire your optimism - particularly in the face of all the 10GbE NIC
vendors' suggestions that everyone use 16 MB socket buffers (or at least
set the auto tuning limits to 16 MB).

> If he does not modify the buffer it is fine too, because _we_ tune the
> buffers as good as we can - and we are good in this.

The "bloat" folks might disagree :)

> But, the backlog is different. Often the programmer does _not_ know how to
> tune this variable. And, often the backlog depends on the target system, on
> the network characteristic and the like.

As do the settings for socket buffer sizes.  So, how is it that the
programmer is educated and intelligent enough to set a minimum socket
buffer size but not a minimum listen queue backlog?

> Therefore we provide the system administrator the _ability_ to tune the actual
> backlog.

And, perhaps, do something that flies in the face of what the programmer
was trying to do, by limiting how many connections could be queued and
so changing the behaviour for the N+1st connection attempt while service
was backlogged. 

It really is a rather existential "Who's right? The Programmer or the
Administrator" question.  And perhaps my asking if there should be a
(possibly) foolish consistency.

rick jones

