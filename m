From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Thu, 08 Jun 2006 13:29:00 -0400
Message-ID: <x49ac8nwo83.fsf@redhat.com>
References: <20060605231125.12584.17039.stgit@gitlost.site>
	<20060606135217.GA21969@hmsreliant.homelinux.net>
	<1149611965.13635.19.camel@strongmad>
	<20060606170513.GB21969@hmsreliant.homelinux.net>
	<4485B8EC.4090603@intel.com>
	<x494pyyw5sr.fsf@segfault.boston.redhat.com>
	<4485BCA2.5070904@intel.com>
	<x49zmgquqn0.fsf@segfault.boston.redhat.com>
	<20060606231727.GK24227@waste.org>
	<20060607150522.GA24608@hmsreliant.homelinux.net>
	<20060607164801.GX24227@waste.org> <44871A19.7080805@intel.com>
	<x49d5dkvm8p.fsf@segfault.boston.redhat.com>
	<1149787174.2928.3.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Matt Mackall <mpm@selenic.com>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:17633 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S964849AbWFHRXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 13:23:52 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <1149787174.2928.3.camel@strongmad> (Mitch Williams's message of "Thu, 08 Jun 2006 10:19:34 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

==> Regarding Re: [PATCH 1/2] e1000: fix netpoll with NAPI; Mitch Williams <mitch.a.williams@intel.com> adds:

mitch.a.williams> On Wed, 2006-06-07 at 11:44 -0700, Jeff Moyer wrote:
>> That patch locks around the tx clean routine.  As such, it doesn't
>> prevent the problem.

mitch.a.williams> The call to netif_rx_schedule_prep provides locking
mitch.a.williams> because it sets the __LINK_STATE_RX_SCHED bit atomically.
mitch.a.williams> The spinlock around e1000_clean_tx_irq is to protect it
mitch.a.williams> from other calls to the transmit routine, not NAPI.

Yes, but what prevents recursion in the poll routine?  Consider that the
poll routine could end up triggerring a printk (think iptables, here).  In
that case, you end up calling into netpoll, and if the tx ring is full, we
call the poll_controller routine.  We've now recursed.

The poll lock was originally introduced to prevent recursion, not
concurrent access.

-Jeff
