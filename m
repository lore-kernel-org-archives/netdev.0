From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/5] once: make helper generic for calling function
 once
Date: Wed, 07 Oct 2015 23:00:39 +0200
Message-ID: <561587F7.1000604@iogearbox.net>
References: <cover.1444224502.git.daniel@iogearbox.net> <68b03e7c018609b0b56e74346e3f22ac0ad67f28.1444224502.git.daniel@iogearbox.net> <56154571.7050900@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55790 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756263AbbJGVAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 17:00:46 -0400
In-Reply-To: <56154571.7050900@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2015 06:16 PM, Alexei Starovoitov wrote:
> On 10/7/15 6:43 AM, Daniel Borkmann wrote:
>> From: Hannes Frederic Sowa<hannes@stressinduktion.org>
>>
>> Make the get_random_once() helper generic enough, so that functions
>> in general would only be called once, where one user of this is then
>> net_get_random_once().
>>
>> The only implementation specific call is to get_random_bytes(), all
>> the rest of this *_once() facility would be duplicated among different
>> subsystems otherwise. The new do_once() helper will be used by prandom()
>> later on, but might also be useful for other scenarios as well where a
>> one-time initialization in often-called, possibly fast-path code could
>> occur.
>>
>> Signed-off-by: Hannes Frederic Sowa<hannes@stressinduktion.org>
>> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>
>> ---
>>   include/linux/once.h | 25 ++++++++++++++++++-------
>>   lib/once.c           | 34 +++++++++++++++++++++-------------
>>   2 files changed, 39 insertions(+), 20 deletions(-)
>
> looking at the patch 1 the once.c file name really looked out of place,
> but this patch makes it fit. Interesting helper, though
> get_random_once_kvec() and kvec are not pretty, since they take extra
> stack and being inited even when static_key is disabled.
> Instead is it possible to split do_once into two parts then
> your macro can have varags and kvec/extra_helper can be removed like:
> #define do_once(func, ...)                      \
>   ({                                             \
>          bool ___ret = false;                    \
>          static bool ___done = false;            \
>          static struct static_key ___once_key =  \
>                  STATIC_KEY_INIT_TRUE;           \
>          if (static_key_true(&___once_key)) {    \
>                  __do_once_lock(&___done);       \
>                  func(##__VA_ARGS__);            \
>                  __do_once_unlock(&_done, &___once_key);\
>          } \
>          ___ret;                                 \
>   })

Thanks, good point, I do like it! After reworking this, the outcome of
the new DO_ONCE() is a bit different than above. I'll send out v2 very
soon to show the code result.

Thanks,
Daniel
