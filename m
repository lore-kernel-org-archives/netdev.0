From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: [PATCH 1/6] Security: define security_sk_getsecid.
Date: Wed, 10 Aug 2011 08:43:13 +0800
Message-ID: <4E41D421.1000302@windriver.com>
References: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com> <1312874910-31010-2-git-send-email-rongqing.li@windriver.com> <4E415CB3.8020202@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>, <sds@tycho.nsa.gov>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4E415CB3.8020202@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/10/2011 12:13 AM, Casey Schaufler wrote:
> On 8/9/2011 12:28 AM, rongqing.li@windriver.com wrote:
>> From: Roy.Li<rongqing.li@windriver.com>
>>
>> Define security_sk_getsecid to get the security id of a sock.
>
> Why are you requesting the secid when you're just going to
> use it to get the secctx? Why not ask for that directly?
> Is there ever a case where you only want the secid?
>
Hi:

As I know, we have not method to get secctx directly.
On the most of time, we get secctx like this.

The below comes from kernel/auditsc.c

void audit_log_task_context(struct audit_buffer *ab)
{
         char *ctx = NULL;
         unsigned len;
         int error;
         u32 sid;

         security_task_getsecid(current, &sid);
         if (!sid)
                 return;

         error = security_secid_to_secctx(sid, &ctx, &len);
         if (error) {
                 if (error != -EINVAL)
                         goto error_path;
                 return;
         }

         audit_log_format(ab, " subj=%s", ctx);
         security_release_secctx(ctx, len);
         return;

error_path:
         audit_panic("error in audit_log_task_context");
         return;
}


-Roy


>>
>> Signed-off-by: Roy.Li<rongqing.li@windriver.com>
>> ---
>>   include/linux/security.h |    6 ++++++
>>   security/security.c      |    6 ++++++
>>   2 files changed, 12 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/security.h b/include/linux/security.h
>> index ebd2a53..739ac39 100644
>> --- a/include/linux/security.h
>> +++ b/include/linux/security.h
>> @@ -2560,6 +2560,7 @@ int security_sk_alloc(struct sock *sk, int family, gfp_t priority);
>>   void security_sk_free(struct sock *sk);
>>   void security_sk_clone(const struct sock *sk, struct sock *newsk);
>>   void security_sk_classify_flow(struct sock *sk, struct flowi *fl);
>> +void security_sk_getsecid(struct sock *sk, u32 *secid);
>>   void security_req_classify_flow(const struct request_sock *req, struct flowi *fl);
>>   void security_sock_graft(struct sock*sk, struct socket *parent);
>>   int security_inet_conn_request(struct sock *sk,
>> @@ -2701,6 +2702,11 @@ static inline void security_sk_classify_flow(struct sock *sk, struct flowi *fl)
>>   {
>>   }
>>
>> +static inline void security_sk_getsecid(struct sock *sk, u32 *secid)
>> +{
>> +	*secid = 0;
>> +}
>> +
>>   static inline void security_req_classify_flow(const struct request_sock *req, struct flowi *fl)
>>   {
>>   }
>> diff --git a/security/security.c b/security/security.c
>> index 0e4fccf..b0e0825 100644
>> --- a/security/security.c
>> +++ b/security/security.c
>> @@ -1104,6 +1104,12 @@ void security_sk_classify_flow(struct sock *sk, struct flowi *fl)
>>   }
>>   EXPORT_SYMBOL(security_sk_classify_flow);
>>
>> +void security_sk_getsecid(struct sock *sk, u32 *secid)
>> +{
>> +	security_ops->sk_getsecid(sk, secid);
>> +}
>> +EXPORT_SYMBOL(security_sk_getsecid);
>> +
>>   void security_req_classify_flow(const struct request_sock *req, struct flowi *fl)
>>   {
>>   	security_ops->req_classify_flow(req, fl);
>
>

-- 
Best Reagrds,
Roy | RongQing Li
