From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 1/5] dp83640: Include hash in timestamp/packet
 matching
Date: Fri, 30 Oct 2015 21:32:01 +0100
Message-ID: <20151030203201.GB27879@netboy>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
 <1446207244-2206-2-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38076 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbbJ3UcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 16:32:06 -0400
Received: by wmeg8 with SMTP id g8so20386692wme.1
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 13:32:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1446207244-2206-2-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 01:14:00PM +0100, Stefan S=F8rensen wrote:
> Only using the message type and sequence id for matching timestamps w=
ith
> packets is error prone, particularly if packets can be reordered. Fix=
 by
> extending the check to include the hash of bytes 20-29 (source id in =
PTPv2)
> that is provided with the timestamps.

The example of reordered packets is bogus, since the sequence numbers
are not affected.  The one case that benefits from the hash check is
when the port is in the master role and multiple clients send
Delay_Req messages all with the same sequence number by chance.
=20
> @@ -819,11 +820,18 @@ static int match(struct sk_buff *skb, unsigned =
int type, struct rxts *rxts)
>  		msgtype =3D data + offset + OFF_PTP_CONTROL;
>  	else
>  		msgtype =3D data + offset;
> +	if (rxts->msgtype !=3D (*msgtype & 0xf))
> +		return 0;
> =20
>  	seqid =3D (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
> +	if (rxts->seqid !=3D ntohs(*seqid))
> +		return 0;
> +
> +	hash =3D ether_crc(10, data + offset + 20) >> 20;

This could use a macro instead of magic 20.

Thanks,
Richard

> +	if (rxts->hash !=3D hash)
> +		return 0;
> =20
> -	return rxts->msgtype =3D=3D (*msgtype & 0xf) &&
> -		rxts->seqid   =3D=3D ntohs(*seqid);
> +	return 1;
>  }
> =20
>  static void decode_rxts(struct dp83640_private *dp83640,
> --=20
> 2.5.0
>=20
