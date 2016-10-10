From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: slab corruption with current -git (was Re: [git pull] vfs pile 1 (splice))
Date: Mon, 10 Oct 2016 12:05:17 -0700
Message-ID: <CA+55aFy0szySf+SnysjXTyfiU=RMBo9U1sHAVaTKG=tUTF+XGw@mail.gmail.com>
References: <CA+55aFz2U83pG0v12E--nd5c6GZAUpVnT3jHuAwHCFk5XbVX0w@mail.gmail.com>
 <20161010005105.GA18349@breakpoint.cc> <f7tbmytkmtr.fsf@redhat.com>
 <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
 <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
 <f7ta8ec71qq.fsf@redhat.com> <CA+55aFy6pRhvodYG9WWjfxQBFr4ExSk_wxwY=treWYTPK+NTvQ@mail.gmail.com>
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy6pRhvodYG9WWjfxQBFr4ExSk_wxwY=treWYTPK+NTvQ@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 9:28 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So as I already answered to Dave, I'm not actually sure that this was
> the buggy code, or that my patch would make any difference at all.

My patch does seem to fix things, and in fact the warning about "hook
not found" now triggers.

So I think the bug really was that the singly-linked list handling
code did not correctly handle the case of not finding the entry, and
then freed (incorrectly) the last one that wasn't actually unlinked.

In fact, I get quite a few warnings (56 total) about 30 seconds after
logging in:

[   54.213170] WARNING: CPU: 1 PID: 111 at net/netfilter/core.c:151
nf_unregister_net_hook+0x8e/0x170
... repeat 54 times ...
[   54.445520] WARNING: CPU: 7 PID: 111 at net/netfilter/core.c:151
nf_unregister_net_hook+0x8e/0x170

and looking in the journal, the first one is (again) immediately
preceded by that systemd-hostnamed service stopping:

  Oct 10 11:45:47 i7 audit[1546]: USER_LOGIN
  ...
  Oct 10 11:46:11 i7 audit[1]: SERVICE_STOP pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=fprintd comm="systemd" exe="/usr/lib/systemd/systemd"
hostname=? addr=? terminal=? res=success'
  Oct 10 11:46:13 i7 pulseaudio[1697]: [pulseaudio] bluez5-util.c:
GetManagedObjects() failed: org.freedesktop.DBus.Error.NoReply: Did
not receive a reply. Possible causes include: the remote application
did not send a reply, the message bus security policy blocked the
reply, the reply timeout expir
  Oct 10 11:46:13 i7 dbus-daemon[1003]: [system] Failed to activate
service 'org.bluez': timed out
  Oct 10 11:46:20 i7 audit[1]: SERVICE_STOP pid=1 uid=0
auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0
msg='unit=systemd-hostnamed comm="systemd"
exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=?
res=success'
  Oct 10 11:46:20 i7 kernel: ------------[ cut here ]------------
  Oct 10 11:46:20 i7 kernel: WARNING: CPU: 1 PID: 111 at
net/netfilter/core.c:151 nf_unregister_net_hook+0x8e/0x170

so I do think it's something to do with some network startup service
thing (perhaps dhcp, perhaps chrome, who knows) as I do my initial
login.

David - I think that also explains what was wrong with the old code.
In the old code, this loop:

        while (hooks_entry && nf_entry_dereference(hooks_entry->next)) {

would exit with "hooks_entry" pointing to the last list entry (because
->next was NULL). Nothing was ever unlinked in the loop itself,
because it never actually found a matching entry, but then after the
loop it would free that last entry because it *thought* that was the
match.

My list rewrite fixes that.

Anyway, I'm assuming it will come to me from the networking tree after
more testing by the maintainers. You can add my

  Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

to the patch, though.

David, if you want me to just commit that thing directly, I can
obviously do so, but I do think somebody should look at

 (a) that I actually got the priority list ordering right on the insertion side
 (b) what it is that makes it try to unregister that hook that isn't
on the list in the first place

but on the whole I consider this issue explained and solved. I'll
continue to run with my patch on my machine (just not committed).

              Linus
