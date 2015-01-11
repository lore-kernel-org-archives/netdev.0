From: "Carlos R. Mafra" <crmafra@gmail.com>
Subject: Re: /proc/net/dev regression
Date: Sun, 11 Jan 2015 01:33:35 +0000
Message-ID: <20150111013335.GA5753@linux-g29b.site>
References: <20150110232518.GA3212@linux-g29b.site>
 <20150111002706.GC22149@ZenIV.linux.org.uk>
 <20150111010036.GD22149@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150111010036.GD22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 11 Jan 2015 at  1:00:36 +0000, Al Viro wrote:
> On Sun, Jan 11, 2015 at 12:27:06AM +0000, Al Viro wrote:
> > On Sat, Jan 10, 2015 at 11:25:18PM +0000, Carlos R. Mafra wrote:
> > > [mafra@linux-g29b:wmnet]$ cat net_dev_bad.txt
> > > Inter-|   Receive                                                |  Transmit
> > >  face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
> > >     lo:     600       8    0    0    0     0          0         0      600       8    0    0    0     0       0          0
> > > wlp3s0b1: 9266848    7298    0    0    0     0          0         0   372229    4030    0    0    0     0       0          0
> > > 
> > > And for some reason this change confuses 'wmnet'. Reading the source code
> > > of 'wmnet' I found that it reads the packets as follows,
> > > 
> > > 	totalpackets_in = strtoul(&buffer[15], NULL, 10);
> > > 
> > > I am not sure if 'wmnet' could do this better (any suggestions?),
> > 
> > *snort*
> > 
> > well, yes - it's called scanf().  And if one is really, really nervous
> > about the overhead of <gasp> parsing a bunch of integers (as if fopen/
> > fgets/fclose alone won't cost enough to make constantly calling that
> > sucker a bad idea), just use ptr + <something> - 6 instead of
> > &buffer[<something>] in there.  That thing has just found where the
> > colon was (and replaced it with NUL), so dealing with "the first field
> > turned out to be too long and shifted everything past it" isn't hard.
> > 
> > > but the fact is that it was working before and now it is not.
> > 
> > True.  Mind you, the real issue is that this code expects the interface
> > names to be never longer than 6 characters, but then /proc/net/dev layout
> > strongly suggests that.  Hell knows; it is a regression and it does
> > break real-world userland code.  The only way to avoid that, AFAICS, is
> > to prohibit interface names longer than 6 chars ;-/
> > 
> > Lovely combination of crappy ABI (procfs file layout), crappy userland
> > code relying on details of said ABI out of sheer laziness and triggering
> > kernel change producing bloody long interface names...
> > 
> > Incidentally, sufficiently long interface name will produce other fun issues
> > for a docked app - it simply won't fit into 64x64 square on screen ;-)
> 
> Mind you, assuming that columns will align is obviously broken - the producing
> side of that thing is
>         seq_printf(seq, "%6s: %7llu %7llu %4llu %4llu %4llu %5llu %10llu %9llu "
>                    "%8llu %7llu %4llu %4llu %4llu %5llu %7llu %10llu\n",
>                    dev->name, stats->rx_bytes, stats->rx_packets,
>                    stats->rx_errors,
>                    stats->rx_dropped + stats->rx_missed_errors,
>                    stats->rx_fifo_errors,
>                    stats->rx_length_errors + stats->rx_over_errors +
>                     stats->rx_crc_errors + stats->rx_frame_errors,
>                    stats->rx_compressed, stats->multicast,
>                    stats->tx_bytes, stats->tx_packets,
>                    stats->tx_errors, stats->tx_dropped,
>                    stats->tx_fifo_errors, stats->collisions,
>                    stats->tx_carrier_errors +
>                     stats->tx_aborted_errors +
>                     stats->tx_window_errors +
>                     stats->tx_heartbeat_errors,
>                    stats->tx_compressed);
> To start with, expecting the ->rx_bytes to remain a 7-digit number is somewhat,
> er, odd.  Long interace names be damned, the columns will not stay aligned,
> no matter what.  Unless your interface vanishes as soon as it has sent
> or received 10 megabytes, that is...

I think the problem with wmnet is not that it was expecting the fields
to be aligned because it never had problems before (when definitely more
than 10 megabytes were received, wmnet is crappy but not _that_ crappy).

I think the problem really was here,

	totalbytes_in = strtoul(&buffer[7], NULL, 10);

After the patch the device name is 8 characters long and &buffer[7]
overlaps with the name instead of reading the bytes. Before the
patch is was fine because the call to strtoul() seems correct in the
sense that it would read everything until the NULL. So more than 10
megabytes was still ok.

So I guess I was wrong when suggesting that the problem was the
alignment.
