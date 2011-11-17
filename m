From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 11:13:12 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEC9@saturn3.aculab.com>
References: <CABoNC83U2k=-6-BkJEyWBXfSnEbb-+K8CD1ffqhjA613Tk04tQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Stephen Hemminger" <stephen.hemminger@vyatta.com>,
	<netdev@vger.kernel.org>, <romieu@fr.zoreil.com>,
	"nic swsd" <nic_swsd@realtek.com>
To: "Junchang Wang" <junchangwang@gmail.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48105 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753225Ab1KQLPA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 06:15:00 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08712-06 for <netdev@vger.kernel.org>;
 Thu, 17 Nov 2011 11:14:58 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <CABoNC83U2k=-6-BkJEyWBXfSnEbb-+K8CD1ffqhjA613Tk04tQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 64bit stats update sequence used to get valid
counts on 32bit systems (that can't do locked 64bit
memory access) seems to be:

> =A0=A0 =A0u64_stats_update_begin(&sky2->tx_stats.syncp);
> =A0=A0 =A0++sky2->tx_stats.packets;
> =A0=A0 =A0sky2->tx_stats.bytes +=3D skb->len;
> =A0=A0 =A0u64_stats_update_end(&sky2->tx_stats.syncp);

I'm not sure what the begin/end markers do, but
they need to hold off the readers during updates
and the writers during reads - this is probably
expensive on the update path.

A thought that might work is for the writer to
write the middle bits of the 64 bit walue to
another location, eg:
       count =3D sky2->tx_stats.bytes + skb->len;
       sky2->tx_stats.bytes =3D count;
       sky2->tx_stats.bytes_check =3D count >> 16;
The reader then loops until the two value are
consistent.

I think this doesn't even require a memory barrier
in the ISR since the order of the reads an writes
doesn't matter at all.

	David
