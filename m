From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: /proc/net/dev regression
Date: Sun, 11 Jan 2015 01:39:13 +0000
Message-ID: <20150111013913.GE22149@ZenIV.linux.org.uk>
References: <20150110232518.GA3212@linux-g29b.site>
 <20150111002706.GC22149@ZenIV.linux.org.uk>
 <20150111010036.GD22149@ZenIV.linux.org.uk>
 <20150111013335.GA5753@linux-g29b.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: "Carlos R. Mafra" <crmafra@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38247 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbbAKBjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 20:39:15 -0500
Content-Disposition: inline
In-Reply-To: <20150111013335.GA5753@linux-g29b.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2015 at 01:33:35AM +0000, Carlos R. Mafra wrote:

> I think the problem with wmnet is not that it was expecting the fields
> to be aligned because it never had problems before (when definitely more
> than 10 megabytes were received, wmnet is crappy but not _that_ crappy).
> 
> I think the problem really was here,
> 
> 	totalbytes_in = strtoul(&buffer[7], NULL, 10);
> 
> After the patch the device name is 8 characters long and &buffer[7]
> overlaps with the name instead of reading the bytes. Before the
> patch is was fine because the call to strtoul() seems correct in the
> sense that it would read everything until the NULL. So more than 10
> megabytes was still ok.
> 
> So I guess I was wrong when suggesting that the problem was the
> alignment.

Several lines below there's this:
                        totalpackets_out = strtoul(&buffer[74], NULL, 10);
                        if (totalpackets_out != lastpackets_out) {
                                totalbytes_out = strtoul(&buffer[66], NULL, 10);
                                diffpackets_out += totalpackets_out - lastpackets_out;
                                diffbytes_out += totalbytes_out - lastbytes_out;
                                lastpackets_out = totalpackets_out;
                                lastbytes_out = totalbytes_out;
                                tx = True;
                        }

So I'm afraid it *is* that crappy.  This function really should use scanf();
note that updateStats_ipchains() in the same file does just that (well,
fgets()+sscanf() for fsck knows what reason).  And I'd be careful with all
those %d, actually - it's not _that_ hard to get more than 4Gb sent.
scanf formats really ought to match the kernel-side (seq_)printf one...
