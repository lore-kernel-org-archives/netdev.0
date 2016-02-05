From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: gigaset: memory leak in gigaset_initcshw
Date: Fri, 5 Feb 2016 14:28:59 +0100
Message-ID: <CACT4Y+aNN8AAtRSvxxrP5RfsTZdd49odnQ_GRq86Y=jXr=pANw@mail.gmail.com>
References: <CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com>
 <1454516189.14366.8.camel@tiscali.nl> <1454526665.14366.22.camel@tiscali.nl>
 <CACT4Y+aDi8L_GELzVv7QM8YdtMD7q-wH4uO7LhioeSvaEU5PJg@mail.gmail.com>
 <1454591389.14366.49.camel@tiscali.nl> <CACT4Y+aXo83LjyOjVG2ihyR94kex-z+=Of+x8o4i+0q8964-1g@mail.gmail.com>
 <1454593604.14366.65.camel@tiscali.nl> <CACT4Y+b2z0NHVPQbyYP1CA_80hXxhk+VOG6dzduMEsi+27Pi7Q@mail.gmail.com>
 <1454598375.14366.72.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454598375.14366.72.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 4, 2016 at 4:06 PM, Paul Bolle <pebolle@tiscali.nl> wrote:
> On do, 2016-02-04 at 15:54 +0100, Dmitry Vyukov wrote:
>> One TIOCSETD is enough to trigger the leak.
>> I've tested with different line disciplines and only N_GIGASET_M101
>> triggers the leak.
>
> So things appear to be just on my plate now. I'll see what I can come up
> with. Feel free to prod me if I stay silent for too long.
>
> Thanks for narrowing things down!

> 0) It's way too late here. And I can't really reproduce, and too many
> things jumps to 100% when running your reproducer. Anyhow, this is all I
> came up with (for drivers/isdn/gigaset/common.c):
>
> @@ -427,7 +427,11 @@ exit:
>
>  static void free_cs(struct cardstate *cs)
>  {
> -       cs->flags = 0;
> +       unsigned long flags;
> +       struct gigaset_driver *drv = cs->driver;
> +       spin_lock_irqsave(&drv->lock, flags);
> +       cs->flags &= ~VALID_MINOR;
> +       spin_unlock_irqrestore(&drv->lock, flags);
>  }
>
>  static void make_valid(struct cardstate *cs, unsigned mask)
>
> 1) On my side the logs do seem more sensible, for what it's worth. But
> does this fix the leak?
>
> 2) Note that I fear your reproducer allows to DOS the box (even if the
> leak turns out to be fixed) so the mess might be getting much worse. I
> need a clear hear to think this through. Ie, I need some sleep.

No, it does not help.

I wonder why you don't see the leak I am seeing... are you suing qemu
or real hardware? I am using qemu.

I've added the following change:

--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -396,6 +396,7 @@ static int gigaset_initcshw(struct cardstate *cs)
                pr_err("out of memory\n");
                return -ENOMEM;
        }
+       WARN_ON(cs->hw.ser != NULL);
        cs->hw.ser = scs;

        cs->hw.ser->dev.name = GIGASET_MODULENAME;

and it does fire.
Can it be a case that free_cs() runs before gigaset_device_release()?
If that would happen, then cs can be reused while the previous
cs->hw.ser is not freed yet. Just a guess.
