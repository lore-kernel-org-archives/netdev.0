From: Ilya Dryomov <idryomov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 06/23] net, ceph: convert ceph_pagelist.refcnt from
 atomic_t to refcount_t
Date: Fri, 24 Mar 2017 14:49:48 +0100
Message-ID: <CAOi1vP8BeC5R8CU0_NpbFBXA_JpVfbBzxyVsAne+9JGkOgPbKA@mail.gmail.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com> <1489752646-8749-7-git-send-email-elena.reshetova@intel.com>
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
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489752646-8749-7-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
>  fs/ceph/mds_client.c          | 2 +-
>  include/linux/ceph/pagelist.h | 6 +++---
>  net/ceph/pagelist.c           | 2 +-
>  3 files changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/fs/ceph/mds_client.c b/fs/ceph/mds_client.c
> index c681762..7b38e6c 100644
> --- a/fs/ceph/mds_client.c
> +++ b/fs/ceph/mds_client.c
> @@ -1991,7 +1991,7 @@ static struct ceph_msg *create_request_message(struct ceph_mds_client *mdsc,
>
>         if (req->r_pagelist) {
>                 struct ceph_pagelist *pagelist = req->r_pagelist;
> -               atomic_inc(&pagelist->refcnt);
> +               refcount_inc(&pagelist->refcnt);
>                 ceph_msg_data_add_pagelist(msg, pagelist);
>                 msg->hdr.data_len = cpu_to_le32(pagelist->length);
>         } else {
> diff --git a/include/linux/ceph/pagelist.h b/include/linux/ceph/pagelist.h
> index 13d71fe..75a7db2 100644
> --- a/include/linux/ceph/pagelist.h
> +++ b/include/linux/ceph/pagelist.h
> @@ -2,7 +2,7 @@
>  #define __FS_CEPH_PAGELIST_H
>
>  #include <asm/byteorder.h>
> -#include <linux/atomic.h>
> +#include <linux/refcount.h>
>  #include <linux/list.h>
>  #include <linux/types.h>
>
> @@ -13,7 +13,7 @@ struct ceph_pagelist {
>         size_t room;
>         struct list_head free_list;
>         size_t num_pages_free;
> -       atomic_t refcnt;
> +       refcount_t refcnt;
>  };
>
>  struct ceph_pagelist_cursor {
> @@ -30,7 +30,7 @@ static inline void ceph_pagelist_init(struct ceph_pagelist *pl)
>         pl->room = 0;
>         INIT_LIST_HEAD(&pl->free_list);
>         pl->num_pages_free = 0;
> -       atomic_set(&pl->refcnt, 1);
> +       refcount_set(&pl->refcnt, 1);
>  }
>
>  extern void ceph_pagelist_release(struct ceph_pagelist *pl);
> diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
> index 6864007..ce09f73 100644
> --- a/net/ceph/pagelist.c
> +++ b/net/ceph/pagelist.c
> @@ -16,7 +16,7 @@ static void ceph_pagelist_unmap_tail(struct ceph_pagelist *pl)
>
>  void ceph_pagelist_release(struct ceph_pagelist *pl)
>  {
> -       if (!atomic_dec_and_test(&pl->refcnt))
> +       if (!refcount_dec_and_test(&pl->refcnt))
>                 return;
>         ceph_pagelist_unmap_tail(pl);
>         while (!list_empty(&pl->head)) {

Applied.

Thanks,

                Ilya
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
