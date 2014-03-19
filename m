From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCHv5 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Wed, 19 Mar 2014 15:23:27 -0600
Message-ID: <OFCDE8D1D8.B2E1BD73-ON87257CA0.007580F9-87257CA0.007580FE@us.ibm.com>
References: <20140319.162053.1175830729987006835.davem@davemloft.net>,
	<201403182009.s2IK9Ias021320@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: amwang@redhat.com, netdev@vger.kernel.org, shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:56987 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbaCSVXb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 17:23:31 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 19 Mar 2014 15:23:31 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6727C19D8036
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 15:23:25 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08026.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2JLMtUh8847690
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 22:22:55 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2JLNSaN015538
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2014 15:23:28 -0600
In-Reply-To: <20140319.162053.1175830729987006835.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----David Miller <davem@davemloft.net> wrote: -----

>
>> + if (dev =3D=3D NULL)
>> +	 return NULL;
>> +
>> +
>> +	len =3D LL_RESERVED_SPACE(dev) + sizeof(struct ipv6hdr) +
>> +	 sizeof(*na) + olen + dev->needed_tailroom;
>
>No need to have two empty lines here, one is sufficient.
>
>> +	olen =3D request->len - skb_transport_offset(request) -
>sizeof(*ns);
>
>This overrides unconditionally, and in all cases, the assignment made
>in the declaration of the 'olen' variable. Therefore the variable
>declaration should not have an initializer. Please remove it.
=2E..
>
>> +	olen =3D 8; /* ND_OPT_TARGET_LL_ADDR */
>
>I guess this is what the variable declaration assignment was
>meant to be used for.

There are 2 packets, neighbor solicitation (received) and
neighbor advertisement (reply) and "olen" is initially the option lengt=
h
of the NA, a constant, for allocating its buffer. After that, the tempo=
rary
variable "olen" is set to the variable length of the options in the
received packet (NS) and used for processing its options.

So, it's an option length in both cases, but not the same
value and not for the same packet, throughout.

I can use a constant for the reply packet case, or a different variable=
;
I overloaded "olen" for the allocation primarily because I had a naked =
"8"
before that, and a #define seemed like overkill here.

>This is also ndisc_opt_addr_space(dev).
>
>> +	na->opt[1] =3D 1; /* 8 bytes */
>
>This is perhaps more clearly expressed as "opt >> 3".
>> @@ -1357,8 +1446,7 @@ static int neigh_reduce(struct net_device
>*dev, struct sk_buff *skb)
>> saddr =3D &iphdr->saddr;
>> daddr =3D &iphdr->daddr;
>>=20
>> -	if (ipv6_addr_loopback(daddr) ||
>> -	 ipv6_addr_is_multicast(daddr))
>> +	if (ipv6_addr_loopback(daddr))
>> goto out;
>>=20
>> msg =3D (struct nd_msg *)skb_transport_header(skb);
>
>Note that the ipv6 stack input path checks to make sure that the
>msg->target is not multicast. Just something I noticed.

I could; a multicast address won't be in the neighbor table, so it won'=
t
respond either way, which is why I didn't bother with the check.

I'll incorporate these and repost.

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0+-DLS
