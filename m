From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [7/8,RFC] CAIF Protocol Stack
Date: Thu, 08 Oct 2009 16:03:22 +0200
Message-ID: <4ACDF12A.6030906@babic.homelinux.org>
References: <1253727096-10413-1-git-send-email-sjur.brandeland@stericsson.com> <4ACA1D31.6000008@babic.homelinux.org> <61D8D34BB13CFE408D154529C120E07902ED671E@eseldmw101.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Kim Lilliestierna XX <kim.xx.lilliestierna@stericsson.com>
To: =?ISO-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout084B.attiva.biz ([85.33.31.84]:32048 "EHLO
	smtpout084B.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756412AbZJHOJh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 10:09:37 -0400
In-Reply-To: <61D8D34BB13CFE408D154529C120E07902ED671E@eseldmw101.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sjur Br=E6ndeland wrote:

> If pser_tty->ops->write() returns zero it will loop infinetly.
> I guess the proper solution would be not to loop, but to implement a =
write_wakeup function for the tty...?

I discovered there is a production bug in the Makefile and the setup of
the extract function in cfcnfg_get_packet_funcs() is inconsistent.
Indeed, I traced the address of the extract function and I can find tha=
t
the address does not point to cfpkt_extract(), as I assumed.

The problem is due to the usage of the define CAIF_USE_SKB. This is use=
d
in caif_layer.h, but some files (net/caif/*) are compiled with the macr=
o
defined, while the drivers (drivers/net/caif/*) not.
Rather I did not get an "oops", because a valid pointer was set....but
to the wrong function !

I have also seen that CAIF_USE_SKB is not used in
cfpkt_get_packet_funcs, and this generates a problem if CAIF_USE_SKB is
not set, because the "fromnative" and "tonative" functions are always
set, even if they do not belong to the structure.

IMHO should be possible to get rid of the usage of CAIF_USE_SKB in the
structure definition (in caif_layer.h) and to provide always the same
structure definition in both case. I would prefer to set the values of
cfpkt_fromnative and cfpkt_tonative to NULL, instead of reducing the
size of the structure.

I mean, something like this:

void cfpkt_get_packet_funcs(caif_packet_funcs_t *f)
{
#ifdef CAIF_USE_SKB
        f->cfpkt_fromnative =3D cfpkt_fromnative;
        f->cfpkt_tonative =3D cfpkt_tonative;
#else
	f->cfpkt_fromnative =3D NULL;
        f->cfpkt_tonative =3D NULL;
#endif

I am not sure I understood the meaning of using this structure, because
at the moment the setup is fixed and I cannot find any point in code
where the structure is assigned to another set of functions. Probably
you arrange to have multiple choices in future, I can suppose.

What about to pass directly the pointer to the structure instead of
copying returning its value ? It seems not necessary to me, I changed
cfpkt_get_packet_funcs in this direction.

Meanwhile, it seems some bytes are sent now to the physical interface.

<caif_chropen:797, TRACE> [caif_chropen:797] WAIT FOR CONNECT RESPONSE
<caif_chropen:820, TRACE> caif_open: connect timed out

However, I get no connection, but probably this is another problem....

Best Regards,
Stefano Babic

--=20
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
=46ingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE

