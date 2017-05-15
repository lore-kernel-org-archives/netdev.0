From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] kmod: don't load module unless req process has CAP_SYS_MODULE
Date: Mon, 15 May 2017 10:07:27 -0700
Message-ID: <CAGXu5j+UkB0UgFKOHXZ3T=2EGk54soemtLuAuv3AdyX2nZ=Y=A@mail.gmail.com>
References: <20170512232259.10820-1-mahesh@bandewar.net> <20170514104537.GA29323@kroah.com>
 <CAF2d9jh6zARipRGM92drOjjrpicF6177cnUf=6oHbR9tHX1ObA@mail.gmail.com> <CANn89i+iuT0xPwiOspxA-_7YpY8CXjWYh4o5MskFj6S=v=K8rA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Ingo Molnar <mingo@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89i+iuT0xPwiOspxA-_7YpY8CXjWYh4o5MskFj6S=v=K8rA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2017 at 6:12 AM, Eric Dumazet <edumazet@google.com> wrote:
> On Sun, May 14, 2017 at 7:42 PM, Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=
=A5=87=E0=A4=B6 =E0=A4=AC=E0=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=
=A4=B0)
> <maheshb@google.com> wrote:
>> On Sun, May 14, 2017 at 3:45 AM, Greg Kroah-Hartman
>> <gregkh@linuxfoundation.org> wrote:
>>> On Fri, May 12, 2017 at 04:22:59PM -0700, Mahesh Bandewar wrote:
>>>> From: Mahesh Bandewar <maheshb@google.com>
>>>>
>> [...]
>>>>   Now try to create a bridge inside this newly created net-ns which wo=
uld
>>>>   mean bridge module need to be loaded.
>>>>   # ip link add br0 type bridge
>>>>   # echo $?
>>>>   0
>>>>   # lsmod | grep bridge
>>>>   bridge                110592  0
>>>>   stp                    16384  1 bridge
>>>>   llc                    16384  2 bridge,stp
>>>>   #
>>>>
>>>>   After this patch -
>>>>   # ip link add br0 type bridge
>>>>   RTNETLINK answers: Operation not supported
>>>>   # echo $?
>>>>   2
>>>>   # lsmod | grep bridge
>>>>   #
>>>
>>> Well, it only loads this because the kernel asked for it to be loaded,
>>> right?
>>>
>> Yes, kernel asked for it because of a user action.
>>
>>>>
>>>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>>>> ---
>>>>  kernel/kmod.c | 3 +++
>>>>  1 file changed, 3 insertions(+)
>>>>
>>>> diff --git a/kernel/kmod.c b/kernel/kmod.c
>>>> index 563f97e2be36..ac30157169b7 100644
>>>> --- a/kernel/kmod.c
>>>> +++ b/kernel/kmod.c
>>>> @@ -133,6 +133,9 @@ int __request_module(bool wait, const char *fmt, .=
..)
>>>>  #define MAX_KMOD_CONCURRENT 50       /* Completely arbitrary value - =
KAO */
>>>>       static int kmod_loop_msg;
>>>>
>>>> +     if (!capable(CAP_SYS_MODULE))
>>>> +             return -EPERM;
>>>
>>> At first glance this looks right, but I'm worried what this will break
>>> that currently relies on this.  There might be lots of systems that are
>>> used to this being the method that the needed module is requested.  Wha=
t
>>> about when userspace asks for a random char device and that module is
>>> then loaded?  Does this patch break that functionality?
>>>
>> Any module when loaded gets loaded system-wide as we can't allow
>> module loading per-ns. To validate the behavior I was comparing it
>> with insmod/modprobe, if that doesn't allow because of lack of this
>> capability in default-ns, then this *indirect* method of loading
>> module should not allow the same action and the behavior should be
>> consistent. So with that logic if userspace asks for a random
>> char-device if insmod/modprobe cannot load it, then this method should
>> not load it either for the consistency, right?
>
>
> This patch will break applications that expected modules being auto loade=
d.

I would prefer that we continue to look at the autoloading
restrictions series, since that will be more flexible and cover a
wider set of cases:

https://lkml.org/lkml/2017/4/19/1086

-Kees

--=20
Kees Cook
Pixel Security
