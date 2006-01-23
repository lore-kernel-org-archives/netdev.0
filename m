From: "kus Kusche Klaus" <kus@keba.com>
Subject: RE: My vote against eepro* removal
Date: Mon, 23 Jan 2006 12:01:47 +0100
Message-ID: <AAD6DA242BC63C488511C611BD51F367323329@MAILIT.keba.co.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"Adrian Bunk" <bunk@stusta.de>, <linux-kernel@vger.kernel.org>,
	<john.ronciak@intel.com>, <ganesh.venkatesan@intel.com>,
	<jesse.brandeburg@intel.com>, <netdev@vger.kernel.org>,
	"Steven Rostedt" <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751393AbWAWLCJ@vger.kernel.org>
Content-class: urn:content-classes:message
To: "John Ronciak" <john.ronciak@gmail.com>,
	"Lee Revell" <rlrevell@joe-job.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Ronciak
> Can we try a couple of things? 1) just comment out all the check for
> link code in the e100 driver and give that a try and 2) just comment
> out the update stats call and see if that works.  These seem to be the
> differences and we need to know which one is causing the problem.

First of all, I am still unable to get any traces of this in the
latency tracer. Moreover, as I told before, removing parts of the 
watchdog usually made my eth0 nonfunctional (which is bad - this
is an embedded system with ssh access).

Hence, I explicitely instrumented the watchdog function with tsc.
Output of the timings is done by a background thread, so the
timings should not increase the runtime of the watchdog.

Here are my results:

If the watchdog doesn't get interrupted, preempted, or whatever,
it spends 340 us in its body:
* 303 us in the mii code
*  36 us in the following code up to e100_adjust_adaptive_ifs
*   1 us in the remaining code (I think my chip doesn't need any
of those chip-specific fixups)

The 303 us in the mii code are divided in the following way:
* 101 us in mii_ethtool_gset
* 135 us in the whole if
*  67 us in mii_check_link

This is with the udelay(2) instead of udelay(20) hack applied.
With udelay(20), the mii times are 128 + 170 + 85 us,
i.e. 383 us instead of 303 us, or >= 420 us for the whole watchdog.

As the RTC runs with 8192 Hz during my tests, the watchdog is hit
by 2-3 interrupts, which adds another 75 - 110 us to its total
execution time, i.e. the time it blocks other rtprio 1 threads.

-- 
Klaus Kusche                 (Software Development - Control Systems)
KEBA AG             Gewerbepark Urfahr, A-4041 Linz, Austria (Europe)
Tel: +43 / 732 / 7090-3120                 Fax: +43 / 732 / 7090-6301
E-Mail: kus@keba.com                                WWW: www.keba.com
 
