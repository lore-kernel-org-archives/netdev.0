From: Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 05/23] net, ceph: convert ceph_osd.o_ref from atomic_t to refcount_t
Date: Fri, 24 Mar 2017 14:49:24 +0100
Message-ID: <CAOi1vP8ajXGamJ_Et93sfAq4xr46sSuse8cP320j-aqnwrSqKg@mail.gmail.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com> <1489752646-8749-6-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-x25-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Ceph Development <ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Yan, Zheng" <zyan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Sage Weil <sage-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
        steffen.klassert-opNxpl+3fjRBDgjK7y7TUQ@public.gmane.org,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
        santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, jreuter-K7Hl1MveuGQ@public.gmane.org,
        ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489752646-8749-6-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 17, 2017 at 1:10 PM, Elena Reshetova
<elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
>
> Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  include/linux/ceph/osd_client.h |  3 ++-
>  net/ceph/osd_client.c           | 16 ++++++++--------
>  2 files changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/ceph/osd_client.h b/include/linux/ceph/osd_client.h
> index 2ea0c28..5ce0cd6 100644
> --- a/include/linux/ceph/osd_client.h
> +++ b/include/linux/ceph/osd_client.h
> @@ -5,6 +5,7 @@
>  #include <linux/kref.h>
>  #include <linux/mempool.h>
>  #include <linux/rbtree.h>
> +#include <linux/refcount.h>
>
>  #include <linux/ceph/types.h>
>  #include <linux/ceph/osdmap.h>
> @@ -27,7 +28,7 @@ typedef void (*ceph_osdc_callback_t)(struct ceph_osd_request *);
>
>  /* a given osd we're communicating with */
>  struct ceph_osd {
> -       atomic_t o_ref;
> +       refcount_t o_ref;
>         struct ceph_osd_client *o_osdc;
>         int o_osd;
>         int o_incarnation;
> diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
> index b65bbf9..99a51f0 100644
> --- a/net/ceph/osd_client.c
> +++ b/net/ceph/osd_client.c
> @@ -1005,7 +1005,7 @@ static bool osd_registered(struct ceph_osd *osd)
>   */
>  static void osd_init(struct ceph_osd *osd)
>  {
> -       atomic_set(&osd->o_ref, 1);
> +       refcount_set(&osd->o_ref, 1);
>         RB_CLEAR_NODE(&osd->o_node);
>         osd->o_requests = RB_ROOT;
>         osd->o_linger_requests = RB_ROOT;
> @@ -1050,9 +1050,9 @@ static struct ceph_osd *create_osd(struct ceph_osd_client *osdc, int onum)
>
>  static struct ceph_osd *get_osd(struct ceph_osd *osd)
>  {
> -       if (atomic_inc_not_zero(&osd->o_ref)) {
> -               dout("get_osd %p %d -> %d\n", osd, atomic_read(&osd->o_ref)-1,
> -                    atomic_read(&osd->o_ref));
> +       if (refcount_inc_not_zero(&osd->o_ref)) {
> +               dout("get_osd %p %d -> %d\n", osd, refcount_read(&osd->o_ref)-1,
> +                    refcount_read(&osd->o_ref));
>                 return osd;
>         } else {
>                 dout("get_osd %p FAIL\n", osd);
> @@ -1062,9 +1062,9 @@ static struct ceph_osd *get_osd(struct ceph_osd *osd)
>
>  static void put_osd(struct ceph_osd *osd)
>  {
> -       dout("put_osd %p %d -> %d\n", osd, atomic_read(&osd->o_ref),
> -            atomic_read(&osd->o_ref) - 1);
> -       if (atomic_dec_and_test(&osd->o_ref)) {
> +       dout("put_osd %p %d -> %d\n", osd, refcount_read(&osd->o_ref),
> +            refcount_read(&osd->o_ref) - 1);
> +       if (refcount_dec_and_test(&osd->o_ref)) {
>                 osd_cleanup(osd);
>                 kfree(osd);
>         }
> @@ -4092,7 +4092,7 @@ void ceph_osdc_stop(struct ceph_osd_client *osdc)
>                 close_osd(osd);
>         }
>         up_write(&osdc->lock);
> -       WARN_ON(atomic_read(&osdc->homeless_osd.o_ref) != 1);
> +       WARN_ON(refcount_read(&osdc->homeless_osd.o_ref) != 1);
>         osd_cleanup(&osdc->homeless_osd);
>
>         WARN_ON(!list_empty(&osdc->osd_lru));

Applied.

Thanks,

                Ilya
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
