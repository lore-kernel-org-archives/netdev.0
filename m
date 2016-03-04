From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 3/3] net: Use l3_dev instead of skb->dev for L3 processing
Date: Fri, 4 Mar 2016 14:12:31 -0800
Message-ID: <CAF2d9jg2ioCsRa+FHUnwEYSXmqszd6h8MFOcWpWaT4ikaUKc0w@mail.gmail.com>
References: <1456783704-18746-1-git-send-email-mahesh@bandewar.net>
 <CAM_iQpXmoSZhNw+CCbFw5b6Dzq4W+vt5WH8FmRc1ZiuJgv1xnQ@mail.gmail.com>
 <CAF2d9jhopDVGxsSM3wfYh2XgENebJNbEOn9D7Vb8t13bQ7dRcQ@mail.gmail.com>
 <CAF2d9jiyjThgeQKw==tKRk3Sh0dNfzUdwJciwsVGPFLdb9uGTA@mail.gmail.com>
 <CAM_iQpUB_b3S_Mi8QyzhX_XBog3+ZshY8xbSby5eUytnG2OQRg@mail.gmail.com>
 <CAF2d9jhgoWeZdPkM-aev6j9a8OjUQ78CbE7dgp1wPXu91qp_-A@mail.gmail.com> <CAM_iQpVoRuWgk6_x-MWj=A520XjpC3e2QoPspQG6pfd--+m=KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:33527 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758796AbcCDWMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 17:12:52 -0500
Received: by mail-yw0-f181.google.com with SMTP id b72so52845905ywe.0
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 14:12:51 -0800 (PST)
In-Reply-To: <CAM_iQpVoRuWgk6_x-MWj=A520XjpC3e2QoPspQG6pfd--+m=KA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 4, 2016 at 9:30 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Thu, Mar 3, 2016 at 5:42 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>>>>> As you mentioned logically we should be able to pass the skb in master's
>>>>> ns
>>>>> until L3 processing is completed. This patch series attempts to do that by
>>>>> disassociating this logic from skb->dev and adding it to l3_dev. This
>>>>> should
>>>>> include not just IPT but all that is done in L3 phase (IPT, routing etc.)
>>>>> Also since dev->l3_dev is same as dev, this should not break any existing
>>>>> logic.
>>>>>
>>>> Well, looking at the code I realized that I missed few places (especially
>>>> routing
>>>> logic) which continues using skb->dev in ingress path and should be
>>>> corrected to
>>>> use l3_dev. I'll correct those places and send the next version.
>>>
>>>
>>> Look, even you yourself are missing something here. ;) This is exactly why
>>> I suggest to consider another approach. Please don't introduce any code
>>> that is hard to debug even for yourself. The struct net pointer is passed
>>> around in kernel network subsystem almost everywhere, it is not easy to make
>>> it bug-free by just switching skb->dev.
>>>
>> I disagree. Conceptually this is very easy to understand as we are taking L3
>> processing off of skb->dev and loading it onto dev->l3_dev. So
>> everything that is
>> associated with l3_dev is for L3. This should neither make debugging harder
>> nor add complicated code.
>
> Nope, conceptually it is not right, that breaks _isolation_ in
> concept, we need to
> make each skb really traverse in the original stack, not just
> switching skb->dev,
> that is cheating. It is just too easy to hide bugs in your way, we
> never use network
> namespace in this way before.

Unfortunately we don't have a way to switch to ns after L3 processing.
So I would
argue it the other-way around. The way it is now; breaks the _isolation_ model.
If the default-ns is responsible for whole L3 (in this situation) and
it does pretty well
on egress but there is no way to do that in ingress path. IPtables is
not the only thing,
how about routing, how about IPsec? None of this will function well.
So we need to
have a generic solution to solve all these problems.
