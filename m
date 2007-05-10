From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: Kernel BUG: NULL pointer dereference , reference to sys_recvmsg
Date: Thu, 10 May 2007 17:07:46 -0400
Message-ID: <464389A2.6080606@redhat.com>
References: <547a31ab0705100712w740e8fbuece5013d05a449b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Croulder Croulder <croulder@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762102AbXEJVIM@vger.kernel.org>
In-Reply-To: <547a31ab0705100712w740e8fbuece5013d05a449b9@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Croulder Croulder wrote:
> The next report is a Kernel NULL pointer dereference in tcp/ip (IPv4).
> 
> I see that message all time in syslog.conf and console.
> 
> Kernel compiled with gcc 4.1.1    ->   (Debian 4.1.1-21)
> Kernel Version: 2.6.21.1 (official source code)
> Processor: 2 x Xeon 2.8
> Ram: 1G
> Swap: 1G
> Raid: Using raid software (Raid1 and Rai5)
> Network report: 2Mb/sg output , 512Kb/sg input
> Protocols: tcp, udp, icmp, arp
> 
> 
> server kernel: EIP: [<c03bc7df>] sys_recvmsg+0x100/0x1cd SS:ESP
> 0068:ec9f1e7c
> May 10 13:41:22 server kernel: BUG: unable to handle kernel NULL
> pointer dereference at virtual address 0000000f
> May 10 13:41:22 server kernel:  printing eip:
> May 10 13:41:22 server kernel: c03bc7df
> May 10 13:41:22 server kernel: *pde = 00000000
> May 10 13:41:22 server kernel: Oops: 0000 [#64]
> May 10 13:41:22 server kernel: SMP
> May 10 13:41:22 server kernel: Modules linked in:
> May 10 13:41:22 server kernel: CPU:    1
> May 10 13:41:22 server kernel: EIP:    0060:[<c03bc7df>]    Not tainted VLI
> May 10 13:41:22 server kernel: EFLAGS: 00010202   (2.6.21.1-dh1 #7)
> May 10 13:41:22 server kernel: EIP is at sys_recvmsg+0x100/0x1cd
> May 10 13:41:22 server kernel: eax: bf5f4148   ebx: 00000000   ecx:
> 00007d00   edx: 00000040
> May 10 13:41:22 server kernel: esi: ffffffff   edi: 00000000   ebp:
> ec9f1f08   esp: ec9f1e7c
> May 10 13:41:22 server kernel: ds: 007b   es: 007b   fs: 00d8  gs:
> 0033  ss: 0068
> May 10 13:41:22 server kernel: Process hlxserverplus (pid: 32149,
> ti=ec9f0000 task=f4bc90b0 task.ti=ec9f0000)
> May 10 13:41:22 server kernel: Stack: 00000001 bf5f4148 00000008
> c0139979 00000002 00000044 00000002 00000000
> May 10 13:41:22 server kernel:        000280d2 c0563630 00000000
> 00000001 3aa4bcb4 00000001 ff4be90f 5761ed52
> May 10 13:41:22 server kernel:        c13edca0 0000096c 000280d2
> c0563628 f4bc90b0 c0139a47 00000044 ec9f1efa
> May 10 13:41:22 server kernel: Call Trace:
> May 10 13:41:22 server kernel:  [<c0139979>]
> get_page_from_freelist+0x24d/0x2c9
> May 10 13:41:22 server kernel:  [<c0139a47>] __alloc_pages+0x52/0x286
> May 10 13:41:22 server kernel:  [<c03f3171>] tcp_v4_hash+0xfe/0x110
> May 10 13:41:22 server kernel:  [<c03bd968>] release_sock+0x12/0x9c
> May 10 13:41:22 server kernel:  [<c03bcf46>] sys_socketcall+0x239/0x242
> May 10 13:41:22 server kernel:  [<c0110bde>] do_page_fault+0x0/0x512
> May 10 13:41:22 server kernel:  [<c0102578>] syscall_call+0x7/0xb
> May 10 13:41:22 server kernel:  =======================
> May 10 13:41:22 server kernel: Code: c0 89 c1 89 84 24 ec 00 00 00 0f
> 88 a9 00 00 00 8b 84 24 dc 00 00 00 c7 84 24 e4 00 00 00 00 00 00 00
> 89 da 83 ca 40 89 44 24 04 <8b> 46 10 f6 40 19 08 89 f0 0f 45 da 8d 94
> 24 cc 00 00 00 89 1c
> May 10 13:41:22 server kernel: EIP: [<c03bc7df>]
> sys_recvmsg+0x100/0x1cd SS:ESP 0068:ec9f1e7c
> 

Here in sys_recvmsg() line 1911:

==>     if (sock->file->f_flags & O_NONBLOCK)
                flags |= MSG_DONTWAIT;
        err = sock_recvmsg(sock, &msg_sys, total_len, flags);

sock == -1, apparently because that's what sockfd_lookup_light() 
returned earlier in the function. (It doesn't check err, just
that the returned sock is nonzero.)
