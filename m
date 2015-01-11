From: "Carlos R. Mafra" <crmafra@gmail.com>
Subject: Re: /proc/net/dev regression
Date: Sun, 11 Jan 2015 00:58:31 +0000
Message-ID: <20150111005831.GA3739@linux-g29b.site>
References: <20150110232518.GA3212@linux-g29b.site>
 <20150111002706.GC22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150111002706.GC22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 11 Jan 2015 at  0:27:06 +0000, Al Viro wrote:
> On Sat, Jan 10, 2015 at 11:25:18PM +0000, Carlos R. Mafra wrote:
> > [mafra@linux-g29b:wmnet]$ cat net_dev_bad.txt
> > Inter-|   Receive                                                |  Transmit
> >  face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
> >     lo:     600       8    0    0    0     0          0         0      600       8    0    0    0     0       0          0
> > wlp3s0b1: 9266848    7298    0    0    0     0          0         0   372229    4030    0    0    0     0       0          0
> > 
> > And for some reason this change confuses 'wmnet'. Reading the source code
> > of 'wmnet' I found that it reads the packets as follows,
> > 
> > 	totalpackets_in = strtoul(&buffer[15], NULL, 10);
> > 
> > I am not sure if 'wmnet' could do this better (any suggestions?),
> 
> *snort*
> 
> well, yes - it's called scanf().  And if one is really, really nervous
> about the overhead of <gasp> parsing a bunch of integers (as if fopen/
> fgets/fclose alone won't cost enough to make constantly calling that
> sucker a bad idea), just use ptr + <something> - 6 instead of
> &buffer[<something>] in there.  That thing has just found where the
> colon was (and replaced it with NUL), so dealing with "the first field
> turned out to be too long and shifted everything past it" isn't hard.

Alright! Thank you.

> > but the fact is that it was working before and now it is not.
> 
> True.  Mind you, the real issue is that this code expects the interface
> names to be never longer than 6 characters, but then /proc/net/dev layout
> strongly suggests that.  Hell knows; it is a regression and it does
> break real-world userland code.  The only way to avoid that, AFAICS, is
> to prohibit interface names longer than 6 chars ;-/
> 
> Lovely combination of crappy ABI (procfs file layout), crappy userland
> code relying on details of said ABI out of sheer laziness and triggering
> kernel change producing bloody long interface names...

I won't mind just changing the crappy and fragile wmnet code and moving on.
I have already lost the 2 hours bisecting this anyway.

Thank you very much for your advice.
