From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: BUG still has locks held in unix_stream_splice_read
Date: Thu, 17 Nov 2016 19:02:28 +0100
Message-ID: <CACT4Y+bhRREoHKE=yWrQ-7Owq6JKYPhSk-PEPznWXqa-j_7QnQ@mail.gmail.com>
References: <CACT4Y+aPybMnXjiH+DdDWDAfz+L6PF-H-J3YT2+hjcDp3aw9SQ@mail.gmail.com>
 <CACT4Y+a6yDm28VYtNPSktYKs_T2UzLGb8jadpFpsdKfNzb7-tA@mail.gmail.com>
 <20161010024607.GV19539@ZenIV.linux.org.uk> <20161010031450.GW19539@ZenIV.linux.org.uk>
 <CACT4Y+ZgbobWZEkAFLVK9bLHB0oLpnxXrH1FQzTgVu_6JQQVDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ZgbobWZEkAFLVK9bLHB0oLpnxXrH1FQzTgVu_6JQQVDQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 10:01 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Mon, Oct 10, 2016 at 5:14 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>> On Mon, Oct 10, 2016 at 03:46:07AM +0100, Al Viro wrote:
>>> On Sun, Oct 09, 2016 at 12:06:14PM +0200, Dmitry Vyukov wrote:
>>> > I suspect this is:
>>> >
>>> > commit 25869262ef7af24ccde988867ac3eb1c3d4b88d4
>>> > Author: Al Viro <viro@zeniv.linux.org.uk>
>>> > Date:   Sat Sep 17 21:02:10 2016 -0400
>>> >     skb_splice_bits(): get rid of callback
>>> >     since pipe_lock is the outermost now, we don't need to drop/regain
>>> >     socket locks around the call of splice_to_pipe() from skb_splice_bits(),
>>> >     which kills the need to have a socket-specific callback; we can just
>>> >     call splice_to_pipe() and be done with that.
>>>
>>> Unlikely, since that particular commit removes unlocking/relocking ->iolock
>>> around the call of splice_to_pipe().  Original would've retaken the same
>>> lock on the way out; it's not as if we could leave the syscall there.
>>>
>>> It might be splice-related, but I don't believe that you've got the right
>>> commit here.
>>
>> It's not that commit
>
> It's highly likely. Sorry for falsely pointing to your commit.
>
>
>> , all right - it's "can't call unix_stream_read_generic()
>> with any locks held" stepped onto a couple of commits prior by
>> "splice: lift pipe_lock out of splice_to_pipe()".  Could somebody explain
>> what is that about?
>>
>> E.g what will happen if some code does a read on AF_UNIX socket with
>> some local mutex held?  AFAICS, there are exactly two callers of
>> freezable_schedule_timeout() - this one and one in XFS; the latter is
>> in a kernel thread where we do have good warranties about the locking
>> environment, but here it's in the bleeding ->recvmsg/->splice_read and
>> for those assumption that caller doesn't hold any locks is pretty
>> strong, especially since it's not documented anywhere.
>>
>> What's going on there?
>
> I never saw that warning before. There is some possibility that fuzzer
> has discovered some new paths, but it's much more likely that
> something has changed recently (the stack looks quite simple -- just a
> splice from unix socket). And my previous pull was like a week ago.

Ping. Just hit it again on 4.9-rc5


[ BUG: syz-executor/15922 still has locks held! ]
4.9.0-rc5+ #43 Not tainted
-------------------------------------
1 lock held by syz-executor/15922:
 #0: [ 1441.143288]  (
[<     inline     >] pipe_lock_nested fs/pipe.c:66
[<ffffffff81a8d72b>] pipe_lock+0x5b/0x70 fs/pipe.c:74

stack backtrace:
CPU: 3 PID: 15922 Comm: syz-executor Not tainted 4.9.0-rc5+ #43
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffff88004a98f568 ffffffff834c2a19 ffffffff00000003 1ffff10009531e40
 ffffed0009531e38 0000000041b58ab3 ffffffff895758b0 ffffffff834c272b
 0000000000000003 ffff880035256640 0000000000000003 ffff88006d122cd8
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff834c2a19>] dump_stack+0x2ee/0x3f5 lib/dump_stack.c:51
 [<     inline     >] print_held_locks_bug kernel/locking/lockdep.c:4296
 [<ffffffff81560245>] debug_check_no_locks_held+0x125/0x140
kernel/locking/lockdep.c:4302
 [<     inline     >] try_to_freeze include/linux/freezer.h:65
 [<     inline     >] freezer_count include/linux/freezer.h:127
 [<     inline     >] freezable_schedule_timeout include/linux/freezer.h:192
 [<ffffffff8716ed5d>] unix_stream_data_wait+0x4fd/0x910 net/unix/af_unix.c:2223
 [<ffffffff871749a2>] unix_stream_read_generic+0x11e2/0x2240
net/unix/af_unix.c:2332
 [<ffffffff87175c7f>] unix_stream_splice_read+0x27f/0x400
net/unix/af_unix.c:2506
 [<ffffffff86a6578e>] sock_splice_read+0xbe/0x100 net/socket.c:772
 [<ffffffff81b3f90f>] do_splice_to+0x10f/0x170 fs/splice.c:897
 [<     inline     >] do_splice fs/splice.c:1185
 [<     inline     >] SYSC_splice fs/splice.c:1409
 [<ffffffff81b4683a>] SyS_splice+0xfaa/0x16a0 fs/splice.c:1392
 [<ffffffff88147905>] entry_SYSCALL_64_fastpath+0x23/0xc6
