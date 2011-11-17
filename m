From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 14:01:19 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AECB@saturn3.aculab.com>
References: <1321534700.2751.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Junchang Wang" <junchangwang@gmail.com>,
	"Stephen Hemminger" <stephen.hemminger@vyatta.com>,
	<netdev@vger.kernel.org>, <romieu@fr.zoreil.com>,
	"nic swsd" <nic_swsd@realtek.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51051 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756345Ab1KQODI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 09:03:08 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13204-03 for <netdev@vger.kernel.org>;
 Thu, 17 Nov 2011 14:03:05 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1321534700.2751.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> Le jeudi 17 novembre 2011 =E0 11:13 +0000, David Laight a =E9crit :
> > The 64bit stats update sequence used to get valid
> > counts on 32bit systems (that can't do locked 64bit
> > memory access) seems to be:
> >=20
> > >     u64_stats_update_begin(&sky2->tx_stats.syncp);
> > >     ++sky2->tx_stats.packets;
> > >     sky2->tx_stats.bytes +=3D skb->len;
> > >     u64_stats_update_end(&sky2->tx_stats.syncp);
> >=20
> > I'm not sure what the begin/end markers do, but
> > they need to hold off the readers during updates
> > and the writers during reads - this is probably
> > expensive on the update path.
> >=20
> > A thought that might work is for the writer to
> > write the middle bits of the 64 bit walue to
> > another location, eg:
> >        count =3D sky2->tx_stats.bytes + skb->len;
> >        sky2->tx_stats.bytes =3D count;
> >        sky2->tx_stats.bytes_check =3D count >> 16;
> > The reader then loops until the two value are
> > consistent.
> >=20
> > I think this doesn't even require a memory barrier
> > in the ISR since the order of the reads an writes
> > doesn't matter at all.
> >=20
> > 	David
> >=20
> >=20
>=20
> Oh well...
>=20
> Before claiming all this, you really should read=20
> include/linux/u64_stats_sync.h
>=20
> This should answer all your questions.

Ah yes ...

Both u64_stats_update_begin & _end increment a numeric field
with an appropriate memory barrier. So the 'update' path
has two extra read-modify-write sequences (possibly the
2nd read can be optimised out), and two smp_wmb() that may
introduce bus delays.

Would be fine if it were guaranteed to work!
Consider the following sequence of events:
       u64_stats_update_begin()
       calculate 'count+1'
                                read_seqcount_begin()
                                read count_hi
       write count_lo
                                read count_lo
       write count_hi
                                read_seqcount_retry()
       ... update other counters ...
       u64_stats_update_end()
The reader gets an invalid value since it reads the same
'sequence' both times.

Could be fixed by using '|=3D 1' in update_begin and
looping on odd values in read_seqcount_begin().

	David

                     =20
