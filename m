From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net v2 7/9] bridge: Properly check if local fdb entry
 can be deleted in br_fdb_delete_by_port
Date: Wed, 18 Dec 2013 12:50:28 -0500
Message-ID: <52B1E064.5070107@redhat.com>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	 <1387281821-21342-8-git-send-email-makita.toshiaki@lab.ntt.co.jp>	 <52B0A208.4030103@redhat.com> <1387333638.3563.22.camel@ubuntu-vm-makita>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48524 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031Ab3LRRud (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 12:50:33 -0500
In-Reply-To: <1387333638.3563.22.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 09:27 PM, Toshiaki Makita wrote:
> On Tue, 2013-12-17 at 14:12 -0500, Vlad Yasevich wrote:
>> On 12/17/2013 07:03 AM, Toshiaki Makita wrote:
>>> br_fdb_delete_by_port() doesn't care about vlan and mac address of the
>>> bridge device.
>>>
>>> As the check is almost the same as mac address changing, slightly modify
>>> fdb_delete_local() and use it.
>>>
>>> Note:
>>> - We change the dst of a local entry when the same address is found.
>>>   This occurs in the case kernel has inserted the same address for another
>>>   port but has failed due to dup. We can regard changing dst as deleting
>>>   old one and inserting new one that should have been added by the dup
>>>   port, so we can always set its added_by_user to 0 in fdb_delete_local().
>>
>> I disagree.  What happens if the user tries add a duplicate fdb with
>> the local bit set?  
> 
> If the user add a dup local entry, the existent entry will be
> overwritten and its add_by_user is set to 1 (if !NLM_F_EXCL).
> The user never fails to add an entry due to dup in !NLM_F_EXCL case.

You are right.  This is actually a very interesting situation.  User may
over-write the current entry on add, but a delete will remove the entry
instead of restoring original configuration.  I wonder if this was done
on purpose...

> 
>> That is permitted and in fact a default because in
>> iproute right now.  That fdb should persist until the port is removed or
>> user removes the fdb.
>>
>> added_by_user flag should only be changed in the netlink code since the
>> user has full control of it.
> 
> Maybe my changelog is misleading.
> 
> br_fdb_delete_by_port() calls fdb_delete_local() for local entries
> regardless of its added_by_user. In this case, we have to check if
> another port has the same address and vlan, and if found, we have to
> create the entry (by changing dst). This is kernel-added entry, not
> user-added.
> 
> br_fdb_changeaddr()/nbp_vlan_delete() doesn't call fdb_delete_local()
> for user-added entry.
> 
> So it is safe to set added_by_user to 0 in fdb_delete_local().
> 
> will reword the changelog.

Ok.  Thanks for clearing this up.  Looking at patch 6 made it a bit
more clear.  Yes, updating the changelog makes sense since I don't see
this patch introducing the the "change in behavior" you note in the
log.

-vlad

> 
> Thanks,
> Toshiaki Makita
> 
> 
