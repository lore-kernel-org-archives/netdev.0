From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: net/sctp: use-after-free in __sctp_connect
Date: Thu, 21 Jan 2016 15:18:18 -0200
Message-ID: <20160121171818.GB3452@mrl.redhat.com>
References: <CACT4Y+YjpSKvD5t8e6wKzE8+j3rFzf_Ep+23WjW1Mg3ws6cOCw@mail.gmail.com>
 <20160115190106.GG6074@mrl.redhat.com>
 <569E4A7E.4080301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <569E4A7E.4080301@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 19, 2016 at 09:38:54AM -0500, Vlad Yasevich wrote:
> On 01/15/2016 02:01 PM, Marcelo Ricardo Leitner wrote:
> > On Wed, Jan 13, 2016 at 10:52:31AM +0100, Dmitry Vyukov wrote:
> >> Hello,
> >>
> >> The following program causes use-after-free in __sctp_connect:
> >>
> > ...
> >> INFO: Freed in sctp_association_put+0x150/0x250 age=0 cpu=3 pid=15267
> >> [<      none      >] __slab_free+0x1fc/0x320 mm/slub.c:2678
> >> [<     inline     >] slab_free mm/slub.c:2833
> >> [<      none      >] kfree+0x2a8/0x2d0 mm/slub.c:3662
> >> [<     inline     >] sctp_association_destroy net/sctp/associola.c:424
> >> [<      none      >] sctp_association_put+0x150/0x250 net/sctp/associola.c:860
> >> [<      none      >] sctp_wait_for_connect+0x37c/0x4f0 net/sctp/socket.c:7067
> >                          ^^^^^^^^^^^^^^
> >> [<      none      >] __sctp_connect+0x905/0xb90 net/sctp/socket.c:1215
> >> [<      none      >] __sctp_setsockopt_connectx+0x198/0x1d0
> >> net/sctp/socket.c:1328
> >> [<     inline     >] sctp_setsockopt_connectx net/sctp/socket.c:1360
> >> [<      none      >] sctp_setsockopt+0x226/0x3630 net/sctp/socket.c:3728
> >> [<      none      >] sock_common_setsockopt+0x95/0xd0 net/core/sock.c:2642
> >> [<     inline     >] SYSC_setsockopt net/socket.c:1752
> >> [<      none      >] SyS_setsockopt+0x158/0x240 net/socket.c:1731
> >> [<      none      >] entry_SYSCALL_64_fastpath+0x16/0x7a
> >> arch/x86/entry/entry_64.S:185
> > 
> > This one may sher some light on that other socket leak one, because the
> > association shouldn't have been freed at that point.
> > Now, how it managed to unbalance that refcnt, hmm...
> > 
> 
> The free may be a result of implicit close when the program ends.  If the thread
> is still waiting for connect to finish when the program ends, we may end up
> in a situation when the association has been freed, but the ref held by wait_for_connect
> prevents the destruction.  When wait_for_connect finishes in puts the ref and
> causes the destruction.

That could be it, yes.

> What I am guessing is happing is the wait_for_connect doesn't catch the error condition
> correctly and thus __sctp_connect() doesn't think there was and error and references
> the assoc which was just destroyed.

Perfect. There is another thing that this program exploits that, in this
case, leads to this. It's creating a tcp-style socket, calling connect()
on it in one thread and sendto() to a different peer in the main thread
probably while the connect is still in progress. Seems that can lead to
one having two assocs on a tcp-style socket, because we don't check if
we the socket has associations but if it's in established state. I don't
see the checks on sctp_sendmsg() protecting from this case.

2511  14:55:10 socket(PF_INET6, SOCK_STREAM, IPPROTO_SCTP) = 3
<0.000366> 
2511  14:55:10 mmap(0x20000000, 65536, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x20000000 <0.000082>
2511  14:55:10 bind(3, {sa_family=AF_INET6, sin6_port=htons(13280),
inet_pton(AF_INET6, "::1", &sin6_addr), sin6_flowinfo=1882116169,
sin6_scope_id=3305060172}, 28) = 0 <0.000119>
 - bound to IPv6

2511  14:55:10 mmap(NULL, 8392704, PROT_READ|PROT_WRITE,
MAP_PRIVATE|MAP_ANONYMOUS|MAP_STACK, -1, 0) = 0x7f52f9e75000 <0.000084>
2511  14:55:10 brk(0)                   = 0x1cf8000 <0.000065>            
2511  14:55:10 brk(0x1d19000)           = 0x1d19000 <0.000079>            
2511  14:55:10 brk(0)                   = 0x1d19000 <0.000064>            
2511  14:55:10 mprotect(0x7f52f9e75000, 4096, PROT_NONE) = 0 <0.000091>   
2511  14:55:10 clone(child_stack=0x7f52fa674ff0,
flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID,
parent_tidptr=0x7f52fa6759d0, tls=0x7f52fa675700,
child_tidptr=0x7f52fa6759d0) = 2512 <0.000211>
2511  14:55:10 setsockopt(3, SOL_SOCKET, SO_LINGER, {onoff=6, linger=0},
8 <unfinished ...>
2512  14:55:10 set_robust_list(0x7f52fa6759e0, 24 <unfinished ...>        
2511  14:55:10 <... setsockopt resumed> ) = 0 <0.000135>                  
2512  14:55:10 <... set_robust_list resumed> ) = 0 <0.000133>             
2511  14:55:10 sendfile(3, 3, [0], 192 <unfinished ...>                   
2512  14:55:10 connect(3, {sa_family=AF_INET, sin_port=htons(13273),
sin_addr=inet_addr("127.0.0.1")}, 128 <unfinished ...>
 - connect to IPv4. This connect should timeout, as we can't find a
 route between ipv4/ipv6.
 - no packet is sent due to this

2511  14:55:10 <... sendfile resumed> ) = -1 ESPIPE (Illegal seek)
<0.000146>
2511  14:55:10 rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0 <0.000066>    
2511  14:55:10 rt_sigaction(SIGCHLD, NULL, {SIG_DFL, [], 0}, 8) = 0
<0.000065>
2511  14:55:10 rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0 <0.000067>    
2511  14:55:10 nanosleep({4, 0}, 0x7ffffd73eee0) = 0 <4.000258>           
 - added a sleep(4) to make this more evident

2511  14:55:14 sendto(3,
"\0\0\0\0\0\0\0\1\335\1\370\375\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
112, 0, {sa_family=AF_INET6, sin6_port=htons(13276), inet_pton(AF_INET6,
"::1", &sin6_addr), sin6_flowinfo=3512421652, sin6_scope_id=4260889053},
128) = 112 <0.001601>
 - sendto() to an IPv6 addr while connect() is still running.
 - socket is not in established state.
 - assoc is not a peeled off, as we can't find a transport using this
 tuple
 - so this new assoc ends up being allowed under a tcp-style socket
 - nobody is listening on 13276. An ABORT is sent back

2512  14:55:14 <... connect resumed> )  = -1 ECONNREFUSED (Connection
refused) <4.003595>
 - And suddenly the connect() is confused and thinks the error was for
 it, exact after sendto() auto-association noticed the error.
 - Funny thing is, as sendto() thinks it succeeded, as connect() already
 consumed the error via sctp_error().

If the program was ending and if the threads awakening were the other
way around, e.g. if connect() had started a bit after sendto(),
connect() probably would have thought it succeeded, and referenced the
freed memory.

I'm thinking we should add a function to better identify busy sockets
such as this. Like in __sctp_connect(), issuing connect()s in parallel
will also fool current checks. Thoughts?

  Marcelo
