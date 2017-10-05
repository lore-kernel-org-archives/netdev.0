From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 5/5] bpf: write back the verifier log buffer
 as it gets filled
Date: Thu, 05 Oct 2017 23:45:51 +0200
Message-ID: <59D6A80F.8030208@iogearbox.net>
References: <20171005153422.8947-1-jakub.kicinski@netronome.com>        <20171005153422.8947-6-jakub.kicinski@netronome.com>    <59D69FAB.1020605@iogearbox.net> <20171005142647.7a8d87a3@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56945 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751381AbdJEVpx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 17:45:53 -0400
In-Reply-To: <20171005142647.7a8d87a3@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2017 11:26 PM, Jakub Kicinski wrote:
> On Thu, 05 Oct 2017 23:10:03 +0200, Daniel Borkmann wrote:
>>>    include/linux/bpf_verifier.h |  7 +++--
>>>    kernel/bpf/verifier.c        | 64 +++++++++++++++++++++++++++++++-------------
>>>    2 files changed, 50 insertions(+), 21 deletions(-)
>>>
>>> diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
>>> index 598802dd1897..c0f0e210c3f8 100644
>>> --- a/include/linux/bpf_verifier.h
>>> +++ b/include/linux/bpf_verifier.h
>>> @@ -140,10 +140,13 @@ struct bpf_verifier_env {
>>>    	bool seen_direct_write;
>>>    	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
>>>
>>> -	u32 log_level;
>>> +	char __user *log_ubuf;
>>> +	u32 log_usize;
>>> +	u32 log_ulen;
>>> +	char *log_buf;
>>>    	u32 log_size;
>>>    	u32 log_len;
>>> -	char *log_buf;
>>> +	u32 log_level;
>>
>> Small request: given we'd now have log_{level,ubuf,usize,ulen,buf,size,len}
>> in struct bpf_verifier_env, could we abstract that a bit e.g. into something
>> like struct bpf_verifier_log, which has level and kbuf and ubuf as members
>> of which {k,u}buf would be something like struct bpf_verifier_buf with three
>> members (mem or buf, len_total, len_used) or such. I think most of patch 1
>> is on passing env into verbose, so likely wouldn't be too much change required
>> for this, but would be nice to make that a bit more structured if we need to
>> touch it anyway.
>
> I thought about it but got put off by the fact that on of the bufs has
> a special __user marking..  So I don't think we can really have a common
> struct bpf_verifier_buf for the two :S  Any suggestions on how to work
> around that?

Little bit annoying, I know. We have same 'issue' with struct sock_fprog_kern
and struct sock_fprog, probably something similar would be needed here for
the bpf_verifier_buf thing as well to make it two structs.

>>>    		ret = -ENOMEM;
>>> -		env->log_buf = vmalloc(env->log_size);
>>> +		env->log_buf = page_address(alloc_page(GFP_USER));
>>
>> alloc_page() can return NULL, if I spot this correctly, then page_address()
>> cannot handle NULL and would try to deref it, no? Am I missing something?
>
> Oh, I need to fix the nfp driver too, then!
