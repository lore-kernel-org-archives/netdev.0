From: Miquel van Smoorenburg <miquels@cistron.nl>
Subject: Re: OOM killer invoked on 2.6.24.4
Date: Mon, 16 Jun 2008 22:46:57 +0200
Message-ID: <1213649217.27392.12.camel@localhost.localdomain>
References: <e1aa27e00806140313o5a62c618kb41b892b7b29e235@mail.gmail.com>
	 <e2e108260806140831s40f36a95s1a412cec4dc47f31@mail.gmail.com>
	 <20080616195538.GA9217@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bart Van Assche <bart.vanassche@gmail.com>,
	Marco Barbero <marco.barbero@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-vbr7.xs4all.nl ([194.109.24.27]:3945 "EHLO
	smtp-vbr7.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbYFPUrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 16:47:19 -0400
In-Reply-To: <20080616195538.GA9217@dmt.cnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-06-16 at 16:55 -0300, Marcelo Tosatti wrote:
> On Sat, Jun 14, 2008 at 05:31:18PM +0200, Bart Van Assche wrote:
> > On Sat, Jun 14, 2008 at 12:13 PM, Marco Barbero <marco.barbero@gmail.com> wrote:
> > > samba/slapd/heartbeat/drbd/mon
> > ...
> > > Jun 14 01:00:17 pippo kernel: Out of memory: kill process 6873 (slapd)
> > > score 5003 or a child
> > > Jun 14 01:00:17 pippo kernel: Killed process 6873 (slapd)
> > >
> > > Anyone can help me in understanding what went wrong? And if I need to
> > > upgrade to last kernel version?
> > 
> > One or more processes on your system used too much memory. Dumping the
> > output of the following command periodically (e.g. every 10 minutes)
> > to a file will tell you which process is using too much memory:
> > 
> > { ps aux | head -n 1; ps aux | sort -n +4 | tail -n 10; }
> 
> There were lots of swap free:
> 
> Jun 14 01:00:17 pippo kernel: Free swap  = 3903752kB
> Jun 14 01:00:17 pippo kernel: Total swap = 3903752kB
> Jun 14 01:00:17 pippo kernel: Free swap:       3903752kB
> 
> Something is wrong.

It was a normal GFP_KERNEL allocation:

Jun 14 01:00:17 pippo kernel: sendmail-mta invoked oom-killer:
gfp_mask=0x800d0, order=0, oomkilladj=0

And the system /is/ low on memory:

Jun 14 01:00:17 pippo kernel: DMA free:3548kB min:68kB low:84kB
high:100kB active:0kB inactive:4kB present:16256kB pages_scanned:25
all_unreclaimable? yes
Jun 14 01:00:17 pippo kernel: lowmem_reserve[]: 0 873 4810 4810
Jun 14 01:00:17 pippo kernel: Normal free:3736kB min:3744kB low:4680kB
high:5616kB active:4616kB inactive:4672kB present:894080kB
pages_scanned:14277 all_unreclaimable? yes
Jun 14 01:00:17 pippo kernel: lowmem_reserve[]: 0 0 31496 31496
Jun 14 01:00:17 pippo kernel: HighMem free:2975684kB min:512kB
low:4736kB high:8960kB active:248580kB inactive:21644kB
present:4031488kB pages_scanned:0 all_unreclaimable? no

Still high memory available, and swap, but ZONE_DMA and ZONE_NORMAL were
all used and "all_unreclaimable? yes" . So __alloc_pages(GFP_KERNEL)
fails.

It might be tcp buffers- see
http://marc.info/?l=linux-netdev&m=121362441431941&w=2

In which case, use this workaround:

echo "98304 131072 196608" > /proc/sys/net/ipv4/tcp_mem

Mike.

