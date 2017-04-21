From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: net/core: BUG in unregister_netdevice_many
Date: Fri, 21 Apr 2017 21:30:30 +0300
Message-ID: <2e044c75-c0e5-f5d5-1d94-7609d7af86fa@cumulusnetworks.com>
References: <CAAeHK+zUZMGQuW=7Qhz3EWYjh6Zwv9eMBCiMCU79QrYNWox0-Q@mail.gmail.com>
 <CA+55aFwg=OtMWmU153uM27Fwk5eVv5ZBGBA9phQqVqn3nNAy6Q@mail.gmail.com>
 <CA+55aFyTFzML+_8E_kDjX=YFkaDi_ejGo15UgGtAT29244UwgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        tcharding <me@tobin.cc>, Jiri Pirko <jiri@mellanox.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38134 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422872AbdDUSad (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:30:33 -0400
Received: by mail-wm0-f45.google.com with SMTP id r190so23753599wme.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:30:33 -0700 (PDT)
In-Reply-To: <CA+55aFyTFzML+_8E_kDjX=YFkaDi_ejGo15UgGtAT29244UwgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/04/17 20:42, Linus Torvalds wrote:
> On Fri, Apr 21, 2017 at 10:25 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> I'm assuming that the real cause is simply that "dev->reg_state" ends
>> up being NETREG_UNREGISTERING or something. Maybe the BUG_ON() could
>> be just removed, and replaced by the previous warning about
>> NETREG_UNINITIALIZED.
>>
>> Something like the attached (TOTALLY UNTESTED) patch.
> 
> .. might as well test it.
> 
> That patch doesn't fix the problem, but it does show that yes, it was
> NETREG_UNREGISTERING:
> 
>   unregister_netdevice: device pim6reg/ffff962dc4606000 was not registered (2)
> 
> but then immediately afterwards we get
> 
>   general protection fault: 0000 [#1] SMP
>   Workqueue: netns cleanup_net
>   RIP: 0010:dev_shutdown+0xe/0xc0
>   Call Trace:
>      rollback_registered_many+0x2a5/0x440
>      unregister_netdevice_many+0x1e/0xb0
>      default_device_exit_batch+0x145/0x170
> 
> which is due to a
> 
>         mov    0x388(%rdi),%eax
> 
> where %rdi is 0xdead000000000090. That is at the very beginning of
> dev_shutdown, it's "dev" itself that has that value, so it comes from
> (_another_) invocation of rollback_registered_many(), when it does
> that
> 
>         list_for_each_entry(dev, head, unreg_list) {
> 
> so it seems to be a case of another "list_del() leaves list in bad
> state", and it was the added test for "dev->reg_state !=
> NETREG_REGISTERED" that did that
> 
>         list_del(&dev->unreg_list);
> 
> and left random contents in the unreg_list.
> 
> So that "handle error case" was almost certainly just buggy too.
> 
> And the bug seems to be that we're trying to unregister a netdevice
> that has already been unregistered.
> 
> Over to Eric and networking people. This oops is user-triggerable, and
> leaves the machine in a bad state (the original BUG_ON() and the new
> GP fault both happen while holding the RTNL, so networking is not
> healthy afterwards.
> 
>                       Linus
> 

Right, I've already posted a patch for ip6mr that should fix the issue.
CCed you and LKML just now.

Thanks,
 Nik
