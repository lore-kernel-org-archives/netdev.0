From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 1/4] e1000: disable TSO workaround on 82544
Date: Fri, 27 Jun 2008 10:25:55 -0400
Message-ID: <20080627142555.GE32408@gospo.rdu.redhat.com>
References: <20080619211836.GC22981@gospo.rdu.redhat.com> <486476F7.9010506@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255AbYF0O03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 10:26:29 -0400
Content-Disposition: inline
In-Reply-To: <486476F7.9010506@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 27, 2008 at 01:13:27AM -0400, Jeff Garzik wrote:
> Andy Gospodarek wrote:
> >It appears that the 82544 does not need the TSO workaround needed on
> >other chips.  This seems to resolve excessive messages that appear to be
> >Tx Unit Hangs when a system is under heavy stress.
> 
> Do these excessive messages occur for all systems with the TSO 
> workaround?  i.e. does this patch merely remove one chip from the list 
> of chips that receive excessive messages?
> 

Jeff,

Sorry I was a bit terse with my original description.  I re-read it and
realize it isn't that descriptive.

This patch was added a looong time ago to address an erratum with any
of this chips that support TSO:

commit fd803241744ad6e4262b6588c6af89e8fb794098
Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date:   Tue Dec 13 00:06:22 2005 -0500

    e1000: Fixes for 8357x

    - TSO workaround
    - Fixes eeprom version reporting
    - Fix loopback test
    - Fix for WOL

The basic idea was that the TSO workaround (really a workaround for the
first non-TSO frame after a TSO frame) was needed on all hardware that
supported TSO (82544 was this first that did, I think).

I've gotten quite a few complaints with 82544 that messages like these
followed by watchdog timeout were frequent under certain loads:

e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
  Tx Queue             <0>
  TDH                  <67>
  TDT                  <51>
  next_to_use          <51>
  next_to_clean        <65>
buffer_info[next_to_clean]
  time_stamp           <5809242>
  next_to_watch        <6b>
  jiffies              <5809b12>
  next_to_watch.status <0>

Users seemed to quit having problems when TSO was disabled though.  More
debugging and dumping of registers took place and Jesse B suggested we
try disabling the workaround added above for 84544 as it may not have
been needed for that controller.

That fix was tested by someone who was having watchdog timeouts like the
one above on a frequent basis ceased to have them with this patch.  I've
seen plenty of reports of these timeouts on 82544 with most users
reporting that they just disabled TSO and would continue to run that way
rather than bother debugging the issue.  Thankfully someone who wanted
to use this hardware and TSO was able to help resolve this.

If you want to read all the gory details you can check out:

https://bugzilla.redhat.com/show_bug.cgi?id=334411

-andy

