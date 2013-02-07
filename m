From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] net: sctp: sctp_auth_make_key_vector: remove
 duplicate ntohs calls
Date: Thu, 07 Feb 2013 10:06:37 -0500
Message-ID: <5113C2FD.4060103@gmail.com>
References: <cover.1360237025.git.dborkman@redhat.com> <c029f55f4d0bde790f77f62d623f4d1e387c4c0b.1360237025.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f51.google.com ([209.85.212.51]:38093 "EHLO
	mail-vb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758377Ab3BGPGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 10:06:41 -0500
In-Reply-To: <c029f55f4d0bde790f77f62d623f4d1e387c4c0b.1360237025.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2013 06:41 AM, Daniel Borkmann wrote:
> Instead of calling 3 times ntohs(random->param_hdr.length), 2 times
> ntohs(hmacs->param_hdr.length), and 3 times ntohs(chunks->param_hdr.length)
> within the same function, we only call each once and store it in a
> variable.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad

> ---
>   net/sctp/auth.c | 21 ++++++++++++---------
>   1 file changed, 12 insertions(+), 9 deletions(-)
>
> diff --git a/net/sctp/auth.c b/net/sctp/auth.c
> index 159b9bc..94a12de 100644
> --- a/net/sctp/auth.c
> +++ b/net/sctp/auth.c
> @@ -200,10 +200,14 @@ static struct sctp_auth_bytes *sctp_auth_make_key_vector(
>   	struct sctp_auth_bytes *new;
>   	__u32	len;
>   	__u32	offset = 0;
> +	__u16	random_len, hmacs_len, chunks_len = 0;
>
> -	len = ntohs(random->param_hdr.length) + ntohs(hmacs->param_hdr.length);
> -        if (chunks)
> -		len += ntohs(chunks->param_hdr.length);
> +	random_len = ntohs(random->param_hdr.length);
> +	hmacs_len = ntohs(hmacs->param_hdr.length);
> +	if (chunks)
> +		chunks_len = ntohs(chunks->param_hdr.length);
> +
> +	len = random_len + hmacs_len + chunks_len;
>
>   	new = kmalloc(sizeof(struct sctp_auth_bytes) + len, gfp);
>   	if (!new)
> @@ -211,16 +215,15 @@ static struct sctp_auth_bytes *sctp_auth_make_key_vector(
>
>   	new->len = len;
>
> -	memcpy(new->data, random, ntohs(random->param_hdr.length));
> -	offset += ntohs(random->param_hdr.length);
> +	memcpy(new->data, random, random_len);
> +	offset += random_len;
>
>   	if (chunks) {
> -		memcpy(new->data + offset, chunks,
> -			ntohs(chunks->param_hdr.length));
> -		offset += ntohs(chunks->param_hdr.length);
> +		memcpy(new->data + offset, chunks, chunks_len);
> +		offset += chunks_len;
>   	}
>
> -	memcpy(new->data + offset, hmacs, ntohs(hmacs->param_hdr.length));
> +	memcpy(new->data + offset, hmacs, hmacs_len);
>
>   	return new;
>   }
>
