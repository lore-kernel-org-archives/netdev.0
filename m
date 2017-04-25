From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH net] macsec: avoid heap overflow in skb_to_sgvec on receive
Date: Tue, 25 Apr 2017 17:59:34 +0200
Message-ID: <CAHmME9pgnhr=yQZqzr3oXpyVrp7hFAZddTUBX=gy-QY-QMsYtg@mail.gmail.com>
References: <f50ef5b9e525d83938f5e419557abb0307ee023b.1493133423.git.sd@queasysnail.net>
 <CAHmME9rxdTEe1-5ApgUhdkqiJztSgJb0QuhV2uSemobeXm_oNg@mail.gmail.com> <20170425155140.GA13414@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:54711 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1951117AbdDYP7g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 11:59:36 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 9b2a7bb2
        for <netdev@vger.kernel.org>;
        Tue, 25 Apr 2017 15:50:55 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 2ffdb52e (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Tue, 25 Apr 2017 15:50:54 +0000 (UTC)
Received: by mail-oi0-f47.google.com with SMTP id y11so144736707oie.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 08:59:35 -0700 (PDT)
In-Reply-To: <20170425155140.GA13414@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 5:51 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> 2017-04-25, 17:39:09 +0200, Jason A. Donenfeld wrote:
>> Hi Sabrina,
>>
>> I think I may have beaten you to the punch here by a few minutes. :)
>
> I said I was going to post a patch.
> Mail headers seem to disagree with you ;)

Oh, whoops, sorry -- thought you wanted me to. Misread, but happy to
have done it anyway.

> Unless I missed something, encrypt was already handling fragments
> correctly. An skb with ->frag_list should have no skb_tailroom, so it
> will be linearized skb_copy_expand().

You're right. In that case, you might as well add back the FRAGLIST
annotation to the FEATURES, so that packets with frag_lists aren't
copied twice -- once upon linearization into xmit and again when
calling copy_expand in case they need more head or tail space. In
general, too, using the precise number of frags saves memory. But
above all, it seems to me the important thing is that it's very
_clear_ there isn't going to be an overflow, that the code doesn't
rely on so many odd particulars that then get violated later in its
life. Using the explicit length makes things a lot more clear. So
maybe better to go with mine?
