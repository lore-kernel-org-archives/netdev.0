From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH net] bpf: fix states equal logic for varlen access
Date: Tue, 29 Nov 2016 09:45:33 -0500
Message-ID: <db0d1d81-b497-4f95-48c1-87f5f52a906e@fb.com>
References: <1480362250-2132-1-git-send-email-jbacik@fb.com>
 <20161129030446.GA13735@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <daniel@iogearbox.net>, <ast@kernel.org>, <jannh@google.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53527 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757299AbcK2OqE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 09:46:04 -0500
In-Reply-To: <20161129030446.GA13735@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 10:04 PM, Alexei Starovoitov wrote:
> On Mon, Nov 28, 2016 at 02:44:10PM -0500, Josef Bacik wrote:
>> If we have a branch that looks something like this
>>
>> int foo = map->value;
>> if (condition) {
>>   foo += blah;
>> } else {
>>   foo = bar;
>> }
>> map->array[foo] = baz;
>>
>> We will incorrectly assume that the !condition branch is equal to the condition
>> branch as the register for foo will be UNKNOWN_VALUE in both cases.  We need to
>> adjust this logic to only do this if we didn't do a varlen access after we
>> processed the !condition branch, otherwise we have different ranges and need to
>> check the other branch as well.
>>
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>> ---
>>  kernel/bpf/verifier.c | 10 ++++++++--
>>  1 file changed, 8 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
>> index 89f787c..2c8a688 100644
>> --- a/kernel/bpf/verifier.c
>> +++ b/kernel/bpf/verifier.c
>> @@ -2478,6 +2478,7 @@ static bool states_equal(struct bpf_verifier_env *env,
>>  {
>>  	struct bpf_reg_state *rold, *rcur;
>>  	int i;
>> +	bool map_access = env->varlen_map_value_access;
>
> that's a bit misleading name for the variable.
> Pls call it varlen_map_access.
>
>>  	for (i = 0; i < MAX_BPF_REG; i++) {
>>  		rold = &old->regs[i];
>> @@ -2489,12 +2490,17 @@ static bool states_equal(struct bpf_verifier_env *env,
>>  		/* If the ranges were not the same, but everything else was and
>>  		 * we didn't do a variable access into a map then we are a-ok.
>>  		 */
>> -		if (!env->varlen_map_value_access &&
>> +		if (!map_access &&
>>  		    rold->type == rcur->type && rold->imm == rcur->imm)
>
> just noticed that this one is missing comparing rold->id == rcur->id
>

Do you want me to fix that here?  I'll fix up the rest of the stuff, and Daniels 
things as well.  Thanks,

Josef
