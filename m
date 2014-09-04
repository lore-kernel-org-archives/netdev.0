From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Thu, 04 Sep 2014 06:09:14 -0700
Message-ID: <1409836154.26422.101.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
	 <54078FBC.5050402@redhat.com>
	 <CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
	 <1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1409793959.3362714.163402573.6A26EDE1@webmail.messagingengine.com>
	 <1409796348.26422.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQLh6qOD2epUq0S5P8RkUgZA38JNxeP40uBMScLHC2SsJg@mail.gmail.com>
	 <CAHj3AVn8q-JS0Eq0QrfpBo-WfJ+-wXumhNoeDAdkPZC7LSeB5g@mail.gmail.com>
	 <1409831412.23465.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:37320 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbaIDNJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 09:09:17 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so20005403pad.35
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 06:09:17 -0700 (PDT)
In-Reply-To: <1409831412.23465.3.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-04 at 13:50 +0200, Hannes Frederic Sowa wrote:

> 
> Denis, I thought about something like this, you can incorperate this in
> your patch if you can give it a test and check for other architectures,
> thanks!
> 


> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 02529fc..87b86aa 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -548,6 +548,10 @@ struct sk_buff {
>  				ip_summed:2,
>  				nohdr:1,
>  				nfctinfo:3;
> +	/* __pkt_type_offset marks the offset of the bitfield pkt_type
> +	 * contains, so bpf can relatively address it
> +	 */
> +	int			__pkt_type_offset[0];

Why is it 'int', while the following uses __u8 ?

This means pkt_type has to stay at this bit offset, and nothing will
detect at compile time or execution time if someone did a reorg or added
a new field (it seems to be the trend lately)

__u8                          bar:4,
                              pkt_type:3,
...




>  	__u8			pkt_type:3,
>  				fclone:2,
>  				ipvs_property:1,
> @@ -647,6 +651,17 @@ struct sk_buff {
>  #define SKB_ALLOC_FCLONE	0x01
>  #define SKB_ALLOC_RX		0x02
>  

> +#ifdef __BIG_ENDIAN_BITFIELD
> +#define PKT_TYPE_MAX   (7 << 5)
> +#else
> +#define PKT_TYPE_MAX   7
> +#endif

It had a sense right before static int pkt_type_offset(void), but here,
a casual reader might be lost.

I am saying this because a reorder of the bit fields is probably needed
to speedup __copy_skb_header() : Grouping together bit fields could
allow optimized word copies instead of bit field manipulations.
