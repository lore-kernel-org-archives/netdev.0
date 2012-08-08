From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC PATCH] tun: don't zeroize sock->file on detach
Date: Wed, 8 Aug 2012 10:48:32 -0700
Message-ID: <CAK6E8=cpODYa1xURk7BZBnWwx5q3OD8-xkCau7GNPn+1BS0oQQ@mail.gmail.com>
References: <20120711114753.24395.53193.stgit@localhost6.localdomain6> <50226147.3010309@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ruanzhijie@hotmail.com" <ruanzhijie@hotmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:47428 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759077Ab2HHRsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 13:48:53 -0400
Received: by obbuo13 with SMTP id uo13so1426069obb.19
        for <netdev@vger.kernel.org>; Wed, 08 Aug 2012 10:48:52 -0700 (PDT)
In-Reply-To: <50226147.3010309@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 8, 2012 at 5:53 AM, Stanislav Kinsbursky
<skinsbursky@parallels.com> wrote:
> Hi, Dave.
> What about this patch?
>
>
> On Wed, Jul 11, 2012 at 03:48:20PM +0400, Stanislav Kinsbursky wrote:
>>
>> This is a fix for bug, introduced in 3.4 kernel by commit
>> 1ab5ecb90cb6a3df1476e052f76a6e8f6511cb3d, which, among other things,
>> replaced
>> simple sock_put() by sk_release_kernel(). Below is sequence, which leads
>> to
>> oops for non-persistent devices:
>>
>> tun_chr_close()
>> tun_detach()                            <== tun->socket.file = NULL
>> tun_free_netdev()
>> sk_release_sock()
>> sock_release(sock->file == NULL)
>> iput(SOCK_INODE(sock))                  <== dereference on NULL pointer
>>
>> This patch just removes zeroing of socket's file from __tun_detach().
>> sock_release() will do this.
>>
>> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

I has tested this patch and it works (so my kernel stops crashing
using tun devices).

>> ---
>>  drivers/net/tun.c |    1 -
>>  1 files changed, 0 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 987aeef..c1639f3 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -185,7 +185,6 @@ static void __tun_detach(struct tun_struct *tun)
>>         netif_tx_lock_bh(tun->dev);
>>         netif_carrier_off(tun->dev);
>>         tun->tfile = NULL;
>> -       tun->socket.file = NULL;
>>         netif_tx_unlock_bh(tun->dev);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
