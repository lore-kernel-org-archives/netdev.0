From: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCHv2 net-next 10/16] net: mvpp2: handle register mapping
 and access for PPv2.2
Date: Thu, 2 Mar 2017 09:45:33 +0100
Message-ID: <20170302094533.5e6dfe93@free-electrons.com>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <1482943592-12556-11-git-send-email-thomas.petazzoni@free-electrons.com>
        <20170106144648.GE14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Yehuda Yitschak <yehuday-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hanna Hawa <hannah-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Stefan Chulski <stefanc-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170106144648.GE14217-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, 6 Jan 2017 14:46:48 +0000, Russell King - ARM Linux wrote:

> I'm not entirely sure this is the best solution - every register access
> will be wrapped with a preempt_disable() and preempt_enable().  At
> every site, when preempt is enabled, we will end up with code to:
> 
> - get the thread info
> - increment the preempt count
> - access the register
> - decrement the preempt count
> - test resulting preempt count and branch to __preempt_schedule()
> 
> If tracing is enabled, it gets much worse, because the increment and
> decrement happen out of line, and are even more expensive.
> 
> If a function is going to make several register accesses, it's going
> to be much more efficient to do:
> 
> 	void __iomem *base = priv->cpu_base[get_cpu()];
> 
> 	...
> 
> 	put_cpu();
> 
> which means we don't end up with multiple instances of the preempt code
> consecutive accesses.

In the next version, these accessors have been reworked. After getting
more details about the HW, it turned out that disabling preemption is
not at all necessary. We just have some global registers (can be
accessed through any per-CPU window) and some per-CPU registers (must
be accessed from a specific per-CPU window), with the trick that
certain sequences of register read/write must occur from the same
per-CPU window.

So we'll have mvpp2_{read,write} that read/write through the register
window of CPU0, used for all non-per CPU register accesses. And we'll
have mvpp2_percpu_{read,write}, taking an additional "cpu" argument,
used for per-CPU register accesses. Thanks to "cpu" being passed as
argument, the caller can ensure the same cpu window is used to do
several reads/writes in a row.

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
