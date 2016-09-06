From: Gao Feng <fgao@ikuai8.com>
Subject: Re: [PATCH v5 nf] netfilter: seqadj: Drop the packet directly when
 fail to add seqadj extension to avoid dereference NULL pointer later
Date: Tue, 6 Sep 2016 22:54:54 +0800
Message-ID: <CA+6hz4pRTvCvopOEoxC7oPwCPXKStZ9W31+Bn9fiChCgtsF=eQ@mail.gmail.com>
References: <1473173035-2175-1-git-send-email-fgao@ikuai8.com> <20160906145117.GB20188@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbgsg2.qq.com ([54.254.200.128]:36552 "EHLO smtpbgsg2.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932845AbcIFOzP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 10:55:15 -0400
In-Reply-To: <20160906145117.GB20188@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inline

On Tue, Sep 6, 2016 at 10:51 PM, Florian Westphal <fw@strlen.de> wrote:
> fgao@ikuai8.com <fgao@ikuai8.com> wrote:
>> From: Gao Feng <fgao@ikuai8.com>
>>
>> When memory is exhausted, nfct_seqadj_ext_add may fail to add the seqadj
>> extension. But the function nf_ct_seqadj_init doesn't check if get valid
>> seqadj pointer by the nfct_seqadj.
>>
>> Now drop the packet directly when fail to add seqadj extension to avoid
>> dereference NULL pointer in nf_ct_seqadj_init.
>>
>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>> ---
>>  v5: Return NF_ACCEPT instead of NF_DROP when nfct_seqadj_ext_add failed in nf_nat_setup_info
>>  v4: Drop the packet directly when fail to add seqadj extension;
>>  v3: Remove the warning log when seqadj is null;
>>  v2: Remove the unnessary seqadj check in nf_ct_seq_adjust
>>  v1: Initial patch
>>
>>  net/netfilter/nf_conntrack_core.c | 6 +++++-
>>  net/netfilter/nf_nat_core.c       | 3 ++-
>>  2 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
>> index dd2c43a..dfa76ce 100644
>> --- a/net/netfilter/nf_conntrack_core.c
>> +++ b/net/netfilter/nf_conntrack_core.c
>> @@ -1036,7 +1036,11 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
>>               return (struct nf_conntrack_tuple_hash *)ct;
>>
>>       if (tmpl && nfct_synproxy(tmpl)) {
>> -             nfct_seqadj_ext_add(ct);
>> +             if (!nfct_seqadj_ext_add(ct)) {
>> +                     nf_conntrack_free(ct);
>> +                     pr_debug("Can't add seqadj extension\n");
>> +                     return NULL;
>> +             }
>
> if (!nfct_add_synrpxy(ct, tmpl)) {
>         nf_conntrack_free(ct);
>         return NULL;
> }
>
> static bool nf_ct_add_synproxy(struct nf_conn *ct, const struct nf_conn *tmpl)
> {
>         if (tmpl && nfct_synproxy(tmpl)) {
>                 if (!nfct_seqadj_ext_add(ct))
>                         return false;
>
>                 if (!nfct_synproxy_ext_add(ct))
>                         return false;
>         }
>
>         return true;
> }
>
>> diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
>> index de31818..f8b916a 100644
>> --- a/net/netfilter/nf_nat_core.c
>> +++ b/net/netfilter/nf_nat_core.c
>> @@ -441,7 +441,8 @@ nf_nat_setup_info(struct nf_conn *ct,
>>                       ct->status |= IPS_DST_NAT;
>>
>>               if (nfct_help(ct))
>> -                     nfct_seqadj_ext_add(ct);
>> +                     if (!nfct_seqadj_ext_add(ct))
>> +                             return NF_ACCEPT;
>>       }
>
> Hmm, why accept?
>
> We are asked to add extension to rewrite sequence numbers, but
> we cannot.  How can the connection work if we cannot munge/track
> seqno rewrites?

I thought we should drop the packet in that case before.
But Pablo point out one case that the ctnetlink also could add the
seqadj extension too.
There is one synchronization case.

I think he is right. Then modify the patch according to his advice.

Best Regards
Feng
