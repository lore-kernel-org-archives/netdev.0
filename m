From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Top 10 kernel oopses for the week ending January 5th, 2008
Date: Tue, 8 Jan 2008 05:59:17 +0000
Message-ID: <20080108055917.GZ27894@ZenIV.linux.org.uk>
References: <477FF149.4070609@linux.intel.com> <20080105213935.GN27894@ZenIV.linux.org.uk> <20080107174431.GC27741@fieldses.org> <4782CF9C.6000508@gmail.com> <alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kevin Winchester <kjwinchester@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, gregkh@suse.de, neilb@suse.de
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47146 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754462AbYAHF7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:59:24 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.00.0801071851120.3148@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2008 at 07:26:12PM -0800, Linus Torvalds wrote:
 
> I usually just compile a small program like
> 
> 	const char array[]="\xnn\xnn\xnn...";
> 
> 	int main(int argc, char **argv)
> 	{
> 		printf("%p\n", array);
> 		*(int *)0=0;
> 	}
Heh.  I prefer
char main[] = {.....};
for the same thing, with gdb a.out and no running at all.

FWIW, I'm going to go through Arjan's collection and post blow-by-blow
analysis of some of those suckers.  Tonight, probably...

Let's take e.g. http://www.kerneloops.org/raw.php?rawid=2618

RIP: 0010:[<ffffffff803b49a1>]  [<ffffffff803b49a1>] kref_put+0x31/0x80
RSP: 0000:ffff81007ffe5df0  EFLAGS: 00010202
RAX: 0000000000000000 RBX: 0000000034333545 RCX: ffffffff80606270
RDX: 0000000000000040 RSI: ffffffff803b38b0 RDI: 0000000034333545
RBP: ffff81007ffe5e00 R08: 0000000000000001 R09: 0000000000000000
R10: ffffffff8094c430 R11: 0000000000000000 R12: ffffffff803b38b0
R13: ffff81011ede44d8 R14: ffffffff804d7d50 R15: ffff81011ff210f0
FS:  0000000002024870(0000) GS:ffff81011ff0dd00(0000)
...
Call Trace:
 [<ffffffff803b37e9>] kobject_put+0x19/0x20
 [<ffffffff803b389b>] kobject_del+0x2b/0x40
 [<ffffffff804d7d50>] delayed_delete+0x0/0xb0
 [<ffffffff804d7db9>] delayed_delete+0x69/0xb0
 [<ffffffff80249775>] run_workqueue+0x175/0x210
 [<ffffffff8024a411>] worker_thread+0x71/0xb0
 [<ffffffff8024d9e0>] autoremove_wake_function+0x0/0x40
 [<ffffffff8024a3a0>] worker_thread+0x0/0xb0
 [<ffffffff8024d5fd>] kthread+0x4d/0x80
 [<ffffffff8020c4b8>] child_rip+0xa/0x12
 [<ffffffff8020bbcf>] restore_args+0x0/0x30
 [<ffffffff8024d5b0>] kthread+0x0/0x80
 [<ffffffff8020c4ae>] child_rip+0x0/0x12

Code: f0 ff 0b 0f 94 c0 31 d2 84 c0 74 0b 48 89 df 41 ff d4 ba 01

What do we have here?  It barfs in kref_put() called from kobject_put().
It's -rc6-mm1 and I don't have -mm at hand.  Let's see if we can make
any sense out of it from the mainline - it might be a good idea for the
first pass, unless there are some clear indications to the contrary.

kref_put() is fairly low-level (and deep in call chain, here).  And it's
pretty small:
int kref_put(struct kref *kref, void (*release)(struct kref *kref))
{
        WARN_ON(release == NULL);
        WARN_ON(release == (void (*)(struct kref *))kfree);

        if (atomic_dec_and_test(&kref->refcount)) {
                release(kref);
                return 1;
        }
        return 0;
}

Poking around on the site (I'm not familiar enough with it, so bear with
me) gives a link to posting and an important detail missed in that page:

<1>Unable to handle kernel paging request at 0000000034333545 RIP:
[<ffffffff803b49a1>] kref_put+0x31/0x80

Now, that's interesting - we barf on dereferencing a pointer that (a) has
upper 32 bits zero and (b) doesn't have a bit 7 set in any byte.  Smells
like ASCII data misinterpreted as a pointer.  Conversion to ASCII gives
"E534", which sure as hell does look like a fragment of some string.

OK, so where does that happen?  In this case we have only one candidate,
really - atomic_dec_and_test(&kref->refcount).  Before it we only compare
argument with constants, after it we pass argument to another function.

Now, looking at the registers (see above) we notice that this address had
come from rbx.  Let's try objdump -d lib/kref.o and see what we've got there
for kref_put():

  4a:   55                      push   %rbp
  4b:   48 85 f6                test   %rsi,%rsi
  4e:   48 c7 c1 00 00 00 00    mov    $0x0,%rcx
  55:   ba 36 00 00 00          mov    $0x36,%edx
  5a:   48 89 e5                mov    %rsp,%rbp
  5d:   41 54                   push   %r12
  5f:   49 89 f4                mov    %rsi,%r12
  62:   53                      push   %rbx
  63:   48 89 fb                mov    %rdi,%rbx
  66:   74 15                   je     7d <kref_put+0x33>
  68:   48 81 fe 00 00 00 00    cmp    $0x0,%rsi
  6f:   75 26                   jne    97 <kref_put+0x4d>
  71:   48 c7 c1 00 00 00 00    mov    $0x0,%rcx
  78:   ba 37 00 00 00          mov    $0x37,%edx
  7d:   48 c7 c6 00 00 00 00    mov    $0x0,%rsi
  84:   48 c7 c7 00 00 00 00    mov    $0x0,%rdi
  8b:   31 c0                   xor    %eax,%eax
  8d:   e8 00 00 00 00          callq  92 <kref_put+0x48>
  92:   e8 00 00 00 00          callq  97 <kref_put+0x4d>
  97:   f0 ff 0b                lock decl (%rbx)
  9a:   0f 94 c0                sete   %al
  9d:   31 d2                   xor    %edx,%edx
  9f:   84 c0                   test   %al,%al
  a1:   74 0b                   je     ae <kref_put+0x64>
  a3:   48 89 df                mov    %rbx,%rdi
  a6:   41 ff d4                callq  *%r12
  a9:   ba 01 00 00 00          mov    $0x1,%edx
  ae:   5b                      pop    %rbx
  af:   41 5c                   pop    %r12
  b1:   c9                      leaveq 
  b2:   89 d0                   mov    %edx,%eax
  b4:   c3                      retq   

It's not necessary identical to what that kernel had; still, not bad for
a starting point.  We are even lucky enough to find 'f0 ff' immediately
in there:
  97:   f0 ff 0b                lock decl (%rbx)
Next instructions also match - actually, better than I expected.  So.
We even have register allocation matching the reported kernel and it
all makes sense - this is the instruction where it had puked, the address
had, indeed, come from rbx and it's locked decrement of *rbx followed
by some testing and conditional jump.  Just what one would expect
from atomic_dec_and_test().

IOW, we have &kref->refcount equal to 0x0000000034333545.  What's the
value of kref itself?  We could look into definition of struct kref,
or just notice that release(kref) should be right after that, so
we could see what gets passed to it.
  a3:   48 89 df                mov    %rbx,%rdi
  a6:   41 ff d4                callq  *%r12
is clearly it.  So what we are passing is rbx itself, so that offset got to
be zero.

All right, so we have kref_put() getting 0x0000000034333545 instead of a
pointer in the first argument.  It's called from kobject_put() and unless
-mm has changes in there, there's no need to guess where in kobject_put()
that had been:
void kobject_put(struct kobject * kobj)
{
        if (kobj)
                kref_put(&kobj->kref, kobject_release);
}

Aha.  Now, we need to work back from &kobj->kref to kobj.  Again, assuming
that -mm doesn't change struct kobject in a way that would affect the
offset, we have
struct kobject {
        const char              * k_name;
        struct kref             kref;
        struct list_head        entry;
...
Looks like it's not too likely, unless somebody had been deliberately
rearranging fields (to fit cachelines better, etc.).  We'll need to
verify that, of course, but for now it's a good starting assumption.
Very well, we have one pointer in front of it.  It's an amd64, so
it's an 8 byte field and no alignment padding is to be expected.
IOW, kobj is 0x0000000034333545 - 8, i.e. 0x000000003433353D.  What's _that_
in ASCII?  "=534".  OK, that makes even more sense for a part of some
string...

Let's check; time to take a look at that patch, after all
 struct kobject {
-       const char              * k_name;
+       const char              *name;
        struct kref             kref;

OK, not a problem.  While we are at it, kobject_put() is unchanged by
the patch.  Now, back to trace.  kobject_put() is called from kobject_del().
Now, that one does differ from mainline:

void kobject_del(struct kobject * kobj)
{
	if (!kobj)
		return;

	sysfs_remove_dir(kobj);
	kobj->state_in_sysfs = 0;
	kobj_kset_leave(kobj);
	kobject_put(kobj->parent);
	kobj->parent = NULL;
}

Humm...  So we have kobj->parent containing crap.  What about the caller?
It's from drivers/md/md.c:
static void delayed_delete(struct work_struct *ws)
{
        mdk_rdev_t *rdev = container_of(ws, mdk_rdev_t, del_work);
        kobject_del(&rdev->kobj);
}
and it's only used in
static void unbind_rdev_from_array(mdk_rdev_t * rdev)
{
        char b[BDEVNAME_SIZE];
        if (!rdev->mddev) {
                MD_BUG();
                return;
        }
        bd_release_from_disk(rdev->bdev, rdev->mddev->gendisk);
        list_del_init(&rdev->same_set);
        printk(KERN_INFO "md: unbind<%s>\n", bdevname(rdev->bdev,b));
        rdev->mddev = NULL;
        sysfs_remove_link(&rdev->kobj, "block");

        /* We need to delay this, otherwise we can deadlock when
         * writing to 'remove' to "dev/state"
         */
        INIT_WORK(&rdev->del_work, delayed_delete);
        schedule_work(&rdev->del_work);
}

Well, that takes care of the rest of trace - we have used INIT_WORK to set
rdev->del_work up, scheduled it for execution and eventually the callback
had been called (asynchronously to us).

So what do we have so far?
	unbind_rdev_from_array(rdev);
had been called and rdev->kobj.parent turned to contain a crap value
(0x000000003433353D) instead of a pointer.  That's about all we can
get out of trace.

Now, let's see what could have triggered it.  Curious... Looking through
diff shows an interesting bit:
-       rdev->kobj.parent = &mddev->kobj;
-       if ((err = kobject_add(&rdev->kobj)))
+       if ((err = kobject_add(&rdev->kobj, &mddev->kobj, "dev-%s", b)))
                goto fail;
in bind_rdev_to_array().  At the first sight the changes in kobject_add() 
seem to match that.  And nothing else in md.c seems to be setting it to
anything non-NULL.  Very well, so it's one of the following:

	* unbind_rdev_from_array() called on rdev that didn't pass through
bind_rdev_to_array().
	* unbind_rdev_from_array() called on rdev that bailed out from
bind_rdev_to_array() before that point.
	* mddev value in the above is crap.  That's bloody unlikely, BTW -
kobject_add() would increment the refcount of rdev->kobj.parent (or we would
be in far more trouble, since it would not match kobject_del() and _that_
would hurt a lot more than just md.c).  So &mddev->kobj would better be
something saner when it went through that point.
	* *rdev got corrupted in between.

Actually, looking at the callers of unbind_rdev_from_array()...  We always
follow it with export_rdev().  Which does (presumably) final kobject_put()
on &rdev->kobj, freeing rdev itself.

What guarantees that it doesn't happen before we get to callback?  AFAICS,
nothing whatsoever...

And if it does happen, we'll get rdev happily freed (by rdev_free(), as
->release() of &rdev->kobj) by the time we get to delayed_delete().  Which
explains what's going on just fine.

BTW, -mm changes in kobject.c explain WTF it doesn't trigger in mainline -
there we managed to get away with that since kobject_add() bumped refcount
of kobject by one and kobject_del() decremented it.  That masked the bug.
