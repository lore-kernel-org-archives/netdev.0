From: Richard MUSIL <richard.musil@st.com>
Subject: Re: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Fri, 17 Aug 2007 10:38:59 +0200
Message-ID: <46C55EA3.9060204@st.com>
References: <46A0B017.4080505@st.com> <46A0B6DE.1080904@trash.net> <46A0BF7F.80001@st.com> <46A0BFFF.5020000@trash.net> <46A0DF91.6000508@st.com> <20070723102909.GA9285@postel.suug.ch> <46A4DB34.4040502@st.com> <20070724093558.GB9285@postel.suug.ch> <46A5DDDD.6070602@st.com> <20070816155819.GE32236@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s200aog12.obsmtp.com ([207.126.144.126]:50936 "EHLO
	s200aog12.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056AbXHQIjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 04:39:25 -0400
In-Reply-To: <20070816155819.GE32236@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
>> @@ -150,9 +176,9 @@ int genl_register_ops(struct genl_family *family, struct genl_ops *ops)
>>  	if (ops->policy)
>>  		ops->flags |= GENL_CMD_CAP_HASPOL;
>>  
>> -	genl_lock();
>> +	genl_fam_lock(family);
>>  	list_add_tail(&ops->ops_list, &family->ops_list);
>> -	genl_unlock();
>> +	genl_fam_unlock(family);
> 
> For registering operations, it is sufficient to just acquire the
> family lock, the family itself can't disappear while holding it.

I agree.

>> @@ -303,38 +332,57 @@ static int genl_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
>>  	struct genlmsghdr *hdr = nlmsg_data(nlh);
>>  	int hdrlen, err;
>>  
>> +	genl_fam_lock(NULL);
>>  	family = genl_family_find_byid(nlh->nlmsg_type);
>> -	if (family == NULL)
>> +	if (family == NULL) {
>> +		genl_fam_unlock(NULL);
>>  		return -ENOENT;
>> +	}
>> +
>> +	/* get particular family lock, but release global family lock
>> +	 * so registering operations for other families are possible */
>> +	genl_onefam_lock(family);
>> +	genl_fam_unlock(NULL);
> 
> I don't like having two locks for something as trivial as this.
> Basically the only reason the global lock is required here is to
> protect from family removal which can be avoided otherwise by
> using RCU list operations.
> 
> Therefore, I'd propose the following lock semantics:
> Use own global mutex to protect writing to the family list, make
> reading side lockless using rcu for use when looking up family
> upon mesage processing. Use a family lock to protect writing to
> operations list and serialize messae processing with unregister
> operations.

I was not aware of RCU lists, but after looking at them, I consider your
proposal to be better. I guess, you would rather write the patch
yourself, so I will wait.

Thanks for help,
Richard
