From: "Johann Baudy" <johaahn@gmail.com>
Subject: Re: Packet mmap: TX RING and zero copy
Date: Thu, 4 Sep 2008 16:44:15 +0200
Message-ID: <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com>
References: <7e0dd21a0809030056q2bfd0344kf3b86a90a4b3fc5f@mail.gmail.com>
	 <20080903.040626.198546183.davem@davemloft.net>
	 <7e0dd21a0809030605odc28306re8b7640f0632ac36@mail.gmail.com>
	 <20080903132734.GA17541@2ka.mipt.ru>
	 <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com>
	 <20080903151340.GA7566@2ka.mipt.ru>
	 <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com>
	 <20080903164346.GA6729@2ka.mipt.ru>
	 <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com>
	 <20080903220347.GA22395@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:63499 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752658AbYIDOoQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 10:44:16 -0400
Received: by rv-out-0506.google.com with SMTP id k40so3325868rvb.1
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2008 07:44:16 -0700 (PDT)
In-Reply-To: <20080903220347.GA22395@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,


> Looks like you try to sendfile() over packet socket.
> Both tcp and udp sockets have sendpage method.
>
> Or your hardware or driver do not support needed fucntionality, so
> tcp_sendpage() falls back to sock_no_sendpage(). From your dump I thi=
nk
> it is the first case above. Well, after I read it again, I found word
> packet_sendmsg(), which explains everything. Please use tcp or udp
> socket for splice/sendfile test.
>

I'm finally able to run a full zero copy mechanism with UDP socket as y=
ou said.
Unfortunately, I need at least one vmsplice() system call per UDP
packet (vmsplice call()).
mere vmsplice(mem to pipe) cost much (80=B5s of CPU). And splice(pipe t=
o
socket) call is worst...
80us is approximately the duration of 12Kbytes sent at 1Gbps. As I
need to send packet of 7200bytes (with no frag)...
I can't use this mechanism unfortunaltely. I've only reached 20Mbytes/s=
=2E

You can find below a FTRACE of vmsplice(), if you find something
abnormal ... :) :
(80=B5s result is an average of vmsplice() duration thanks to
gettimeofday(): WITHOUT FTRACE IN KERNEL CONFIG)

      main-849   [00] ..  1 4154502892.139088: sys_gettimeofday
<-ret_from_syscall
            main-849   [00] ..  1 4154502892.139090: do_gettimeofday
<-sys_gettimeofday
            main-849   [00] ..  1 4154502892.139092: getnstimeofday
<-do_gettimeofday
            main-849   [00] ..  1 4154502892.139100: sys_vmsplice
<-ret_from_syscall
            main-849   [00] ..  1 4154502892.139107: fget_light <-sys_v=
msplice
            main-849   [00] ..  1 4154502892.139118: rt_down_read <-sys=
_vmsplice
            main-849   [00] ..  1 4154502892.139120: __rt_down_read
<-rt_down_read
            main-849   [00] ..  1 4154502892.139124:
rt_mutex_down_read <-__rt_down_read
            main-849   [00] ..  1 4154502892.139132: pagefault_disable
<-sys_vmsplice
            main-849   [00] ..  1 4154502892.139136: pagefault_enable
<-sys_vmsplice
            main-849   [00] ..  1 4154502892.139141: get_user_pages
<-sys_vmsplice
            main-849   [00] ..  1 4154502892.139147: find_extend_vma
<-get_user_pages
            main-849   [00] ..  1 4154502892.139150: find_vma <-find_ex=
tend_vma
            main-849   [00] ..  1 4154502892.139158: _cond_resched
<-get_user_pages
            main-849   [00] ..  1 4154502892.139161: follow_page
<-get_user_pages
            main-849   [00] ..  1 4154502892.139165: rt_spin_lock <-fol=
low_page
            main-849   [00] ..  1 4154502892.139167: __rt_spin_lock
<-rt_spin_lock
            main-849   [00] ..  1 4154502892.139171: vm_normal_page
<-follow_page
            main-849   [00] ..  1 4154502892.139176:
mark_page_accessed <-follow_page
            main-849   [00] ..  1 4154502892.139180: rt_spin_unlock
<-follow_page
            main-849   [00] ..  1 4154502892.139185: flush_dcache_page
<-get_user_pages
            main-849   [00] ..  1 4154502892.139192: rt_up_read <-sys_v=
msplice
            main-849   [00] ..  1 4154502892.139194: rt_mutex_up_read
<-rt_up_read
            main-849   [00] ..  1 4154502892.139203: splice_to_pipe
<-sys_vmsplice
            main-849   [00] ..  1 4154502892.139206: _mutex_lock
<-splice_to_pipe
            main-849   [00] ..  1 4154502892.139209: rt_mutex_lock <-_m=
utex_lock
            main-849   [00] ..  1 4154502892.139217: _mutex_unlock
<-splice_to_pipe
            main-849   [00] ..  1 4154502892.139221: rt_mutex_unlock
<-_mutex_unlock
            main-849   [00] ..  1 4154502892.139224: kill_fasync
<-splice_to_pipe
            main-849   [00] ..  1 4154502892.139235: sys_gettimeofday
<-ret_from_syscall
            main-849   [00] ..  1 4154502892.139237: do_gettimeofday
<-sys_gettimeofday
            main-849   [00] ..  1 4154502892.139239: getnstimeofday
<-do_gettimeofday


So, I will return to work on my circular buffer.
This way I can control (ethernet frame length)*(number of frame)/
(number of system call) ratio.

Thanks to splice kernel and pktgen code analyses, I've also found a
clean way to perform
zero copy between my circular buffer and socket buffer. I will test it
and I'll let you know
changes and results.

Many thanks for your help,
Johann Baudy









--=20
Johann Baudy
johaahn@gmail.com
