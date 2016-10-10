From: Aaron Conole <aconole@redhat.com>
Subject: Re: slab corruption with current -git (was Re: [git pull] vfs pile 1 (splice))
Date: Sun, 09 Oct 2016 21:35:44 -0400
Message-ID: <f7tbmytkmtr.fsf@redhat.com>
References: <CA+55aFz2U83pG0v12E--nd5c6GZAUpVnT3jHuAwHCFk5XbVX0w@mail.gmail.com>
        <20161010005105.GA18349@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jens Axboe <axboe@fb.com>, "Ted Ts'o" <tytso@mit.edu>,
        Christoph Lameter <cl@linux.com>,
        David Miller <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161010005105.GA18349@breakpoint.cc> (Florian Westphal's
        message of "Mon, 10 Oct 2016 02:51:05 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Westphal <fw@strlen.de> writes:

> Linus Torvalds <torvalds@linux-foundation.org> wrote:
>> On Sun, Oct 9, 2016 at 12:11 PM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>> >
>> > Anyway, I don't think I can bisect it, but I'll try to narrow it down
>> > a *bit* at least.
>> >
>> > Not doing any more pulls on this unstable base, I've been puttering
>> > around in trying to clean up some stupid printk logging issues
>> > instead.
>> 
>> So I finally got a oops with slub debugging enabled. It doesn't really
>> narrow things down, though, it kind of extends on the possible
>> suspects. Now adding David Miller and Pablo, because it looks like it
>> may be netfilter that does something bad and corrupts memory.
>
> Quite possible, the netns interactions are not nice :-/
>
>> Without further ado, here's the new oops:
>> 
>>    general protection fault: 0000 [#1] SMP
>>    CPU: 7 PID: 169 Comm: kworker/u16:7 Not tainted
>> 4.8.0-11288-gb66484cd7470 #1
>>    Hardware name: System manufacturer System Product Name/Z170-K, BIOS
> ..
>>    Call Trace:
>>      netfilter_net_exit+0x2f/0x60
>>      ops_exit_list.isra.4+0x38/0x60
>>      cleanup_net+0x1ba/0x2a0
>>      process_one_work+0x1f1/0x480
>>      worker_thread+0x48/0x4d0
>>      ? process_one_work+0x480/0x480
>
> ..
>
>> like it's a pointer loaded from a free'd allocation.
>> 
>> The code disassembles to
>> 
>>    0: 0f b6 ca             movzbl %dl,%ecx
>>    3: 48 8d 84 c8 00 01 00 lea    0x100(%rax,%rcx,8),%rax
>>    a: 00
>>    b: 49 8b 5c c5 00       mov    0x0(%r13,%rax,8),%rbx
>>   10: 48 85 db             test   %rbx,%rbx
>>   13: 0f 84 cb 00 00 00     je     0xe4
>>   19: 4c 3b 63 40           cmp    0x40(%rbx),%r12
>>   1d: 48 8b 03             mov    (%rbx),%rax
>>   20: 0f 84 e9 00 00 00     je     0x10f
>>   26: 48 85 c0             test   %rax,%rax
>>   29: 74 26                 je     0x51
>>   2b:* 4c 3b 60 40           cmp    0x40(%rax),%r12 <-- trapping instruction
>>   2f: 75 08                 jne    0x39
>>   31: e9 ef 00 00 00       jmpq   0x125
>>   36: 48 89 d8             mov    %rbx,%rax
>>   39: 48 8b 18             mov    (%rax),%rbx
>>   3c: 48 85 db             test   %rbx,%rbx
>> 
>> and that oopsing instruction seems to be the compare of
>> "hooks_entry->orig_ops" from hooks_entry in this expression:
>> 
>>         if (hooks_entry && hooks_entry->orig_ops == reg) {
>> 
>> so hooks_entry() is bogus. It was gotten from
>> 
>>         hooks_entry = nf_hook_entry_head(net, reg);
>> 
>> but that's as far as I dug. And yes, I do have
>> CONFIG_NETFILTER_INGRESS=y in case that matters.
>> 
>> And all this code has changed pretty radically in commit e3b37f11e6e4
>> ("netfilter: replace list_head with single linked list"), and there
>> was clearly already something wrong with that code, with commit
>> 5119e4381a90 ("netfilter: Fix potential null pointer dereference")
>> adding the test against NULL. But I suspect that only hid the "oops,
>> it's actually not NULL, it loaded some uninitialized value" problem.
>> 
>> Over to the networking guys.. Ideas?
>
> Sorry, not off the top of my head.
> Pablo is currently travelling back home from netdev 1.2 in Tokyo,
> I can help starting Wednesday when I am back.
>
> One shot in the dark (not even compile tested; wonder if we can end up
> zapping bogus hook ...)
>

I was just about to build and test something similar:

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index c9d90eb..e84103f 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -189,7 +189,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
 
 unlock:
        mutex_unlock(&nf_hook_mutex);
-       if (!hooks_entry) {
+       if (!hooks_entry || hooks_entry->orig_ops != reg) {
                WARN(1, "nf_unregister_net_hook: hook not found!\n");
                return;
        }
