From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net RFC 1/2] netdevice: add might_sleep() call to napi_disable
Date: Tue, 8 Oct 2013 15:39:18 +0300
Message-ID: <5253FCF6.1040808@mellanox.com>
References: <20130918201541.8697.3548.stgit@jekeller-desk1.amr.corp.intel.com> <20130918201949.8697.50700.stgit@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Alex Duyck <alexander.h.duyck@intel.com>,
	Hyong-Youb Kim <hykim@myri.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:39115 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751635Ab3JHMjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 08:39:33 -0400
In-Reply-To: <20130918201949.8697.50700.stgit@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/09/2013 23:20, Jacob Keller wrote:
> napi_disable potentially calls msleep(1) if the NAPI_STATE_SCHED bit is
> previously set by something else. Because it does not always call msleep, it
> was difficult to track down a bug related to calling napi_disable within
> local_bh_disable()d context. This patch adds a might_sleep() call to the
> napi_disable routine in order to aid in the future debugging of similar issues.
> This will cause a BUG in drivers which have implemented busy polling in a
> similar fashion to ixgbe, and which call napi_disable inside the
> local_bh_disable()d section where the vector napi lock is taken.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Cc: Alex Duyck <alexander.h.duyck@intel.com>
> Cc: Hyong-Youb Kim <hykim@myri.com>
> Cc: Amir Vadai <amirv@mellanox.com>
> Cc: Dmitry Kravkov <dmitry@broadcom.com>
> ---
>  include/linux/netdevice.h |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 3de49ac..81dab00 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -483,6 +483,8 @@ extern void napi_hash_del(struct napi_struct *napi);
>   */
>  static inline void napi_disable(struct napi_struct *n)
>  {
> +	might_sleep();
> +
>  	set_bit(NAPI_STATE_DISABLE, &n->state);
>  	while (test_and_set_bit(NAPI_STATE_SCHED, &n->state))
>  		msleep(1);
> 

Works ok with mlx4_en driver.

Acked-By: Amir Vadai <amirv@mellanox.com>
