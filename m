From: Patrick McHardy <kaber@trash.net>
Subject: Re: Still oopsing in nf_nat_move_storage()
Date: Sat, 02 Feb 2008 11:26:27 +0100
Message-ID: <47A44553.2090703@trash.net>
References: <479F5E5A.8050108@redhat.com> <479F5FDC.5040903@trash.net> <47A20D57.5040907@redhat.com> <47A3AE41.6070104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47A3AE41.6070104@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:
> On 01/31/2008 01:03 PM, Chuck Ebbert wrote:
>> On 01/29/2008 12:18 PM, Patrick McHardy wrote:
>>> Chuck Ebbert wrote:
>>>> nf_nat_move_storage():
>>>> /usr/src/debug/kernel-2.6.23/linux-2.6.23.i686/net/ipv4/netfilter/nf_nat_core.c:612
>>>>
>>>>       87:       f7 47 64 80 01 00 00    testl  $0x180,0x64(%edi)
>>>>       8e:       74 39                   je     c9
>>>> <nf_nat_move_storage+0x65>
>>>>
>>>> line 612:
>>>>         if (!(ct->status & IPS_NAT_DONE_MASK))
>>>>                 return;
>>>>
>>>> ct is NULL
>>> The current kernel (and 2.6.23-stable) have:
>>>
>>>         if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
>>>                 return;
>>>
>>> so it seems you're using an old version.
> 
> So, it is now oopsing after the test for NULL and only x86_64 is
> catching the invalid address because it is non-canonical. Checking
> for NULL is obviously not enough...


The addresses passed to ->move seems to be bogus, we're doing:

           t->move(ct, ct->ext + ct->ext->offset[i]);

without assigning the new ct->ext first, which is wrong for
two reasons:

- the new ext hasn't been assigned to the conntrack yet,
   so its moving within the same extension

- ct->ext + ct->ext->offset[i] should be (void *)ct->ext + ...

I'll fix it and send a patch after some testing. Still wondering
why this wasn't noticed before.
