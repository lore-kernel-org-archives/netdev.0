From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: usbnet: prevent buggy devices from killing us
Date: Fri, 25 Jan 2013 09:14:23 +0100
Message-ID: <878v7hfzmo.fsf@nemi.mork.no>
References: <2556579.vjYlY1iKn5@linux-5eaq.site>
	<1359055016-13603-1-git-send-email-bjorn@mork.no>
	<1359071829.2117.6.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1359071829.2117.6.camel@joe-AO722> (Joe Perches's message of
	"Thu, 24 Jan 2013 15:57:09 -0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> writes:

> On Thu, 2013-01-24 at 20:16 +0100, Bj=C3=B8rn Mork wrote:
>> A device sending 0 length frames as fast as it can has been
>> observed killing the host system due to the resulting memory
>> pressure.
> []
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> []
>> @@ -539,6 +545,22 @@ block:
>>  		break;
>>  	}
>> =20
>> +	/* stop rx if packet error rate is high */
>> +	if (++dev->pkt_cnt > 30) {
>> +		dev->pkt_cnt =3D 0;
>> +		dev->pkt_err =3D 0;
>> +	} else {
>> +		if (state =3D=3D rx_cleanup)
>> +			dev->pkt_err++;
>> +		if (dev->pkt_err > 20) {
>> +			set_bit(EVENT_RX_KILL, &dev->flags);
>> +			if (net_ratelimit())
>> +				netif_dbg(dev, rx_err, dev->net,
>> +					  "rx kill: high error rate\n");
>> +			dev->pkt_err =3D 0;
>> +		}
>> +	}
>
> Maybe use ratelimit() here?
>
>> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> []
>> @@ -33,6 +33,7 @@ struct usbnet {
>>  	wait_queue_head_t	*wait;
>>  	struct mutex		phy_mutex;
>>  	unsigned char		suspend_count;
>> +	unsigned char		pkt_cnt, pkt_err;
>
> and instead:
>
> 	struct ratelimit_state errors;

Thanks.  I took a look at this, but it seems to be more complex than I
really wanted for keeping the debug noise down here.  The rest of usbne=
t
does not care much about rate limiting debug messages at all.  I'll get
a message for every 0 length packet for example.

Maybe usbnet should get a private debug ratelimiter all over?

Is the problem that these instances will hide more important net
messages?  Would it help to make the ratelimit call depend on whether
debugging is enabled like ath5k and brcm80211 seems to do?



Bj=C3=B8rn

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
