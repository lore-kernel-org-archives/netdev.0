From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: rxrpc: Replace time_t type with time64_t type
Date: Wed, 9 Aug 2017 11:01:17 +0200
Message-ID: <CAK8P3a2WU5uYddGrkWhyfNB4qTEDYne_pyCVG6n5b1w+vb1-OQ@mail.gmail.com>
References: <cover.1502246501.git.baolin.wang@linaro.org> <8ac57c96bf5a0695ecc67fd230440b0b9d15740f.1502246502.git.baolin.wang@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Howells <dhowells@redhat.com>,
        David Miller <davem@davemloft.net>, james.l.morris@oracle.com,
        "Serge E. Hallyn" <serge@hallyn.com>, marc.dionne@auristor.com,
        Dan Carpenter <dan.carpenter@oracle.com>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Mark Brown <broonie@kernel.org>, keyrings@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        Networking <netdev@vger.kernel.org>
To: Baolin Wang <baolin.wang@linaro.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <8ac57c96bf5a0695ecc67fd230440b0b9d15740f.1502246502.git.baolin.wang@linaro.org>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 9, 2017 at 4:51 AM, Baolin Wang <baolin.wang@linaro.org> wrote:

> diff --git a/include/keys/rxrpc-type.h b/include/keys/rxrpc-type.h
> index 5de0673..76421e2 100644
> --- a/include/keys/rxrpc-type.h
> +++ b/include/keys/rxrpc-type.h
> @@ -127,4 +127,25 @@ struct rxrpc_key_data_v1 {
>  #define AFSTOKEN_K5_ADDRESSES_MAX      16      /* max K5 addresses */
>  #define AFSTOKEN_K5_AUTHDATA_MAX       16      /* max K5 pieces of auth data */
>
> +/*
> + * truncate a time64_t to the range from 1970 to 2106 as
> + * in the network protocol
> + */
> +static inline u32 rxrpc_time64_to_u32(time64_t time)
> +{
> +       if (time < 0)
> +               return 0;
> +
> +       if (time > UINT_MAX)
> +               return UINT_MAX;
> +
> +       return (u32)time;
> +}
>+
> +/* extend u32 back to time64_t using the same 1970-2106 range */
> +static inline time64_t rxrpc_u32_to_time64(u32 time)
> +{
> +       return (time64_t)time;
> +}

When reviewing this, I could not find any clear definition on whether
the preparse functions should treat this as a signed or unsigned
32-bit number. The function as defined here documents as an unsigned
as that is more useful (it pushes out the last day this works from year
2038 to 2106) and matches the existing behavior that we got on
64-bit architectures (intentionally or not).

> @@ -433,6 +435,7 @@ static int rxrpc_preparse_xdr_rxk5(struct key_preparsed_payload *prep,
>         struct rxrpc_key_token *token, **pptoken;
>         struct rxk5_key *rxk5;
>         const __be32 *end_xdr = xdr + (toklen >> 2);
> +       time64_t expiry;
>         int ret;
>
>         _enter(",{%x,%x,%x,%x},%u",
> @@ -533,8 +536,9 @@ static int rxrpc_preparse_xdr_rxk5(struct key_preparsed_payload *prep,
>              pptoken = &(*pptoken)->next)
>                 continue;
>         *pptoken = token;
> -       if (token->kad->expiry < prep->expiry)
> -               prep->expiry = token->kad->expiry;
> +       expiry = rxrpc_u32_to_time64(token->kad->expiry);
> +       if (expiry < prep->expiry)
> +               prep->expiry = expiry;
>
>         _leave(" = 0");
>         return 0;

I'm still slightly puzzled by what this function does: it does have
four timestamps
(authtime, starttime, endtime, renew_till) that are all transferred as
64-bit values
and won't expire, but then it also uses the 32-bit expiry field in
rxrpc_key_token->kad->expiry instead of the 64-bit rxrpc_key_token->k5
fields.

This appears to overlay the first 32 bits of the rxrpc_key_token->k5->starttime
field, which is also a time value on little-endian architectures by chance,
but I would assume that it's always in the past, meaning the keys would
already be expired. Any idea what is the intended behavior here?

       Arnd
