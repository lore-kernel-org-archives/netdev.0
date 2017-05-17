From: Firo Yang <firogm@gmail.com>
Subject: Re: [PATCH] hdlcdrv: fix divide error bug if bitrate is 0
Date: Wed, 17 May 2017 21:42:46 +0800
Message-ID: <20170517134246.GA24874@snow>
References: <20170517123549.22659-1-firogm@gmail.com>
 <591C493B.6060908@bfs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: t.sailer@alumni.ethz.ch, davem@davemloft.net,
        gregkh@linuxfoundation.org, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, dvyukov@google.com,
        syzkaller@googlegroups.com
To: walter harms <wharms@bfs.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36329 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753814AbdEQNmu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 09:42:50 -0400
Content-Disposition: inline
In-Reply-To: <591C493B.6060908@bfs.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 17, 2017 at 02:59:39PM +0200, walter harms wrote:
>
>
>Am 17.05.2017 14:35, schrieb Firo Yang:
>> The divisor s->par.bitrate will always be 0 until initialized by
>> ndo_open() and hdlcdrv_open().
>> 
>> In order to fix this divide zero error, check whether the netdevice
>> was opened by ndo_open() before performing divide.
>> 
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Signed-off-by: Firo Yang <firogm@gmail.com>
>> ---
>>  drivers/net/hamradio/hdlcdrv.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/hamradio/hdlcdrv.c b/drivers/net/hamradio/hdlcdrv.c
>> index 8c3633c..3c783fd 100644
>> --- a/drivers/net/hamradio/hdlcdrv.c
>> +++ b/drivers/net/hamradio/hdlcdrv.c
>> @@ -574,7 +574,7 @@ static int hdlcdrv_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>>  		break;		
>>  
>>  	case HDLCDRVCTL_CALIBRATE:
>> -		if(!capable(CAP_SYS_RAWIO))
>> +		if (!capable(CAP_SYS_RAWIO) || !netif_running(dev))
>>  			return -EPERM;
>>  		if (bi.data.calibrate > INT_MAX / s->par.bitrate)
>>  			return -EINVAL;
>
>I would still check for s->par.bitrate > 0 later changes may affect the setting of it
>and it is much more obvious.

I think 0 is not valid value for bitrate, so we should check it in
other places, like what ser12_open() did:
429         if (bc->baud < 300 || bc->baud > 4800) {
430                 printk(KERN_INFO "baycom_ser_fdx: invalid baudrate "
431                                 "(300...4800)\n");
432                 return -EINVAL;
433         }
...
440         bc->hdrv.par.bitrate = bc->baud;

>
>Also perhaps !netif_running(dev) should better return ENODEV.

However, the 'dev' truly exists in this circumstance.

Thanks,
Firo

>
>
>just my 2 cents,
>re,
> wh
>
