From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Xen backend support for paged out grant targets V4.
Date: Mon, 17 Sep 2012 09:17:45 +0100
Message-ID: <1347869865.14977.15.camel@zakaz.uk.xensource.com>
References: <1347632819-13684-1-git-send-email-andres@lagarcavilla.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"David Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andres Lagar-Cavilla <andres@lagarcavilla.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347632819-13684-1-git-send-email-andres@lagarcavilla.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(I think I forgot to hit send on this on Friday, sorry. Also
s/xen.lists.org/lists.xen.org in the CC line...)

On Fri, 2012-09-14 at 15:26 +0100, Andres Lagar-Cavilla wrote:
> Since Xen-4.2, hvm domains may have portions of their memory paged out. When a
> foreign domain (such as dom0) attempts to map these frames, the map will
> initially fail. The hypervisor returns a suitable errno, and kicks an
> asynchronous page-in operation carried out by a helper. The foreign domain is
> expected to retry the mapping operation until it eventually succeeds. The
> foreign domain is not put to sleep because itself could be the one running the
> pager assist (typical scenario for dom0).
> 
> This patch adds support for this mechanism for backend drivers using grant
> mapping and copying operations. Specifically, this covers the blkback and
> gntdev drivers (which map foregin grants), and the netback driver (which copies

                           foreign

> foreign grants).
> 
> * Add a retry method for grants that fail with GNTST_eagain (i.e. because the
>   target foregin frame is paged out).

          foreign

> * Insert hooks with appropriate wrappers in the aforementioned drivers.
> 
> The retry loop is only invoked if the grant operation status is GNTST_eagain.
> It guarantees to leave a new status code different from GNTST_eagain. Any other
> status code results in identical code execution as before.
> 
> The retry loop performs 256 attempts with increasing time intervals through a
> 32 second period. It uses msleep to yield while waiting for the next retry.
[...]
> Signed-off-by: Andres Lagar-Cavilla <andres@lagarcavilla.org>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Since this is more about grant tables than netback this should probably
go via Konrad rather than Dave, is that OK with you Dave?

(there's one more typo below)

> ---
>  drivers/net/xen-netback/netback.c  |   11 ++------
>  drivers/xen/grant-table.c          |   53 ++++++++++++++++++++++++++++++++++++
>  drivers/xen/xenbus/xenbus_client.c |    6 ++--
>  include/xen/grant_table.h          |   12 ++++++++
>  4 files changed, 70 insertions(+), 12 deletions(-)
[...]
> diff --git a/include/xen/grant_table.h b/include/xen/grant_table.h
> index 11e27c3..da9386e 100644
> --- a/include/xen/grant_table.h
> +++ b/include/xen/grant_table.h
> @@ -189,4 +189,16 @@ int gnttab_map_refs(struct gnttab_map_grant_ref *map_ops,
>  int gnttab_unmap_refs(struct gnttab_unmap_grant_ref *unmap_ops,
>  		      struct page **pages, unsigned int count, bool clear_pte);
>  
> +/* Perform a batch of grant map/copy operations. Retry every batch slot
> + * for which the hypervisor returns GNTST_eagain. This is typically due 
> + * to paged out target frames.
> + *
> + * Will retry for 1, 2, ... 255 ms, i.e. 256 times during 32 seconds.
> + *
> + * Return value in each iand every status field of the batch guaranteed

                          and

> + * to not be GNTST_eagain. 
> + */
> +void gnttab_batch_map(struct gnttab_map_grant_ref *batch, unsigned count);
> +void gnttab_batch_copy(struct gnttab_copy *batch, unsigned count);
> +
>  #endif /* __ASM_GNTTAB_H__ */
