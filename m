From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: changing usbnet's API to better deal with cdc-ncm
Date: Fri, 7 Sep 2012 17:23:33 +0200
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA5753D@EXDCVYMBSTM006.EQ1STM.local>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
 <1446113.XC2Qbo4flT@linux-lqwf.site>
 <2AC7D4AD8BA1C640B4C60C61C8E520154A6AA5741E@EXDCVYMBSTM006.EQ1STM.local>
 <1800340.RWjbMaZGSN@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: =?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Ming Lei <tom.leiming@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:39894 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755791Ab2IGPXx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 11:23:53 -0400
In-Reply-To: <1800340.RWjbMaZGSN@linux-lqwf.site>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Oliver Neukum [mailto:oneukum@suse.de]
> Sent: Friday, September 07, 2012 3:09 PM

> >
> > Until we do something with network device framework in order to get
> > access to upper layer Tx queue we need to utilize timer.
> 
> Could you explain your reasoning? From what you say we must reduce the
> number of transfers, thus use them efficiently, but why by means of a
> timer?
> 

What was omitted in the previous mail is the fact that in addition to
reducing amount of transfers we need to fill in NTB to the maximum size.
It's quite important especially for embedded systems.

As an example, on device (modem) side, DMA job for max NTB is initially
set. 
- If device receives full NTB, only one interrupt (per NTB) is
generated at the completion of DMA job and NCM function can immediately
parse incoming NTB frame. 
- In case of "skinny" (not full) NTB, device gets INT for the short
packet, then original DMA job for full NTB shall be cancelled, then DMA
job to get short packet shall be set and after that we get INT for its
completion. Only at this point all data is received and NTB parsing
can be done by NCM function. All above takes quite more time than first
case.

There is a temptation to send full NTBs even with a single IP packet,
But it will lead to wasted USB bandwidth and reduced ability to send
real data for other functions in the device or other devices on the
same root hub. Most important it will also harm IN direction.

The challenge is to ensure that an acceptable timeout value is used. Too
long and latency is introduced. Too short and too many padded NTBs will
go out and that reduces the available throughput. The ideal timer value
depends on the throughput available in the network. Something that is not
really explicitly known to the NCM layer nor to the layer above.

Alternate methods exist to achieve the same result without using a timer.
But an optimal implementation requires that the amount of IP packets "in
progress" or queued up is known to NCM so NCM can decide to send short or
padded NTB or aggregate and send one or more full NTBs plus short or
padded NTB. 

An implementation where NCM only knows if there is more data available or
not can be shown to have side-effects that are not easily circumvented.
And likewise shown to limit throughput compared to a timer-based solution.   

Regards,
Alexey
