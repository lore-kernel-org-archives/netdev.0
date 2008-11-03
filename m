From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
 (fwd) [SOLVED]
Date: Mon, 3 Nov 2008 17:37:09 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811031705390.23792@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810011546371.1034@wrl-59.cs.helsinki.fi>
 <alpine.LFD.1.10.0810021407400.5549@apollo.tec.linutronix.de>
 <48e4d63a.060ec00a.6a4e.ffff95bf@mx.google.com>
 <alpine.LFD.1.10.0810022113540.5549@apollo.tec.linutronix.de>
 <Pine.LNX.4.64.0810022251400.22964@wrl-59.cs.helsinki.fi>
 <48e5364d.0603c00a.6e25.fffff993@mx.google.com>
 <Pine.LNX.4.64.0810030008280.22964@wrl-59.cs.helsinki.fi>
 <48e8fef7.0610c00a.5fa2.ffffaab0@mx.google.com> <alpine.LFD.2.00.0810052008131.3398@apollo>
 <48ed0b51.0913c00a.7715.4aa7@mx.google.com> <alpine.LFD.2.00.0810082154420.3237@apollo>
 <48f2c9d7.0603c00a.1df2.ffff9357@mx.google.com>
 <Pine.LNX.4.64.0810131633370.3843@wrl-59.cs.helsinki.fi>
 <48f9251b.1626360a.6574.61ec@mx.google.com> <Pine.LNX.4.64.0810210028550.30254@wrl-59.cs.helsinki.fi>
 <48fe8c06.4719360a.3996.04a9@mx.google.com> <Pine.LNX.4.64.0810301232360.7072@wrl-59.cs.helsinki.fi>
 <490d4120.0807c00a.32d8.5eaf@mx.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-532832151-1225724872=:23792"
Cc: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59645 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754149AbYKCPhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 10:37:12 -0500
In-Reply-To: <490d4120.0807c00a.32d8.5eaf@mx.google.com>
Content-ID: <Pine.LNX.4.64.0811031715090.23792@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-532832151-1225724872=:23792
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0811031708011.23792@wrl-59.cs.helsinki.fi>

On Sun, 2 Nov 2008, Dâniel Fraga wrote:

> On Thu, 30 Oct 2008 12:43:05 +0200 (EET)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Perhaps we could try to solve it though stracing syslogd...
> 
> 	Well Ilpo, you're right, what I'm about to write here will make
> me very ashamed, but the truth must be told! The culprit was syslogd!
> Almost unbeliavable, but I had been using and old syslogd version for
> about 5 years!
> 
> 	How can I'm sure that it's syslogd's fault? Simply, because I
> had a stall today and when I killed syslogd everything was back to
> normal.

Once there's any kind of flow control, anything jamming downstream will 
eventually make upstream to stall as well (or to appear as not working 
as expected. Sadly, it's exactly opposite from correctness point of view 
as flow control is a feature in TCP, not a bug :-)). Thus I occassionally 
run to these tcp with flow control not working reports which turn to be 
totally unrelated.

This still doesn't explain everything though afaik... E.g., why did the 
sendto() to SOCK_DGRAM socket hung.

> 	But no problem. I'll just wait a few more days to test if
> syslogd is the only responsible for this, but I'm 90% sure it is.

And you had the same old syslogd on both hosts?

In any case the loss of every other character deterministically sounds 
like a real bug in the syslogd since it doesn't make too much sense to 
happen in kernel->syslogd communication (where I'd expect it to not show 
up in such consistent pattern but would cause more randomness).

> 	I apologize for thinking that it was a kernel fault.

It's not clear what caused this to happen _now_, nor the exact mechanism.

> 	Ps: just for curiosity, I was using a syslogd binary from Mar,
> 3, 2003! Extremely old! This is so old, it was compiled for Linux
> 2.2.5. Or maybe I was too lazy and copied it from another machine...

In theory this shouldn't be too big problem, but I'm hardly an expert of 
those things and syslogd is anyway more thightly coupled to kernel than 
some random app.

> 	Ps3: anyway, it's interesting how a small piece of the system
> (syslogd) can generate those kinds of problems... I mean, a simple
> error on syslogd could lead to a complete stall on connections, just
> because everything is waiting for it to log through /dev/log.

This is more of a philosophical question than something else... it's 
always balancing between data loss (=possibly losing a logline of an 
important event) or possibility of a stall. But this shouldn't be a 
concern in the case where SOCK_DGRAM was used by the sudo (like in the 
strace you sent to sudo people), in general UDP doesn't guarantee 
reliability so not delivering wouldn't be a problem but I don't know if 
PF_FILE domain does something otherwise in there.

> Of course
> the problem was the binary, but it could have a time out, so even if it
> was in fact a buggy syslogd, it won't cause such a stall on the
> system. I really don't know what changed from 2.6.24 to 2.6.25, but
> maybe 2.6.24 had such a timeout? Maybe I'm just silly writing that...
> you guys know much more than me.

Until we know more details than that killing syslogd helped it's hard to 
tell what is the actual cause. And I have no clue about semantics of 
/dev/log anyway.

> 	Ps4: maybe now we can understand why nmap solved the issue...

Not very clear but at least sudo does some writing there too.

-- 
 i.
---696208474-532832151-1225724872=:23792--
