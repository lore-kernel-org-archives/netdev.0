From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 10:44:40 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E6F@saturn3.aculab.com>
References: <201202141122.10705.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Steffen Klassert" <klassert@mathematik.tu-chemnitz.de>,
	<netdev@vger.kernel.org>
To: "Jean Delvare" <jdelvare@suse.de>,
	"Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34979 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751387Ab2BNKpM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 05:45:12 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20284-07 for <netdev@vger.kernel.org>;
 Tue, 14 Feb 2012 10:45:09 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <201202141122.10705.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> Well I am still curious why the 3c59x driver has such slow 
> polling when 
> other drivers I have been testing are able to report almost instantly 
> when I remove a network cable. Could it be that other network chips 
> generate an interrupt on cable removal and the 3com chips do not?

Not sure about those specific cards, but detecting the
link state might require software bit-banging of an MII
(or similar) interface.

Since this needs delays between all the edges it can
end up spinning the cpu for a noticable time, especially
if the resolution (and minimim delay) of the delay()
function used is significantly longer than the delays
actually required - which might only be a few 100ns.

Using a cpu spin for the delays is also slightly
problematical because the writes might get 'posted'
and delayed further - so the writes have to be forced
out to the device itself (eg by a readback) prior to
the delay() being requested.

If the driver is polling the link status it might
be valid to do one bit-bang transition on each timer
interrupt. This would separate the edges without
spinning the cpu - provided there is a fast method
for being called on every timer tick.

Another scheme I have used is to write each value
to the bit-bang register multiple times - using
the maximum speed of the IO writes to generate the
required delays.

	David
