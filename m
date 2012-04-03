From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Tue, 03 Apr 2012 11:18:39 -0700
Message-ID: <4F7B3EFF.1030706@hp.com>
References: <1333417997.18626.1.camel@edumazet-glaptop> <20120402.215911.1929019308299701014.davem@davemloft.net> <1333419304.18626.5.camel@edumazet-glaptop> <20120402.222300.1137842205135530387.davem@davemloft.net> <4F7A60A4.5040600@hp.com> <1333420452.18626.11.camel@edumazet-glaptop> <4F7A62FE.2050103@hp.com> <1333422844.18626.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, remi@remlab.net,
	levinsasha928@gmail.com, remi.denis-courmont@nokia.com,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333422844.18626.26.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/02/2012 08:14 PM, Eric Dumazet wrote:
> It seems netperf has some problems zith AF_UNIX dgram :
>
> socket(PF_FILE, SOCK_DGRAM, 0)          = 4
> setsockopt(4, SOL_SOCKET, SO_SNDBUF, [0], 4) = 0
> getsockopt(4, SOL_SOCKET, SO_SNDBUF, [2048], [4]) = 0
> setsockopt(4, SOL_SOCKET, SO_RCVBUF, [0], 4) = 0
> getsockopt(4, SOL_SOCKET, SO_RCVBUF, [2288], [4]) = 0
> sendto(3, "\0\0\0+\377\377\377\377\0\0\0\0\0\0\10\0\0\0\0\10\0\0\0\0\0\0\0\0\0\0\0\0"..., 256, 0, NULL, 0) = 256
> select(1024, [3], NULL, NULL, {120, 0}) = 1 (in [3], left {119, 979635})
> recvfrom(3, "\0\0\0,\0\0\0\0\0\0\10\360\0\0\10\0\0\0\0\0\0\0\0\n\0\0\0\0\0\0\0\0"..., 256, 0, NULL, NULL) = 256
> connect(4, {sa_family=AF_FILE, path="/tmp/netpe62HGNM"}, 110) = 0
> rt_sigaction(SIGALRM, {0x403171, [ALRM], SA_RESTORER|SA_INTERRUPT, 0x7f691f026af0}, NULL, 8) = 0
> alarm(10)                               = 0
> sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 2048, 0, NULL, 0) = -1 EMSGSIZE (Message too long)
> dup(2)                                  = 5
> fcntl(5, F_GETFL)                       = 0x8002 (flags O_RDWR|O_LARGEFILE)
> fstat(5, {st_mode=S_IFCHR|0600, st_rdev=makedev(136, 3), ...}) = 0
> mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f691fa18000
> lseek(5, 0, SEEK_CUR)                   = -1 ESPIPE (Illegal seek)
> write(5, "dg_send: data send error: Messag"..., 43dg_send: data send error: Message too long
> ) = 43
> close(5)                                = 0
> munmap(0x7f691fa18000, 4096)            = 0
> exit_group(1)                           = ?
>
> I guess the SO_SNDBUF/SO_RCVBUF limits are a bit too low ?

The AF_UNIX support in netperf is from a time when the code was very 
simplistic - if no socket buffer size specified on the command line, 
take the system default.  If no send size specified, use the SO_SNDBUF 
size, though some limits were applied.

Of course, along the way, there was a change in the value for socket 
buffer size that meant "take the default" - it used to be 0 but then 
became -1.  Something to do with when Windows would decide to do copy 
avoidance - tell Windows the socket buffer size is 0 and it will do copy 
avoidance. The code in src/nettest_unix.c was still initializing to 0 
rather than -1.

I've fixed that in the top-of-trunk:

raj@tardy:~/netperf2_trunk$ src/netperf -t DG_STREAM
DG UNIDIRECTIONAL SEND TEST
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

126976   65507    10.00     1195647      0     811.07
  2288            10.00     1195647            811.07

BTW, the local CPU utilization seems sane, but "remote" (which is 
redundant anyway) seems to be fubar somehow.  More bitrot I suspect.

happy benchmarking,

rick jones
