From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UBSAN reports issue in ip_idents_reserve
Date: Tue, 20 Sep 2016 06:28:35 -0700
Message-ID: <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920120000.GI1843@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34742 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751124AbcITN2h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 09:28:37 -0400
Received: by mail-pa0-f47.google.com with SMTP id wk8so7217806pab.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 06:28:37 -0700 (PDT)
In-Reply-To: <20160920120000.GI1843@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 14:00 +0200, Jiri Pirko wrote:
> Hi.
> 
> I'm consistently getting following UBSAN warning on every bootup:
> 
> [   47.545820] ================================================================================
> [   47.554340] UBSAN: Undefined behaviour in ./arch/x86/include/asm/atomic.h:156:11
> [   47.561808] signed integer overflow:
> [   47.565420] -2117905507 + -695755206 cannot be represented in type 'int'
> [   47.572226] CPU: 0 PID: 389 Comm: ntpd Not tainted 4.8.0-rc6jiri+ #1
> [   47.578636] Hardware name: Mellanox Technologies Ltd. Mellanox switch/Mellanox switch, BIOS 4.6.5 05/21/2015
> [   47.588586]  ffffffff847bf8c0 00000000987b8f47 ffff8803829af5a8 ffffffff818354e3
> [   47.596165]  0000000041b58ab3 ffffffff8277e711 ffffffff81835431 ffff8803829af5d0
> [   47.603722]  ffff8803829af580 ffffffffd6879e3a 1ffffffff08f8214 ffffed0070535e6c
> [   47.611298] Call Trace:
> [   47.613795]  [<ffffffff818354e3>] dump_stack+0xb2/0x10f
> [   47.619077]  [<ffffffff81835431>] ? _atomic_dec_and_lock+0xa1/0xa1
> [   47.625327]  [<ffffffff818a884f>] ubsan_epilogue+0xd/0x4e
> [   47.630811]  [<ffffffff818a9821>] handle_overflow+0x190/0x1de
> [   47.636627]  [<ffffffff818a9691>] ? __ubsan_handle_negate_overflow+0x140/0x140
> [   47.643914]  [<ffffffff81863130>] ? iov_iter_copy_from_user_atomic+0x6e0/0x6e0
> [   47.651219]  [<ffffffff811e6f79>] ? __lock_acquire.isra.17+0xb79/0xe50
> [   47.657832]  [<ffffffff81e581f2>] ? ip_generic_getfrag+0xd2/0x190
> [   47.664011]  [<ffffffff81e58120>] ? ip_setup_cork+0x320/0x320
> [   47.669827]  [<ffffffff818a987d>] __ubsan_handle_add_overflow+0xe/0x10
> [   47.676444]  [<ffffffff81e41d52>] ip_idents_reserve+0xb2/0xe0
> [   47.682254]  [<ffffffff81e443e9>] __ip_select_ident+0x159/0x1b0
> [   47.688248]  [<ffffffff81e44290>] ? update_or_create_fnhe+0x850/0x850
> [   47.694782]  [<ffffffff81e58120>] ? ip_setup_cork+0x320/0x320
> [   47.700624]  [<ffffffff81e5ef40>] __ip_make_skb+0x8a0/0xab0
> [   47.706259]  [<ffffffff81e5f3fd>] ip_make_skb+0x17d/0x1d0
> [   47.711717]  [<ffffffff81e58120>] ? ip_setup_cork+0x320/0x320
> [   47.717526]  [<ffffffff81e5f280>] ? ip_flush_pending_frames+0x20/0x20
> [   47.724032]  [<ffffffff81e46ef0>] ? ip_rt_update_pmtu+0x4f0/0x4f0
> [   47.730231]  [<ffffffff81f35291>] ? xfrm_lookup_route+0x21/0xe0
> [   47.736216]  [<ffffffff81ec0cdb>] udp_sendmsg+0x9db/0xf60
> [   47.741668]  [<ffffffff81e58120>] ? ip_setup_cork+0x320/0x320
> [   47.747472]  [<ffffffff81ec0300>] ? udp_abort+0x70/0x70
> [   47.752763]  [<ffffffff81ede3d8>] inet_sendmsg+0x198/0x220
> [   47.758324]  [<ffffffff81ede292>] ? inet_sendmsg+0x52/0x220
> [   47.763982]  [<ffffffff81ede240>] ? inet_recvmsg+0x300/0x300
> [   47.769728]  [<ffffffff81d6fd25>] sock_sendmsg+0xa5/0xd0
> [   47.775100]  [<ffffffff81d72f70>] SYSC_sendto+0x1d0/0x280
> [   47.780551]  [<ffffffff81d72da0>] ? SYSC_connect+0x200/0x200
> [   47.786283]  [<ffffffff814f66df>] ? poll_select_copy_remaining+0x2af/0x310
> [   47.793265]  [<ffffffff814f6430>] ? set_fd_set+0x60/0x60
> [   47.798665]  [<ffffffff811ee360>] ? do_raw_spin_trylock+0x90/0x90
> [   47.804853]  [<ffffffff814f80e3>] ? SyS_select+0x1a3/0x200
> [   47.810399]  [<ffffffff814f7f40>] ? core_sys_select+0x570/0x570
> [   47.816415]  [<ffffffff8100467c>] ? exit_to_usermode_loop+0xec/0x110
> [   47.822842]  [<ffffffff811e8abd>] ? lockdep_sys_exit+0x2d/0xb0
> [   47.828769]  [<ffffffff81004016>] ? lockdep_sys_exit_thunk+0x16/0x30
> [   47.835199]  [<ffffffff81d7433e>] SyS_sendto+0xe/0x10
> [   47.840321]  [<ffffffff820381f2>] entry_SYSCALL_64_fastpath+0x1a/0xa9
> [   47.846826] ================================================================================
> 
> Looks like this might be result of following commit:
> 
> commit 04ca6973f7c1a0d8537f2d9906a0cf8e69886d75
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Sat Jul 26 08:58:10 2014 +0200
> 
>     ip: make IP identifiers less predictable
> 
> Eric, could you please take look at that?

Sure

I do not think we have to worry here.

These is best effort, and unfortunately atomic_t are int.

Adding uatomic_t helpers in the kernel with unsigned int would be a huge
effort, given this would touch all arches.
