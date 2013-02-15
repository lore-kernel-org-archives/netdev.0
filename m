From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 3/3] GRE: Add TCP segmentation offload for GRE
Date: Thu, 14 Feb 2013 19:31:02 -0800
Message-ID: <CALnjE+po3bQWUWqKQKTV-8sPunT+ZbkY2XXeo5COBPJ_TJB0Ng@mail.gmail.com>
References: <1360871101-2086-1-git-send-email-pshelar@nicira.com>
	<CAHXqBFJi57WA6vJsWEBrzz_-f7_iSYA8eN+Mta9-6rx9n9bfhw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	bhutchings@solarflare.com
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:39640 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932322Ab3BODbE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 22:31:04 -0500
Received: by mail-vb0-f71.google.com with SMTP id p1so3685883vbi.2
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 19:31:03 -0800 (PST)
In-Reply-To: <CAHXqBFJi57WA6vJsWEBrzz_-f7_iSYA8eN+Mta9-6rx9n9bfhw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2013 at 6:35 PM, Micha=C5=82 Miros=C5=82aw <mirqus@gmai=
l.com> wrote:
> 2013/2/14 Pravin B Shelar <pshelar@nicira.com>:
>> Following patch adds GRE protocol offload handler so that
>> skb_gso_segment() can segment GRE packets.
>> SKB GSO CB is added to keep track of total header length so that
>> skb_segment can push entire header. e.g. in case of GRE, skb_segment
>> need to push inner and outer headers to every segment.
>> New NETIF_F_GRE_GSO feature is added for devices which support HW
>> GRE TSO offload. Currently none of devices support it therefore GRE =
GSO
>> always fall backs to software GSO.
> [...]
>> @@ -1044,6 +1102,14 @@ static int ipgre_tunnel_bind_dev(struct net_d=
evice *dev)
>>                 mtu =3D 68;
>>
>>         tunnel->hlen =3D addend;
>> +       if (tunnel->parms.o_flags & GRE_SEQ) {
>> +               /* TCP offload with GRE SEQ is not supported. */
>> +               dev->features &=3D ~NETIF_F_GSO_SOFTWARE;
>> +               dev->hw_features &=3D ~NETIF_F_GSO_SOFTWARE;
>> +       } else {
>> +               dev->features |=3D NETIF_F_GSO_SOFTWARE;
>> +               dev->hw_features |=3D NETIF_F_GSO_SOFTWARE;
>> +       }
>
> Feature clipping belongs to ndo_fix_features. Here,
> netdev_update_features() for the tunnel device should be called.
>

Actually no clipping is required. After creating tunnel device
features do not change. In short code above is setting features not
updating it. I will remove GRE_SEQ case since it is not required and
it is less confusing.
