From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH V2] Fix a sleep-in-atomic bug in shash_setkey_unaligned
Date: Tue, 3 Oct 2017 19:45:06 -0300
Message-ID: <20171003224505.GE19750@localhost.localdomain>
References: <1506997522-26684-1-git-send-email-baijiaju1990@163.com>
 <CALCETrWdXjTTTywbb3duCEsLYNxkeGx7bf3SM4PYKeErCyiUNQ@mail.gmail.com>
 <20171003052643.GB22750@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@kernel.org>,
        Jia-Ju Bai <baijiaju1990@163.com>,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>, vyasevich@gmail.com,
        Kalle Valo <kvalo@codeaurora.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org,
        Linux Wireless List <linux-wireless@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171003052643.GB22750@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2017 at 01:26:43PM +0800, Herbert Xu wrote:
> On Mon, Oct 02, 2017 at 09:18:24PM -0700, Andy Lutomirski wrote:
> > > On Oct 2, 2017, at 7:25 PM, Jia-Ju Bai <baijiaju1990@163.com> wrote:
> > >
> > > The SCTP program may sleep under a spinlock, and the function call path is:
> > > sctp_generate_t3_rtx_event (acquire the spinlock)
> > >  sctp_do_sm
> > >    sctp_side_effects
> > >      sctp_cmd_interpreter
> > >        sctp_make_init_ack
> > >          sctp_pack_cookie
> > >            crypto_shash_setkey
> > >              shash_setkey_unaligned
> > >                kmalloc(GFP_KERNEL)
> > 
> > I'm going to go out on a limb here: why on Earth is out crypto API so
> > full of indirection that we allocate memory at all here?
> 
> The crypto API operates on a one key per-tfm basis.  So normally
> tfm allocation and key setting is done once only and not done on
> the data path.
> 
> I have looked at the SCTP code and it appears to fit this paradigm.
> That is, we should be able to allocate the tfm and set the key when
> the key is actually generated via get_random_bytes, rather than every
> time the key is used which is not only a waste but as you see runs
> into API issues.

Fair point, but

> 
> Usually if you're invoking setkey from a non-sleeping code-path
> you're probably doing something wrong.

Usually but not always. There are 3 calls to that function on SCTP
code:
- pack a cookie, which is sent on an INIT_ACK packet to the client
- unpack the cookie above, after it is sent back by the client on a
  COOKIE_ECHO packet
- send a chunk authenticated by a hash

the first two happen during softirq processing, while processing a
packet that was received.

As I explained on the other email, SCTP code is not supposed to store
any information about the peer between the 1st and the 2nd moments
above, to be less vulnerable to DoS attacks (it's planned so by the
RFC), thus why it uses the cookie.

The 3rd one we probably can improve, but I don't think we can do much
about the 2 first ones from the SCTP side.

Note on sctp_sf_do_5_1B_init() how sctp_make_init_ack() is explicitly
called with GFP_ATOMIC, and also on sctp_sf_do_unexpected_init().
Though we can't propagate that to crypto_shash_setkey.

Ideas?

Thanks,
Marcelo

> 
> As someone else noted recently, there is no single forum for
> reviewing code that uses the crypto API so buggy code like this
> is not surprising.
> 
> > We're synchronously computing a hash of a small amount of data using
> > either HMAC-SHA1 or HMAC-SHA256 (determined at runtime) if I read it
> > right.  There's a sane way to do this that doesn't need kmalloc,
> > alloca, or fancy indirection.  And then there's crypto_shash_xyz().
> 
> There are some legitimate cases where you want to use a different
> key for every hashing operation.  But so far these are uses have
> been very few so there has been no need to provide an API for them.
> 
> Cheers,
> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
