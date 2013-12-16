From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] SCTP: Reduce log spamming for sctp setsockopt
Date: Mon, 16 Dec 2013 16:13:59 +0100
Message-ID: <52AF18B7.6050602@redhat.com>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com> <1387206233.18217.21.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753806Ab3LPPOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 10:14:14 -0500
In-Reply-To: <1387206233.18217.21.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 04:03 PM, Joe Perches wrote:
> On Mon, 2013-12-16 at 09:44 -0500, Neil Horman wrote:
>> During a recent discussion regarding some sctp socket options, it was noted that
>> we have several points at which we issue log warnings that can be flooded at an
>> unbounded rate by any user.  Fix this by converting all the pr_warns in the
>> sctp_setsockopt path to be pr_warn_ratelimited.
>
> trivial note:
[...]
>> @@ -5311,8 +5311,8 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
> []
>> +		pr_warn_ratelimited("Use of int in max_burst socket option deprecated\n");
>> +		pr_warn_ratelimited("Use struct sctp_assoc_value instead\n");
>
> Perhaps a dedicated "deprecated" warning function
> to centralize these?
>
> void _sctp_warn_deprecated(const char *func, const char *from, const char *to);
> {
> 	etc.
> }
> #define sctp_warn_deprecated(from, to)		\
> 	_sctp_warn_deprecated(__func__, from, to)

If so, then this should better get even more "centralized" ... as e.g.
pr_warn_deprecated() [which internally is ratelimited]. I don't see the
point why only SCTP should have this special-cased.

> and use
>
> 		sctp_warn_deprecated("struct sctp_assoc_value", "struct sctp_sack_info");
> 		sctp_warn_deprecated("int", "");
> 		sctp_warn_deprecated("int", "struct sctp_assoc_value");
> 		sctp_warn_deprecated("struct sctp_assoc_value", "struct sctp_sack_info");
> 		sctp_warn_deprecated("int", "struct sctp_assoc_value");
> 		sctp_warn_deprecated("int", "struct sctp_assoc_value");
>
