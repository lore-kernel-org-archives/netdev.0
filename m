From: Albert Cahalan <acahalan@gmail.com>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination for
	32byte SSIDs
Date: Tue, 15 Dec 2009 05:16:56 -0500
Message-ID: <787b0d920912150216t58e817b2g64e8a19b0a1331bf@mail.gmail.com>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org,
	Michael Hirsch <m.hirsch@raumfeld.com>,
	libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
	netdev@vger.kernel.org, stable@kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:61570 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbZLOKQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 05:16:59 -0500
In-Reply-To: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 12, 2009 at 3:47 PM, Daniel Mack <daniel@caiaq.de> wrote:

> While the root cause turned out to be an issue with the wpa-supplicant
> which feeds the kernel driver with garbage, this occasion pointed out a
> bug in the wireless wext core when SSIDs with 32 byte lengths are passed
> from userspace. In this case, the string is not properly NULL-terminated
> which causes some other part to corrupt memory.

This is the wrong fix.

These are not strings. They are 32 arbitrary bytes. It is perfectly
legitimate to have a NUL byte in the middle; the use of C string
functions will corrupt the data.

For your testing I suggest:

a. start the SSID with '-'
b. include "/../" in the SSID
c. include UTF-16 surrogates wrongly encoded as UTF-8
d. include "\r\n" in the SSID
e. include quote and backslash characters in the SSID
f. include bytes in the 0x80 to 0x9f range, surrounded by ASCII
g. include bytes in the 0xc0 to 0xff range, surrounded by ASCII
h. include the sequence 0xc0,0x80 (Java UTF-8 pseudo-NUL)
i. include the NUL byte
j. end the SSID with a plain ASCII letter

Verify that the whole stack, from driver to GUI, can handle this.
That includes config files, command lines, /proc and /sys, etc.
