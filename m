From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 32/58] isdn/gigaset: Convert timers to use
 timer_setup()
Date: Thu, 19 Oct 2017 23:31:20 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1710192328110.2054@nanos>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>         <1508200182-104605-33-git-send-email-keescook@chromium.org>         <1508447002.2274.14.camel@tiscali.nl> <1508448028.2274.21.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>,
        Karsten Keil <isdn@linux-pingi.de>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508448028.2274.21.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Oct 2017, Paul Bolle wrote:

> On Thu, 2017-10-19 at 23:03 +0200, Paul Bolle wrote:
> > On Mon, 2017-10-16 at 17:29 -0700, Kees Cook wrote:
> > > In preparation for unconditionally passing the struct timer_list pointer to
> > > all timer callbacks, switch to using the new timer_setup() and from_timer()
> > > to pass the timer pointer explicitly.
> > 
> > Acked-by: Paul Bolle <pebolle@tiscali.nl>
> 
> I have to take this back, sorry!
> 
> > For the record: this patch made me nervous but survived the rigorous testing I
> > threw at it. (Ie, dialing up using bas_gigaset and downloading almost 20 MB in
> > just over an hour. Whoot! That's more than good enough to ack this patch.)
> > 
> > There was some cleanup I had in mind to make this patch more straightforward.
> > But that can wait until someone finds a way to hit an issue with this patch.
> > We'll see.
> 
> That someone turns out to be me, doing "modprobe -r bas_gigaset":
> 
> <1>[30143.538135] BUG: unable to handle kernel NULL pointer dereference at 000001e9
> <1>[30143.538154] IP: mutex_lock+0x19/0x30
> <0>[30143.538300]  gigaset_shutdown+0x28/0x130 [gigaset]
> <0>[30143.538307]  ? find_module_all+0x62/0x80
> <0>[30143.538314]  bas_gigaset_exit+0x31/0x1077 [bas_gigaset]

bas_gigaset_exit()
{
        for (i = 0; i < driver->minors; i++) {
                if (gigaset_shutdown(driver->cs + i) < 0)

gigaset_shutdown(cs)
{
	mutex_lock(&cs->mutex); <-------- Explodes here

So driver->cs + i is invalid. No idea how that might be related to that
timer conversion patch, but ....

Thanks,

	tglx
