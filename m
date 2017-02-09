From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH v2 net-next 6/9] openvswitch: Inherit master's labels.
Date: Thu, 9 Feb 2017 11:04:25 -0800
Message-ID: <0206A754-ACDA-4EF8-B100-CE7F641A5DE1@ovn.org>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org> <1486582330-31152-7-git-send-email-jarno@ovn.org> <CAPWQB7FVmJD07gsKG7WHHzFj5OoBo79OquOouF46AHA=dYs3zw@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34841 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751356AbdBITEf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:04:35 -0500
Received: by mail-pg0-f66.google.com with SMTP id 204so999705pge.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 11:04:27 -0800 (PST)
In-Reply-To: <CAPWQB7FVmJD07gsKG7WHHzFj5OoBo79OquOouF46AHA=dYs3zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 8, 2017, at 3:25 PM, Joe Stringer <joe@ovn.org> wrote:
> 
> On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
>> We avoid calling into nf_conntrack_in() for expected connections, as
>> that would remove the expectation that we want to stick around until
>> we are ready to commit the connection.  Instead, we do a lookup in the
>> expectation table directly.  However, after a successful expectation
>> lookup we have set the flow key label field from the master
>> connection, whereas nf_conntrack_in() does not do this.  This leads to
>> master's labels being inherited after an expectation lookup, but those
>> labels not being inherited after the corresponding conntrack action
>> with a commit flag.
>> 
>> This patch resolves the problem by changing the commit code path to
>> also inherit the master's labels to the expected connection.
>> Resolving this conflict in favor or inheriting the labels allows more
> 
> *of inheriting
> 
>> information be passed from the master connection to related
>> connections, which would otherwise be much harder if the 32 bits in
>> the connmark are not enough.  Labels can still be set explicitly, so
>> this change only affects the default values of the labels in presense
>> of a master connection.
>> 
>> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> 
> <snip>
> 
>> @@ -272,18 +274,32 @@ static int ovs_ct_init_labels(struct nf_conn *ct, struct sw_flow_key *key,
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
> 
> I don't think (ct->master) needs the parentheses.

Fixed these style issues for v4.

  Jarno
