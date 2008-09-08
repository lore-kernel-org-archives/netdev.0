From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Mon, 8 Sep 2008 11:54:05 -0700
Message-ID: <200809081154.05512.david-b@pacbell.net>
References: <1220881350-4043-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Catalin Marinas <catalin.marinas@arm.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp117.sbc.mail.sp1.yahoo.com ([69.147.64.90]:33626 "HELO
	smtp117.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754228AbYIHTUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 15:20:47 -0400
In-Reply-To: <1220881350-4043-1-git-send-email-steve.glendinning@smsc.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 08 September 2008, Steve Glendinning wrote:
> +
> +#define SMSC_WARNING(msg, args...) \
> +=A0=A0=A0=A0=A0=A0=A0printk(KERN_WARNING "%s: WARNING: " msg "\n", _=
_func__, ## args)
> +
> +#ifdef USE_DEBUG
> +#define SMSC_TRACE(debug_bit, msg, args...) \
> +=A0=A0=A0=A0=A0=A0=A0if (debug_mode & debug_bit) { \
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0printk(KERN_WARNING "%s=
: " msg "\n", __func__, ## args); \
> +=A0=A0=A0=A0=A0=A0=A0}
> +#else
> +#define SMSC_TRACE(dbgBit, msg, args...) =A0 ({ do {} while (0); 0; =
})
> +#endif

Standard feedback for such stuff:

 - avoid printk() for diagnostics, use dev_*() driver model calls
 - ... or in this case, pr_warning() if you really must
 - provide better messages and avoid passing __func__=20
 - use inline functions instead of CPP macros
 - make dead code elimination remove debug code, not #ifdefs

And specific to network devices:

 - use the ethtool message level flags not private debug_mode


> +int turbo_mode =3D true;
> +module_param(turbo_mode, bool, 0);
> +MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transact=
ion");

I'm curious ... does this actually improve things on Linux?

My understanding is that on MS-Windows the costs of sending
a transaction through the USB stack are so high that their
APIs encourage such batching, and this has in some cases
extended down to wire protocols and (as seems true here)
even to hardware.

The approach Linux prefers is just to ensure that a queue
of transactions works efficiently ... so that for example
each Ethernet frame maps directly to one URB, and there's
no time wasted batching/unbatching.  (Neither in Linux,
nor in the peripheral.)

Last time I had any measurements on such issues, the
Linux stack outperformed MS-Windows in terms of per-packet
latency and also throughput, indicating that batching was
not necessary for performance on most network loads.  But
maybe that's not the case with your particular hardware,
or in certain significant/common use cases?

- Dave
