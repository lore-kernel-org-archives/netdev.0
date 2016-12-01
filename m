From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH] netfilter: avoid warn and OOM on vmalloc call
Date: Thu, 1 Dec 2016 17:08:18 -0200
Message-ID: <20161201190818.GA6650@localhost.localdomain>
References: <20161130192145.GB13169@localhost.localdomain>
 <6fd343e83c26c5108d4b6c189e434a5a6e7ebd01.1480534469.git.marcelo.leitner@gmail.com>
 <CAAeHK+wjP=h_4YxB6VUc+FjKcZi9igmyTs3nPAuUJeNomYSA0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Neil Horman <nhorman@tuxdriver.com>,
        netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAAeHK+wjP=h_4YxB6VUc+FjKcZi9igmyTs3nPAuUJeNomYSA0w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 01, 2016 at 10:42:22AM +0100, Andrey Konovalov wrote:
> On Wed, Nov 30, 2016 at 8:42 PM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> > Hi Andrey,
> >
> > Please let me know how this works for you. It seems good here, though
> > your poc may still trigger OOM through other means.
> 
> Hi Marcelo,
> 
> Don't see any reports with this patch.
> 
> Thanks!

Thanks Andrey.
I'll post a v2 after a few more tests here and to s/OOM/OOM killer/ in
most of the changelog.

> 
> >
> > Thanks,
> > Marcelo
> >
> > ---8<---
> >
> > Andrey Konovalov reported that this vmalloc call is based on an
> > userspace request and that it's spewing traces, which may flood the logs
> > and cause DoS if abused.
> >
> > Florian Westphal also mentioned that this call should not trigger OOM,
> > as kmalloc one is already not triggering it.
> >
> > This patch brings the vmalloc call in sync to kmalloc and disables the
> > warn trace on allocation failure and also disable OOM invocation.
> >
> > Note, however, that under such stress situation, other places may
> > trigger OOM invocation.
> >
> > Reported-by: Andrey Konovalov <andreyknvl@google.com>
> > Cc: Florian Westphal <fw@strlen.de>
> > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > ---
> >  net/netfilter/x_tables.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> > index fc4977456c30e098197b4f987b758072c9cf60d9..dece525bf83a0098dad607fce665cd0bde228362 100644
> > --- a/net/netfilter/x_tables.c
> > +++ b/net/netfilter/x_tables.c
> > @@ -958,7 +958,9 @@ struct xt_table_info *xt_alloc_table_info(unsigned int size)
> >         if (sz <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> >                 info = kmalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
> >         if (!info) {
> > -               info = vmalloc(sz);
> > +               info = __vmalloc(sz, GFP_KERNEL | __GFP_NOWARN |
> > +                                    __GFP_NORETRY | __GFP_HIGHMEM,
> > +                                PAGE_KERNEL);
> >                 if (!info)
> >                         return NULL;
> >         }
> > --
> > 2.9.3
> >
> 
