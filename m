From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] netlink: don't compare the nul-termination in nla_strcmp
Date: Mon, 31 Mar 2014 20:25:52 +0100
Message-ID: <20140331192552.GB11670@casper.infradead.org>
References: <1396280048-3740-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fw@strlen.de
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33539 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaCaTZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 15:25:54 -0400
Content-Disposition: inline
In-Reply-To: <1396280048-3740-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/14 at 05:34pm, Pablo Neira Ayuso wrote:
> nla_strcmp compares the string length plus one, so it's implicitly
> including the nul-termination in the comparison.
> 
>  int nla_strcmp(const struct nlattr *nla, const char *str)
>  {
>         int len = strlen(str) + 1;
>         ...
>                 d = memcmp(nla_data(nla), str, len);
> 
> However, if NLA_STRING is used, userspace can send us a string without
> the nul-termination. This is a problem since the string
> comparison will not match as the last byte may be not the
> nul-termination.
> 
> Fix this by skipping the comparison of the nul-termination if the
> attribute data is nul-terminated. Suggested by Thomas Graf.
> 
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  lib/nlattr.c |   10 ++++++++--
>  1 file changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/nlattr.c b/lib/nlattr.c
> index 18eca78..53beba5 100644
> --- a/lib/nlattr.c
> +++ b/lib/nlattr.c
> @@ -303,9 +303,15 @@ int nla_memcmp(const struct nlattr *nla, const void *data,
>   */
>  int nla_strcmp(const struct nlattr *nla, const char *str)
>  {
> -	int len = strlen(str) + 1;
> -	int d = nla_len(nla) - len;
> +	int len = strlen(str);
> +	char *buf = nla_data(nla);
> +	int attrlen = nla_len(nla);
> +	int d;
>  
> +	if (buf[attrlen - 1] == '\0')
> +		attrlen--;

Perhaps check for attrlen > 0? It should never happen if the
attribute has been validated against NLA_STRING or
NLA_NUL_STRING but not all attributes get validated.
