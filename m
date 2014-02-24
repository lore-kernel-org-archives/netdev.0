From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 4/5] be2net: wait longer to reap TX compls in
 be_close()
Date: Mon, 24 Feb 2014 11:30:21 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6C98FD@AcuExch.aculab.com>
References: <57bc5399-f8f6-4c65-8cae-131c83d548ad@CMEXHTCAS1.ad.emulex.com>
 <063D6719AE5E284EB5DD2968C1650D6D0F6C9608@AcuExch.aculab.com>
 <d3bd3dc1-8e29-4388-bbd3-e4af196d592b@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Vasundhara Volam <Vasundhara.Volam@Emulex.Com>
To: 'Sathya Perla' <Sathya.Perla@Emulex.Com>,
	Somnath Kotur <Somnath.Kotur@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56437 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752140AbaBXLbT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 06:31:19 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24354-07 for <netdev@vger.kernel.org>;
 Mon, 24 Feb 2014 11:31:17 +0000 (GMT)
In-Reply-To: <d3bd3dc1-8e29-4388-bbd3-e4af196d592b@CMEXHTCAS2.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Sathya Perla 
> > From: David Laight [mailto:David.Laight@ACULAB.COM]
> >
> > From: Of Somnath Kotur
> > > be_close() currently waits for a max of 200ms to receive all pending
> > > TX compls. This timeout value was roughly calcuated based on 10G
> > > transmission speeds and the TX queue depth. This timeout may not be
> > > enough when the link is operating at lower speeds or in
> > > multi-channel/SR-IOV configs with TX-rate limiting setting.
> > > Increase the timeout to 2000ms and also bail-out if there is
> > > a HW-error.
> >
> > What about monitoring whether transmits are actually completing,
> > and giving up if none are completed within a suitable time period?
> >
> 
> David, the code already does that. All the queues are checked for
> any new TX compls each 1ms in the be_close()->be_tx_compl_clean()
> path. This patch is not changing that logic.

Yes, but it might be better to modify the logic rather than just
increase the timeout.

The code is waiting for any pending transmits to complete.
The purpose of the timeout is to give up if the transmits aren't going
to complete.
So instead of assuming that a specific interval is long enough, abort
if no transmits completed in (say) a 10ms period.
Move the sleep() to the top of the loop and abort if nothing is found
on any queue.
Oh and move the zeroing of cmpl and num_wrbs to a sensible place.

	David
