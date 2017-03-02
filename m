From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 02/26] rewrite READ_ONCE/WRITE_ONCE
Date: Thu, 2 Mar 2017 22:45:23 +0100
Message-ID: <CAK8P3a2mepCjPfM9Ychk7CHFHi0UW8RBzK4skJKMSOjw3gKoYg@mail.gmail.com>
References: <20170302163834.2273519-1-arnd@arndb.de> <20170302163834.2273519-3-arnd@arndb.de>
 <76790664-a7a9-193c-2e30-edaee1308cb0@de.ibm.com> <CAK8P3a082Bi6Vf5gEFLAJtJvUm=7MtddBzcCOqagQyfJPFTu_g@mail.gmail.com>
 <2adc6ff4-5dc5-8f1d-cce1-47f3124a528f@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kasan-dev <kasan-dev@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2adc6ff4-5dc5-8f1d-cce1-47f3124a528f@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 2, 2017 at 8:00 PM, Christian Borntraeger
<borntraeger@de.ibm.com> wrote:
> On 03/02/2017 06:55 PM, Arnd Bergmann wrote:
>> On Thu, Mar 2, 2017 at 5:51 PM, Christian Borntraeger
>> <borntraeger@de.ibm.com> wrote:
>>> On 03/02/2017 05:38 PM, Arnd Bergmann wrote:
>>>>
>>>> This attempts a rewrite of the two macros, using a simpler implementation
>>>> for the most common case of having a naturally aligned 1, 2, 4, or (on
>>>> 64-bit architectures) 8  byte object that can be accessed with a single
>>>> instruction.  For these, we go back to a volatile pointer dereference
>>>> that we had with the ACCESS_ONCE macro.
>>>
>>> We had changed that back then because gcc 4.6 and 4.7 had a bug that could
>>> removed the volatile statement on aggregate types like the following one
>>>
>>> union ipte_control {
>>>         unsigned long val;
>>>         struct {
>>>                 unsigned long k  : 1;
>>>                 unsigned long kh : 31;
>>>                 unsigned long kg : 32;
>>>         };
>>> };
>>>
>>> See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58145
>>>
>>> If I see that right, your __ALIGNED_WORD(x)
>>> macro would say that for above structure  sizeof(x) == sizeof(long)) is true,
>>> so it would fall back to the old volatile cast and might reintroduce the
>>> old compiler bug?
>
> Oh dear, I should double check my sentences in emails before sending...anyway
> the full story is referenced in
>
> commit 60815cf2e05057db5b78e398d9734c493560b11e
>     Merge tag 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/borntraeger/linux
> which has a pointer to
> http://marc.info/?i=54611D86.4040306%40de.ibm.com
> which contains the full story.

Ok, got it. So I guess the behavior of forcing aligned accesses on aligned
data is accidental, and allowing non-power-of-two arguments is also not
the main purpose. Maybe we could just bail out on new compilers if we get
either of those? That might catch code that accidentally does something
that is inherently non-atomic or that causes a trap when the intention was
to have a simple atomic access.

     Arnd
