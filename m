From: Willy Tarreau <w@1wt.eu>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO packets'
Date: Thu, 17 May 2012 23:47:10 +0200
Message-ID: <20120517214710.GA21692@1wt.eu>
References: <20120517121800.GA18052@1wt.eu> <1337287279.3403.44.camel@edumazet-glaptop> <20120517211414.GP14498@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2346 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762166Ab2EQVrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2012 17:47:14 -0400
Content-Disposition: inline
In-Reply-To: <20120517211414.GP14498@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 11:14:14PM +0200, Willy Tarreau wrote:
> On Thu, May 17, 2012 at 10:41:19PM +0200, Eric Dumazet wrote:
> > You drain bytes from fd 0xe to pipe buffers, but I dont see you check
> > write ability on destination socket prior the splice(pipe -> socket)
> 
> I don't, I only rely on EAGAIN to re-enable polling for write (otherwise
> it becomes a real mess of epoll_ctl which sensibly hurts performance). I
> only re-enable polling if FDs can't move anymore.
> 
> Before doing a splice(read), if any data are left pending in the pipe, I
> first try a splice(write) to try to flush the pipe, then I perform the
> splice(read) then try to flush the pipe again using a splice(write).
> Then polling is enabled if we block on EAGAIN.

Just for the sake of documentation, I have rebuilt an up-to-date strace
so that we get the details of the epoll_ctl(). I've restarted with only
the classical epoll (without the events cache) so that it's easier to
trace event status with strace.

Here we clearly see that the output FD (6) was not reported as being
writable for a long period, until haproxy's timeout struck :

15:07:50.130499 gettimeofday({1324652870, 130772}, NULL) = 0
15:07:50.130937 gettimeofday({1324652870, 131071}, NULL) = 0
15:07:50.131195 epoll_wait(3, {}, 6, 1000) = 0
15:07:51.132529 gettimeofday({1324652871, 132654}, NULL) = 0
15:07:51.132777 gettimeofday({1324652871, 132895}, NULL) = 0
15:07:51.133013 epoll_wait(3, {{EPOLLIN, {u32=4, u64=4}}}, 6, 1000) = 1
15:07:51.561594 gettimeofday({1324652871, 561723}, NULL) = 0
15:07:51.561866 accept(4, {sa_family=AF_INET, sin_port=htons(56441), sin_addr=inet_addr("192.168.0.31")}, [16]) = 6
15:07:51.562249 fcntl64(6, F_SETFL, O_RDONLY|O_NONBLOCK) = 0
15:07:51.562582 setsockopt(6, SOL_TCP, TCP_NODELAY, [1], 4) = 0
15:07:51.562844 accept(4, 0x7ea65a64, [128]) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.563142 epoll_ctl(3, EPOLL_CTL_ADD, 6, {EPOLLIN, {u32=6, u64=6}}) = 0
15:07:51.563421 gettimeofday({1324652871, 563540}, NULL) = 0
15:07:51.563657 epoll_wait(3, {{EPOLLIN, {u32=6, u64=6}}}, 7, 1000) = 1
15:07:51.563923 gettimeofday({1324652871, 564041}, NULL) = 0
15:07:51.564180 recv(6, "GET /?s=1g HTTP/1.0\r\nUser-Agent:"..., 7000, 0) = 126
15:07:51.564574 socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 7
15:07:51.564817 fcntl64(7, F_SETFL, O_RDONLY|O_NONBLOCK) = 0
15:07:51.565040 setsockopt(7, SOL_TCP, TCP_NODELAY, [1], 4) = 0
15:07:51.565277 setsockopt(7, SOL_TCP, TCP_QUICKACK, [0], 4) = 0
15:07:51.565524 connect(7, {sa_family=AF_INET, sin_port=htons(8000), sin_addr=inet_addr("192.168.0.31")}, 16) = -1 EINPROGRESS (Operation now in progress)
15:07:51.565955 epoll_ctl(3, EPOLL_CTL_ADD, 7, {EPOLLOUT, {u32=7, u64=7}}) = 0
15:07:51.566235 epoll_ctl(3, EPOLL_CTL_DEL, 6, {0, {u32=6, u64=6}}) = 0
15:07:51.566494 gettimeofday({1324652871, 566613}, NULL) = 0
15:07:51.566730 epoll_wait(3, {{EPOLLOUT, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.566994 gettimeofday({1324652871, 567114}, NULL) = 0
15:07:51.567246 send(7, "GET /?s=1g HTTP/1.0\r\nUser-Agent:"..., 107, MSG_DONTWAIT|MSG_NOSIGNAL) = 107
15:07:51.567589 epoll_ctl(3, EPOLL_CTL_MOD, 7, {EPOLLIN, {u32=7, u64=7}}) = 0
15:07:51.567907 gettimeofday({1324652871, 568031}, NULL) = 0
15:07:51.568148 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.568471 gettimeofday({1324652871, 568593}, NULL) = 0
15:07:51.568715 recv(7, "HTTP/1.1 200\r\nConnection: close\r"..., 7000, 0) = 4380
15:07:51.569057 recv(7, "89.12345678\n.123456789.123456789"..., 2620, 0) = 2620
15:07:51.569425 epoll_ctl(3, EPOLL_CTL_DEL, 7, {0, {u32=7, u64=7}}) = 0
15:07:51.569745 epoll_ctl(3, EPOLL_CTL_ADD, 6, {EPOLLOUT, {u32=6, u64=6}}) = 0
15:07:51.570013 gettimeofday({1324652871, 570133}, NULL) = 0
15:07:51.570251 epoll_wait(3, {{EPOLLOUT, {u32=6, u64=6}}}, 8, 1000) = 1
15:07:51.570514 gettimeofday({1324652871, 570634}, NULL) = 0
15:07:51.570754 send(6, "HTTP/1.1 200\r\nConnection: close\r"..., 7000, MSG_DONTWAIT|MSG_NOSIGNAL|MSG_MORE) = 7000
15:07:51.571244 epoll_ctl(3, EPOLL_CTL_DEL, 6, {0, {u32=6, u64=6}}) = 0
15:07:51.571518 epoll_ctl(3, EPOLL_CTL_ADD, 7, {EPOLLIN, {u32=7, u64=7}}) = 0
15:07:51.571825 gettimeofday({1324652871, 571947}, NULL) = 0
15:07:51.572064 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.572355 gettimeofday({1324652871, 572476}, NULL) = 0
15:07:51.572617 pipe([8, 9])            = 0
15:07:51.572863 fcntl64(8, 0x407 /* F_??? */, 0x40000) = 262144
15:07:51.573107 splice(7, NULL, 9, NULL, 1073734988, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 9060
15:07:51.573408 splice(7, NULL, 9, NULL, 1073725928, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 1460
15:07:51.573696 splice(7, NULL, 9, NULL, 1073724468, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.573942 splice(8, NULL, 6, NULL, 10520, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 10520
15:07:51.574328 gettimeofday({1324652871, 574452}, NULL) = 0
15:07:51.574572 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.574988 gettimeofday({1324652871, 575112}, NULL) = 0
15:07:51.575235 splice(7, NULL, 9, NULL, 1073724468, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 16060
15:07:51.575513 splice(8, NULL, 6, NULL, 16060, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 16060
15:07:51.575878 gettimeofday({1324652871, 576003}, NULL) = 0
15:07:51.576142 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.576510 gettimeofday({1324652871, 576631}, NULL) = 0
15:07:51.576753 splice(7, NULL, 9, NULL, 1073708408, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 11680
15:07:51.577027 splice(8, NULL, 6, NULL, 11680, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 11680
15:07:51.577358 gettimeofday({1324652871, 577480}, NULL) = 0
15:07:51.577614 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.577959 gettimeofday({1324652871, 578080}, NULL) = 0
15:07:51.578201 splice(7, NULL, 9, NULL, 1073696728, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 13140
15:07:51.578492 splice(8, NULL, 6, NULL, 13140, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 13140
15:07:51.578799 gettimeofday({1324652871, 578921}, NULL) = 0
15:07:51.579057 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.579413 gettimeofday({1324652871, 579534}, NULL) = 0
15:07:51.579654 splice(7, NULL, 9, NULL, 1073683588, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 14600
15:07:51.579927 splice(8, NULL, 6, NULL, 14600, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 14600
15:07:51.580260 gettimeofday({1324652871, 580389}, NULL) = 0
15:07:51.580526 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.580952 gettimeofday({1324652871, 581073}, NULL) = 0
15:07:51.581195 splice(7, NULL, 9, NULL, 1073668988, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 16060
15:07:51.581491 splice(8, NULL, 6, NULL, 16060, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 16060
15:07:51.581801 gettimeofday({1324652871, 581930}, NULL) = 0
15:07:51.582173 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.582475 gettimeofday({1324652871, 582597}, NULL) = 0
15:07:51.582719 splice(7, NULL, 9, NULL, 1073652928, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 17520
15:07:51.582998 splice(8, NULL, 6, NULL, 17520, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 17520
15:07:51.583345 gettimeofday({1324652871, 583476}, NULL) = 0
15:07:51.583725 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.584001 gettimeofday({1324652871, 584131}, NULL) = 0
15:07:51.584329 splice(7, NULL, 9, NULL, 1073635408, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 29200
15:07:51.584599 splice(8, NULL, 6, NULL, 29200, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 24820
15:07:51.584968 epoll_ctl(3, EPOLL_CTL_ADD, 6, {EPOLLOUT, {u32=6, u64=6}}) = 0

Here FD6 was enabled on output since some data remained in the pipe.

15:07:51.585244 gettimeofday({1324652871, 585374}, NULL) = 0
15:07:51.585583 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.585852 gettimeofday({1324652871, 585972}, NULL) = 0
15:07:51.586093 splice(7, NULL, 9, NULL, 1073606208, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 45260
15:07:51.586384 splice(8, NULL, 6, NULL, 49640, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.586668 gettimeofday({1324652871, 586789}, NULL) = 0
15:07:51.586908 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.587246 gettimeofday({1324652871, 587367}, NULL) = 0
15:07:51.587488 splice(7, NULL, 9, NULL, 1073560948, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 20440
15:07:51.587764 splice(8, NULL, 6, NULL, 70080, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.588045 gettimeofday({1324652871, 588166}, NULL) = 0
15:07:51.588284 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.588641 gettimeofday({1324652871, 588762}, NULL) = 0
15:07:51.588882 splice(7, NULL, 9, NULL, 1073540508, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 23360
15:07:51.589157 splice(8, NULL, 6, NULL, 93440, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.589438 gettimeofday({1324652871, 589558}, NULL) = 0
15:07:51.589677 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.590041 gettimeofday({1324652871, 590163}, NULL) = 0
15:07:51.590284 splice(7, NULL, 9, NULL, 1073517148, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.590533 splice(8, NULL, 6, NULL, 93440, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.590781 epoll_ctl(3, EPOLL_CTL_DEL, 7, {0, {u32=7, u64=7}}) = 0
15:07:51.591054 gettimeofday({1324652871, 591173}, NULL) = 0
15:07:51.591290 epoll_wait(3, {{EPOLLOUT, {u32=6, u64=6}}}, 8, 1000) = 1

write reported on FD6

15:07:51.623172 gettimeofday({1324652871, 623304}, NULL) = 0
15:07:51.623430 splice(8, NULL, 6, NULL, 93440, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 74460

74kB sent, 18980 bytes remaining, FD status not changed.

15:07:51.623739 epoll_ctl(3, EPOLL_CTL_ADD, 7, {EPOLLIN, {u32=7, u64=7}}) = 0
15:07:51.624009 gettimeofday({1324652871, 624128}, NULL) = 0
15:07:51.624246 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.624510 gettimeofday({1324652871, 624629}, NULL) = 0
15:07:51.624749 splice(7, NULL, 9, NULL, 1073517148, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 59860
15:07:51.625067 splice(8, NULL, 6, NULL, 78840, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.625357 gettimeofday({1324652871, 625479}, NULL) = 0
15:07:51.625597 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.625970 gettimeofday({1324652871, 626092}, NULL) = 0
15:07:51.626213 splice(7, NULL, 9, NULL, 1073457288, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = 14600
15:07:51.626490 splice(8, NULL, 6, NULL, 93440, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.626773 gettimeofday({1324652871, 626894}, NULL) = 0
15:07:51.627013 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 1000) = 1
15:07:51.627387 gettimeofday({1324652871, 627509}, NULL) = 0
15:07:51.627630 splice(7, NULL, 9, NULL, 1073442688, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.627883 splice(8, NULL, 6, NULL, 93440, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:51.628131 epoll_ctl(3, EPOLL_CTL_DEL, 7, {0, {u32=7, u64=7}}) = 0

And here we're blocked on both FDs. We disable polling for reads on the input
FD since the pipe is full. We have still not disabled events on FD6, which is
not reported anymore.

15:07:51.628389 gettimeofday({1324652871, 628508}, NULL) = 0
15:07:51.628625 epoll_wait(3, {}, 8, 1000) = 0
15:07:52.629938 gettimeofday({1324652872, 630103}, NULL) = 0
15:07:52.630232 gettimeofday({1324652872, 630364}, NULL) = 0
15:07:52.630481 epoll_wait(3, {}, 8, 1000) = 0
15:07:53.631760 gettimeofday({1324652873, 631895}, NULL) = 0
15:07:53.632018 gettimeofday({1324652873, 632146}, NULL) = 0
15:07:53.632289 epoll_wait(3, {}, 8, 1000) = 0
15:07:54.633641 gettimeofday({1324652874, 633770}, NULL) = 0
15:07:54.633896 gettimeofday({1324652874, 634017}, NULL) = 0
15:07:54.634135 epoll_wait(3, {}, 8, 1000) = 0
15:07:55.635457 gettimeofday({1324652875, 635582}, NULL) = 0
15:07:55.635705 gettimeofday({1324652875, 635824}, NULL) = 0
15:07:55.635943 epoll_wait(3, {}, 8, 930) = 0
15:07:56.567197 gettimeofday({1324652876, 567322}, NULL) = 0
15:07:56.567448 gettimeofday({1324652876, 567568}, NULL) = 0
15:07:56.567685 epoll_wait(3, {}, 8, 1000) = 0
15:07:57.568855 gettimeofday({1324652877, 569012}, NULL) = 0
15:07:57.569145 gettimeofday({1324652877, 569278}, NULL) = 0
15:07:57.569396 epoll_wait(3, {}, 8, 1000) = 0
15:07:58.570760 gettimeofday({1324652878, 570899}, NULL) = 0
15:07:58.571023 gettimeofday({1324652878, 571154}, NULL) = 0
15:07:58.571270 epoll_wait(3, {}, 8, 999) = 0
15:07:59.571418 gettimeofday({1324652879, 571546}, NULL) = 0

Timeout strikes, we're about to close. It happens that the FD is re-enabled
at this point. That doesn't really matter anyway.

15:07:59.571688 epoll_ctl(3, EPOLL_CTL_ADD, 7, {EPOLLIN, {u32=7, u64=7}}) = 0
15:07:59.571964 gettimeofday({1324652879, 572084}, NULL) = 0
15:07:59.572227 epoll_wait(3, {{EPOLLIN, {u32=7, u64=7}}}, 8, 57) = 1
15:07:59.572499 gettimeofday({1324652879, 572619}, NULL) = 0
15:07:59.572742 splice(7, NULL, 9, NULL, 1073442688, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)
15:07:59.573010 splice(8, NULL, 6, NULL, 93440, SPLICE_F_MOVE|SPLICE_F_NONBLOCK) = -1 EAGAIN (Resource temporarily unavailable)

The FD 6 was still blocked.

15:07:59.573269 epoll_ctl(3, EPOLL_CTL_DEL, 7, {0, {u32=7, u64=7}}) = 0
15:07:59.573529 gettimeofday({1324652879, 573649}, NULL) = 0
15:07:59.573766 epoll_wait(3, {}, 8, 56) = 0
15:07:59.630081 gettimeofday({1324652879, 630202}, NULL) = 0
15:07:59.630327 setsockopt(6, SOL_SOCKET, SO_LINGER, {onoff=1, linger=0}, 8) = 0
15:07:59.630594 close(6)                = 0
15:07:59.630909 close(7)                = 0

FDs are closed.

15:07:59.631424 close(9)                = 0
15:07:59.631746 close(8)                = 0

And pipe is killed because it contains remaining data.

Regards,
Willy
