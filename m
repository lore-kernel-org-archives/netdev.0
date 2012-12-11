From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH v4 1/5] net: Add support for hardware-offloaded encapsulation
Date: Tue, 11 Dec 2012 08:46:42 -0800
Message-ID: <50C76372.7070403@intel.com>
References: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com> <1354925658-24115-2-git-send-email-joseph.gasparakis@intel.com> <CAMAG_ee6xW4EnzPFt=_5+NL2+LuyUjxd52Xc242inYm2+Yhg7g@mail.gmail.com> <504C9EFCA2D0054393414C9CB605C37F1BFC3555@SJEXCHMB06.corp.ad.broadcom.com> <CAMAG_efu-skGsJiTDR5gQ09kJ1Y7OtJ3P-ii1QEX6ZpyUm-d4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Dmitry Kravkov <dmitry@broadcom.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"chrisw@sous-sol.org" <chrisw@sous-sol.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: saeed bishara <saeed.bishara@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMAG_efu-skGsJiTDR5gQ09kJ1Y7OtJ3P-ii1QEX6ZpyUm-d4Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2012 12:11 AM, saeed bishara wrote:
> On Mon, Dec 10, 2012 at 9:58 PM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
>>> -----Original Message-----
>>> From: saeed bishara [mailto:saeed.bishara@gmail.com]
>>> Sent: Monday, December 10, 2012 12:04 PM
>>> To: Joseph Gasparakis
>>> Cc: davem@davemloft.net; shemminger@vyatta.com; chrisw@sous-sol.org;
>>> gospo@redhat.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
>>> Dmitry Kravkov; bhutchings@solarflare.com; Peter P Waskiewicz Jr; Alexander
>>> Duyck
>>> Subject: Re: [PATCH v4 1/5] net: Add support for hardware-offloaded
>>> encapsulation
>>>
>>>> +static inline struct iphdr *inner_ip_hdr(const struct sk_buff *skb)
>>>> +{
>>>> +       return (struct iphdr *)skb_inner_network_header(skb);
>>>> +}
>>>
>>> Hi,
>>> I'm a little bit bothered because of those inner_ functions, what
>>> about the following approach:
>>> 1. the skb will have a new state, that state can be outer (normal
>>> mode) and inner.
>>> 2. when you change the state to inner, all the helper functions such
>>> as ip_hdr will return the innter header.
>>>
>>> that's ofcourse the API side. the implementation may still use the
>>> fields you added to the skb.
>>>
>>> what you think?
>>> saeed
>>
>> Some drivers will probably need both inner_ and other_ in same flow, switching between two states will consume cpu cycles.
> from performance perspective, I'm not sure the switching is worse, it
> may be better as it reduces code size. please have a look at patch
> 2/5, with switching you can avoid doing the following change -> less
> code, less if-else.
> -                               skb_set_transport_header(skb,
> -                                       skb_checksum_start_offset(skb));
> +                               if (skb->encapsulation)
> +                                       skb_set_inner_transport_header(skb,
> +                                               skb_checksum_start_offset(skb));
> +                               else
> +                                       skb_set_transport_header(skb,
> +                                               skb_checksum_start_offset(skb));
>                                 if (!(features & NETIF_F_ALL_CSUM) &&
> 
> I think also that from (stack) maintenance perspective, less code is better.

I don't think your argument is making much sense.  With the approach we
took the switching only needs to take place in the offloaded path.  If
we were to put the switching in place generically we would end up with
the code scattered all throughout the stack.  In addition we will need
both the inner and outer headers to be captured in the case of an
encapsulated offload because the stack will need access to the outer
headers for routing.

My advice is if you have an idea then please just code it up, test it,
and submit a patch so that we can see what you are talking about.  My
concern is that you are suggesting we come up with a generic network and
transport offset that I don't believe has been completely thought through.

Thanks,

Alex
