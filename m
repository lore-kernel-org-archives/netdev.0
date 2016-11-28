From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net/sctp: vmalloc allocation failure in
 sctp_setsockopt/xt_alloc_table_info
Date: Mon, 28 Nov 2016 12:46:47 -0500
Message-ID: <20161128174647.GC29839@hmsreliant.think-freely.org>
References: <CAAeHK+wecw6ST_DWJQBLFNwVsOVgderGE-EEJiN0-kf796XHtw@mail.gmail.com>
 <20161128141340.GA29839@hmsreliant.think-freely.org>
 <CAAeHK+xJmwF6hddS-sO-y3HQkRicwQN=ZceFWTZT2M_0h4E2hQ@mail.gmail.com>
 <20161128143931.GB29839@hmsreliant.think-freely.org>
 <20161128151312.GA13172@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        linux-sctp@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161128151312.GA13172@localhost.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 01:13:12PM -0200, Marcelo Ricardo Leitner wrote:
> On Mon, Nov 28, 2016 at 09:39:31AM -0500, Neil Horman wrote:
> > On Mon, Nov 28, 2016 at 03:33:40PM +0100, Andrey Konovalov wrote:
> > > On Mon, Nov 28, 2016 at 3:13 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> > > > On Mon, Nov 28, 2016 at 02:00:19PM +0100, Andrey Konovalov wrote:
> > > >> Hi!
> > > >>
> > > >> I've got the following error report while running the syzkaller fuzzer.
> > > >>
> > > >> On commit d8e435f3ab6fea2ea324dce72b51dd7761747523 (Nov 26).
> > > >>
> > > >> A reproducer is attached.
> > > >>
> > > >> a.out: vmalloc: allocation failure, allocated 823562240 of 1427091456
> > > >> bytes, mode:0x24000c2(GFP_KERNEL|__GFP_HIGHMEM)
> > > >>
> > > > How much total ram do you have in this system?  The call appears to be
> > > > attempting to allocate 1.3 Gb of data.  Even using vmalloc to allow
> > > > discontiguous allocation, thats alot of memory, and if enough is in use already,
> > > > I could make the argument that this might be expected behavior.
> > > 
> > > Hi Neail,
> > > 
> > > I have 2 Gb.
> > > 
> > That would be why.  Allocating 65% of the available system memory will almost
> > certainly lead to OOM failures quickly.
> > 
> > > Just tested with 4 Gb, everything seems to be working fine.
> > > So I guess this is not actually a bug and allocating 1.3 Gb is OK.
> 
> Still we probably should avoid the warn triggered by an userspace
> application: (untested)
> 
I'm not sure I agree with that.  Generally speaking it seems like the right
thing to do, if you want to avoid filling logs with warnings, but this is the
sort of error that is going to be accompanied by severe service interruption.
I'd rather see a reason behind that in the logs, than just have it occur
silently.

Neil

> --8<--
> 
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index fc4977456c30..b56a0e128fc3 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -958,7 +958,8 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
>  	if (sz <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
>  		info = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
>  	if (!info) {
> -		info = vmalloc(sz);
> +		info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_HIGHMEM,
> +				 PAGE_KERNEL);
>  		if (!info)
>  			return NULL;
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
