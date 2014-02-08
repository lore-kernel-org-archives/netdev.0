From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: REGRESSION f54b311142a92ea2e42598e347b84e1655caf8e3 tcp auto
 corking slows down iSCSI file system creation by factor of 70 [WAS: 4 TB
 VMFS creation takes 15 minutes vs 26 seconds]
Date: Sat, 08 Feb 2014 09:08:38 -0800
Message-ID: <1391879318.10160.108.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140207205142.GA8609@glanzmann.de>
	 <20140208093808.GD16336@glanzmann.de>
	 <1391865273.10160.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391866389.10160.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391867404.10160.88.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1391868816.10160.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208141905.GG20512@glanzmann.de>
	 <1391869805.10160.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208150001.GI20512@glanzmann.de>
	 <1391871986.10160.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140208165732.GB22359@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Ogness <john.ogness@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	target-devel <target-devel@vger.kernel.org>,
	Linux Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Thomas Glanzmann <thomas@glanzmann.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:44241 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbaBHRIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Feb 2014 12:08:39 -0500
In-Reply-To: <20140208165732.GB22359@glanzmann.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-02-08 at 17:57 +0100, Thomas Glanzmann wrote:
> Hello Eric,
> 
> > Note : We did some patches in the MSG_MORE logic for sendpage(), but
> > in your case I do not think its related
> > (git grep -n MSG_SENDPAGE_NOTLAST ) if you are curious
> 
> thank you for the pointer. The iSCSI target code actually uses sendpage
> whenever it can.

Yep, but the problem (at least on your pcap), is about sending the 48
bytes headers in  TCP segment of its own, then the 512 byte payload in a
separate segment.

I suspect the sendpage() is only used for the payload. No need for
MSG_MORE here.

The MSG_MORE would need to be set on the first part (48 bytes header),
so that TCP stack will defer the push of the segment at the time the 512
bytes payload is added.
