From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net-next 4/7] openvswitch: Inherit master's labels.
Date: Tue, 7 Feb 2017 21:31:05 -0800
Message-ID: <A0D51CE7-1226-4F71-B53F-4DDC4DEFBBA0@ovn.org>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <1486084206-109903-4-git-send-email-jarno@ovn.org> <CAPWQB7HLGN7LpROpD1XW4+9TH27ZTM14earFB+Cx5fExRXeUAQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34843 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752759AbdBHFbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 00:31:07 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so10833369pfa.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 21:31:07 -0800 (PST)
In-Reply-To: <CAPWQB7HLGN7LpROpD1XW4+9TH27ZTM14earFB+Cx5fExRXeUAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 6, 2017, at 1:53 PM, Joe Stringer <joe@ovn.org> wrote:
> 
> On 2 February 2017 at 17:10, Jarno Rajahalme <jarno@ovn.org> wrote:
>> We avoid calling into nf_conntrack_in() for expected connections, as
>> that would remove the expectation that we want to stick around until
>> we are ready to commit the connection.  Instead, we do a lookup in the
>> expectation table directly.  However, after a successful expectation
>> lookup we have set the flow key label field from the master
>> connection, whereas nf_conntrack_in() does not do this.  This leads to
>> master's labels being iherited after an expectation lookup, but those
>> labels not being inherited after the corresponding conntrack action
>> with a commit flag.
>> 
>> This patch resolves the problem by changing the commit code path to
>> also inherit the master's labels to the expected connection.
>> Resolving this conflict in favor or inheriting the labels allows
>> information be passed from the master connection to related
>> connections, which would otherwise be much harder.  Labels can still
>> be set explicitly, so this change only affects the default values of
>> the labels in presense of a master connection.
>> 
>> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>> ---
>> net/openvswitch/conntrack.c | 48 ++++++++++++++++++++++++++++++++-------------
>> 1 file changed, 34 insertions(+), 14 deletions(-)
>> 
>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> index a163c44..738a4fa 100644
>> --- a/net/openvswitch/conntrack.c
>> +++ b/net/openvswitch/conntrack.c
>> @@ -265,6 +265,8 @@ static struct nf_conn_labels *ovs_ct_get_conn_labels(struct nf_conn *ct)
>>        return cl;
>> }
>> 
>> +static bool labels_nonzero(const struct ovs_key_ct_labels *labels);
>> +
> 
> These declarations typically live at the top of the file, not
> somewhere in the middle.
> 

Moved.

>> /* Initialize labels for a new, to be committed conntrack entry.  Note that
>>  * since the new connection is not yet confirmed, and thus no-one else has
>>  * access to it's labels, we simply write them over.  Also, we refrain from
>> @@ -275,18 +277,35 @@ static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
>>                              const struct ovs_key_ct_labels *labels,
>>                              const struct ovs_key_ct_labels *mask)
>> {
>> -       struct nf_conn_labels *cl;
>> -       u32 *dst;
>> -       int i;
>> +       struct nf_conn_labels *cl, *master_cl;
>> +       bool have_mask = labels_nonzero(mask);
>> +
>> +       /* Inherit master's labels to the related connection? */
>> +       master_cl = (ct->master) ? nf_ct_labels_find(ct->master) : NULL;
>> +
>> +       if (!master_cl && !have_mask)
>> +               return 0;   /* Nothing to do. */
>> 
>>        cl = ovs_ct_get_conn_labels(ct);
>>        if (!cl)
>>                return -ENOSPC;
>> 
>> -       dst = (u32 *)cl->bits;
>> -       for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
>> -               dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
>> -                       (labels->ct_labels_32[i] & mask->ct_labels_32[i]);
>> +       /* Inherit the master's labels, if any. */
>> +       if (master_cl) {
>> +               size_t len = sizeof(master_cl->bits);
>> +
>> +               memcpy(&cl->bits, &master_cl->bits,
>> +                      len > OVS_CT_LABELS_LEN ? OVS_CT_LABELS_LEN : len);
> 
> Looks like this is another spot where we're trying to handle differing
> label lengths, which we could simplify if there was a stronger
> guarantee they're the same.

Indeed, here the ‘cl’s are different instances of the same structure, so we do need not worry about the sizes at all. I’ll change this to an simple structure assignment for v2.

> 
>> +       }
>> +       if (have_mask) {
>> +               u32 *dst = (u32 *)cl->bits;
>> +               int i;
>> +
>> +               for (i = 0; i < OVS_CT_LABELS_LEN_32; i++)
>> +                       dst[i] = (dst[i] & ~mask->ct_labels_32[i]) |
>> +                               (labels->ct_labels_32[i]
>> +                                & mask->ct_labels_32[i]);
>> +       }
> 
> By the way, is this open-coding nf_connlabels_replace()? Can
> ovs_ct_set_labels() and this share the code?

nf_connlabels_replace() uses the compare-and-exchange function to change each 32-bit unit individually, and also triggers the nf netlink change event, first of which we do not need and the second of which we do not want.

> 
>> 
>>        memcpy(&key->ct.labels, cl->bits, OVS_CT_LABELS_LEN);
>> 
>> @@ -916,13 +935,14 @@ static int ovs_ct_commit(struct net *net, struct sw_flow_key *key,
>>                if (err)
>>                        return err;
>>        }
>> -       if (labels_nonzero(&info->labels.mask)) {
>> -               if (!nf_ct_is_confirmed(ct))
>> -                       err = ovs_ct_init_labels(ct, key, &info->labels.value,
>> -                                                &info->labels.mask);
>> -               else
>> -                       err = ovs_ct_set_labels(ct, key, &info->labels.value,
>> -                                               &info->labels.mask);
>> +       if (!nf_ct_is_confirmed(ct)) {
>> +               err = ovs_ct_init_labels(ct, key, &info->labels.value,
>> +                                        &info->labels.mask);
>> +               if (err)
>> +                       return err;
>> +       } else if (labels_nonzero(&info->labels.mask)) {
>> +               err = ovs_ct_set_labels(ct, key, &info->labels.value,
>> +                                       &info->labels.mask);
>>                if (err)
>>                        return err;
>>        }
>> --
>> 2.1.4
