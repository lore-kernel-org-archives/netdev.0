From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: gigaset: memory leak in gigaset_initcshw
Date: Fri, 05 Feb 2016 17:06:27 +0100
Message-ID: <1454688387.28847.34.camel@tiscali.nl>
References: <CACT4Y+Y+P7-pM0D4HTz4ZF6i+Rya22eOkPdnrv_OmDCMB7eQtg@mail.gmail.com>
	 <1454516189.14366.8.camel@tiscali.nl>
	 <1454526665.14366.22.camel@tiscali.nl>
	 <CACT4Y+aDi8L_GELzVv7QM8YdtMD7q-wH4uO7LhioeSvaEU5PJg@mail.gmail.com>
	 <1454591389.14366.49.camel@tiscali.nl>
	 <CACT4Y+aXo83LjyOjVG2ihyR94kex-z+=Of+x8o4i+0q8964-1g@mail.gmail.com>
	 <1454593604.14366.65.camel@tiscali.nl>
	 <CACT4Y+b2z0NHVPQbyYP1CA_80hXxhk+VOG6dzduMEsi+27Pi7Q@mail.gmail.com>
	 <1454598375.14366.72.camel@tiscali.nl>
	 <CACT4Y+aNN8AAtRSvxxrP5RfsTZdd49odnQ_GRq86Y=jXr=pANw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
	"David S. Miller" <davem@davemloft.net>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, syzkaller@googlegroups.com,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+aNN8AAtRSvxxrP5RfsTZdd49odnQ_GRq86Y=jXr=pANw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dmitry,

(If anyone is confused by this conversation: Dmitry replied to an off
list message.)

On vr, 2016-02-05 at 14:28 +0100, Dmitry Vyukov wrote:
> I wonder why you don't see the leak I am seeing...

So do I, for a few days now.

> are you suing qemu or real hardware? I am using qemu.

Real hardware (a ThinkPad). Probably less powerful that your VM.

What is the rate you're seeing leakage of a struct ser_cardstate? I'm
running your latest test at about 2.000 TIOCSETD's per second - which is
by itself not very useful for our driver - and notice no _obvious_
leakage when I do that for a few minutes. I do note the hardware
screaming to just keep up with the abuse, though.

> I've added the following change:
> 
> --- a/drivers/isdn/gigaset/ser-gigaset.c
> +++ b/drivers/isdn/gigaset/ser-gigaset.c
> @@ -396,6 +396,7 @@ static int gigaset_initcshw(struct cardstate *cs)
>                 pr_err("out of memory\n");
>                 return -ENOMEM;
>         }
> +       WARN_ON(cs->hw.ser != NULL);
>         cs->hw.ser = scs;
> 
>         cs->hw.ser->dev.name = GIGASET_MODULENAME;
> 
> and it does fire.
> Can it be a case that free_cs() runs before gigaset_device_release()?

gigaset_device_release() is the release operation that is run when our
struct device goes away. The core code is responsible for calling it, we
can't be certain when that will happen. At least, we should not expect
it to happen directly after calling platform_device_unregister().

(It was actually syzkaller that warned us that we did just that until
recently. See commit 4c5e354a9742 ("ser_gigaset: fix deallocation of
platform device structure").)

> If that would happen, then cs can be reused while the previous
> cs->hw.ser is not freed yet. Just a guess.

I'll have to ponder on that a bit, sorry.


Paul Bolle
