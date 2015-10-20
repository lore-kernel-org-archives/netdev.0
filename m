From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: removed USB_USBNET as a config option
Date: Tue, 20 Oct 2015 10:43:00 +0200
Message-ID: <87k2qiszfv.fsf@nemi.mork.no>
References: <1445257387-4278-1-git-send-email-oneukum@suse.com>
	<87oafuu0ru.fsf@nemi.mork.no> <1445322539.2246.1.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:58297 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753511AbbJTInS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 04:43:18 -0400
In-Reply-To: <1445322539.2246.1.camel@suse.com> (Oliver Neukum's message of
	"Tue, 20 Oct 2015 08:28:59 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.com> writes:
> On Mon, 2015-10-19 at 21:16 +0200, Bj=C3=B8rn Mork wrote:
>
>> This looks incomplete.
>
> Yes, it is against the earlier patch set which introduces the CDC
> parser in cdc-acm and cdc-wdm. In hindsight I should have reversed
> the order of patches.

Ah, right, I see.

But that patch has it's own set of problems, as pointed out by the test
robot:

All the USBNET based minidrivers (as well as the USB_USBNET
infrastructure itself) are protected by

menuconfig USB_NET_DRIVERS
        tristate "USB Network Adapters"
        default USB if USB
        depends on USB && NET

if USB_NET_DRIVERS
=2E.


but USB_ACM and USB_WDM don't have similar protection.  So you'll have
to make them select NET and USB_NET_DRIVERS too.

Selecting NET is going to be messy.  It already selects 3 other symbols=
,
which you'll have to add as well.  And I have a feeling that the list o=
f
NET dependencies might grow, which probably explains why there currentl=
y
are no "select NET"'s in the kernel. So "select NET" is most likely out
of the question.  And I don't think we want to make USB_ACM or USB_WDM
depend on NET either.  It will not make sense to anyone attempting to
select these drivers, resulting in infinite confusion.

So we might need to move cdc_parse_cdc_header() out of usbnet.c after
all. Keeping it there creates an unnecessary "select" mess.  But I don'=
t
know where to put it...  Either a common CDC helper module or the USB
core I guess.

Sorry for not bringing this up earlier. I know you asked specifically
about this. I obviously didn't think it thoroughly through before.




Bj=C3=B8rn
