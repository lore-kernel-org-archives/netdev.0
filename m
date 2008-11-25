From: nik-lists@varna.net
Subject: RE: e1000 and PBA
Date: Tue, 25 Nov 2008 10:40:50 +0200 (EET)
Message-ID: <2f008dd9695b75b0c1447bcd21c5277d.webmail@www.varna.net>
References: <1d380c73ba9296d4277c279e9808e84a.webmail@www.varna.net>
    <F169D4F5E1F1974DBFAFABF47F60C10A1714B109@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=windows-1251
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.Varna.Net ([217.145.80.1]:56810 "EHLO ns.varna.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751904AbYKYIkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 03:40:52 -0500
Received: from www.varna.net (mail2.Varna.Net [217.145.80.3])
	by ns.varna.net (8.13.6/8.13.6) with ESMTP id mAP8eoo4020248
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 10:40:50 +0200
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A1714B109@orsmsx507.amr.corp.intel.com
     >
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> what other devices do you have on the PCI bus?  Since there are different
> versions of this part having a device ID here in the discussion would
> help.  Also, you may want to try setting InterruptThrottleRate=8000 at
> driver load time to set the interrupt rate, if and only if you're also
> seeing rx_no_buffer errors.  If the packets are being dropped due to
> too low an interrupt rate, then both counters will go.
> The total size is 64KB or 48KB, but see below.
>

There is one e100 as well, but it hardly sees any traffic. The OS runs
from a ramdisk, and I believe that the e1000 has the entire PCI bus for
itself. Here comes my big controversy with my colleague - my opinion is
that it is better to have one single good quality board with a very well
tuned driver rather than few boards (provided of course that this one
board is able to handle the traffic). Am I right? :-)

More details about the gige card in question:
lspci -n:
8086:107c (rev 05)

lspci -v | grep Intel
00:09.0 Ethernet controller: Intel Corporation 82541PI Gigabit Ethernet
Controller (rev 05)
        Subsystem: Intel Corporation PRO/1000 GT Desktop Adapter

Don't blame me for using a desktop adapter for non-desktop purposes -
'Cutting costs' is the most used collocation these days :-)

Yes, I am seeing rx_no_buffer_count errors as well, but the value is
smaller than rx_missed_errors. The InterruptThrottleRate option is with
it's default value (3). I am thinking of changing it to (1), as the
traffic has no specific profile (let's consider it as random), as well as
doubling the rx ring size.

> the upper 16 bits is always the transmit space and is automatically
> configured by subtracting the lower 16 bits value from the maximum
> value.  so, if you have 64KB (0x40), and you want to have 4KB transmit
> fifo, E1000_WRITE_REG(hw, E1000_PBA, 0x3C)
>
> so the upper and lower 16 bits added together gives you the size in KB
> of the total FIFO.

Therefore, if it is 48K and I want to play safe, I am setting the pba
value to

pba = 40;

and the rest 8 will be used for the tx buffer.

Respectively, if it is 64K, I can set pba = 56;

Is there a specific reason to NOT make this a parameter which can be
passed to the module at load time?
>
> Hope this helps, and maybe you can take a look at the reference manuals
> at e1000.sourceforge.net
>
> I also suggest that you can download the ethregs utility and try it as
> well, it outputs this:
> # ethregs -s 4:2.0|grep PBA
>         PBA            00100030
>
> I suggest you change the line
>     560         switch (mac->type) {
>     561         case e1000_82542:
>     562         case e1000_82543:
>     563         case e1000_82544:
>     564         case e1000_82540:
>     565         case e1000_82541:
>     566         case e1000_82541_rev_2:
>     567                 legacy_pba_adjust = TRUE;
>>>>>568                 pba = E1000_PBA_48K;
>     569                 break;
>
> to pba = 60;
>
> you may need to try using 56 instead of 60 because there may be an 8K
> boundary
> requirement but I didn't see it in the manual when I quickly looked.

Yes, that helps me. Thank you very much indeed.


