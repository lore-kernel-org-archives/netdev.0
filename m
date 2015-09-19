From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2] geneve: remove use of internal IP header when calling IP_ECN_decapsulate
Date: Fri, 18 Sep 2015 19:19:47 -0700
Message-ID: <CAEP_g=-qUK7XGuBMNAP_deV+_iYrdPRaJooeVMtiUhDW8JCqXw@mail.gmail.com>
References: <1442510271-10110-1-git-send-email-linville@tuxdriver.com>
 <1442522094-876-1-git-send-email-linville@tuxdriver.com> <CAEP_g=-EGH-hfCRYQ8WStY2btq=1g-y=g=PvC_e-aC8QZKugJA@mail.gmail.com>
 <20150918204023.GD18191@tuxdriver.com> <CAEP_g=_aDApp8+Uj8JOpg=jzxEs73XzSufgWzA-ODpfXS-ss-Q@mail.gmail.com>
 <20150919013638.GF18191@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:34463 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbbISCUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 22:20:09 -0400
Received: by lahg1 with SMTP id g1so40479258lah.1
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 19:20:07 -0700 (PDT)
In-Reply-To: <20150919013638.GF18191@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 18, 2015 at 6:36 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> On Fri, Sep 18, 2015 at 02:49:30PM -0700, Jesse Gross wrote:
>> On Fri, Sep 18, 2015 at 1:40 PM, John W. Linville
>> <linville@tuxdriver.com> wrote:
>> > On Fri, Sep 18, 2015 at 01:30:36PM -0700, Jesse Gross wrote:
>> >> On Thu, Sep 17, 2015 at 1:34 PM, John W. Linville
>> >> <linville@tuxdriver.com> wrote:
>> >> > This seems to have been a "thinko".  IP_ECN_decapsulate needs info
>> >> > from both internal and external headers.
>> >> >
>> >> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
>> >>
>> >> This looks good to me although I realized that the transmit path is
>> >> also conditional based on !collect_md metadata. I suppose that means
>> >> that this difference is intentional and I guess I could see arguments
>> >> either way but I still think it is better to be consistent across
>> >> different code paths in this respect.
>> >
>> > I'm happy with the v2 patch if you are. :-)
>>
>> I'm happy with this part of the code path after this patch. However,
>> my concern was that this patch, while correct, will make receive
>> inconsistent with transmit. Presumably we should update the transmit
>> side as well.
>
> Oh, sorry -- I missed your point.  You mean something like this?
>
> @@ -812,19 +815,16 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev)
>                 if (unlikely(err))
>                         goto err;
>
> -               tos = key->tos;
> +               tos = ip_tunnel_ecn_encap(key->tos, iip, skb);
>                 ttl = key->ttl;
>                 df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
>
> Am I understanding now?

Yes, essentially though I think that 'iip' is only defined in the
latter half of the if statement and it might be nice to have the ECN
encapsulation called only once before udp_tunnel_xmit_skb() rather
than independently in each code path.
