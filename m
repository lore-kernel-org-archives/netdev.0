From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2 net-next] af_unix: improve STREAM behavior with fragmented memory
Date: Sun, 11 Aug 2013 16:06:05 +0200
Message-ID: <20130811140605.GA5666@order.stressinduktion.org>
References: <1375997852.4004.130.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>,
	David Rientjes <rientjes@google.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44674 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666Ab3HKOGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 10:06:07 -0400
Content-Disposition: inline
In-Reply-To: <1375997852.4004.130.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 08, 2013 at 02:37:32PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> unix_stream_sendmsg() currently uses order-2 allocations,
> and we had numerous reports this can fail.
> 
> The __GFP_REPEAT flag present in sock_alloc_send_pskb() is
> not helping.
> 
> This patch extends the work done in commit eb6a24816b247c
> ("af_unix: reduce high order page allocations) for
> datagram sockets.
> 
> This opens the possibility of zero copy IO (splice() and
> friends)
> 
> The trick is to not use skb_pull() anymore in recvmsg() path,
> and instead add a @consumed field in UNIXCB() to track amount
> of already read payload in the skb.
> 
> There is a performance regression for large sends
> because of extra page allocations that will be addressed
> in a follow-up patch, allowing sock_alloc_send_pskb()
> to attempt high order page allocations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: David Rientjes <rientjes@google.com>

I am sorry to report that I had to revert both these patches to have a working
systemd again.

This is the af_unix stream server side:

$ strace -e network -p 1
Process 1 attached
accept4(9, {sa_family=AF_LOCAL, NULL}, [2], SOCK_CLOEXEC) = 15
getsockname(15, {sa_family=AF_LOCAL, sun_path="/run/systemd/private"}, [23]) = 0
recvmsg(15, {msg_name(0)=NULL, msg_iov(1)=[{"\0", 1}], msg_controllen=0, msg_flags=0}, 0) = 1
getsockopt(15, SOL_SOCKET, SO_PEERCRED, {pid=515, uid=0, gid=0}, [12]) = 0
sendto(15, "OK cfd216826810ecc1c17014b052079"..., 37, MSG_NOSIGNAL, NULL, 0) = 37
sendto(15, "AGREE_UNIX_FD\r\n", 15, MSG_NOSIGNAL, NULL, 0) = 15
getsockopt(15, SOL_SOCKET, SO_PEERSEC, "unconfined_u:unconfined_r:unconf"..., [54]) = 0
socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC, 0) = 28
connect(28, {sa_family=AF_LOCAL, sun_path="/var/run/setrans/.setrans-unix"}, 110) = -1 ENOENT (No such file or directory)
socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC, 0) = 28
connect(28, {sa_family=AF_LOCAL, sun_path="/var/run/setrans/.setrans-unix"}, 110) = -1 ENOENT (No such file or directory)
getsockopt(15, SOL_SOCKET, SO_PEERCRED, {pid=515, uid=0, gid=0}, [12]) = 0
socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC, 0) = 28
connect(28, {sa_family=AF_LOCAL, sun_path="/var/run/setrans/.setrans-unix"}, 110) = -1 ENOENT (No such file or directory)
socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC, 0) = 28
connect(28, {sa_family=AF_LOCAL, sun_path="/var/run/setrans/.setrans-unix"}, 110) = -1 ENOENT (No such file or directory)
sendmsg(15, {msg_name(0)=NULL, msg_iov(2)=[{"l\2\1\0018\233\0\0\1\0\0\0\33\0\0\0\5\1u\0\1\0\0\0\10\1g\0\ra(s"..., 48}, {"0\233\0\0\0\0\0\0\20\0\0\0ebtables.service\0\0\0\0"..., 39736}], msg_controllen=0, msg_flags=0}, MSG_NOSIGNAL) = 39784
recvmsg(15, {msg_name(0)=NULL, msg_iov(1)=[{"", 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 0

This the af_unix stream client side:

socket(PF_LOCAL, SOCK_STREAM|SOCK_CLOEXEC, 0) = 3
connect(3, {sa_family=AF_LOCAL, sun_path="/run/systemd/private"}, 22) = 0
getsockname(3, {sa_family=AF_LOCAL, NULL}, [2]) = 0
getsockopt(3, SOL_SOCKET, SO_PEERCRED, {pid=1, uid=0, gid=0}, [12]) = 0
sendto(3, "\0", 1, MSG_NOSIGNAL, NULL, 0) = 1
sendto(3, "AUTH EXTERNAL 30\r\n", 18, MSG_NOSIGNAL, NULL, 0) = 18
sendto(3, "NEGOTIATE_UNIX_FD\r\n", 19, MSG_NOSIGNAL, NULL, 0) = 19
sendto(3, "BEGIN\r\n", 7, MSG_NOSIGNAL, NULL, 0) = 7
sendmsg(3, {msg_name(0)=NULL, msg_iov(2)=[{"l\1\0\1\0\0\0\0\1\0\0\0\222\0\0\0\1\1o\0\31\0\0\0/org/fre"..., 168}, {"", 0}], msg_controllen=0, msg_flags=0}, MSG_NOSIGNAL) = 168
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"l\2\1\0018\233\0\0\1\0\0\0\33\0\0\0\5\1u\0\1\0\0\0\10\1g\0\ra(s"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"rget\0\0\0\0$\0\0\0systemd-update-utmp-"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"/systemd1/unit/systemd_2duser_2d"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"ed\0\0\10\0\0\0inactive\0\0\0\0\4\0\0\0dead\0\0\0\0"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"emd-random-seed-load.service\0\0\0\0"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"\4\0\0\0dead\0\0\0\0\0\0\0\0\0\0\0\0B\0\0\0/org/fre"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"\6\0\0\0exited\0\0\0\0\0\0\0\0\0\0009\0\0\0/org/fre"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"ode\0\6\0\0\0loaded\0\0\10\0\0\0inactive\0\0\0\0"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"4\0\0\0/org/freedesktop/systemd1/un"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"up_2etarget\0\0\0\0\0\0\0\0\0\0\0\0\0;\0\0\0/org"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"art Card Daemon\0\6\0\0\0loaded\0\0\10\0\0\0"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"inactive\0\0\0\0\4\0\0\0dead\0\0\0\0\0\0\0\0\0\0\0\0"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{".swap\0\0\0006\0\0\0/dev/disk/by-uuid/3b"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"ice\0\0\0\0\0\0\0\0\0\0\0\0\0K\0\0\0/org/freedes"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"s_2dclean_2etimer\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"8250_2dtty_2dttyS1_2edevice\0\0\0\0\0"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{".device\0003\0\0\0/org/freedesktop/sys"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"dblock_2dvda_2edevice\0\0\0\16\0\0\0dev-"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{")\0\0\0SYSV: Initializes network co"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 2048
recvmsg(3, {msg_name(0)=NULL, msg_iov(1)=[{"emd-random-seed-save.service\0\0\0\0"..., 2048}], msg_controllen=0, msg_flags=MSG_CMSG_CLOEXEC}, MSG_CMSG_CLOEXEC) = 872
Failed to issue method call: Did not receive a reply. Possible causes include: the remote application did not send a reply, the message bus security policy blocked the reply, the reply timeout expired, or the network connection was broken.
--- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=516, si_status=0, si_utime=0, si_stime=0} ---

Total bytes consumed here is 19 * 2048 + 872 = 39784 which corresponds to
number of bytes send from the server.

Strange, all this looks normal even if I compare the results to a working
systemctl -a.

When stracing with -s40000 I see that the last string send is
'\0\0/org/freedesktop/systemd1/unit/polkit_2eservice\0' but on the receiver
side I get a '0\0\0/\0\0\0/org/freedesktop/systemd1/unit/prefd'. Which is
actually payload from the second recvmsg on the client side. The rest of the
payload matches up, too.

Maybe you could have a look?

Greetings,

  Hannes
