From: Jakub Jelinek <jakub@redhat.com>
Subject: Re: [PATCH 1/8][ATM]: [zatm] eliminate kfree warning (from Tobias Hirning <sskyman@web.de>)
Date: Wed, 20 Jul 2005 09:19:20 +0200
Message-ID: <20050720071919.GV4740@sunsite.mff.cuni.cz>
References: <200507192044.j6JKirFb027183@ginger.cmf.nrl.navy.mil>
Reply-To: Jakub Jelinek <jakub@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200507192044.j6JKirFb027183@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 19, 2005 at 04:44:54PM -0400, chas williams - CONTRACTOR wrote:
> please apply to 2.6 -- thanks!
> 
> [ATM]: [zatm] eliminate kfree warning (from Tobias Hirning <sskyman@web.de>)
> 
>   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
> 
> 
> ---
> commit 4932248439d20412610ffaade625cbde0e001e37
> tree 35a60e3551f5f1abced8a435238575c488041af6
> parent 238921d2cb04eb6dcc2ff5914d555d7dcaa4dfc5
> author chas williams <chas@relax.(none)> Wed, 06 Jul 2005 13:10:18 -0400
> committer chas williams <chas@relax.(none)> Wed, 06 Jul 2005 13:10:18 -0400
> 
>  drivers/atm/zatm.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
> --- a/drivers/atm/zatm.c
> +++ b/drivers/atm/zatm.c
> @@ -1339,7 +1339,7 @@ static int __init zatm_start(struct atm_
>  	return 0;
>      out:
>  	for (i = 0; i < NR_MBX; i++)
> -		kfree(zatm_dev->mbx_start[i]);
> +		kfree(&zatm_dev->mbx_start[i]);

This can't be right.  zatm_dev->mbx_start[i] is allocated with:
   1306                         here = (unsigned long) kmalloc(2*MBX_SIZE(i),
   1307                             GFP_KERNEL);
   1308                         if (!here) {
   1309                                 error = -ENOMEM;
   1310                                 goto out;
   1311                         }
   1312                         if ((here^(here+MBX_SIZE(i))) & ~0xffffUL)/* paranoia */
   1313                                 here = (here & ~0xffffUL)+0x10000;
   1314                         zatm_dev->mbx_start[i] = here;

so even kfree((void *)zatm_dev->mbx_start[i]); is wrong in case
there was an alignment, but kfree(&zatm_dev->mbx_start[i])
is wrong in all cases.

	Jakub
