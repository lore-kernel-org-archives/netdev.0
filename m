From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: slab corruption with current -git (was Re: [git pull] vfs pile 1 (splice))
Date: Sun, 9 Oct 2016 14:31:46 -0700
Message-ID: <CA+55aFz2U83pG0v12E--nd5c6GZAUpVnT3jHuAwHCFk5XbVX0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jens Axboe <axboe@fb.com>, "Ted Ts'o" <tytso@mit.edu>,
        Christoph Lameter <cl@linux.com>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Aaron Conole <aconole@bytheb.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 9, 2016 at 12:11 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Anyway, I don't think I can bisect it, but I'll try to narrow it down
> a *bit* at least.
>
> Not doing any more pulls on this unstable base, I've been puttering
> around in trying to clean up some stupid printk logging issues
> instead.

So I finally got a oops with slub debugging enabled. It doesn't really
narrow things down, though, it kind of extends on the possible
suspects. Now adding David Miller and Pablo, because it looks like it
may be netfilter that does something bad and corrupts memory.

Of course, maybe this is another symptom, and not the root cause for
my troubles, but it does look like it might be getting closer to the
cause... In particular, now it very much looks like a use-after-free
in the netfilter code, which *could* explain my original symptom with
later allocation users oopsing randomly.

Without further ado, here's the new oops:

   general protection fault: 0000 [#1] SMP
   CPU: 7 PID: 169 Comm: kworker/u16:7 Not tainted 4.8.0-11288-gb66484cd7470 #1
   Hardware name: System manufacturer System Product Name/Z170-K, BIOS
1803 05/06/2016
   Workqueue: netns cleanup_net
   task: ffff91935e001fc0 task.stack: ffffb4e2c213c000
   RIP: nf_unregister_net_hook+0x5f/0x190
   RSP: 0000:ffffb4e2c213fd40  EFLAGS: 00010202
   RAX: 6b6b6b6b6b6b6b6b RBX: ffff91933c4ab968 RCX: 0000000000000002
   RDX: 0000000000000002 RSI: ffffffffc0642280 RDI: ffffffff91cf9820
   RBP: ffffb4e2c213fd58 R08: ffff91933c4a86c8 R09: 0000000000000025
   R10: 00000000000000cc R11: ffff91935dd22000 R12: ffffffffc0642280
   R13: ffff91934cc0ea80 R14: ffffffff91cf97e0 R15: 00000000ffffffff
   FS:  0000000000000000(0000) GS:ffff919376dc0000(0000) knlGS:0000000000000000
   CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
   CR2: 0000000003e7c000 CR3: 00000003fdb62000 CR4: 00000000003406e0
   DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
   DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
   Call Trace:
     netfilter_net_exit+0x2f/0x60
     ops_exit_list.isra.4+0x38/0x60
     cleanup_net+0x1ba/0x2a0
     process_one_work+0x1f1/0x480
     worker_thread+0x48/0x4d0
     ? process_one_work+0x480/0x480
     ? process_one_work+0x480/0x480
     kthread+0xd9/0xf0
     ? kthread_park+0x60/0x60
     ret_from_fork+0x22/0x30
   Code: 0f b6 ca 48 8d 84 c8 00 01 00 00 49 8b 5c c5 00 48 85 db 0f
84 cb 00 00 00 4c 3b 63 40 48 8b 03 0f 84 e9 00 00 00 48 85 c0 74 26
<4c> 3b 60 40 75 08 e9 ef 00 00 00 48 89 d8 48 8b 18 48 85 db 0f
   RIP  [<ffffffff916bae8f>] nf_unregister_net_hook+0x5f/0x190

and note the value in %rax: 6b is POISON_FREE, so it very much looks
like it's a pointer loaded from a free'd allocation.

The code disassembles to

   0: 0f b6 ca             movzbl %dl,%ecx
   3: 48 8d 84 c8 00 01 00 lea    0x100(%rax,%rcx,8),%rax
   a: 00
   b: 49 8b 5c c5 00       mov    0x0(%r13,%rax,8),%rbx
  10: 48 85 db             test   %rbx,%rbx
  13: 0f 84 cb 00 00 00     je     0xe4
  19: 4c 3b 63 40           cmp    0x40(%rbx),%r12
  1d: 48 8b 03             mov    (%rbx),%rax
  20: 0f 84 e9 00 00 00     je     0x10f
  26: 48 85 c0             test   %rax,%rax
  29: 74 26                 je     0x51
  2b:* 4c 3b 60 40           cmp    0x40(%rax),%r12 <-- trapping instruction
  2f: 75 08                 jne    0x39
  31: e9 ef 00 00 00       jmpq   0x125
  36: 48 89 d8             mov    %rbx,%rax
  39: 48 8b 18             mov    (%rax),%rbx
  3c: 48 85 db             test   %rbx,%rbx

and that oopsing instruction seems to be the compare of
"hooks_entry->orig_ops" from hooks_entry in this expression:

        if (hooks_entry && hooks_entry->orig_ops == reg) {

so hooks_entry() is bogus. It was gotten from

        hooks_entry = nf_hook_entry_head(net, reg);

but that's as far as I dug. And yes, I do have
CONFIG_NETFILTER_INGRESS=y in case that matters.

And all this code has changed pretty radically in commit e3b37f11e6e4
("netfilter: replace list_head with single linked list"), and there
was clearly already something wrong with that code, with commit
5119e4381a90 ("netfilter: Fix potential null pointer dereference")
adding the test against NULL. But I suspect that only hid the "oops,
it's actually not NULL, it loaded some uninitialized value" problem.

Over to the networking guys.. Ideas?

               Linus
