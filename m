From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: add verification checks to SCTP_AUTH_KEY option
Date: Mon, 25 Aug 2008 21:24:41 -0400
Message-ID: <48B35B59.2020208@hp.com>
References: <20080825164440.GA504@kernel.sg> <12196959323990-git-send-email-vladislav.yasevich@hp.com> <48B35561.2010001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, security@kernel.org
To: Eugene Teo <eteo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:26539 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752812AbYHZBYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 21:24:44 -0400
In-Reply-To: <48B35561.2010001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eugene Teo wrote:
> Vlad Yasevich wrote:
>> The structure used for SCTP_AUTH_KEY option contains a
>> length that needs to be verfied to prevent buffer overflow
>> conditions.  Spoted by Eugene Teo <eteo@redhat.com>.
>>
>> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
>> ---
>>  net/sctp/auth.c   |    4 ++++
>>  net/sctp/socket.c |    5 +++++
>>  2 files changed, 9 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/sctp/auth.c b/net/sctp/auth.c
>> index 675a5c3..1fcb4cf 100644
>> --- a/net/sctp/auth.c
>> +++ b/net/sctp/auth.c
>> @@ -80,6 +80,10 @@ static struct sctp_auth_bytes *sctp_auth_create_key(__u32 key_len, gfp_t gfp)
> 
> This should be __u16 key_len.
> 
>>  {
>>  	struct sctp_auth_bytes *key;
>>  
>> +	/* Verify that we are not going to overflow INT_MAX */
>> +	if ((INT_MAX - key_len) < sizeof(struct sctp_auth_bytes))
>> +		return NULL;
> 
> Shouldn't this be UINT_MAX? But then if you are going to change
> sctp_auth_create_key() to accept __u16 key_len, then it should be
> USHORT_MAX.
> 

I'd rather keep it a u32 since this function is not only for userspace,
but for creating a generated key.

Yes, UINT_MAX makes more sense.

>>  	/* Allocate the shared key */
>>  	key = kmalloc(sizeof(struct sctp_auth_bytes) + key_len, gfp);
>>  	if (!key)
>> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
>> index bb5c9ef..afa952e 100644
>> --- a/net/sctp/socket.c
>> +++ b/net/sctp/socket.c
>> @@ -3144,6 +3144,11 @@ static int sctp_setsockopt_auth_key(struct sock *sk,
>>  		goto out;
>>  	}
>>  
>> +	if (authkey->sca_keylength > optlen) {
>> +		ret = -EINVAL;
>> +		goto out;
> 
> Is there a better upper bound check?

Hm...  optlen - sizeof(struct sctp_authkey)  is more accurate.

There is really no other bound.

-vlad

> 
>>  	asoc = sctp_id2assoc(sk, authkey->sca_assoc_id);
>>  	if (!asoc && authkey->sca_assoc_id && sctp_style(sk, UDP)) {
>>  		ret = -EINVAL;
> 
> Thanks,
> Eugene
> 

