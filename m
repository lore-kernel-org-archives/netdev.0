From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: /proc/net/dev regression
Date: Mon, 12 Jan 2015 11:47:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC5823@AcuExch.aculab.com>
References: <20150110232518.GA3212@linux-g29b.site>
 <20150111002706.GC22149@ZenIV.linux.org.uk>
 <20150111010036.GD22149@ZenIV.linux.org.uk>
 <20150111013335.GA5753@linux-g29b.site>
 <20150111013913.GE22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: LKML <linux-kernel@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Al Viro' <viro@ZenIV.linux.org.uk>,
	"Carlos R. Mafra" <crmafra@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:57804 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753121AbbALLsf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 06:48:35 -0500
In-Reply-To: <20150111013913.GE22149@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro
> > I think the problem with wmnet is not that it was expecting the fields
> > to be aligned because it never had problems before (when definitely more
> > than 10 megabytes were received, wmnet is crappy but not _that_ crappy).
> >
> > I think the problem really was here,
> >
> > 	totalbytes_in = strtoul(&buffer[7], NULL, 10);
> >
> > After the patch the device name is 8 characters long and &buffer[7]
> > overlaps with the name instead of reading the bytes. Before the
> > patch is was fine because the call to strtoul() seems correct in the
> > sense that it would read everything until the NULL. So more than 10
> > megabytes was still ok.
> >
> > So I guess I was wrong when suggesting that the problem was the
> > alignment.
> 
> Several lines below there's this:
>                         totalpackets_out = strtoul(&buffer[74], NULL, 10);
>                         if (totalpackets_out != lastpackets_out) {
>                                 totalbytes_out = strtoul(&buffer[66], NULL, 10);
>                                 diffpackets_out += totalpackets_out - lastpackets_out;
>                                 diffbytes_out += totalbytes_out - lastbytes_out;
>                                 lastpackets_out = totalpackets_out;
>                                 lastbytes_out = totalbytes_out;
>                                 tx = True;
>                         }
> 
> So I'm afraid it *is* that crappy.  This function really should use scanf();
> note that updateStats_ipchains() in the same file does just that (well,
> fgets()+sscanf() for fsck knows what reason).  And I'd be careful with all
> those %d, actually - it's not _that_ hard to get more than 4Gb sent.
> scanf formats really ought to match the kernel-side (seq_)printf one...

IMHO it is safer to use strchr(p, ' '); to skip the interface name and then
use repeated calls to strtoull() to read the numbers.
Correctly/safely using scanf() is really too hard.

	David
