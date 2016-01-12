From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 2/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Mon, 11 Jan 2016 19:11:48 -0800
Message-ID: <20160112031148.GA13416@kafai-mba.local>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
 <1452206155-1492617-3-git-send-email-kafai@fb.com>
 <CACVXFVNg_3j0T8WCmtVR8XEb9xRd0qJBEZcsW3_OJ+HYZHNvEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACVXFVNg_3j0T8WCmtVR8XEb9xRd0qJBEZcsW3_OJ+HYZHNvEg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 09, 2016 at 06:06:15PM +0800, Ming Lei wrote:
> On Fri, Jan 8, 2016 at 6:35 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> > This patch adds BPFMAP_TYPE_PERCPU_HASH map type and its
> > htab_map_ops implementation.
> >
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > ---
> >  include/uapi/linux/bpf.h |   1 +
> >  kernel/bpf/hashtab.c     | 201 ++++++++++++++++++++++++++++++++++++++++++++++-
> >  2 files changed, 201 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> > index 8bed7f1..e4f8060 100644
> > --- a/include/uapi/linux/bpf.h
> > +++ b/include/uapi/linux/bpf.h
> > @@ -81,6 +81,7 @@ enum bpf_map_type {
> >         BPF_MAP_TYPE_ARRAY,
> >         BPF_MAP_TYPE_PROG_ARRAY,
> >         BPF_MAP_TYPE_PERF_EVENT_ARRAY,
> > +       BPF_MAP_TYPE_PERCPU_HASH,
> >  };
> >
> >  enum bpf_prog_type {
> > diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
> > index d55df8c..63f2945 100644
> > --- a/kernel/bpf/hashtab.c
> > +++ b/kernel/bpf/hashtab.c
> > @@ -278,7 +278,7 @@ find_first_elem:
> >  }
> >
> >  static struct htab_elem_common *htab_elem_common_alloc(struct bpf_htab *htab,
> > -                                                       void *key)
> > +                                                      void *key)
>
> better to not introduce the above change.
What is the concern?

>
> >  {
> >         struct htab_elem_common *l;
> >
> > @@ -451,9 +451,208 @@ static struct bpf_map_type_list htab_type __read_mostly = {
> >         .type = BPF_MAP_TYPE_HASH,
> >  };
> >
> > +/* each htab_percpu_elem is struct htab_percpu_elem + key  */
> > +struct htab_percpu_elem {
> > +       struct htab_elem_common common;
> > +       void * __percpu value;
> > +       char key[0] __aligned(8);
> > +};
> > +
> > +static struct htab_percpu_elem *htab_percpu_elem(struct htab_elem_common *l)
> > +{
> > +       return (struct htab_percpu_elem *)l;
> > +}
> > +
> > +static void htab_percpu_elem_free(struct htab_percpu_elem *l)
> > +{
> > +       free_percpu(l->value);
> > +       kfree(l);
> > +}
> > +
> > +static void htab_percpu_elem_rcu_free(struct rcu_head *head)
> > +{
> > +       struct htab_elem_common *l = container_of(head,
> > +                                                 struct htab_elem_common,
> > +                                                 rcu);
> > +
> > +       htab_percpu_elem_free(htab_percpu_elem(l));
> > +}
> > +
> > +static void htab_percpu_map_flush(struct bpf_htab *htab)
> > +{
> > +       int i;
> > +
> > +       for (i = 0; i < htab->n_buckets; i++) {
> > +               struct hlist_head *head = select_bucket(htab, i);
> > +               struct hlist_node *n;
> > +               struct htab_elem_common *l;
> > +
> > +               hlist_for_each_entry_safe(l, n, head, hash_node) {
> > +                       hlist_del_rcu(&l->hash_node);
> > +                       atomic_dec(&htab->count);
> > +                       htab_percpu_elem_free(htab_percpu_elem(l));
> > +               }
> > +       }
> > +}
>
> The above helper should have been saved by introduce percpu_map
> flag in bpf_htab.
There is no need to introduce a new flag. Is it the same as checking
htab->map.map_type == BPF_MAP_TYPE_PERCPU_HASH?

The current 'struct bpf_map_ops' setup has already made a clean function
dispatch based on different 'enum bpf_map_type'.  I have been refraining
to make another map_type check else where again.

I will make another attempt to further remove duplicate code first and
will post it shortly.

Thanks,
-- Martin
