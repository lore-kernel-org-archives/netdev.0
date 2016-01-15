From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: [PATCH 2/8] kernfs: implement kernfs_walk_and_get()
Date: Fri, 15 Jan 2016 13:29:06 +0100
Message-ID: <CAMuHMdXT63aJ2hXJg9mtMv-PZYT7CEw+ab-j42_VoFB-ib+ghg@mail.gmail.com>
References: <1449527935-27056-1-git-send-email-tj@kernel.org>
	<1449527935-27056-3-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-team-b10kYP2dOMg@public.gmane.org, ninasc-b10kYP2dOMg@public.gmane.org,
	Josh Triplett <josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449527935-27056-3-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 7, 2015 at 11:38 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Implement kernfs_walk_and_get() which is similar to
> kernfs_find_and_get() but can walk a path instead of just a name.
>
> v2: Use strlcpy() instead of strlen() + memcpy() as suggested by
>     David.
>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Acked-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
> Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---
>  fs/kernfs/dir.c        | 46 ++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/kernfs.h | 12 ++++++++++++
>  2 files changed, 58 insertions(+)
>
> diff --git a/fs/kernfs/dir.c b/fs/kernfs/dir.c
> index 91e0045..742bf4a 100644
> --- a/fs/kernfs/dir.c
> +++ b/fs/kernfs/dir.c
> @@ -694,6 +694,29 @@ static struct kernfs_node *kernfs_find_ns(struct kernfs_node *parent,
>         return NULL;
>  }
>
> +static struct kernfs_node *kernfs_walk_ns(struct kernfs_node *parent,
> +                                         const unsigned char *path,
> +                                         const void *ns)
> +{
> +       static char path_buf[PATH_MAX]; /* protected by kernfs_mutex */

This is showing up in bloat-o-meter as increasing kernel size by 4 KiB.

> +       size_t len = strlcpy(path_buf, path, PATH_MAX);

The full input string is copied because strsep() replaces the delimiters by
zeroes?
Can this be handled in some other way?

> +       char *p = path_buf;
> +       char *name;
> +
> +       lockdep_assert_held(&kernfs_mutex);
> +
> +       if (len >= PATH_MAX)
> +               return NULL;
> +
> +       while ((name = strsep(&p, "/")) && parent) {
> +               if (*name == '\0')
> +                       continue;
> +               parent = kernfs_find_ns(parent, name, ns);
> +       }
> +
> +       return parent;
> +}

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
