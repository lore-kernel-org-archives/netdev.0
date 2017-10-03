From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH V2] Fix a sleep-in-atomic bug in shash_setkey_unaligned
Date: Tue, 3 Oct 2017 13:26:43 +0800
Message-ID: <20171003052643.GB22750@gondor.apana.org.au>
References: <1506997522-26684-1-git-send-email-baijiaju1990@163.com>
 <CALCETrWdXjTTTywbb3duCEsLYNxkeGx7bf3SM4PYKeErCyiUNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Linux Crypto Mailing List <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CALCETrWdXjTTTywbb3duCEsLYNxkeGx7bf3SM4PYKeErCyiUNQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2017 at 09:18:24PM -0700, Andy Lutomirski wrote:
> > On Oct 2, 2017, at 7:25 PM, Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org> wrote:
> >
> > The SCTP program may sleep under a spinlock, and the function call path is:
> > sctp_generate_t3_rtx_event (acquire the spinlock)
> >  sctp_do_sm
> >    sctp_side_effects
> >      sctp_cmd_interpreter
> >        sctp_make_init_ack
> >          sctp_pack_cookie
> >            crypto_shash_setkey
> >              shash_setkey_unaligned
> >                kmalloc(GFP_KERNEL)
> 
> I'm going to go out on a limb here: why on Earth is out crypto API so
> full of indirection that we allocate memory at all here?

The crypto API operates on a one key per-tfm basis.  So normally
tfm allocation and key setting is done once only and not done on
the data path.

I have looked at the SCTP code and it appears to fit this paradigm.
That is, we should be able to allocate the tfm and set the key when
the key is actually generated via get_random_bytes, rather than every
time the key is used which is not only a waste but as you see runs
into API issues.

Usually if you're invoking setkey from a non-sleeping code-path
you're probably doing something wrong.

As someone else noted recently, there is no single forum for
reviewing code that uses the crypto API so buggy code like this
is not surprising.

> We're synchronously computing a hash of a small amount of data using
> either HMAC-SHA1 or HMAC-SHA256 (determined at runtime) if I read it
> right.  There's a sane way to do this that doesn't need kmalloc,
> alloca, or fancy indirection.  And then there's crypto_shash_xyz().

There are some legitimate cases where you want to use a different
key for every hashing operation.  But so far these are uses have
been very few so there has been no need to provide an API for them.

Cheers,
-- 
Email: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
