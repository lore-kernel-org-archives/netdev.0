From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: integer overflow in sctp_auth_create_key()
Date: Mon, 28 Nov 2011 10:45:01 -0500
Message-ID: <4ED3AC7D.6090108@hp.com>
References: <426D7BA8-ECD0-44D6-A09F-2033F0C825FC@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: Xi Wang <xi.wang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <426D7BA8-ECD0-44D6-A09F-2033F0C825FC@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/22/2011 08:25 PM, Xi Wang wrote:
> The previous commit 30c2235c is incomplete and cannot prevent integer
> overflows. For example, when key_len is 0x80000000 (INT_MAX + 1), the
> left-hand side of the check, (INT_MAX - key_len), which is unsigned,
> becomes 0xffffffff (UINT_MAX) and bypasses the check.
> 
> Signed-off-by: Xi Wang <xi.wang@gmail.com>
> ---
>  net/sctp/auth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sctp/auth.c b/net/sctp/auth.c
> index 865e68f..989e0fd 100644
> --- a/net/sctp/auth.c
> +++ b/net/sctp/auth.c
> @@ -82,7 +82,7 @@ static struct sctp_auth_bytes *sctp_auth_create_key(__u32 key_len, gfp_t gfp)
>  	struct sctp_auth_bytes *key;
>  
>  	/* Verify that we are not going to overflow INT_MAX */
> -	if ((INT_MAX - key_len) < sizeof(struct sctp_auth_bytes))
> +	if (key_len > INT_MAX - sizeof(struct sctp_auth_bytes))
>  		return NULL;
>  
>  	/* Allocate the shared key */


Hmm.  Yes, this is a more correct check.

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>


However, I don't think this is a security issue.  As I've written before, this function is
called from 2 places:

  1) setsockopt() code path

  2) sctp_auth_asoc_set_secret() code path

In case (1), sca_keylength is never going to exceed 65535 since it's
bounded by a u16 from the user api.  As such, The integer promotion will
not impact anything and the malloc() will never overflow.

In case (2), sca_keylength is computed based on the key the user provided
(MAX_USHORT) and the combination of protocol negotiated data where that
combination has a max size of 3 * MAX_USHORT (see sctp_auth_make_key_vector()).
So, even this case, our maximum key length can be 4* MAX_USHORT which still
will always be below MAX_INT and will not overflow.

So, I don't think there is big security consideration here, just a bad
check that just happens to always work.

-vlad
