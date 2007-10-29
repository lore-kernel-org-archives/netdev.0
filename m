From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 8/8] Use nested compat attributes to pass parameters.
Date: Mon, 29 Oct 2007 00:27:29 -0700
Message-ID: <47258B61.1000901@fatooh.org>
References: <1193642587-32657-1-git-send-email-bugfood-ml@fatooh.org> <1193642587-32657-9-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:50461 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbXJ2H1b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 03:27:31 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id D166317C231
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:27:30 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IDs8zygVmeZj for <netdev@vger.kernel.org>;
	Mon, 29 Oct 2007 02:27:30 -0500 (CDT)
Received: from [10.1.0.0] (c-24-7-71-25.hsd1.ca.comcast.net [24.7.71.25])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id 4E83217C094
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 02:27:30 -0500 (CDT)
In-Reply-To: <1193642587-32657-9-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> +/* SFQ parameters exist as individual rtattr attributes, with a nested
> + * "struct tc_sfq_qopt" for compatibility with older userspace tools. If an
> + * individual attribute is set, we want to use it; otherwise, fall back to the
> + * nested struct.
> + * There is one caveat: if a member of the nested struct is 0, we cannot
> + * determine if that parameter is supposed to be 0 or if it is merely unset.
> + * So, only set a parameter if the corresponding struct member (u32 compat) is
> + * nonzero. When setting a parameter to 0, it is necessary to use the
> + * individual attribute. */
> +static inline int
> +sfq_get_parameter(u32 *dst, struct rtattr *tb[TCA_SFQ_MAX], int attr,
> +		  u32 compat)
> +{
> +	struct rtattr *rta = tb[(attr - 1)];
> +	if (rta)
> +		*dst = RTA_GET_U32(rta);
> +	else if (compat)
> +		*dst = compat;
> +
> +	rtattr_failure:
> +		return -EINVAL;
> +}
> +	
>  static int
>  sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
>  {
> @@ -465,21 +488,24 @@ sfq_q_init(struct sfq_sched_data *q, struct rtattr *opt)
>  	 * the previous values (sfq_change). So, overwrite the parameters as
>  	 * specified. */
>  	if (opt) {
> -		struct tc_sfq_qopt *ctl = RTA_DATA(opt);
> -
> -		if (opt->rta_len < RTA_LENGTH(sizeof(*ctl)))
> -			return -EINVAL;
> -
> -		if (ctl->quantum)
> -			q->quantum = ctl->quantum;
> -		if (ctl->perturb_period)
> -			q->perturb_period = ctl->perturb_period;
> -		if (ctl->divisor)
> -			q->hash_divisor = ctl->divisor;
> -		if (ctl->flows)
> -			q->depth = ctl->flows;
> -		if (ctl->limit)
> -			q->limit = ctl->limit;
> +		struct tc_sfq_qopt *ctl;
> +		struct rtattr *tb[TCA_SFQ_MAX];
> +
> +		if (rtattr_parse_nested_compat(tb, TCA_SFQ_MAX, opt, ctl,
> +				sizeof(*ctl)))
> +			goto rtattr_failure;
> +
> +		if (sfq_get_parameter(&(q->quantum),        tb, TCA_SFQ_QUANTUM,
> +				ctl->quantum)        ||
> +		    sfq_get_parameter(&(q->perturb_period), tb, TCA_SFQ_PERTURB,
> +				ctl->perturb_period) ||
> +		    sfq_get_parameter(&(q->hash_divisor),   tb, TCA_SFQ_DIVISOR,
> +				ctl->divisor)        ||
> +		    sfq_get_parameter(&(q->depth),          tb, TCA_SFQ_FLOWS,
> +				ctl->flows)          ||
> +		    sfq_get_parameter(&(q->limit),          tb, TCA_SFQ_LIMIT,
> +				ctl->limit))
> +			goto rtattr_failure;
>  

You may note that this part ended up being rather ugly, and I wouldn't
blame anyone for wanting it to be improved. I don't see any good
solutions; the alternatives I can provide are:

1. Use a macro, as I had originally written for this patch:
http://marc.info/?l=linux-netdev&m=119102007907626&w=2
(search for GET_PARAM)
The macro itself doesn't look pretty, but the usage is fairly clean.

2. Use neither macro nor function.
There would be five repetitions of very similar code, with five lines
per repetition: not very nice, but the formatting would still look better.

3. Only use a separate rtattr for perturb, since the other parameters
work fine already. From the start, I had wanted to keep parameter
parsing consistent, but it may not be worth it. This would definitely be
the cleanest approach for readability, and the most simple.


Sorry to bother you with such a superficial problem, but I really don't
know what would be preferable.

Thanks,
Corey
