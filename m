From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [PATCH 06/14] libceph: use list_for_each_entry_safe
Date: Mon, 11 Jan 2016 23:06:07 +0100
Message-ID: <CAOi1vP_sZgBz+Xb0o-NX-4o4BveQ6LKJsu_RC6OozjkehM=1UQ@mail.gmail.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
	<40510e6829654a5a4726650c63bf00d88c037593.1450451516.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <40510e6829654a5a4726650c63bf00d88c037593.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 18, 2015 at 4:33 PM, Geliang Tang <geliangtang@163.com> wrote:
> Use list_for_each_entry_safe() instead of list_for_each_safe() to
> simplify the code.
>
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  net/ceph/messenger.c | 14 +++++---------
>  1 file changed, 5 insertions(+), 9 deletions(-)
>
> diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
> index 9981039..c664b7f 100644
> --- a/net/ceph/messenger.c
> +++ b/net/ceph/messenger.c
> @@ -3361,9 +3361,8 @@ static void ceph_msg_free(struct ceph_msg *m)
>  static void ceph_msg_release(struct kref *kref)
>  {
>         struct ceph_msg *m = container_of(kref, struct ceph_msg, kref);
> -       LIST_HEAD(data);
> -       struct list_head *links;
> -       struct list_head *next;
> +       LIST_HEAD(head);
> +       struct ceph_msg_data *data, *next;
>
>         dout("%s %p\n", __func__, m);
>         WARN_ON(!list_empty(&m->list_head));
> @@ -3376,12 +3375,9 @@ static void ceph_msg_release(struct kref *kref)
>                 m->middle = NULL;
>         }
>
> -       list_splice_init(&m->data, &data);
> -       list_for_each_safe(links, next, &data) {
> -               struct ceph_msg_data *data;
> -
> -               data = list_entry(links, struct ceph_msg_data, links);
> -               list_del_init(links);
> +       list_splice_init(&m->data, &head);
> +       list_for_each_entry_safe(data, next, &head, links) {
> +               list_del_init(&data->links);
>                 ceph_msg_data_destroy(data);
>         }
>         m->data_length = 0;

Applied.  I killed the call to list_splice_init() along with its
list_head while at it.

Thanks,

                Ilya
