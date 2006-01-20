From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: My vote against eepro* removal
Date: Fri, 20 Jan 2006 14:05:08 +0300
Message-ID: <20060120110508.GB24815@2ka.mipt.ru>
References: <AAD6DA242BC63C488511C611BD51F367323326@MAILIT.keba.co.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Ronciak <john.ronciak@gmail.com>,
	Adrian Bunk <bunk@stusta.de>,
	Lee Revell <rlrevell@joe-job.com>,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750827AbWATLFp@vger.kernel.org>
To: kus Kusche Klaus <kus@keba.com>
Content-Disposition: inline
In-Reply-To: <AAD6DA242BC63C488511C611BD51F367323326@MAILIT.keba.co.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 20, 2006 at 11:51:23AM +0100, kus Kusche Klaus (kus@keba.com) wrote:
> From: Evgeniy Polyakov [mailto:johnpol@2ka.mipt.ru] 
> > Each MDIO read can take upto 2 msecs (!) and at least 20 
> > usecs in e100,
> > and this runs in timer handler.
> > Concider attaching (only compile tested) patch which moves 
> > e100 watchdog
> > into workqueue.
> 
> Tested the patch. Works and has the expected effects:
> 
> Fully preemptible kernel: 
> No change: 500 us delay at rtprio 1, no delay at higher rtprio.
> (you just moved the 500 us piece of code from one rtprio 1 kernel 
> thread to another rtprio 1 kernel thread).
> 
> Kernel with desktop preemption:
> Originally: Threads at any rtprio suffered from 500 us delay.
> With your patch: Only rtprio 1 threads suffer from 500 us delay,
> no delay at higher rtprio.

Just a hack:

--- drivers/net/e100.c.1	2006-01-20 13:39:19.000000000 +0300
+++ drivers/net/e100.c	2006-01-20 14:15:40.000000000 +0300
@@ -879,8 +879,8 @@
 
 	writel((reg << 16) | (addr << 21) | dir | data, &nic->csr->mdi_ctrl);
 
-	for(i = 0; i < 100; i++) {
-		udelay(20);
+	for(i = 0; i < 1000; i++) {
+		udelay(2);
 		if((data_out = readl(&nic->csr->mdi_ctrl)) & mdi_ready)
 			break;
 	}


> -- 
> Klaus Kusche                 (Software Development - Control Systems)
> KEBA AG             Gewerbepark Urfahr, A-4041 Linz, Austria (Europe)
> Tel: +43 / 732 / 7090-3120                 Fax: +43 / 732 / 7090-6301
> E-Mail: kus@keba.com                                WWW: www.keba.com
>  

-- 
	Evgeniy Polyakov
