From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: Stop using tasklets for bottom halves
Date: Tue, 08 Sep 2009 13:27:18 -0400
Message-ID: <1252430838.5493.5.camel@gandalf.stny.rr.com>
References: <43e72e890909071558s637b45c7i10807587dc40e8c4@mail.gmail.com>
	 <20090907171406.6a4b6116@nehalam>
	 <1252376254.21261.2052.camel@gandalf.stny.rr.com>
	 <20090908091143.1e613963@nehalam>
	 <1252428023.15626.30.camel@gandalf.stny.rr.com>
	 <20090908100144.6e06872b@nehalam>
Reply-To: rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matt Smith <Matt.Smith-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Kevin Hayes <kevin-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>, Jouni Malinen <j@w1.fi>,
	Ivan Seskar <Seskar-NvJAj8134tRxEa0u/P/EHDe48wsgrGvP@public.gmane.org>, ic.felix-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090908100144.6e06872b@nehalam>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[ added Thomas Gleixner to Cc]

On Tue, 2009-09-08 at 10:01 -0700, Stephen Hemminger wrote:
> On Tue, 08 Sep 2009 12:40:23 -0400
> Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
> 
> > On Tue, 2009-09-08 at 09:11 -0700, Stephen Hemminger wrote:
> > 
> > > > > Process context is too slow.
> > > > 
> > > > Well, I'm hoping to prove the opposite. I'm working on some stuff that I
> > > > plan to present at Linux Plumbers. I've been too distracted by other
> > > > things, but hopefully I'll have some good numbers to present by then.
> > > > 
> > > 
> > > 
> > > That's great, does it keep the good properties of NAPI (irq disabling
> > > and throttling?)
> > 
> > Not exactly sure what you mean by throttling, but I'm assuming it will.
> > 
> > As for irqs disabling, I'm trying to avoid doing that. Note, the device
> > will have its interrupts disabled, but not all other devices will.
> > 
> > -- Steve
> > 
> > 
> 
> The way NAPI works is that in irq routine, the device disables interrupts
> then schedules processing packets, when processing is done irq's are re-enabled.
> This means that if machine is being flooded, irq's stay off, and the packets
> get discarded (because device hardware ring is full), rather than in software
> (because software receive queue is full).

That sounds exactly like what threaded IRQs will do. When an interrupt
comes in, the device driver will disable the device interrupts, and then
the device irq thread handler is awoken.

The device irq handler will handle all the packets. If new packets come
in, and the hardware ring buffer is full, those packets will be dropped.
When the irq handler thread is done processing all pending packets, it
will re-enable the device's interrupts and go to sleep.

Yeah, looking at the NAPI code, it does seem to follow what threaded
interrupts do.

-- Steve


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
