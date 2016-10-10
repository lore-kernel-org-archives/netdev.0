From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: BUG still has locks held in unix_stream_splice_read
Date: Mon, 10 Oct 2016 10:01:05 +0200
Message-ID: <CACT4Y+ZgbobWZEkAFLVK9bLHB0oLpnxXrH1FQzTgVu_6JQQVDQ@mail.gmail.com>
References: <CACT4Y+aPybMnXjiH+DdDWDAfz+L6PF-H-J3YT2+hjcDp3aw9SQ@mail.gmail.com>
 <CACT4Y+a6yDm28VYtNPSktYKs_T2UzLGb8jadpFpsdKfNzb7-tA@mail.gmail.com>
 <20161010024607.GV19539@ZenIV.linux.org.uk> <20161010031450.GW19539@ZenIV.linux.org.uk>
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
In-Reply-To: <20161010031450.GW19539@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 5:14 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Mon, Oct 10, 2016 at 03:46:07AM +0100, Al Viro wrote:
>> On Sun, Oct 09, 2016 at 12:06:14PM +0200, Dmitry Vyukov wrote:
>> > I suspect this is:
>> >
>> > commit 25869262ef7af24ccde988867ac3eb1c3d4b88d4
>> > Author: Al Viro <viro@zeniv.linux.org.uk>
>> > Date:   Sat Sep 17 21:02:10 2016 -0400
>> >     skb_splice_bits(): get rid of callback
>> >     since pipe_lock is the outermost now, we don't need to drop/regain
>> >     socket locks around the call of splice_to_pipe() from skb_splice_bits(),
>> >     which kills the need to have a socket-specific callback; we can just
>> >     call splice_to_pipe() and be done with that.
>>
>> Unlikely, since that particular commit removes unlocking/relocking ->iolock
>> around the call of splice_to_pipe().  Original would've retaken the same
>> lock on the way out; it's not as if we could leave the syscall there.
>>
>> It might be splice-related, but I don't believe that you've got the right
>> commit here.
>
> It's not that commit

It's highly likely. Sorry for falsely pointing to your commit.


> , all right - it's "can't call unix_stream_read_generic()
> with any locks held" stepped onto a couple of commits prior by
> "splice: lift pipe_lock out of splice_to_pipe()".  Could somebody explain
> what is that about?
>
> E.g what will happen if some code does a read on AF_UNIX socket with
> some local mutex held?  AFAICS, there are exactly two callers of
> freezable_schedule_timeout() - this one and one in XFS; the latter is
> in a kernel thread where we do have good warranties about the locking
> environment, but here it's in the bleeding ->recvmsg/->splice_read and
> for those assumption that caller doesn't hold any locks is pretty
> strong, especially since it's not documented anywhere.
>
> What's going on there?

I never saw that warning before. There is some possibility that fuzzer
has discovered some new paths, but it's much more likely that
something has changed recently (the stack looks quite simple -- just a
splice from unix socket). And my previous pull was like a week ago.
