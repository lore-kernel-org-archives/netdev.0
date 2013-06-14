From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: sctp: sctp_seq_dump_local_addrs: throw
 BUG if primary_path is NULL
Date: Fri, 14 Jun 2013 10:33:08 -0400
Message-ID: <51BB29A4.7090106@gmail.com>
References: <1371139463-12512-1-git-send-email-dborkman@redhat.com> <1371139463-12512-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f179.google.com ([209.85.128.179]:35383 "EHLO
	mail-ve0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884Ab3FNOdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 10:33:11 -0400
In-Reply-To: <1371139463-12512-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/13/2013 12:04 PM, Daniel Borkmann wrote:
> This clearly states a BUG somewhere in the SCTP code as e.g. fixed once
> in f28156335 ("sctp: Use correct sideffect command in duplicate cookie
> handling"). If this ever comes up again, throw a BUG and add a comment
> why this is the case since it is not too obvious when primary != NULL
> test passes and at a later point in time triggering a NULL ptr dereference
> caused by primary. While at it, also fix up the white space.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>   net/sctp/proc.c | 15 ++++++++++++---
>   1 file changed, 12 insertions(+), 3 deletions(-)
>
> diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> index 4e45ee3..f171366 100644
> --- a/net/sctp/proc.c
> +++ b/net/sctp/proc.c
> @@ -134,9 +134,18 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
>   	struct sctp_af *af;
>
>   	if (epb->type == SCTP_EP_TYPE_ASSOCIATION) {
> -	    asoc = sctp_assoc(epb);
> -	    peer = asoc->peer.primary_path;
> -	    primary = &peer->saddr;
> +		asoc = sctp_assoc(epb);
> +		peer = asoc->peer.primary_path;
> +
> +		/* There must be no such case where an association is linked
> +		 * into sctp_assoc_hashtable that does not have a primary
> +		 * path! This means either sctp_association_free() was called
> +		 * without sctp_unhash_established(), or somewhere in the
> +		 * interpreter SCTP_CMD_ASOC_NEW was called on a non-fully
> +		 * set up association. So do hara-kiri until this is fixed.
> +		 */
> +		BUG_ON(peer == NULL);
> +		primary = &peer->saddr;

I am still trying to convince myself whether this BUG_ON() is the right 
thing to do...

The fact that we reached this association may not necessarily help in 
diagnosing how we managed that and what might be going on.  Also 
crashing the system just because someone read /proc is a bit of an
overkill, especially considering that the system might have stayed up
if the user did not read /proc.

One thought I had was to change the above into something like this:
	if (peer == NULL) {
		WARN(1, "Association %p with NULL primary path", asoc);
		return;
	}

And add the following to handler for SCTP_CMD_NEW_ASOC and may be also 
to sctp_cmd_delete_tcb()

	BUG_ON(asoc->peer.primary_path == NULL);

This way, we would bug on additional and removal paths which have the
possibility of giving us a lot more information about why the condition
occurred in the first place.

-vlad



>   	}
>
>   	rcu_read_lock();
>
