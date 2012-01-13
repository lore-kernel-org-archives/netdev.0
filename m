From: Dimitri Sivanich <sivanich@sgi.com>
Subject: Re: [PATCH] Fix panic in __d_lookup with high dentry hashtable
 counts
Date: Fri, 13 Jan 2012 10:39:27 -0600
Message-ID: <20120113163927.GB26353@sgi.com>
References: <20120113155237.GA25103@sgi.com>
 <20120113162236.GK23916@ZenIV.linux.org.uk>
 <20120113163642.GB25788@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Kosina <jkosina@suse.cz>, Avi Kivity <avi@redhat.com>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120113163642.GB25788@sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 13, 2012 at 10:36:42AM -0600, Dimitri Sivanich wrote:
> On Fri, Jan 13, 2012 at 04:22:36PM +0000, Al Viro wrote:
> > On Fri, Jan 13, 2012 at 09:52:37AM -0600, Dimitri Sivanich wrote:
> > > When the number of dentry cache hash table entries gets too high
> > > (2147483648 entries), use of a signed integer in the initialization
> > > loop prevents the dentry_hashtable from getting initialized, resulting
> > > in a panic in __d_lookup.  Fixing this in dcache_init and a few other
> > > spots for consistency.
> > 
> > >  static void __init dcache_init(void)
> > >  {
> > > -	int loop;
> > > +	long loop;
> > 
> > You've got to be kidding.  Note that D_HASHMASK is at most 32bit.  Use
> > of long here is an overkill and so's 2^31 hash buckets (that's what,
> > 16Gb in hash list heads alone?  What kind of average chain length do
> > you expect, BTW?)
> 
> Yes, long might be overkill right now, but the code is all __init time code.
> I don't have numbers showing average chain length at this point, I was
> simply fixing this one end case
> 
> > 
> > Can alloc_large_system_hash() produce the horrors that large, anyway?
> 
> On a 16TB system, alloc_large_system_hash() produces 2^31 hash buckets, yes.
> 
> Would simply capping the value in alloc_large_system_hash() be more palatable?
> 
> Something like the following?
> 
> Index: linux/mm/page_alloc.c
> ===================================================================
> --- linux.orig/mm/page_alloc.c
> +++ linux/mm/page_alloc.c
> @@ -5257,6 +5257,7 @@ void *__init alloc_large_system_hash(con
>         if (max == 0) {
>                 max = ((unsigned long long)nr_all_pages << PAGE_SHIFT) >> 4;
>                 do_div(max, bucketsize);
> +               max = min(max, 1ULL << 30);
>         }
>  
>         if (numentries > max)

Sorry, you'd probably want something more like this:

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -5258,6 +5258,7 @@ void *__init alloc_large_system_hash(con
                max = ((unsigned long long)nr_all_pages << PAGE_SHIFT) >> 4;
                do_div(max, bucketsize);
        }
+       max = min(max, 1ULL << 30);
 
        if (numentries > max)
                numentries = max;

