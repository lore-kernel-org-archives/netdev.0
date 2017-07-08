From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Patch] mqueue: fix the retry logic for netlink_attachskb()
Date: Fri, 7 Jul 2017 17:23:13 -0700
Message-ID: <CA+55aFxNtoGV=Ly5X-T2n9YzV31sm+i33b+wjs-Qrsybbe1Saw@mail.gmail.com>
References: <1499452335-3478-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        geneblue.mail@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
        Manfred Spraul <manfred@colorfullife.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499452335-3478-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 7, 2017 at 11:32 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> The retry logic for netlink_attachskb() inside sys_mq_notify()
> is suspicious and vulnerable:
>
> 1) The sock refcnt is already released when retry is needed
> 2) The fd is controllable by user-space because we already
>    release the file refcnt

Hmm. What's different the second (and third.. and..) time around from
the first time?

I don't dislike your patch (it looks fine), but  avoiding the
fdget/fdput in the retry loop doesn't seem to really change anything -
it's just as if we'd just react to the original thing a bit later.

> so we when retry and the fd has been closed during this small
> window, we end up calling netlink_detachskb() on the error path
> which releases the sock again and could lead to a use-after-free.

So this seems to be a real problem: "sock" is not NULL'ed out in that

                        if (!f.file) {

error case (or alternatively, in the retry case).  Plus, since we did
the "fput()" early, "sock" may be gone by the time we do the
netlink_attachskb() even when it's all successful.

But I don't think this is really so much about the retrying - the
"sock may be gone" case seems to be true even the first time around,
and even if we never retry at all.

Am I reading this correctly?

Basically, I think the patch is fine, but the explanation seems a bit
misleading. This isn't really about the re-trying: that would be fine
if we just cleaned up sock properly.

Can you confirm that? I don't know where the original report is.

And that code is ancient, so we should do a "cc: stable" there too,
and backport it basically forever. I think most of the code in this
area predates the git tree, although Al Viro actually touched some
things around here very recently to make the compat case cleaner.

                 Linus
