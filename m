From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [7/8,RFC] CAIF Protocol Stack
Date: Thu, 08 Oct 2009 11:48:27 +0200
Message-ID: <4ACDB56B.1060002@babic.homelinux.org>
References: <1253727096-10413-1-git-send-email-sjur.brandeland@stericsson.com> <4ACA1D31.6000008@babic.homelinux.org> <61D8D34BB13CFE408D154529C120E07902ED671E@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>
To: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout26.attiva.biz ([85.37.16.27]:4230 "EHLO
	smtpout26.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756890AbZJHJtN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 05:49:13 -0400
In-Reply-To: <61D8D34BB13CFE408D154529C120E07902ED671E@eseldmw101.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sjur Br=E6ndeland wrote:
> Yes, I'll fix this documentation in a new PATCH delivery (hopefully) =
this week.

Ok, I will test it again when you will send to the ML.

> Hmm, the hanging might be due to a tight loop in the phyif_ser.c:ser_=
phy_tx function.

Agree. I can trace what happens and I can check that the tty write
function returns always 0. However, I can check that the ops field of
pser_tty is correctly set to the uart_* functions in serial_core.c and
that pser_tty->index points to the serial I chose. At least the
connection to the physical interface seems right.

> [snip]
> 		do {
> 			tty_wr =3D
> 			    pser_tty->ops->write(pser_tty, bufp, actual_len);

Yes, tty_wr is always 0.

> If pser_tty->ops->write() returns zero it will loop infinetly.
> I guess the proper solution would be not to loop, but to implement a =
write_wakeup function for the tty...?

Agree, but this is not the problem now, because pser_tty->ops->write
returns always 0.
I have supposed that "clocal" was not set on the serial, but I have
found something different.

In phyif_ser.c, I traced the result of the extract function:

[snip]
do {
                char *bufp;
                /* By default we assume that we will extract
                 * all data in one go. */
                cont =3D false;

                /* Extract data from the packet. */
                f.cfpkt_extract(cfpkt, sbuf_wr, WRITE_BUF_SIZE,
&actual_len);

I can state that actual_len is always wrong (at least, the first time
=2Eser_phy_txis called). I get a completely wrong value for it, as if t=
his
variable is not initialized:

actual_len -1090496676

Then the uart_write function cannot work with negative numbers and
explains why it returns 0. So it seems to me at the moment there is a
bug in the extract function. What do you think about ?

Best regards,
Stefano Babic

--=20
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
=46ingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
