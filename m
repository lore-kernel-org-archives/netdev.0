From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Tue, 29 May 2007 14:01:55 -0700
Message-ID: <20070529140155.07693380@freepuppy>
References: <20070525172431.60affaca@freepuppy>
	<200705281655.15105.mb@bu3sch.de>
	<1180448075.17146.12.camel@dhcp-10-12-136-115.broadcom.com>
	<200705292245.22940.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Gary Zambrano" <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Maximilian Engelhardt" <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	"linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Arnaldo Carvalho de Melo" <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	"Jeff Garzik" <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705292245.22940.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I am busy bisecting the real cause. Unfortunately, oprofile doesn't work
on the laptop, and build time sucks...

This how I think the IRQ should work:

--- a/drivers/net/b44.c	2007-05-29 09:47:53.000000000 -0700
+++ b/drivers/net/b44.c	2007-05-29 09:49:50.000000000 -0700
@@ -908,9 +908,11 @@ static irqreturn_t b44_interrupt(int irq
 	u32 istat, imask;
 	int handled = 0;
 
-	spin_lock(&bp->lock);
-
 	istat = br32(bp, B44_ISTAT);
+	if (istat == 0 || istat == ~0)
+		return IRQ_NONE;
+
+	spin_lock(&bp->lock);
 	imask = br32(bp, B44_IMASK);
 
 	/* The interrupt mask register controls which interrupt bits
