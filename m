From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Thu, 16 Aug 2007 17:58:19 +0200
Message-ID: <20070816155819.GE32236@postel.suug.ch>
References: <46A0B017.4080505@st.com> <46A0B6DE.1080904@trash.net> <46A0BF7F.80001@st.com> <46A0BFFF.5020000@trash.net> <46A0DF91.6000508@st.com> <20070723102909.GA9285@postel.suug.ch> <46A4DB34.4040502@st.com> <20070724093558.GB9285@postel.suug.ch> <46A5DDDD.6070602@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Richard MUSIL <richard.musil@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42928 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764821AbXHPP57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 11:57:59 -0400
Content-Disposition: inline
In-Reply-To: <46A5DDDD.6070602@st.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Richard MUSIL <richard.musil@st.com> 2007-07-24 13:09
> Thomas Graf wrote:
> > Please provide a new overall patch which is not based on your
> > initial patch so I can review your idea properly.
> 
> Here it goes (merging two previous patches). I have diffed
> against v2.6.22, which I am using currently as my base:

Sorry for taking so long.

> @@ -150,9 +176,9 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
>  	if (ops->policy)
>  		ops->flags |= GENL_CMD_CAP_HASPOL;
>  
> -	genl_lock();
> +	genl_fam_lock(family);
>  	list_add_tail(&ops->ops_list, &family->ops_list);
> -	genl_unlock();
> +	genl_fam_unlock(family);

For registering operations, it is sufficient to just acquire the
family lock, the family itself can't disappear while holding it.

> @@ -216,8 +242,9 @@ int genl_register_family(struct genl_family *family)
>  		goto errout;
>  
>  	INIT_LIST_HEAD(&family->ops_list);
> +	mutex_init(&family->lock);
>  
> -	genl_lock();
> +	genl_fam_lock(family);
>  
>  	if (genl_family_find_byname(family->name)) {
>  		err = -EEXIST;
> @@ -251,14 +278,14 @@ int genl_register_family(struct genl_family *family)
>  		family->attrbuf = NULL;
>  
>  	list_add_tail(&family->family_list, genl_family_chain(family->id));
> -	genl_unlock();
> +	genl_fam_unlock(family);

This looks good.

> @@ -303,38 +332,57 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>  	struct genlmsghdr *hdr = nlmsg_data(nlh);
>  	int hdrlen, err;
>  
> +	genl_fam_lock(NULL);
>  	family = genl_family_find_byid(nlh->nlmsg_type);
> -	if (family == NULL)
> +	if (family == NULL) {
> +		genl_fam_unlock(NULL);
>  		return -ENOENT;
> +	}
> +
> +	/* get particular family lock, but release global family lock
> +	 * so registering operations for other families are possible */
> +	genl_onefam_lock(family);
> +	genl_fam_unlock(NULL);

I don't like having two locks for something as trivial as this.
Basically the only reason the global lock is required here is to
protect from family removal which can be avoided otherwise by
using RCU list operations.

Therefore, I'd propose the following lock semantics:
Use own global mutex to protect writing to the family list, make
reading side lockless using rcu for use when looking up family
upon mesage processing. Use a family lock to protect writing to
operations list and serialize messae processing with unregister
operations.
