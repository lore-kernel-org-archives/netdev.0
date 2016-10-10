From: Aaron Conole <aconole@redhat.com>
Subject: Re: slab corruption with current -git (was Re: [git pull] vfs pile 1 (splice))
Date: Mon, 10 Oct 2016 09:49:33 -0400
Message-ID: <f7ta8ec71qq.fsf@redhat.com>
References: <CA+55aFz2U83pG0v12E--nd5c6GZAUpVnT3jHuAwHCFk5XbVX0w@mail.gmail.com>
        <20161010005105.GA18349@breakpoint.cc> <f7tbmytkmtr.fsf@redhat.com>
        <CA+55aFzntXuUyL85A68ghS-D-t3VdgKo9-FiqQBG3efW2xns3A@mail.gmail.com>
        <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
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
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwS1jfnNzU=8CzRyxC79qKrStwmTXYrBHQYcftAg4LT3Q@mail.gmail.com>
        (Linus Torvalds's message of "Sun, 9 Oct 2016 20:41:17 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Sun, Oct 9, 2016 at 7:49 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
>>
>> There is one *correct* way to remove an entry from a singly linked
>> list, and it looks like this:
>>
>>     struct entry **pp, *p;
>>
>>     pp = &head;
>>     while ((p = *pp) != NULL) {
>>         if (right_entry(p)) {
>>             *pp = p->next;
>>             break;
>>         }
>>         pp = &p->next;
>>     }
>>
>> and that's it. Nothing else.

Sorry, I should have done that.

> This COMPLETELY UNTESTED patch tries to fix the nf_hook_entry code to do this.
>
> I repeat: it's ENTIRELY UNTESTED. I just converted the insertion and
> deletion to the proper pattern, but I could easily have gotten the
> insertion priority test the wrong way around entirely, for example. Or
> it could simply have some other completely broken bug in it. It
> compiles for me, but that's all I actually checked.

Okay, I'm looking it over.  Sorry for the mess.

> Note that the "correct way" of doing list operations also almost
> inevitably is the shortest way by far, since it gets rid of all the
> special cases. So the patch looks nice. It gets rid of the magic
> "nf_set_hooks_head()" thing too, because once you do list following
> right, the head is no different from any other pointer in the list.
>
> So the patch stats look good:
>
>  net/netfilter/core.c | 108 ++++++++++++++++-----------------------------------
>  1 file changed, 33 insertions(+), 75 deletions(-)
>
> but again, it's entirely *entirely* untested. Please consider this
> just a "this is generally how list insert/delete operations should be
> done, avoiding special cases for the first entry".

I'll review it, and test it.  Can you tell me what steps you took to
reproduce the oops?  I'll enable slab debugging and try to reproduce
without and with this patch (and I'll also look into David's recent
email as well).  Are you simply creating and removing network
namespaces (I did test that, but I should have done a better job)?

> ALSO NOTE! The code assumes that the "nf_hook_mutex" locking only
> protects the actual *lists*, and that the address to the list can be
> looked up without holding the lock. That's generally how things are
> done, and it simplifies error handling (because you can do the "there
> is no such list at all" test before you do anything else. But again, I
> don't actually know the code, and if there is something that actually
> expands the number of lists etc that depends on that mutex, then the
> list head lookup may need to be inside the lock too.

That should be correct, the nf_hook_mutex is only for protecting the
lists.

>            Linus
