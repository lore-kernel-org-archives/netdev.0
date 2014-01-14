From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 net-next] bonding: handle slave's name change with
 primary_slave logic
Date: Tue, 14 Jan 2014 22:10:24 +0300
Message-ID: <52D58BA0.7040905@cogentembedded.com>
References: <1389720901-2298-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:48245 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbaANSK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 13:10:26 -0500
Received: by mail-la0-f52.google.com with SMTP id c6so589331lan.39
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 10:10:25 -0800 (PST)
In-Reply-To: <1389720901-2298-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/14/2014 08:35 PM, Veaceslav Falico wrote:

> Currently, if a slave's name change, we just pass it by. However, if the
> slave is a current primary_slave, then we end up with using a slave, whose
> name != params.primary, for primary_slave. And vice-versa, if we don't have
> a primary_slave but have params.primary set - we will not detected a new
> primary_slave.

> Fix this by catching the NETDEV_CHANGENAME event and setting primary_slave
> accordingly. Also, if the primary_slave was changed, issue a reselection of
> the active slave, cause the priorities have changed.

> Reported-by: Ding Tianhong <dingtianhong@huawei.com>
> CC: Ding Tianhong <dingtianhong@huawei.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---

> Notes:
>      v2->v3:
>      Reword the info message, per Jay's comment.

>      v1->v2:
>      Proper patch

>   drivers/net/bonding/bond_main.c | 23 ++++++++++++++++++++---
>   1 file changed, 20 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index e06c445..ea51661 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2860,9 +2860,26 @@ static int bond_slave_netdev_event(unsigned long event,
>   		 */
>   		break;
>   	case NETDEV_CHANGENAME:
> -		/*
> -		 * TODO: handle changing the primary's name
> -		 */
> +		/* we don't care if we don't have primary set */
> +		if (!USES_PRIMARY(bond->params.mode) ||
> +		    !bond->params.primary[0])
> +			break;
> +
> +		if (slave == bond->primary_slave) {
> +			/* slave's name changed - he's no longer primary */
> +			bond->primary_slave = NULL;
> +		} else if (!strcmp(slave_dev->name, bond->params.primary)) {
> +			/* we have a new primary slave */
> +			bond->primary_slave = slave;
> +		} else  /* we didn't change primary - exit */
> +			break;

    *else* should have {} too, as the other *if* arms have it. Source: 
Documentation/CodingStyle.

WBR, Sergei
