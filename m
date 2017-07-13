From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: don't dereference ptr before leaving
 _sctp_walk_{params,errors}()
Date: Thu, 13 Jul 2017 11:32:06 -0700 (PDT)
Message-ID: <20170713.113206.177363709000549854.davem@davemloft.net>
References: <20170713181034.41123-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        lucien.xin@gmail.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170713181034.41123-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Thu, 13 Jul 2017 20:10:34 +0200

> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index a9519a06a23b..f13632ee33f0 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -469,6 +469,7 @@ _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
>  
>  #define _sctp_walk_params(pos, chunk, end, member)\
>  for (pos.v = chunk->member;\
> +     pos.v < (void *)chunk + end &&\
>       pos.v <= (void *)chunk + end - ntohs(pos.p->length) &&\
>       ntohs(pos.p->length) >= sizeof(struct sctp_paramhdr);\
>       pos.v += SCTP_PAD4(ntohs(pos.p->length)))
> @@ -479,6 +480,7 @@ _sctp_walk_errors((err), (chunk_hdr), ntohs((chunk_hdr)->length))
>  #define _sctp_walk_errors(err, chunk_hdr, end)\
>  for (err = (sctp_errhdr_t *)((void *)chunk_hdr + \
>  	    sizeof(struct sctp_chunkhdr));\
> +     (void *)err <= (void *)chunk_hdr + end &&\
>       (void *)err <= (void *)chunk_hdr + end - ntohs(err->length) &&\
>       ntohs(err->length) >= sizeof(sctp_errhdr_t); \
>       err = (sctp_errhdr_t *)((void *)err + SCTP_PAD4(ntohs(err->length))))

Even with the "err < ..." fixed in the second hunk, I still think you need
to tweak these checks some more.

What is necessary is that the first two members of sctp_paramhdr or
sctp_errhdr are in the range ptr to end.

struct sctp_paramhdr {
	__be16 type;
	__be16 length;
};

typedef struct sctp_errhdr {
	__be16 cause;
	__be16 length;
	__u8  variable[0];
} sctp_errhdr_t;

so that we can legally dereference ->length.

But that is not what your new check is doing.  Your new check is only
making sure there is at least one byte there.

I guess it's not easy to write a clean test that doesn't hardcode the
offset of the length field and it's size.

Something like:

	pos.v + offsetof(pos.v, length) + sizeof(pos.v->length) <= (void *) chunk + end

and

	(void *)err + offsetof(err, length) + sizeof(err->length) <= (void *) chunk_hdr + end

And yeah, that isn't exactly concise nor pretty...
