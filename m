From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 00/16] net_sched: fix races with RCU callbacks
Date: Mon, 30 Oct 2017 22:44:50 -0700
Message-ID: <CAM_iQpUTG6hzi=kPP2t=Svoj_MHgfcs7m+_ruWVafJq26RFV8g@mail.gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
 <CAMDBHYJGU-8SgYnzMKJsD6QKdMBSi4evHxJi2p-fJ12+09fBsw@mail.gmail.com>
 <CAM_iQpW=1kbpLxwCbBtGj3D+aVy5QseEAU+omEJUmJJwJ6P58A@mail.gmail.com> <CAMDBHYJTMv4MDQENNKjOXaUBHyXicOnkM_j+i7__3d1CAgdVRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Lucas Bates <lucasb@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:51311 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753229AbdJaFpL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 01:45:11 -0400
Received: by mail-pg0-f65.google.com with SMTP id p9so13733391pgc.8
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 22:45:11 -0700 (PDT)
In-Reply-To: <CAMDBHYJTMv4MDQENNKjOXaUBHyXicOnkM_j+i7__3d1CAgdVRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 6:03 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
> On Oct 30, 2017 19:13, "Cong Wang" <xiyou.wangcong@gmail.com> wrote:
>>
>> On Mon, Oct 30, 2017 at 3:39 PM, Lucas Bates <lucasb@mojatatu.com> wrote:
>> > e.On Thu, Oct 26, 2017 at 9:24 PM, Cong Wang <xiyou.wangcong@gmail.com>
>> > wrote:
>> >> Recently, the RCU callbacks used in TC filters and TC actions keep
>> >> drawing my attention, they introduce at least 4 race condition bugs:
>> > <snip>
>> >> As suggested by Paul, we could defer the work to a workqueue and
>> >> gain the permission of holding RTNL again without any performance
>> >> impact, however, in tcf_block_put() we could have a deadlock when
>> >> flushing workqueue while hodling RTNL lock, the trick here is to
>> >> defer the work itself in workqueue and make it queued after all
>> >> other works so that we keep the same ordering to avoid any
>> >> use-after-free. Please see the first patch for details.
>> >
>> > Cong, I don't believe the problem's been resolved just yet....  I have
>> > a new kernel, compiled just today and I'm still tripping over a kernel
>> > bug in this scenario when I run Chris' new test case.
>> >
>>
>> Without a stack trace, I can't do anything. "a kernel bug" could
>> be anything, why do you believe it is caused by this patchset?
>>
> The stack trace I saw touched on the same code that was affected by the
> patchset.  I've attached a photo of the trace - sorry, I should have sent it
> earlier.  I also apologize for having to send a photo but I was doing the
> testing on a small device lacking any kind of serial console access.


Can you try this patch? From your stack trace it is not clear where
the cause is, but we know that the crash is in __tcf_idr_release(),
this is how I came up with the following patch:


diff --git a/include/net/act_api.h b/include/net/act_api.h
index b944e0eb93be..5072446d5f06 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -122,7 +122,9 @@ void tcf_idrinfo_destroy(const struct tc_action_ops *ops,

 static inline void tc_action_net_exit(struct tc_action_net *tn)
 {
+       rtnl_lock();
        tcf_idrinfo_destroy(tn->ops, tn->idrinfo);
+       rtnl_unlock();
        kfree(tn->idrinfo);
 }



>
> If you need more information or need me to try something else, I'll be able
> to tomorrow.
>

I will look deeper tomorrow. It doesn't look like caused by this patchset
so far, probably yet another missing rtnl like what the above patch shows.


Thanks!
