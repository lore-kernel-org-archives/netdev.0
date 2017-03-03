From: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/26] rewrite READ_ONCE/WRITE_ONCE
Date: Fri, 3 Mar 2017 09:26:50 +0100
Message-ID: <f86cf852-3960-0dcf-5917-509080ca7bf5@de.ibm.com>
References: <20170302163834.2273519-1-arnd@arndb.de>
 <20170302163834.2273519-3-arnd@arndb.de>
 <76790664-a7a9-193c-2e30-edaee1308cb0@de.ibm.com>
 <CAK8P3a082Bi6Vf5gEFLAJtJvUm=7MtddBzcCOqagQyfJPFTu_g@mail.gmail.com>
 <2adc6ff4-5dc5-8f1d-cce1-47f3124a528f@de.ibm.com>
 <CAK8P3a2mepCjPfM9Ychk7CHFHi0UW8RBzK4skJKMSOjw3gKoYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
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
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAK8P3a2mepCjPfM9Ychk7CHFHi0UW8RBzK4skJKMSOjw3gKoYg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/02/2017 10:45 PM, Arnd Bergmann wrote:
> On Thu, Mar 2, 2017 at 8:00 PM, Christian Borntraeger
> <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org> wrote:
>> On 03/02/2017 06:55 PM, Arnd Bergmann wrote:
>>> On Thu, Mar 2, 2017 at 5:51 PM, Christian Borntraeger
>>> <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org> wrote:
>>>> On 03/02/2017 05:38 PM, Arnd Bergmann wrote:
>>>>>
>>>>> This attempts a rewrite of the two macros, using a simpler implementation
>>>>> for the most common case of having a naturally aligned 1, 2, 4, or (on
>>>>> 64-bit architectures) 8  byte object that can be accessed with a single
>>>>> instruction.  For these, we go back to a volatile pointer dereference
>>>>> that we had with the ACCESS_ONCE macro.
>>>>
>>>> We had changed that back then because gcc 4.6 and 4.7 had a bug that could
>>>> removed the volatile statement on aggregate types like the following one
>>>>
>>>> union ipte_control {
>>>>         unsigned long val;
>>>>         struct {
>>>>                 unsigned long k  : 1;
>>>>                 unsigned long kh : 31;
>>>>                 unsigned long kg : 32;
>>>>         };
>>>> };
>>>>
>>>> See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58145
>>>>
>>>> If I see that right, your __ALIGNED_WORD(x)
>>>> macro would say that for above structure  sizeof(x) == sizeof(long)) is true,
>>>> so it would fall back to the old volatile cast and might reintroduce the
>>>> old compiler bug?
>>
>> Oh dear, I should double check my sentences in emails before sending...anyway
>> the full story is referenced in
>>
>> commit 60815cf2e05057db5b78e398d9734c493560b11e
>>     Merge tag 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/borntraeger/linux
>> which has a pointer to
>> http://marc.info/?i=54611D86.4040306%40de.ibm.com
>> which contains the full story.
> 
> Ok, got it. So I guess the behavior of forcing aligned accesses on aligned
> data is accidental, and allowing non-power-of-two arguments is also not
> the main purpose.


Right. The main purpose is to read/write _ONCE_. You can assume a somewhat
atomic access for sizes <= word size. And there are certainly places that
rely on that. But the *ONCE thing is mostly used for things where we used
barrier() 10 years ago.


 Maybe we could just bail out on new compilers if we get
> either of those? That might catch code that accidentally does something
> that is inherently non-atomic or that causes a trap when the intention was
> to have a simple atomic access.

I think Linus stated that its ok to assume that the compiler is smart enough 
to uses a single instruction to access aligned and properly sized scalar types
for *ONCE.

Back then when I changed ACCESS_ONCE there were many places that did use it
for non-atomic, > word size accesses. For example on some architectures a pmd_t
is a typedef to an array, for which there is no way to read that atomically.
So the focus must be on the "ONCE" part.

If some code uses a properly aligned, word sized object we can also assume 
atomic access. If the access is not properly sized/aligned we do not get
atomicity, but we do get the "ONCE".
But adding a check for alignment/size would break the compilation of some
code.
