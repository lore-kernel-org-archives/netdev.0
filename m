From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH 10/29] drivers, md: convert stripe_head.count from
 atomic_t to refcount_t
Date: Tue, 7 Mar 2017 11:07:59 -0800
Message-ID: <20170307190759.jnrq66kfpkr4m7zl@kernel.org>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
 <1488810076-3754-11-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, linux-pci@vger.kernel.org,
 target-devel@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
 devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
 linux-scsi@vger.kernel.org, linux-serial@vger.kernel.org,
 fcoe-devel@open-fcoe.org, xen-devel@lists.xenproject.org,
 open-iscsi@googlegroups.com, linux-media@vger.kernel.org,
 Kees Cook <keescook@chromium.org>, linux-raid@vger.kernel.org,
 linux-bcache@vger.kernel.org, Hans Liljestrand <ishkamiel@gmail.com>,
 David Windsor <dwindsor@gmail.com>, gregkh@linuxfoundation.org,
 linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, devel@linuxdriverproject.org
To: Elena Reshetova <elena.reshetova@intel.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1488810076-3754-11-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, Mar 06, 2017 at 04:20:57PM +0200, Elena Reshetova wrote:
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
> 
> Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Signed-off-by: David Windsor <dwindsor@gmail.com>
> ---
>  drivers/md/raid5-cache.c |  8 +++---
>  drivers/md/raid5.c       | 66 ++++++++++++++++++++++++------------------------
>  drivers/md/raid5.h       |  3 ++-
>  3 files changed, 39 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/md/raid5-cache.c b/drivers/md/raid5-cache.c
> index 3f307be..6c05e12 100644
> --- a/drivers/md/raid5-cache.c
> +++ b/drivers/md/raid5-cache.c

snip
>  	       sh->check_state, sh->reconstruct_state);
>  
>  	analyse_stripe(sh, &s);
> @@ -4924,7 +4924,7 @@ static void activate_bit_delay(struct r5conf *conf,
>  		struct stripe_head *sh = list_entry(head.next, struct stripe_head, lru);
>  		int hash;
>  		list_del_init(&sh->lru);
> -		atomic_inc(&sh->count);
> +		refcount_inc(&sh->count);
>  		hash = sh->hash_lock_index;
>  		__release_stripe(conf, sh, &temp_inactive_list[hash]);
>  	}
> @@ -5240,7 +5240,7 @@ static struct stripe_head *__get_priority_stripe(struct r5conf *conf, int group)
>  		sh->group = NULL;
>  	}
>  	list_del_init(&sh->lru);
> -	BUG_ON(atomic_inc_return(&sh->count) != 1);
> +	BUG_ON(refcount_inc_not_zero(&sh->count));

This changes the behavior. refcount_inc_not_zero doesn't inc if original value is 0

Thanks,
Shaohua
