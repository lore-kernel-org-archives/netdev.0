From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] e1000 TSO parameter
Date: Mon, 14 Jul 2003 22:38:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030714223822.23b78f9b.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229169@orsmsx402.jf.intel.com>
	<20030714214510.17e02a9f.davem@redhat.com>
	<16147.37268.946613.965075@napali.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davidm@napali.hpl.hp.com, scott.feldman@intel.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidm@hpl.hp.com
In-Reply-To: <16147.37268.946613.965075@napali.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Jul 2003 22:31:00 -0700
David Mosberger <davidm@napali.hpl.hp.com> wrote:

> With TSO enabled:
> 
>  ftp> get big.iso /dev/null
>  local: /dev/null remote: big.iso
>  200 PORT command successful.
>  150 Opening BINARY mode data connection for 'big.iso' (2038628352 bytes).
>  226 Transfer complete.
>  2038628352 bytes received in 21.16 secs (94070.2 kB/s)
> 
>  ftp server CPU utilization: ~ 15%
> 
> So we get almost 15% of throughput drop.  This was with plain "netkit
> fptd".  AFAIK, it does a simple read/write loop (not sendfile()).

When we use TSO for non-sendfile() applications it really
stresses memory allocations.  We do these 64K+ kmalloc()'s
for each packet we construct.

But I don't think that's what is happening here, rather the PCI
controller is "talking" to the CPU's L2 cache with coherency
transactions on all the data of every packet going to the chip.

Whereas with a sendfile() type setup, the PCI controller is going
straight to main memory for the data part of the packets since the
CPU is unlikely to have each page cache page in it's L2 caches.  In
the sendmsg() case, it's virtually guarenteed that the cpu will have
all the packet data in it's L2 cache in an unshared-modified state.

I know how this can be fixed, can you use L2-bypassing stores in
your csum_and_copy_from_user() and copy_from_user() implementations
like we do on sparc64?  That would exactly eliminate this situation
where the card is talking to the cpu's L2 cache for all the data
during the PCI DMA transation on the send side.
