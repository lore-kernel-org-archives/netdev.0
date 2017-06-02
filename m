From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: Leak in ipv6_gso_segment()?
Date: Fri, 2 Jun 2017 15:27:41 -0400
Message-ID: <CAEfhGiyR-A6yuR8ZJX6WagHTED1McdLqa0eyA3Hg463xSUzSTA@mail.gmail.com>
References: <1496233562.3992.10.camel@decadent.org.uk> <20170602.140506.1833605091602891315.davem@davemloft.net>
 <CAEfhGizesRT9YOfKs09mbnA+PKnG5i2ERmPNyx_+Z6LZ1_bcFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Ben Hutchings <ben@decadent.org.uk>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:32933 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750918AbdFBT1o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 15:27:44 -0400
Received: by mail-qk0-f171.google.com with SMTP id y201so67121232qka.0
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 12:27:44 -0700 (PDT)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com. [209.85.220.169])
        by smtp.gmail.com with ESMTPSA id p43sm1096986qtg.30.2017.06.02.12.27.42
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 12:27:42 -0700 (PDT)
Received: by mail-qk0-f169.google.com with SMTP id p66so50631609qkf.3
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 12:27:42 -0700 (PDT)
In-Reply-To: <CAEfhGizesRT9YOfKs09mbnA+PKnG5i2ERmPNyx_+Z6LZ1_bcFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 2, 2017 at 2:25 PM, Craig Gallek <kraigatgoog@gmail.com> wrote:
> On Fri, Jun 2, 2017 at 2:05 PM, David Miller <davem@davemloft.net> wrote:
>> From: Ben Hutchings <ben@decadent.org.uk>
>> Date: Wed, 31 May 2017 13:26:02 +0100
>>
>>> If I'm not mistaken, ipv6_gso_segment() now leaks segs if
>>> ip6_find_1stfragopt() fails.  I'm not sure whether the fix would be as
>>> simple as adding a kfree_skb(segs) or whether more complex cleanup is
>>> needed.
>>
>> I think we need to use kfree_skb_list(), like the following.
> I think this is problematic as well.  ipv6_gso_segment could
> previously return errors, in which case the caller uses kfree_skb (ex
> validate_xmit_skb() -> skb_gso_segment -> ...
> callbacks.gso_segment()).  Having the kfree_skb_list here would cause
> a double free if I'm reading this correctly.
>
> My first guess was going to be skb_gso_error_unwind(), but I'm still
> trying to understand that code...
>
> Sorry again for the fallout from this bug fix.  This is my first time
> down this code path and I clearly didn't understand it fully :/

Ok, I take it back.  I believe your kfree_skb_list suggestion is correct.

I was assuming that skb_segment consumed the original skb upon
successful segmentation.  It does not.  This is exactly why
validate_xmit_skb calls consume_skb when segments are returned.
Further, there is at least one existing example of kfree_skb_list in a
similar post-semgent cleanup path (esp6_gso_segment).
