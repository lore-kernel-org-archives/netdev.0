From: Norbert Eicker <n.eicker@fz-juelich.de>
Subject: Re: [PATCH] spidernet: Fix problem sending IP fragments
Date: Mon, 12 Mar 2007 12:21:14 +0100
Message-ID: <200703121221.14859.n.eicker@fz-juelich.de>
References: <20070308231556.GE30703@austin.ibm.com>
	<200703121045.49211.n.eicker@fz-juelich.de>
	<Pine.LNX.4.62.0703121130100.15998@pademelon.sonytel.be>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux/PPC Development <linuxppc-dev@ozlabs.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Geoff Levand <geoffrey.levand@am.sony.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zam837.fz-juelich.de ([134.94.100.69]:41337 "HELO
	zam837.fz-juelich.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S965689AbXCLLVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 07:21:17 -0400
In-Reply-To: <Pine.LNX.4.62.0703121130100.15998@pademelon.sonytel.be>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, 12. March 2007 11:44, Geert Uytterhoeven wrote:
> On Mon, 12 Mar 2007, Norbert Eicker wrote:
> > On Monday, 12. March 2007 09:28, Geert Uytterhoeven wrote:
> > > On Sat, 10 Mar 2007, Norbert Eicker wrote:
> > > > On Friday, 9. March 2007 17:53, Jeff Garzik wrote:
> > > > > Linas Vepstas wrote:
> > > > > > Please apply. The rather long patch description is from the
> > > > > > submitter, Norbert Eicker, I don't know if that's alright,
> > > > > > or if I should ask to have it trimmed.
> > > > > >
> > > > > > Thanks,
> > > > > > --linas
> > > > > >
> > > > > > From: Norbert Eicker <n.eicker@fz-juelich.de>
> > > > > >
> > > > > >
> > > > > > Signed-off-by: Norbert Eicker <n.eicker@fz-juelich.de>
> > > > > > Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> > > > >
> > > > > are you sure it can't send out fragmented IP frames?  what's
> > > > > really going on here?
> > > >
> > > > Pretty sure that fragmented IP frames are not send out. Here's
> > > > a small test using ttcp and tcpdump reproducing the problem (I
> > > > assume a MTU of 1500):
> > >
> > > Hence if I understand that correctly, NFS over UDP doesn't work
> > > at all as NFS uses 8 KiB UDP packets by default?
> >
> > NFS seems to work but considering what I saw in tcpdump it uses TCP
> > instead of UDP. I have not yet found out why NFS seems to default
> > to TCP on Cell (the man-pages claims that UDP is the default).
>
> Hmm, I just checked and for me it defaults to UDP.
>
> > If I explicitely demand to use UDP it indeed does not work at all.
>
> And NFS over UDP works fine on my PS3 with the gelic Ethernet driver.
> Ethereal (on the server side) did show fragmented packets.

Well, the gelic is a different driver, so for me it's no surprise it 
shows different behavior.

In fact from a quick inspection I would guess that it has not the bug 
that's inside the spidernet driver: The section I patched in 
spider_net.c shows up similarly around line 839 in gelic_net.c. But an 
important difference is in the lines before: It only appears in the 
else-branch of an 'if'. This one tests if ip_summed is set to 
CHECKSUM_PARTIAL.

I.e. gelic_net.c has the test that is missing in spider_net.c.

> However, I remember having NFS problems when using a different NFS
> server before.  I just retried using that server, and got these error
> messages from
>
> the gelic driver:
> | error in received descriptor found, data_status=x70002300,
> | data_error=x06100000 ERROR DESTROY:6100000
> | error in received descriptor found, data_status=x70002900,
> | data_error=x06100000 ERROR DESTROY:6100000
>
> Ethereal (on the server side) did show fragmented packets with
> retransmissions.
>
> So sometimes it works, sometimes it doesn't?
>
> The differences between the 2 NFS servers are:
>   - working one runs 2.6.11, non-working one runs 2.4.17
>   - working one is on the same subnet as the PS3, non-working one
> isn't. - both work fine with e.g. my laptop as an NFS client
>   - both have nfs-kernel-server 1:1.0.6-3.1
>   - both have 3c905 Tornado Ethernet
>
> For completeness, sometimes (1-2 times a week) I do see a similar
> gelic error message when using the working NFS server, but it
> recovers fine and never is a problem.

IMHO the problem I reported is not an NFS problem at all (there might be 
more problems in this arena;-)). As I have pointed out you can see the 
problem even with ttcp (or some other tool sending UDP frames larger 
than MTU - some_header_length).

Norbert
-- 
Fon ++49-(0)2461/61-1492
http://www.fz-juelich.de

