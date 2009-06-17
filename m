From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13561] New: swapper: page allocation failure.
 order:0, mode:0x20
Date: Wed, 17 Jun 2009 12:46:20 -0700
Message-ID: <20090617124620.44dd5ef0.akpm@linux-foundation.org>
References: <bug-13561-10286@http.bugzilla.kernel.org/>
	<20090617121610.d4f0ea9d.akpm@linux-foundation.org>
	<4A394415.30004@lbsd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Nigel Kukard <nkukard@lbsd.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48579 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753180AbZFQTqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 15:46:23 -0400
In-Reply-To: <4A394415.30004@lbsd.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Jun 2009 19:29:25 +0000
Nigel Kukard <nkukard@lbsd.net> wrote:

> > yep, that's OK.  The kernel was excessively low on memory and the
> > network driver was unable to allocate a page for a received packet. 
> >   
> 
> Even though the box had 4Gbyte RAM with nothing running but console? 

yep.

> maybe I"m mistaking the amount of RAM for the amount of memory in a
> buffer used for network IO?

[ 1884.639264] Node 0 DMA free:11692kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15284kB pages_scanned:0 all_unreclaimable? yes

[ 1884.639271] Node 0 DMA32 free:5412kB min:6560kB low:8200kB high:9840kB active_anon:60476kB inactive_anon:12224kB active_file:28720kB inactive_file:2987624kB unevictable:0kB present:3333216kB pages_scanned:0 all_unreclaimable? no

[ 1884.639279] Node 0 Normal free:444kB min:1524kB low:1904kB high:2284kB active_anon:12436kB inactive_anon:13984kB active_file:16356kB inactive_file:666568kB unevictable:480kB present:775680kB pages_scanned:0 all_unreclaimable? no

Pretty much all your memory was used by pagecache.  The DMA32 zone is
below the minimum threshold.  The VM has decided that there's no memory
left for networking.  It has retained a little bit of free memory so
the block device drivers can still perform writeout, to free up
additional memory.

What is _supposed_ to happen (and usually does) it that kswapd will see
that the machine is getting short on memory and will work to free some
up, thus making it available to networking receive.  But sometimes
kswapd can't keep up.
