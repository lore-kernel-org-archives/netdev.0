From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: include NLM_F_APPEND flag in append route notifications
Date: Wed, 17 Jun 2015 07:50:38 -0700
Message-ID: <5581893E.3070609@cumulusnetworks.com>
References: <1434471120-26742-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bDnVEq1mqUmmYMFAd9CeEbn9tTzD_UnoDKYVScT5G=QJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:33494 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755377AbbFQOul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 10:50:41 -0400
Received: by iebgx4 with SMTP id gx4so35319969ieb.0
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 07:50:40 -0700 (PDT)
In-Reply-To: <CAE4R7bDnVEq1mqUmmYMFAd9CeEbn9tTzD_UnoDKYVScT5G=QJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/17/15, 12:50 AM, Scott Feldman wrote:
> On Tue, Jun 16, 2015 at 9:11 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>
> [snip]
>
>> @@ -1203,6 +1204,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>>
>>                  if (!(cfg->fc_nlflags & NLM_F_APPEND))
>>                          fa = fa_first;
>> +               else
>> +                       nlflags |= NLM_F_APPEND;
>>          }
> The if and else parts above don't seem logically related.
I have it at this place because here is where the decision to append 
really happens.
>   Maybe you
> could initialize nlflags as:
>
>      unsigned int nlflags = cfg->fc_nlflags & (NLM_F_REPLACE|NLM_F_APPEND);
>
> And then pass rtmsg_fib(..., nlflags) to avoid the flag test/set?
nlflags should only contain NLM_F_REPLACE and NLM_F_APPEND if a replace or
append really took place. Hence the check and setting of nlflags is at 
the place where that
decision is made.

I had tried this patch a couple of other ways.... Do you think the below 
would be less confusing ?

thanks.



diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3c699c4..9bfa3d8 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1082,6 +1082,7 @@ int fib_table_insert(struct fib_table *tb, struct 
fib_config *cfg)
         struct trie *t = (struct trie *)tb->tb_data;
         struct fib_alias *fa, *new_fa;
         struct key_vector *l, *tp;
+       unsigned int nlflags = 0;
         struct fib_info *fi;
         u8 plen = cfg->fc_dst_len;
         u8 slen = KEYLENGTH - plen;
@@ -1189,8 +1190,9 @@ int fib_table_insert(struct fib_table *tb, struct 
fib_config *cfg)
                         fib_release_info(fi_drop);
                         if (state & FA_S_ACCESSED)
rt_cache_flush(cfg->fc_nlinfo.nl_net);
+                       nlflags |= NLM_F_REPLACE;
                         rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
-                               tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
+                               tb->tb_id, &cfg->fc_nlinfo, nlflags);

                         goto succeeded;
                 }
@@ -1201,7 +1203,9 @@ int fib_table_insert(struct fib_table *tb, struct 
fib_config *cfg)
                 if (fa_match)
                         goto out;

-               if (!(cfg->fc_nlflags & NLM_F_APPEND))
+               if (cfg->fc_nlflags & NLM_F_APPEND)
+                       nlflags |= NLM_F_APPEND;
+               else
                         fa = fa_first;
         }
         err = -ENOENT;
@@ -1238,7 +1242,7 @@ int fib_table_insert(struct fib_table *tb, struct 
fib_config *cfg)

         rt_cache_flush(cfg->fc_nlinfo.nl_net);
         rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
-                 &cfg->fc_nlinfo, 0);
+                 &cfg->fc_nlinfo, nlflags);
  succeeded:
         return 0;
