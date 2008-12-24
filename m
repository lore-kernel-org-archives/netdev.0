From: Michel Lespinasse <walken@zoy.org>
Subject: Re: [Bugme-new] [Bug 12282] New: Network data corruption on eee 1000
Date: Wed, 24 Dec 2008 04:17:57 -0800
Message-ID: <20081224121756.GB13948@zoy.org>
References: <bug-12282-10286@http.bugzilla.kernel.org/> <20081223232035.5a5caea9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"J. K. Cliburn" <jcliburn@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:37274 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbYLXMn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 07:43:56 -0500
Content-Disposition: inline
In-Reply-To: <20081223232035.5a5caea9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At this point I wonder if this could be an issue with marginal memory
timings, but which somehow only gets triggered when transfering with the
network adapter, and never when being accessed by the CPU. But is that
even possible ???

Here are few additional data points I collected:

In order to see what the raw data looks like before scp complains about the
corrupted MAC, I decided to drop scp and use nfs + cp + md5sum:

cp /mnt/shared/net_test/data1GB /tmp; md5sum /tmp/data1GB
(/mnt/shared is an nfs3 over tcp mount, and /tmp is a tmpfs).

After a few tries I usually get the wrong md5sum in /tmp/data1GB,
I then copy the file back to the server, check that it arrived there
with the same corrupted md5sum as it had on the eee client side,
and use "cmp -l" to figure out what's different between the original
and the corrupted file.

Turns out that in all cases I've observed, the corrupted file had a
128-byte region with unexpected (garbage) contents. Not just single bits
being flipped, but the whole region being entirely different. The regions
were not necessarily aligned on a 128 byte boundary relative to the start
of the file, though.

At this point I wondered "bad memory?" and I swapped back the original 1GB
stick that came with the EEE 1000, instead of the 2GB upgrade I had installed
on the first day. Turns out that only made things worse ! with that stick,
I still see some 128-byte regions getting corrupted, and I additionally
see a few bytes here and there (always at an offset multiple of 4 relative
to the start of the file) having bit 0x02 set when they should not.
If I run md5sum on the /tmp file multiple times I will always get the
same hash, but it did take me 3 trials (with a 500MB file, my /tmp is
smaller now that I have only 1GB of memeory) before I did end up with a
copy on the server that had the same hash as the corrupted /tmp file.
The two other copies had a few more 0x02 bits mistakenly set here and there.

Both memory sticks do check out fine with "memtester" (I have not tried
memtest86 yet), and that I don't observe any trouble when not using the LAN.

Could this be a timing issue that would only show up when transfering
between memory and the network adapter ? And if so, what can we even do
about it ? I'm using bios version 0803 which is the most recent available
for the EEE 1000.

I won't be able to do much testing in the following week as I'll be away
from my LAN :) , I should be able to get wireless and read my email though.

On Tue, Dec 23, 2008 at 11:20:35PM -0800, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Tue, 23 Dec 2008 21:24:45 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=12282
> > 
> >            Summary: Network data corruption on eee 1000
> >            Product: Drivers
> >            Version: 2.5
> >      KernelVersion: 2.6.28-rc8
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: jgarzik@pobox.com
> >         ReportedBy: walken@zoy.org
> > 
> > 
> > Latest working kernel version: unknown
> > Earliest failing kernel version: 2.6.28-rc8
> > Distribution: debian lenny
> > Hardware Environment: eee 1000, no hardware changes except for a 2GB memory
> > upgrade.
> > Software Environment:
> > Problem Description: Intermittent data corruption over wired network
> > 
> > 
> > Running debian lenny on my eee 1000, I've seen occasional scp failures where
> > scp would complain about a corrupted MAC when copying files around on my local
> > network. Also when compiling things over NFS I occasionally got my source files
> > to appear corrupted on the client (while they were still fine on the server)
> > and when I tried running things in an nfsroot environment (I know this sounds
> > silly for a laptop, but I see it as a good way to try new software without
> > having to install it on disk), I got occasional segfaults in various processes.
> > Since I've not seen such failures when running with a disk based root, I blame
> > them all on the networking subsystem.
> > 
> > 
> > I've been running the following command as a way to try and reproduce the
> > problem:
> > 
> > for x in 0 1 2 3 4 5 6 7 8 9; do for y in 0 1 2 3 4 5 6 7 8 9; do for z in 0 1
> > 2 3 4 5 6 7 8 9; do echo $x$y$z; scp server:shared/net_test/data1GB /tmp ||
> > sleep 36000; date; done; done; done
> > 000
> > data1GB                                       100% 1005MB   5.2MB/s   03:15    
> > Tue Dec 23 20:17:36 PST 2008
> > 001
> > data1GB                                       100% 1005MB   5.2MB/s   03:12    
> > Tue Dec 23 20:20:49 PST 2008
> > 002
> > data1GB                                       100% 1005MB   5.2MB/s   03:13    
> > Tue Dec 23 20:24:03 PST 2008
> > 003
> > data1GB                                       100% 1005MB   6.4MB/s   02:38    
> > Tue Dec 23 20:26:42 PST 2008
> > 004
> > data1GB                                        98%  994MB   5.4MB/s   00:02
> > ETADisconnecting: Corrupted MAC on input.
> > lost connection
> > 
> > The failures don't always happen at the same place, and they might be slightly
> > more likely soon after boot, but I'm not sure about that.
> > 
> > Even after scp detected some data corruption, ifconfig does not report any
> > errors:
> > 
> > eth0      Link encap:Ethernet  HWaddr 00:22:15:85:7c:94  
> >           inet addr:10.3.0.1  Bcast:10.255.255.255  Mask:255.0.0.0
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:3683950 errors:0 dropped:0 overruns:0 frame:0
> >           TX packets:1432256 errors:0 dropped:0 overruns:0 carrier:2
> >           collisions:0 txqueuelen:1000 
> >           RX bytes:1246310892 (1.1 GiB)  TX bytes:101092933 (96.4 MiB)
> >           Interrupt:59 
> > 
> > (Note the RX bytes value is also wrong since I transferred almost 5GB above,
> > I believe this is because the value wraps around after 4GB ? Also,
> > /proc/interrupts reports >3 million interrupts (PCI-MSI-edge) on eth0)
> > 
> > I'm tempted to blame either the hardware or the newish atl1e network driver,
> > but have no hard proof either way at this point.
> > 
> 

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
