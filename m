From: Willy Tarreau <w@1wt.eu>
Subject: Re: GRO + splice panics in 3.7.0-rc5
Date: Sat, 1 Dec 2012 20:43:04 +0100
Message-ID: <20121201194304.GI25450@1wt.eu>
References: <20121115222812.GA647@1wt.eu> <1353023344.10798.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:36366 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873Ab2LATnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 14:43:12 -0500
Content-Disposition: inline
In-Reply-To: <1353023344.10798.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Nov 15, 2012 at 03:49:04PM -0800, Eric Dumazet wrote:
> On Thu, 2012-11-15 at 23:28 +0100, Willy Tarreau wrote:
> > Hello,
> > 
> > I was just about to make a quick comparison between LRO and GRO in
> > 3.7.0-rc5 to see if LRO still had the big advantage I've always observed,
> > but I failed the test because as soon as I enable LRO + splice, the kernel
> > panics and reboots.
> > 
> > I could not yet manage to catch the panic output, I could just reliably
> > reproduce it, it crashes instantly.
> > 
> > All I can say at the moment is the following :
> >   - test consist in forwarding HTTP traffic between two NICs via haproxy
> >   - driver used was myri10ge
> >   - LRO + recv+send : OK
> >   - LRO + splice : OK
> >   - GRO + recv+send : OK
> >   - GRO + splice : panic
> >   - no such problem was observed in 3.6.6 so I think this is a recent
> >     regression.
> > 
> > I'll go back digging for more information, but as I'm used to often see
> > Eric suggest the right candidates for reverting, I wanted to report the
> > issue here in case there are easy ones to try first.
> 
> Hi Willy
> 
> Nothing particular comes to mind, there were a lot of recent changes
> that could trigger this kind of bug.
> 
> A stack trace would be useful of course ;)

First, sorry for the long delay, I would really have liked to debug
this earlier.

I could finally bisect the regression to this commit :

  69b08f62e17439ee3d436faf0b9a7ca6fffb78db is the first bad commit
  commit 69b08f62e17439ee3d436faf0b9a7ca6fffb78db
  Author: Eric Dumazet <edumazet@google.com>
  Date:   Wed Sep 26 06:46:57 2012 +0000

    net: use bigger pages in __netdev_alloc_frag

The regression is still present in latest git (7c17e486), and goes away
if I revert this patch.

I get this trace both on my 64-bit 10Gig machines with a myri10ge NIC,
and on my 32-bit eeepc with an atl1c NIC at 100 Mbps, so this is not
related to the driver nor the architecture.

The trace looks like this on my eeepc, it crashes in tcp_sendpage()
(more precisely in do_tcp_sendpages() which was inlined in the former) :

BUG: unable to handle kernel NULL pointer dereference at 00000b50
IP: [<c13fdf9c>] tcp_sendpage+0x28c/0x5d0
*pde = 00000000 
Oops: 0000 [#1] SMP 
Modules linked in: snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss uvcvideo videobuf2_core videobuf2_vmalloc videobuf2_memops ath9k mac80211 snd_hda_codec_realtek microcode ath9k_common psmouse ath9k_hw serio_raw uhci_hcd ath sg cfg80211 snd_hda_intel lpc_ich ehci_hcd mfd_core snd_hda_codec atl1c snd_hwdep rtc_cmos snd_pcm snd_timer snd snd_page_alloc eeepc_laptop sparse_keymap evdev
Pid: 2880, comm: haproxy Not tainted 3.7.0-rc7-eeepc #1 ASUSTeK Computer INC. 1005HA/1005HA
EIP: 0060:[<c13fdf9c>] EFLAGS: 00210246 CPU: 0
EIP is at tcp_sendpage+0x28c/0x5d0
EAX: c16a4138 EBX: f5202500 ECX: 00000b50 EDX: f5a72f68
ESI: f5333cc0 EDI: 000005a8 EBP: f55b7e34 ESP: f55b7df0
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
CR0: 8005003b CR2: 00000b50 CR3: 35556000 CR4: 000007d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
Process haproxy (pid: 2880, ti=f55b6000 task=f62060c0 task.ti=f55b6000)
Stack:
 00000000 00000002 00000000 00000582 02000000 f52025a0 000005a8 00000002
 00000b50 00001582 00000000 f6eb3900 00000b50 00000000 f5202500 c13fdd10
 00000040 f55b7e5c c14201c7 000005a8 00000040 f55b7ecc f6eb3900 f5fc1680
Call Trace:
 [<c13fdd10>] ? sk_stream_alloc_skb+0xf0/0xf0
 [<c14201c7>] inet_sendpage+0x57/0xc0
 [<c1420170>] ? inet_dgram_connect+0x80/0x80
 [<c13b6d99>] kernel_sendpage+0x29/0x50
 [<c13b6de8>] sock_sendpage+0x28/0x30
 [<c13b6dc0>] ? kernel_sendpage+0x50/0x50
 [<c10e55b5>] pipe_to_sendpage+0x65/0x80
 [<c10e5647>] splice_from_pipe_feed+0x77/0x150
 [<c10e5550>] ? splice_from_pipe_begin+0x10/0x10
 [<c10e5a84>] __splice_from_pipe+0x54/0x60
 [<c10e5550>] ? splice_from_pipe_begin+0x10/0x10
 [<c10e7190>] splice_from_pipe+0x50/0x70
 [<c10e7200>] ? default_file_splice_write+0x50/0x50
 [<c10e7222>] generic_splice_sendpage+0x22/0x30
 [<c10e5550>] ? splice_from_pipe_begin+0x10/0x10
 [<c10e5af6>] do_splice_from+0x66/0x90
 [<c10e787f>] sys_splice+0x42f/0x480
 [<c14671cc>] syscall_call+0x7/0xb
 [<c1460000>] ? blk_iopoll_cpu_notify+0x2c/0x5d
Code: 7d 08 0f 47 7d 08 39 f8 0f 4e f8 8b 43 1c 8b 40 60 85 c0 74 09 39 7b 64 0f 8c 21 01 00 00 80 7d ce 00 0f 85 ef 00 00 00 8b 4d dc <8b> 01 f6 c4 80 0f 85 0e 03 00 00 8b 45 dc f0 ff 40 10 8b 55 d8
EIP: [<c13fdf9c>] tcp_sendpage+0x28c/0x5d0 SS:ESP 0068:f55b7df0
CR2: 0000000000000b50
---[ end trace a07522433caf9655 ]---

In order to reproduce it, I'm just running haproxy with TCP splicing
enabled. It simply forwards data from one TCP socket to another one.

In case this matters, here's what the sequence looks like when it works
(just relevant syscalls). fd 7 = client retrieving data, fd 8 = server
providing data :

  socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 8
  fcntl64(8, F_SETFL, O_RDONLY|O_NONBLOCK) = 0
  setsockopt(8, SOL_TCP, TCP_NODELAY, [1], 4) = 0
  connect(8, {sa_family=AF_INET, sin_port=htons(8000), sin_addr=inet_addr("10.8.3.1")}, 16) = -1 EINPROGRESS (Operation now in progress)
  send(8, "GET /?s=100k HTTP/1.1\r\nConnection"..., 120, MSG_DONTWAIT|MSG_NOSIGNAL) = 120
  pipe([9, 10])                           = 0

  splice(0x8, 0, 0xa, 0, 0x40000000, 0x3) = 5792
  splice(0x8, 0, 0xa, 0, 0x40000000, 0x3) = 1448
  splice(0x8, 0, 0xa, 0, 0x40000000, 0x3) = -1 EAGAIN (Resource temporarily unavailable)
  splice(0x9, 0, 0x7, 0, 0x1c48, 0x3)     = 7240

And the splice() block above repeats over and over with varying sizes.

It's worth mentionning that the issue does not happend when recv/send are
used instead of splice(). Changing the pipe size using F_SETPIPE_SZ does
not change the behaviour either (was using 1 MB when it first appeared and
thought it was the cause).

I managed to catch the oops with strace running on the process. It crashed
on the first splice() call on the sending side and confirms the stack trace :

  pipe([9, 10])                           = 0
  splice(0x8, 0, 0xa, 0, 0x40000000, 0x3) = 10136
  splice(0x9, 0, 0x7, 0, 0x2798, 0x3)     ---> never completes, oops here.

Are there any additional information I can provide to help debug this ?

Seeing what the patch does, I don't think it's the direct responsible
but that it triggers an existing bug somewhere else. However I don't
know how to try to trigger the same bug without the patch.

The corresponding disassembled code looks like this :

    1ee3:       0f 47 7d 08             cmova  0x8(%ebp),%edi
    1ee7:       39 f8                   cmp    %edi,%eax
    1ee9:       0f 4e f8                cmovle %eax,%edi
    1eec:       8b 43 1c                mov    0x1c(%ebx),%eax
    1eef:       8b 40 60                mov    0x60(%eax),%eax
    1ef2:       85 c0                   test   %eax,%eax
    1ef4:       74 09                   je     1eff <tcp_sendpage+0x27f>
    1ef6:       39 7b 64                cmp    %edi,0x64(%ebx)
    1ef9:       0f 8c 21 01 00 00       jl     2020 <tcp_sendpage+0x3a0>
    1eff:       80 7d ce 00             cmpb   $0x0,-0x32(%ebp)
    1f03:       0f 85 ef 00 00 00       jne    1ff8 <tcp_sendpage+0x378>
    1f09:       8b 4d dc                mov    -0x24(%ebp),%ecx
--> 1f0c:       8b 01                   mov    (%ecx),%eax
    1f0e:       f6 c4 80                test   $0x80,%ah
    1f11:       0f 85 0b 03 00 00       jne    2222 <tcp_sendpage+0x5a2>
    1f17:       8b 45 dc                mov    -0x24(%ebp),%eax
    1f1a:       f0 ff 40 10             lock incl 0x10(%eax)
    1f1e:       8b 55 d8                mov    -0x28(%ebp),%edx
    1f21:       8b 4d dc                mov    -0x24(%ebp),%ecx
    1f24:       8d 04 d5 20 00 00 00    lea    0x20(,%edx,8),%eax
    1f2b:       03 86 90 00 00 00       add    0x90(%esi),%eax

This seems to be at the beginning of this block, at new_segment :

   866                  int size = min_t(size_t, psize, PAGE_SIZE - offset);
   867                  bool can_coalesce;
   868
   869                  if (!tcp_send_head(sk) || (copy = size_goal - skb->len) <= 0) {
   870  new_segment:
   871                          if (!sk_stream_memory_free(sk))
   872                                  goto wait_for_sndbuf;
   873

I'm trying to add some debug code.

Regards,
Willy
