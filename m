From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] route: allow to route in a peer netns via
 lwt framework
Date: Mon, 27 Jul 2015 21:56:18 +0200
Message-ID: <55B68CE2.10008@6wind.com>
References: <55B1077F.1090501@6wind.com>	 <1437747419-8442-1-git-send-email-nicolas.dichtel@6wind.com> <1437752397.20182.8.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, tgraf@suug.ch
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33934 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbbG0T4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 15:56:22 -0400
Received: by wibud3 with SMTP id ud3so154022738wib.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 12:56:21 -0700 (PDT)
In-Reply-To: <1437752397.20182.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/07/2015 17:39, Eric Dumazet a =C3=A9crit :
>
> On Fri, 2015-07-24 at 16:16 +0200, Nicolas Dichtel wrote:
>> This patch takes advantage of the newly added lwtunnel framework to
>> allow the user to set routes that point to a peer netns.
>>
>> Packets are injected to the peer netns via the loopback device. It w=
orks
>> only when the output device is 'lo'.
>>
>> Example:
>> ip route add 40.1.1.1/32 encap netns nsid 5 via dev lo
>>
>
> Is this feature so badly wanted to add complexity on lo device ?
>
The goal is to be scalable when the number of netns is high (10k or mor=
e).
Which this patch, we can save two interfaces (veth) per netns, which he=
lps to to=20
reduce memory consumption and the time needed to create a netns.

[snip]
>> +	if (nsid !=3D NETNSA_NSID_NOT_ASSIGNED) {
>> +		peernet =3D get_net_ns_by_id(dev_net(dev), nsid);
>> +		if (!peernet) {
>> +			kfree_skb(skb);
>> +			goto end;
>> +		}
>> +
>> +		/* it's OK to use per_cpu_ptr() because BHs are off */
>> +		lb_stats =3D this_cpu_ptr(peernet->loopback_dev->lstats);
>> +		ret =3D dev_forward_skb(peernet->loopback_dev, skb);
>> +	} else {
>> +		skb_orphan(skb);
>>
>> -	/* it's OK to use per_cpu_ptr() because BHs are off */
>> -	lb_stats =3D this_cpu_ptr(dev->lstats);
>> +		skb->protocol =3D eth_type_trans(skb, dev);
>> +
>> +		/* it's OK to use per_cpu_ptr() because BHs are off */
>> +		lb_stats =3D this_cpu_ptr(dev->lstats);
>> +		ret =3D netif_rx(skb);
>> +	}
>>
>>   	len =3D skb->len;
>
> <use after free error>  At this point you no longer can access skb
Right, will fix it.
