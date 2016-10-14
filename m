From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Fri, 14 Oct 2016 09:25:16 +0200
Message-ID: <1476429916.4382.12.camel@sipsolutions.net>
References: <20161010150358.GA514@swordfish>
         <20161010153050.GA836@swordfish>
         <1476263106.5271.23.camel@sipsolutions.net>
         <20161012141245.GA436@swordfish>
         <1476282127.5271.30.camel@sipsolutions.net>
         <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
         <1476338524.4904.1.camel@sipsolutions.net> <20161013134252.GA583@swordfish>
         <1476366354.4904.31.camel@sipsolutions.net>
         <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com>
         (sfid-20161013_235018_225755_5BCF27D2)
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
        Ard Biesheuvel <ard.biesheuvel@linaro.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <CALCETrW8imkGTtR9-mFB=e=Gdr1QXVuhXN3GRs2B6wbmPaaGhA@mail.gmail.com> (sfid-20161013_235018_225755_5BCF27D2)
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-10-13 at 14:49 -0700, Andy Lutomirski wrote:
> 
> It's failing before that.  With CONFIG_VMAP_STACK=y, the stack may
> not be physically contiguous and can't be used for DMA, so putting it
> in a scatterlist is bogus in general, and the crypto code mostly
> wants a scatterlist.

I see, so all this stuff is getting inlined, and we crash in
sg_set_buf() because it does sg_set_page() and that obviously needs to
do virt_to_page(), which is invalid on this address now.
With CONFIG_DEBUG_SG we'd have hit the BUG_ON there instead.

It does indeed look like AEAD doesn't have any non-SG API.

So ultimately, the bug already goes back to Ard's commit 7ec7c4a9a686
("mac80211: port CCMP to cryptoapi's CCM driver") since that already
potentially used stack space for DMA.

Since we don't have any space in the SKB or anywhere else at this point
(other than the stack that we can't use), I see two ways out of this:

   1. revert that patch (doing so would need some major adjustments now,
      since it's pretty old and a number of new things were added in the
      meantime)
   2. allocate a per-CPU buffer for all the things that we put on the
      stack and use in SG lists, those are:
       * CCM/GCM: AAD (32B), B_0/J_0 (16B)
       * GMAC: AAD (20B), zero (16B)
       * (not sure why CMAC isn't using this API, but it would be like
      GMAC)

Thoughts?

johannes
