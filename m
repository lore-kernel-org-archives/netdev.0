From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 1/1] ipv4: off-by-one in continuation handling in
 /proc/net/route
Date: Thu, 13 Aug 2015 09:07:39 -0700
Message-ID: <55CCC0CB.6030309@gmail.com>
References: <1439461267-10627-1-git-send-email-apw@canonical.com>
 <1439478658.7960.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Whitcroft <apw@canonical.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439478658.7960.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/13/2015 08:10 AM, Eric Dumazet wrote:
> On Thu, 2015-08-13 at 11:21 +0100, Andy Whitcroft wrote:
>> When generating /proc/net/route we emit a header followed by a line for
>> each route.  When a short read is performed we will restart this process
>> based on the open file descriptor.  When calculating the start point we
>> fail to take into account that the 0th entry is the header.  This leads
>> us to skip the first entry when doing a continuation read.
>>
>> This can be easily seen with the comparison below:
>>
>>    while read l; do echo "$l"; done </proc/net/route >A
>>    cat /proc/net/route >B
>>    diff -bu A B | grep '^[+-]'
>>
>> On my example machine I have approximatly 10KB of route output.  There we
>> see the very first non-title element is lost in the while read case,
>> and an entry around the 8K mark in the cat case:
>>
>>    +wlan0 00000000 02021EAC 0003 0 0 400 00000000 0 0 0
>>    -tun1  00C0AC0A 00000000 0001 0 0 950 00C0FFFF 0 0 0
>>
>> Fix up the off-by-one when reaquiring position on continuation.
>>
>> BugLink: http://bugs.launchpad.net/bugs/1483440
>> Signed-off-by: Andy Whitcroft <apw@canonical.com>
>> ---
>>   net/ipv4/fib_trie.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> 	From code inspection I belive this was introduced by the Fixes
>> 	below, but I have not tested this to confirm.
>>
>> 	Fixes: 8be33e955cb9 ("ipv4: off-by-one in continuation handling in /proc/net/route")
> You probably meant
>
> Fixes: 8be33e955cb9 ("fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf")
>
> CC Alexander for review/comment

I agree the Fixes line needs to be updated.  Other than that the fix 
looks good.  Once you get the comment fixed feel free to add my 
acked-by.  Also you might call out that this is needed for net, and 4.1 
stable as well.

Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
