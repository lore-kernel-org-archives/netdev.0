From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 02/26] rewrite READ_ONCE/WRITE_ONCE
Date: Fri, 3 Mar 2017 10:54:07 +0100
Message-ID: <CAK8P3a0M6KAiLj9HM8UYykL-CtZNEsDcD0L1kZ1usPCx4=vq+g@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-3-arnd@arndb.de>
 <76790664-a7a9-193c-2e30-edaee1308cb0@de.ibm.com> <CAK8P3a082Bi6Vf5gEFLAJtJvUm=7MtddBzcCOqagQyfJPFTu_g@mail.gmail.com>
 <2adc6ff4-5dc5-8f1d-cce1-47f3124a528f@de.ibm.com> <CAK8P3a2mepCjPfM9Ychk7CHFHi0UW8RBzK4skJKMSOjw3gKoYg@mail.gmail.com>
 <f86cf852-3960-0dcf-5917-509080ca7bf5@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kasan-dev <kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
        Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
        Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-build-reports-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Paul McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f86cf852-3960-0dcf-5917-509080ca7bf5-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 9:26 AM, Christian Borntraeger
<borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org> wrote:
> On 03/02/2017 10:45 PM, Arnd Bergmann wrote:
>> Ok, got it. So I guess the behavior of forcing aligned accesses on aligned
>> data is accidental, and allowing non-power-of-two arguments is also not
>> the main purpose.
>
>
> Right. The main purpose is to read/write _ONCE_. You can assume a somewhat
> atomic access for sizes <= word size. And there are certainly places that
> rely on that. But the *ONCE thing is mostly used for things where we used
> barrier() 10 years ago.

Ok

>
>  Maybe we could just bail out on new compilers if we get
>> either of those? That might catch code that accidentally does something
>> that is inherently non-atomic or that causes a trap when the intention was
>> to have a simple atomic access.
>
> I think Linus stated that its ok to assume that the compiler is smart enough
> to uses a single instruction to access aligned and properly sized scalar types
> for *ONCE.
>
> Back then when I changed ACCESS_ONCE there were many places that did use it
> for non-atomic, > word size accesses. For example on some architectures a pmd_t
> is a typedef to an array, for which there is no way to read that atomically.
> So the focus must be on the "ONCE" part.
>
> If some code uses a properly aligned, word sized object we can also assume
> atomic access. If the access is not properly sized/aligned we do not get
> atomicity, but we do get the "ONCE".
> But adding a check for alignment/size would break the compilation of some
> code.

So what should be the expected behavior for objects that have a smaller
alignment? E.g. this structure

struct fourbytes {
   char bytes[4];
} __packed;

when passed into the current READ_ONCE() will be accessed with
a 32-bit load, while reading it with

struct fourbytes local = *(volatile struct fourbytes *)voidpointer;

on architectures like ARMv5 or lower will turn into four single-byte
reads to avoid an alignment trap when the pointer is actually
unaligned.

I can see arguments for and against either behavior, but what should
I do when modifying it for newer compilers? The possible options
that I see are

- keep assuming that the pointer will be aligned at runtime
  and doesn't trap
- use the regular gcc behavior and do byte-accesses on those
  architectures that otherwise might trap
- add a runtime alignment check to do atomic accesses whenever
  possible, but never trap
- fail the build

     Arnd
