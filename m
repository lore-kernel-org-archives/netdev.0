From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 01/29] fib_trie: Convert fib_alias to hlist from
 list
Date: Wed, 25 Feb 2015 01:09:33 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502250054131.3125@ja.home.ssi.bg>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20> <20150224204801.26106.10186.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53339 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750748AbbBXXJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 18:09:40 -0500
In-Reply-To: <20150224204801.26106.10186.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 24 Feb 2015, Alexander Duyck wrote:

> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 3daf022..e0d44b7 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c

> @@ -1192,8 +1193,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>  		 */
>  		fa_match = NULL;
>  		fa_first = fa;
> -		fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
> -		list_for_each_entry_continue(fa, fa_head, fa_list) {
> +		hlist_for_each_entry_from(fa, fa_list) {
>  			if (fa->fa_tos != tos)
>  				break;
>  			if (fa->fa_info->fib_priority != fi->fib_priority)

	Also, as this loop when implemented as hlist
can exit with fa = NULL we have to use fa_last = fa at
end of loop:

		hlist_for_each_entry_from(fa, fa_list) {
			if (fa->fa_tos != tos)
				break;
			if (fa->fa_info->fib_priority != fi->fib_priority)
				break;
			if (fa->fa_type == cfg->fc_type &&
			    fa->fa_info == fi) {
				fa_match = fa;
				break;
			}
+			fa_last = fa;
		}

	It is needed so that NLM_F_APPEND can work.
Basicly, if list_for_* end with pos pointing to head,
hlist_for_* end with NULL.

Regards

--
Julian Anastasov <ja@ssi.bg>
