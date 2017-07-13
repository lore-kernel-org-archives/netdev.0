From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [PATCH net] libceph: osdmap: Fix some NULL dereferences
Date: Thu, 13 Jul 2017 18:13:22 +0200
Message-ID: <CAOi1vP8tNXb7izDJXV1LzHhFMcqhFh_+_+zxsHQZnqgb_S+Etg@mail.gmail.com>
References: <20170713074517.io64uezw3qf6oush@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Ceph Development <ceph-devel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:33419 "EHLO
        mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdGMQNX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 12:13:23 -0400
In-Reply-To: <20170713074517.io64uezw3qf6oush@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 13, 2017 at 9:45 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> There are hidden gotos in the ceph_decode_* macros.  We need to set the
> "err" variable on these error paths otherwise we end up returning
> ERR_PTR(0) which is NULL.  It causes NULL dereferences in the callers.
>
> Fixes: 278b1d709c6a ("libceph: ceph_decode_skip_* helpers")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/net/ceph/osdmap.c b/net/ceph/osdmap.c
> index 864789c5974e..c7521a847ef7 100644
> --- a/net/ceph/osdmap.c
> +++ b/net/ceph/osdmap.c
> @@ -510,6 +510,7 @@ static struct crush_map *crush_decode(void *pbyval, void *end)
>                 }
>         }
>
> +       err = -EINVAL;
>         ceph_decode_skip_map(p, end, 32, string, bad); /* type_map */
>         ceph_decode_skip_map(p, end, 32, string, bad); /* name_map */
>         ceph_decode_skip_map(p, end, 32, string, bad); /* rule_name_map */
> @@ -1825,9 +1826,9 @@ struct ceph_osdmap *osdmap_apply_incremental(void **p, void *end,
>         if (struct_v >= 3) {
>                 /* new_erasure_code_profiles */
>                 ceph_decode_skip_map_of_map(p, end, string, string, string,
> -                                           bad);
> +                                           e_inval);
>                 /* old_erasure_code_profiles */
> -               ceph_decode_skip_set(p, end, string, bad);
> +               ceph_decode_skip_set(p, end, string, e_inval);
>         }
>
>         if (struct_v >= 4) {

Hi Dan,

I applied osdmap_apply_incremental() hunk and fixed a similar bug in
osdmap_decode() (it's a not NULL deref, that's why smatch didn't catch
it).

I posted a separate patch for crush_decode().  This is the second time
in two months you are fixing it, so I wanted something more future-proof.

See the end result at https://github.com/ceph/ceph-client/commits/testing.

Thanks,

                Ilya
