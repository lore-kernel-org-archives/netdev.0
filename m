From: Dan Williams <dcbw@redhat.com>
Subject: Re: question: Any way to trigger DHCP renewal from kernel code?
Date: Fri, 23 May 2014 10:06:56 -0500
Message-ID: <1400857616.18322.9.camel@dcbw.local>
References: <c64a7b76572942fda9acffc25dd76c29@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054AbaEWPG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 11:06:59 -0400
In-Reply-To: <c64a7b76572942fda9acffc25dd76c29@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-22 at 22:24 +0000, Haiyang Zhang wrote:
> Hi,
> 
> Our synthetic network driver is notified when the Hyper-V host 
> resume from sleep/hibernation. We need to renew DHCP in this case.
> I'm looking for a way to trigger DHCP renewal from kernel mode 
> code.

Another approach could be to change the 'operstate' of your synthetic
netdevice to IF_OPER_DORMANT and then back to IF_OPER_UP.  Possibly like
drivers/net/hsr/hsr_device.c does in __hsr_set_operstate().

The netdev_state_change() call will send out a netlink message that the
device has changed, which includes the device flags.  Before changing
the operstate, the flags will include IFF_RUNNING, which indicates the
netdevice is operating and passing traffic.  When you change the
operstate to IF_OPER_DORMANT, a netlink message will be sent which does
*not* include IFF_RUNNING.  Then changing back to IF_OPER_UP will emit a
netlink message that *does* include IFF_RUNNING again.

The DHCP client can listen for device flag changes and trigger a DHCP
renew when the IFF_RUNNING flag re-appears on the device.  There are
some notes about this in Documentation/networking/operstates.txt too.

(Random note: long ago when WiMAX was relevant there was also a need to
trigger a DHCP renew in userspace based on events from the driver; a
renew should be performed when the device comes out of fast sleep, which
can happen quite often.  I don't remember how Inaky solved this, but I
think it was out-of-band driver messages to the userspace control
daemon.  A more standardized kernel facility somewhat less convoluted
than manually munging operstates would have been nice...)

Dan
