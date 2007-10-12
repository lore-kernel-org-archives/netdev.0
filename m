From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 13:48:41 +0200
Message-ID: <470F5F19.70606@trash.net>
References: <200710120031.42805.a1426z@gawab.com> <470EF994.4080403@trash.net> <200710120837.18152.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Al Boldi <a1426z@gawab.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200710120837.18152.a1426z@gawab.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Boldi wrote:
> Patrick McHardy wrote:
> 
>>Please send mails discussing netfilter to netfilter-devel.
> 
> 
> Ok.  I just found out this changed to vger.  But 
> netfilter-devel@vger.kernel.org is bouncing me.

Seems to work, I got your mail on netfilter-devel.

>>Al Boldi wrote:
>>
>>>With the existence of the mangle table, how useful is the filter table?
>>>
>>>Other than requiring the REJECT target to be ported to the mangle table,
>>>is the filter table faster than the mangle table?
>>
>>There are some minor differences in ordering (mangle comes before
>>DNAT, filter afterwards), but for most rulesets thats completely
>>irrelevant. The only difference that really matters is that mangle
>>performs rerouting in LOCAL_OUT for packets that had their routing
>>key changed, so its really a superset of the filter table. If you
>>want to use REJECT in the mangle table, you just need to remove the
>>restriction to filter, it works fine. I would prefer to also remove
>>the restriction of MARK, CONNMARK etc. to mangle, they're used for
>>more than just routing today so that restriction also doesn't make
>>much sense. Patches for this are welcome.
> 
> 
> Something like this (untested):
> 
> --- ipt_REJECT.bak.c    2007-10-12 08:25:17.000000000 +0300
> +++ ipt_REJECT.c        2007-10-12 08:31:44.000000000 +0300
> @@ -165,6 +165,7 @@ static void send_reset(struct sk_buff *o
>  
>  static inline void send_unreach(struct sk_buff *skb_in, int code)
>  {
> +       if (!skb_in->dst) ip_route_me_harder(&skb_in, RTN_UNSPEC);
>         icmp_send(skb_in, ICMP_DEST_UNREACH, code, 0);
>  }
>  
> @@ -245,9 +246,6 @@ static struct xt_target ipt_reject_reg =
>         .family         = AF_INET,
>         .target         = reject,
>         .targetsize     = sizeof(struct ipt_reject_info),
> -       .table          = "filter",
> -       .hooks          = (1 << NF_IP_LOCAL_IN) | (1 << NF_IP_FORWARD) |
> -                         (1 << NF_IP_LOCAL_OUT),
>         .checkentry     = check,
>         .me             = THIS_MODULE,
>  };


That includes an unrelated change, I meant to simply remove the filter
table restriction.

>>>If not, then shouldn't the filter table be obsoleted to avoid confusion?
>>
>>That would probably confuse people. Just don't use it if you don't
>>need to.
> 
> 
> The problem is that people think they are safe with the filter table, when in 
> fact they need the prerouting chain to seal things.  Right now this is only 
> possible in the mangle table.


Why do they need PREROUTING?
