From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] mqueue: fix the retry logic for netlink_attachskb()
Date: Sat, 8 Jul 2017 11:04:32 -0700
Message-ID: <CAM_iQpX2+sq9Czwk4qiwDH5JdvTjDxLtoCj56iSHgEpUPo=uzQ@mail.gmail.com>
References: <1499452335-3478-1-git-send-email-xiyou.wangcong@gmail.com> <CA+55aFxNtoGV=Ly5X-T2n9YzV31sm+i33b+wjs-Qrsybbe1Saw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Gene Blue <geneblue.mail@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Manfred Spraul <manfred@colorfullife.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxNtoGV=Ly5X-T2n9YzV31sm+i33b+wjs-Qrsybbe1Saw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 7, 2017 at 5:23 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Jul 7, 2017 at 11:32 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> so we when retry and the fd has been closed during this small
>> window, we end up calling netlink_detachskb() on the error path
>> which releases the sock again and could lead to a use-after-free.
>
> So this seems to be a real problem: "sock" is not NULL'ed out in that
>
>                         if (!f.file) {
>
> error case (or alternatively, in the retry case).  Plus, since we did
> the "fput()" early, "sock" may be gone by the time we do the
> netlink_attachskb() even when it's all successful.
>
> But I don't think this is really so much about the retrying - the
> "sock may be gone" case seems to be true even the first time around,
> and even if we never retry at all.
>
> Am I reading this correctly?


Yes you are correct.

>
> Basically, I think the patch is fine, but the explanation seems a bit
> misleading. This isn't really about the re-trying: that would be fine
> if we just cleaned up sock properly.
>
> Can you confirm that? I don't know where the original report is.

Yes of course, setting 'sock' to NULL before 'goto retry' is sufficient
to fix it, that is in fact my initial thought. And I realized retry'ing
fdget() can't help anything in this situation but increases the
attack vector, so I decided to get rid of it from the retry loop
instead of just NULL'ing 'sock'.

Or do you prefer the simpler fix? Or should I just resend it with
a improved changelog?

BTW, the original report is here:
https://groups.google.com/forum/#!topic/syzkaller/QsmbsGoYPzA


>
> And that code is ancient, so we should do a "cc: stable" there too,
> and backport it basically forever. I think most of the code in this
> area predates the git tree, although Al Viro actually touched some
> things around here very recently to make the compat case cleaner.
>

Yeah, sorry about forgetting it.

Thanks!
