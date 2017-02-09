From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH v2 net-next 8/9] openvswitch: Add force commit.
Date: Thu, 9 Feb 2017 11:39:30 -0800
Message-ID: <6A5BA647-145C-4914-B0B8-A61BC326A18D@ovn.org>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org> <1486582330-31152-9-git-send-email-jarno@ovn.org> <CAPWQB7HV5FM+1xv_vfvfrSQf3nYXEN6pd0vvjnLYs_cKNxk9cQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34166 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752804AbdBITjd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:39:33 -0500
Received: by mail-pg0-f67.google.com with SMTP id v184so1068639pgv.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 11:39:33 -0800 (PST)
In-Reply-To: <CAPWQB7HV5FM+1xv_vfvfrSQf3nYXEN6pd0vvjnLYs_cKNxk9cQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 8, 2017, at 3:53 PM, Joe Stringer <joe@ovn.org> wrote:
> 
> On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
>> Stateful network admission policy may allow connections to one
>> direction and reject connections initiated in the other direction.
>> After policy change it is possible that for a new connection an
>> overlapping conntrack entry already exists, where the original
>> direction of the existing connection is opposed to the new
>> connection's initial packet.
>> 
>> Most importantly, conntrack state relating to the current packet gets
>> the "reply" designation based on whether the original direction tuple
>> or the reply direction tuple matched.  If this "directionality" is
>> wrong w.r.t. to the stateful network admission policy it may happen
>> that packets in neither direction are correctly admitted.
>> 
>> This patch adds a new "force commit" option to the OVS conntrack
>> action that checks the original direction of an existing conntrack
>> entry.  If that direction is opposed to the current packet, the
>> existing conntrack entry is deleted and a new one is subsequently
>> created in the correct direction.
>> 
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> 
> <snip>
> 
>>                if (help && rcu_access_pointer(help->helper) != info->helper)
>>                        return false;
>>        }
>> +       /* Force conntrack entry direction to the current packet? */
>> +       if (info->force && CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL) {
>> +               /* Delete the conntrack entry if confirmed, else just release
>> +                * the reference.
>> +                */
>> +               if (nf_ct_is_confirmed(ct))
>> +                       nf_ct_delete(ct, 0, 0);
>> +               else
>> +                       nf_conntrack_put(&ct->ct_general);
>> +               skb->nfct = NULL;
>> +               skb->nfctinfo = 0;
> 
> This can use nf_ct_set().

This is in v3.

  Jarno
