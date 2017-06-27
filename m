From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: Re: [PATCH] netfilter: ip_tables: remove useless variable
 assignment in get_info()
Date: Mon, 26 Jun 2017 22:42:03 -0500
Message-ID: <20170626224203.Horde.ALtRsX1tRN9DvF9T3nJ53UG@gator4166.hostgator.com>
References: <20170626223428.GA11614@embeddedgus>
 <1498531618.24295.57.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed; DelSp=Yes
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498531618.24295.57.camel@perches.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

Quoting Joe Perches <joe@perches.com>:

> On Mon, 2017-06-26 at 17:34 -0500, Gustavo A. R. Silva wrote:
>> Value assigned to variable _ret_ at line 970 is overwritten either at
>> line 986 or 988, before it can be used. This makes such variable
>> assignment useless.
>>
>> Addresses-Coverity-ID: 1226932
> []
>> diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
> []
>> @@ -967,7 +967,7 @@ static int get_info(struct net *net, void __user *user,
>>  		struct xt_table_info tmp;
>>
>>  		if (compat) {
>> -			ret = compat_table_info(private, &tmp);
>> +			compat_table_info(private, &tmp);
>
> why isn't it more appropriate to test the return value?
>

Oh, in this particular case, based on git blame, the code has been  
like that for more than 10 years. So my reasoning was that if it  
hasn't been fixed yet, maybe that return value is not relevant.

But in case it turns out to actually be relevant, what do you think  
about the following patch:

--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -968,7 +968,8 @@ static int get_info(struct net *net, void __user *user,

                 if (compat) {
                         ret = compat_table_info(private, &tmp);
-                       xt_compat_flush_offsets(AF_INET);
+                       if (!ret)
+                               goto out;
                         private = &tmp;
                 }
  #endif
@@ -986,14 +987,20 @@ static int get_info(struct net *net, void __user *user,
                         ret = -EFAULT;
                 else
                         ret = 0;
+       } else
+               ret = -ENOENT;

+out:
+       if (t) {
                 xt_table_unlock(t);
                 module_put(t->me);
-       } else
-               ret = -ENOENT;
+       }
+
  #ifdef CONFIG_COMPAT
-       if (compat)
+       if (compat) {
+               xt_compat_flush_offsets(AF_INET);
                 xt_compat_unlock(AF_INET);
+       }
  #endif
         return ret;
  }


Thank you!
--
Gustavo A. R. Silva
