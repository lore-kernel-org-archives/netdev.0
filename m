From: Patrick McHardy <kaber@trash.net>
Subject: Re: More tc action mess
Date: Thu, 20 Jan 2005 07:32:49 +0100
Message-ID: <41EF5091.9040402@trash.net>
References: <41EDEB97.3080503@trash.net>	 <1106140256.1049.903.camel@jzny.localdomain>  <41EEC19B.3010504@trash.net> <1106195414.1048.34.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1106195414.1048.34.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>On Wed, 2005-01-19 at 15:22, Patrick McHardy wrote:
>  
>
>>This does not help. Netfilter calls skb_ip_make_writable if it has to
>>touch the packet, if it is shared or cloned the packet will be copied.
>>    
>>
>
>for ipt, just restore:
>
>if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) 
>	return -ENOMEM
>
>for the rest, the action code will handle all just fine. There will only
>be one copy per serious of tramplings. This is design intent.
>  
>
It seems to be more clever than I initially realized :) But it does need
some fixing for ipt. The ->act function takes a struct sk_buff **, which
implies the skb might get replaced, but tcf_action_exec only takes a struct
sk_buff * and doesn't own the skb. So if the skb is replaced in the action
the owner ends up with a pointer to freed memory. pskb_expand_head is not
enough to stop netfilter from copying, at ingress the the skb might be
nonlinear, in which case it is copied. On egress it seems fine.

>Give me some examples which show something is broken then we can have a
>more coherent discussion. I am willing to kill ipt if it is the problem.
>
Instead of killing ipt we could teach netfilter to be smarter about this.
If the data that needs to be mangled is in the non-linear range we could
just linearize the skb. Additionally we should change act_api to only pass
single skb pointers around, to avoid all confusion and possible trouble.

This seems a lot better than changing almost entire net/sched to pass
double pointers around :)

Regards
Patrick
