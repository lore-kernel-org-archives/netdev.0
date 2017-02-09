From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH v2 net-next 3/9] openvswitch: Simplify labels length logic.
Date: Thu, 9 Feb 2017 11:39:46 -0800
Message-ID: <65D1BBED-46C7-44C7-92D9-CB3492856BD6@ovn.org>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org> <1486582330-31152-4-git-send-email-jarno@ovn.org> <CAPWQB7G_HVJXXPf-RAK+kneKwvoRu=0ySFs98PUTqLop4eVFNw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35476 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753394AbdBITjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:39:49 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so1065697pge.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 11:39:48 -0800 (PST)
In-Reply-To: <CAPWQB7G_HVJXXPf-RAK+kneKwvoRu=0ySFs98PUTqLop4eVFNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 8, 2017, at 2:47 PM, Joe Stringer <joe@ovn.org> wrote:
> 
> On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
>> Since 23014011ba42 ("netfilter: conntrack: support a fixed size of 128
>> distinct labels"), the size of conntrack labels extension has fixed to
>> 128 bits, so we do not need to check for labels sizes shorter than 128
>> at run-time.  This patch simplifies labels length logic accordingly,
>> but allows the conntrack labels size to be increased in the future
>> without breaking the build.  In the event of conntrack labels
>> increasing in size OVS would still be able to deal with the 128 first
>> label bits.
>> 
>> Suggested-by: Joe Stringer <joe@ovn.org>
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>> ---
>> net/openvswitch/conntrack.c | 22 +++++++++++-----------
>> 1 file changed, 11 insertions(+), 11 deletions(-)
>> 
>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>> index 6730f09..a07e5cd 100644
>> --- a/net/openvswitch/conntrack.c
>> +++ b/net/openvswitch/conntrack.c
>> @@ -129,22 +129,22 @@ static u32 ovs_ct_get_mark(const struct nf_conn *ct)
>> #endif
>> }
>> 
>> +/* Guard against conntrack labels max size shrinking below 128 bits. */
>> +#if NF_CT_LABELS_MAX_SIZE < 16
>> +#error NF_CT_LABELS_MAX_SIZE must be at least 16 bytes
>> +#endif
>> +
>> static void ovs_ct_get_labels(const struct nf_conn *ct,
>>                              struct ovs_key_ct_labels *labels)
>> {
>>        struct nf_conn_labels *cl = ct ? nf_ct_labels_find(ct) : NULL;
>> 
>> -       if (cl) {
>> -               size_t len = sizeof(cl->bits);
>> -
>> -               if (len > OVS_CT_LABELS_LEN)
>> -                       len = OVS_CT_LABELS_LEN;
>> -               else if (len < OVS_CT_LABELS_LEN)
>> -                       memset(labels, 0, OVS_CT_LABELS_LEN);
>> -               memcpy(labels, cl->bits, len);
>> -       } else {
>> +       if (cl)
>> +               memcpy(labels, cl->bits,
>> +                      sizeof(cl->bits) > OVS_CT_LABELS_LEN
>> +                      ? OVS_CT_LABELS_LEN : sizeof(cl->bits));
> 
> Is this to be defensive? If sizeof(cl->bits) is larger than
> OVS_CT_LABELS_LEN, we'll use OVS_CT_LABELS_LEN; if it's equal, we'll
> still use OVS_CT_LABELS_LEN; if it's less, the precompiler will fail
> above. Why not memcpy(.., OVS_CT_LABELS_LEN) ?

Right, I’ll post v4 simplifying this as suggested. Functionality is still the same, though.

  Jarno
