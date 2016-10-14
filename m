From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 10:28:19 +0200
Message-ID: <1476433699.31114.6.camel@sipsolutions.net>
References: <20161010150358.GA514@swordfish>
         <20161010153050.GA836@swordfish>
         <1476263106.5271.23.camel@sipsolutions.net>
         <20161012141245.GA436@swordfish>
         <1476282127.5271.30.camel@sipsolutions.net>
         <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
         <1476338524.4904.1.camel@sipsolutions.net> <20161013134252.GA583@swordfish>
         <1476366354.4904.31.camel@sipsolutions.net>
         <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
         (sfid-20161013_235018_225755_5BCF27D2) <1476429916.4382.12.camel@sipsolutions.net>
         (sfid-20161014_092541_208009_922C51BD)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Jouni Malinen <j@w1.fi>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476429916.4382.12.camel@sipsolutions.net> (sfid-20161014_092541_208009_922C51BD)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>    1. revert that patch (doing so would need some major adjustments now,
>       since it's pretty old and a number of new things were added in the
>       meantime)

This it will have to be, I guess.

>    2. allocate a per-CPU buffer for all the things that we put on the
>       stack and use in SG lists, those are:
>        * CCM/GCM: AAD (32B), B_0/J_0 (16B)
>        * GMAC: AAD (20B), zero (16B)
>        * (not sure why CMAC isn't using this API, but it would be like GMAC)

This doesn't work - I tried to move the mac80211 buffers, but because
we also put the struct aead_request on the stack, and crypto_ccm has
the "odata" in there, and we can't separate the odata from that struct,
we'd have to also put that into a per-CPU buffer, but it's very big -
456 bytes for CCM, didn't measure the others but I'd expect them to be
larger, if different.

I don't think we can allocate half a kb for each CPU just to be able to
possibly use the acceleration here. We can't even make that conditional
on not having hardware crypto in the wifi NIC because drivers are
always allowed to pass undecrypted frames, regardless of whether or not
HW crypto was attempted, so we don't know upfront if we'll have to
decrypt anything in software...

Given that, I think we have had a bug in here basically since Ard's
patch, we never should've put these structs on the stack. Herbert, you
also touched this later and converted the API usage, did you see the
way the stack is used here and think it should be OK, or did you simply
not realize that?

Ard, are you able to help out working on a revert of your patch? That
would require also reverting a number of other patches (various fixes,
API adjustments, etc. to the AEAD usage), but the more complicated part
is that in the meantime Jouni introduced GCMP and CCMP-256, both of
which we of course need to retain.

johannes
