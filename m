From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: [PATCH 1/5] Define the function to write sock's security context
 to seq_file.
Date: Mon, 8 Aug 2011 17:32:48 +0800
Message-ID: <4E3FAD40.1020404@windriver.com>
References: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>	 <1312534686-4099-2-git-send-email-rongqing.li@windriver.com> <1312552618.19283.51.camel@moss-pluto>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	lsm <linux-security-module@vger.kernel.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1312552618.19283.51.camel@moss-pluto>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/05/2011 09:56 PM, Stephen Smalley wrote:
> On Fri, 2011-08-05 at 16:58 +0800, rongqing.li@windriver.com wrote:
>> From: Roy.Li<rongqing.li@windriver.com>
>>
>> This function will write the sock's security context to a seq_file
>> and return the error code, and the number of characters successfully
>> written is written in int pointers parameter.
>>
>> This function will be called when export socket information to proc.
>>
>> Signed-off-by: Roy.Li<rongqing.li@windriver.com>
>> ---
>>   include/net/sock.h |    1 +
>>   net/core/sock.c    |   26 ++++++++++++++++++++++++++
>>   2 files changed, 27 insertions(+), 0 deletions(-)
>
>> diff --git a/net/core/sock.c b/net/core/sock.c
>> index bc745d0..1126a49 100644
>> --- a/net/core/sock.c
>> +++ b/net/core/sock.c
>> @@ -2254,6 +2254,32 @@ void sk_common_release(struct sock *sk)
>>   }
>>   EXPORT_SYMBOL(sk_common_release);
>>
>> +int sock_write_secctx(struct sock *sk, struct seq_file *seq, int *len)
>> +{
>> +	struct flowi fl;
>> +	char *ctx = NULL;
>> +	u32 ctxlen;
>> +	int res = 0;
>> +
>> +	*len = 0;
>> +
>> +	if (sk == NULL)
>> +		return -EINVAL;
>
> Is this ever possible?
>
Hi Stephen:

When output the tcp information to proc by tcp4_seq_show and
tcp state is TCP_SEQ_STATE_TIME_WAIT, the input argument v is
struct inet_timewait_sock, it seem we can not get the struct sock
from struct inet_timewait_sock, so I assume the sk is NULL in that
condition.

static int tcp4_seq_show(struct seq_file *seq, void *v)
{

        case TCP_SEQ_STATE_TIME_WAIT:
                 get_timewait4_sock(v, seq, st->num, &len);
                 break;
         }
}


>> +	res = security_socket_getsockname(sk->sk_socket);
>> +	if (res)
>> +		return res;
>
> I'm not sure it is a good idea to output nothing if permission is denied
> to the socket, as opposed to some well-defined string indicating that
> condition.  Particularly if someone later adds another field to
> the /proc files after the context; we don't want the contents of that
> field to be interpreted as the context if permission was denied.
>

 From your review, I redesign the output information as below.

when disable SELinux, print "(none)" in proc
when enable  SELinux, no error on getting security context, print the 
real security context
when enable  SELinux, there is error on getting security context, print 
"??"

Do you think it is OK?

Thanks very much

-Roy

>> +
>> +	security_sk_classify_flow(sk,&fl);
>> +
>> +	res = security_secid_to_secctx(fl.flowi_secid,&ctx,&ctxlen);
>> +	if (res)
>> +		return res;
>
> Likewise, if we couldn't map the secid to a secctx for some reason, we
> likely ought to output some well-defined string indicating that
> condition.
>
>> +
>> +	seq_printf(seq, " %s%n", ctx, len);
>> +	security_release_secctx(ctx, ctxlen);
>> +	return res;
>> +}
>> +
>>   static DEFINE_RWLOCK(proto_list_lock);
>>   static LIST_HEAD(proto_list);
>>
>

-- 
Best Reagrds,
Roy | RongQing Li
