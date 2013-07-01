From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ethtool: make .get_dump_data() harder to
 misuse by drivers
Date: Mon, 1 Jul 2013 16:53:55 +0100
Message-ID: <1372694035.2083.0.camel@bwh-desktop.uk.level5networks.com>
References: <1372692210-31131-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Anirban Chakraborty" <anirban.chakraborty@qlogic.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38972 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab3GAPyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 11:54:04 -0400
In-Reply-To: <1372692210-31131-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-01 at 17:23 +0200, Michal Schmidt wrote:
> As the patch "bnx2x: remove zeroing of dump data buffer" showed,
> it is too easy implement .get_dump_data incorrectly in a driver.
> 
> Let's make sure drivers cannot get confused by userspace requesting
> a too big dump.
> 
> Also WARN if the driver sets dump->len to something weird and make
> sure the length reported to userspace is the actual length of data
> copied to userspace.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
>  net/core/ethtool.c | 21 ++++++++++++++++++++-
>  1 file changed, 20 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index ce91766..3b71cdb 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -1319,10 +1319,19 @@ static int ethtool_get_dump_data(struct net_device *dev,
>  	if (ret)
>  		return ret;
>  
> -	len = (tmp.len > dump.len) ? dump.len : tmp.len;
> +	len = min(tmp.len, dump.len);
>  	if (!len)
>  		return -EFAULT;
>  
> +	/* Don't ever let the driver think there's more space available
> +	 * than it requested with .get_dump_flag().
> +	 */
> +	dump.len = len;
> +
> +	/* Always allocate enough space to hold the whole thing so that the
> +	 * driver does not need to check the length and bother with partial
> +	 * dumping.
> +	 */
>  	data = vzalloc(tmp.len);
>  	if (!data)
>  		return -ENOMEM;
> @@ -1330,6 +1339,16 @@ static int ethtool_get_dump_data(struct net_device *dev,
>  	if (ret)
>  		goto out;
>  
> +	/* There are two sane possibilities:
> +	 * 1. The driver's .get_dump_data() does not touch dump.len.
> +	 * 2. Or it may set dump.len to how much it really writes, which
> +	 *    should be tmp.len (or len if it can do a partial dump).
> +	 * In any case respond to userspace with the actual length of data
> +	 * it's receiving.
> +	 */
> +	WARN_ON(dump.len != len && dump.len != tmp.len);
> +	dump.len = len;
> +
>  	if (copy_to_user(useraddr, &dump, sizeof(dump))) {
>  		ret = -EFAULT;
>  		goto out;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
