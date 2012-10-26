From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: bpf filter : support for vlan tag
Date: Fri, 26 Oct 2012 10:05:10 +0200
Message-ID: <CAD6jFUQ+F4nBu6WmC6pW2GLSeUy+QfHngT=5NStt=2BRQFnA4w@mail.gmail.com>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
	<1350369998.3954.563.camel@edumazet-glaptop>
	<CAD6jFUTn98+i_0eh6gc-CYgVXHNLbZdZmV6==mL+duFM-oNRmg@mail.gmail.com>
	<1350386917.3954.890.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50226 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757110Ab2JZIFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 04:05:18 -0400
Received: from [78.46.5.203] (helo=sslproxy01.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TReuq-0000ut-GE
	for netdev@vger.kernel.org; Fri, 26 Oct 2012 10:05:16 +0200
Received: from [74.125.83.46] (helo=mail-ee0-f46.google.com)
	by sslproxy01.your-server.de with esmtpsa (TLSv1:RC4-SHA:128)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1TReup-0006r0-58
	for netdev@vger.kernel.org; Fri, 26 Oct 2012 10:05:15 +0200
Received: by mail-ee0-f46.google.com with SMTP id b15so894862eek.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 01:05:10 -0700 (PDT)
In-Reply-To: <1350386917.3954.890.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 16, 2012 at 1:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-10-16 at 13:00 +0200, Daniel Borkmann wrote:
>> On Tue, Oct 16, 2012 at 8:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Mon, 2012-10-15 at 19:10 -0700, Ani Sinha wrote:
>> >> I was looking at the kernel side implementation of the BPF filter. I
>> >> do not see any code that supports filtering of packets based on
>> >> provided vlan tag information from the skbuff. This will make it
>> >> impossible to provide any filter to tcpdump that will filter packets
>> >> based on the tag information if libpcap uses the kernel filter.
>> >>
>> >> Any help will be much appreciated.
>> >
>> > Right, we need a basic support, using a new ancillary definition.
>> >
>> > Is the following patch enough to address your need, or do you also need
>> > access to vlan_tx_tag_present() ?
>>
>> I like this patch, it's especially useful to speed up processing for
>> packet analyzers. vlan_tx_tag_present() might also be good to have if
>> this doesn't waste to much room for future ancillary operations.
>
> There is plenty of room in ancillary space
>
> Note that if speed is needed, we also want to update various JIT
> implementations.

Eric, can you submit this patch to net-next if there are no objections
from your side regarding the follow-up comments? Big thanks.

> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 24d251f..c9f0005 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -123,6 +123,8 @@ enum {
>         BPF_S_ANC_CPU,
>         BPF_S_ANC_ALU_XOR_X,
>         BPF_S_ANC_SECCOMP_LD_W,
> +       BPF_S_ANC_VLAN_TAG,
> +       BPF_S_ANC_VLAN_TAG_PRESENT,
>  };
>
>  #endif /* __LINUX_FILTER_H__ */
> diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
> index 3d79224..9cfde69 100644
> --- a/include/uapi/linux/filter.h
> +++ b/include/uapi/linux/filter.h
> @@ -127,7 +127,9 @@ struct sock_fprog { /* Required for SO_ATTACH_FILTER. */
>  #define SKF_AD_RXHASH  32
>  #define SKF_AD_CPU     36
>  #define SKF_AD_ALU_XOR_X       40
> -#define SKF_AD_MAX     44
> +#define SKF_AD_VLAN_TAG        44
> +#define SKF_AD_VLAN_TAG_PRESENT 48
> +#define SKF_AD_MAX     52
>  #define SKF_NET_OFF   (-0x100000)
>  #define SKF_LL_OFF    (-0x200000)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 3d92ebb..5a114d4 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -39,6 +39,7 @@
>  #include <linux/reciprocal_div.h>
>  #include <linux/ratelimit.h>
>  #include <linux/seccomp.h>
> +#include <linux/if_vlan.h>
>
>  /* No hurry in this branch
>   *
> @@ -341,6 +342,12 @@ load_b:
>                 case BPF_S_ANC_CPU:
>                         A = raw_smp_processor_id();
>                         continue;
> +               case BPF_S_ANC_VLAN_TAG:
> +                       A = vlan_tx_tag_get(skb);
> +                       continue;
> +               case BPF_S_ANC_VLAN_TAG_PRESENT:
> +                       A = !!vlan_tx_tag_present(skb);
> +                       continue;
>                 case BPF_S_ANC_NLATTR: {
>                         struct nlattr *nla;
>
> @@ -600,6 +607,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>                         ANCILLARY(RXHASH);
>                         ANCILLARY(CPU);
>                         ANCILLARY(ALU_XOR_X);
> +                       ANCILLARY(VLAN_TAG);
> +                       ANCILLARY(VLAN_TAG_PRESENT);
>                         }
>                 }
>                 ftest->code = code;
>
>
