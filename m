From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [BUGS] [CHECKER] 99 synchronization bugs and a lock summary
 database
Date: Fri, 2 Jul 2004 12:50:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040702125008.25e65252@dell_ss3.pdx.osdl.net>
References: <20040702004956.448c95d9.akpm@osdl.org>
	<E1BgLql-00055X-00@gondolin.me.apana.org.au>
	<20040702123022.563ee931.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040702123022.563ee931.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2 Jul 2004 12:30:22 -0700
Andrew Morton <akpm@osdl.org> wrote:

> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> >
> > Andrew Morton <akpm@osdl.org> wrote:
> > > 
> > > Could someone please take a look at the locking in
> > > net/ipv4/ipmr.c:ipmr_mfc_seq_next?  It seems rather broken.
> > 
> > Obfuscated yes, broken no.
> 
> Really?  Even if that goto
> 
> 	if (it->cache == &mfc_unres_queue) 
> 		goto end_of_list;
> 
> is taken?

The problem is that the seq_file interface is trying to create an iterator
over  a set of data.  The interface expects that the usage will always fit
a given pattern.

The implied semantic is:
	if returned handle is NULL, then nothing is locked and it->cache = NULL

	if returned handle is in the mfc_cache_table then
		it->cache points to mfc_cache_array and mrt_lock is held
	if returned handle is in the mfc_unres_queue then
		it->cache points to mfc_unres_queue and mfc_unres_lock is held

the seq_next is only valid to mean give me the next entry after the passed handle
therefore if there are no more entries after the handle and the handle was on
the unresolved queue, then the end is reached. 

When seq_stop is called, the it->cache pointer will be NULL so no unlock is done.
