From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: slab corruption with current -git (was Re: [git pull] vfs pile 1 (splice))
Date: Mon, 10 Oct 2016 09:28:46 -0700
Message-ID: <CA+55aFy6pRhvodYG9WWjfxQBFr4ExSk_wxwY=treWYTPK+NTvQ@mail.gmail.com>
References: <CA+55aFz2U83pG0v12E--nd5c6GZAUpVnT3jHuAwHCFk5XbVX0w@mail.gmail.com>
 <20161010005105.GA18349@breakpoint.cc> <f7tbmytkmtr.fsf@redhat.com>
 <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
 <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com> <f7ta8ec71qq.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jens Axboe <axboe@fb.com>, "Ted Ts'o" <tytso@mit.edu>,
        Christoph Lameter <cl@linux.com>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>
To: Aaron Conole <aconole@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36283 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752586AbcJJQac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 12:30:32 -0400
In-Reply-To: <f7ta8ec71qq.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 6:49 AM, Aaron Conole <aconole@redhat.com> wrote:
>
> Okay, I'm looking it over.  Sorry for the mess.

So as I already answered to Dave, I'm not actually sure that this was
the buggy code, or that my patch would make any difference at all.

I never got a good reproducer for the bug: I spent much of the weekend
rebooting, because it seems to happen only just after a reboot, as I
log in and start my usual thing.

I initially blamed some off filesystem or block layer issue ("Oh, it
only happens with a cold cache"), partly because the initial
non-poisoned slub oopses happened in filesystem code.

But I now think it's netfilter, and I *think* that what triggers it is
something like the bluetooth subsystem giving up or something. What I
do when I log into a new session tends to be to go to the kernel
subdirectory in one or two terminals, and fire up chrome to read
email. And the problem either happened within half a minute of me
doing that, or it never happens at all.

Which is why I ended up rebooting a *lot*. Just running the kernel
never triggered it.

(It took me some time to figure that out, which is basically why I did
almost no pull requests the whole weekend)

The journal entries for that invalid kernel access is somewhat suggestive:

  Oct 09 13:24:03 i7 dbus-daemon[1030]: [system] Failed to activate
service 'org.bluez': timed out

  Oct 09 13:24:09 i7 audit[1]: SERVICE_STOP pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-hostnamed comm="systemd"
exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=?
res=success'

  Oct 09 13:24:09 i7 kernel: general protection fault: 0000 [#1] SMP

so it happened just as *some* network setup thing was finishing off (I
don't think it was systemd-hostnamed itself that necessarily matters,
but clearly something was finishing up as the netfilter problem
occurred.

> I'll review it, and test it.  Can you tell me what steps you took to
> reproduce the oops?

See above: I can't actually really "reproduce" it. It's probably
highly timing-dependent, and it is not unlikely that it's also very
much about specific setup. I'm running plain Fedora 24, I boot up, log
in, start two or three terminals, fire up chrome, and ...

So far I've seen the problem maybe 5-6 times, but a couple of those
were just silent hangs (I may have rebooted too quickly for things to
hit the disk, or the oops may just have killed the machine too hard).
Two I got the oops inside slub code, and I only have one successful
slub poisoning oops from netfilter.

(Part of the reason I only have one is that once I got that, I stopped
rebooting, and instead started looking at the netfilter code and
started to do some merge window pulls again because I felt that this
is *probably* the core reason, and I cant' afford to not do pulls
during the merge window for _too_ long).

              Linus
