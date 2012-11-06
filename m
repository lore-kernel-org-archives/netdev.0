From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: convert delay parameters to unsigned
 integers
Date: Tue, 06 Nov 2012 20:39:34 +0100
Message-ID: <50996776.7030205@redhat.com>
References: <1352202733-27906-1-git-send-email-nikolay@redhat.com> <5112.1352228613@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141Ab2KFTjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2012 14:39:52 -0500
In-Reply-To: <5112.1352228613@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/12 20:03, Jay Vosburgh wrote:
> Nikolay Aleksandrov<nikolay@redhat.com>  wrote:
>
>> This patch converts the following parameters from int to unsigned int in order
>> to remove the unnecessary<  0 checks in the code and make it less error prone.
>> The functionality remains unchanged as before it wasn't allowed to have these
>> be less than zero too. Their maximum value was INT_MAX, now it will be UINT_MAX.
>> It also fixes how min_links parameter is treated since it is unsigned int
>> already but was treated as signed integer.
> 	Is this patch fixing any actual bugs, and if so, what?
I don't claim that it fixes any bugs, it is a cosmetic change that 
allows to remove
< 0 checks in the code without affecting functionality. The only "fix" 
there is, is
how min_links is treated when changed (everywhere it was used as int but it
is in fact unsigned int), although this didn't present any problems it 
was more
of an inconsistency.
>> struct bond_params members:
>> updelay downdelay miimon arp_interval
>>
>> The delay variable is initialized from updelay and downdelay parameters and
>> counted down to zero so it should never be<  0.
>>
>> struct slave members:
>> delay
>>
>> The change to struct ifbond's miimon parameter (s32 ->  u32) will probably
>> affect some user-space software but it should be all right in 99 % of the
>> cases as I don't think anyone uses>  INT_MAX for that.
> 	The struct ifbond is used to pass information from the kernel to
> user space in response to an SIOCBONDINFOQUERY ioctl.  It is not used to
> set values within the kernel.  In any event, I don't believe it is
> acceptable to modify a user-visible structure like this, even to change
> types from signed to unsigned of the same size.
I should've explained more about the "limited" part. This is exactly 
what I meant,
if this variable type can/should be changed. But I don't know who would 
use this
at such high values (it loses any meaning IMO). If it is a problem I 
will re-post this
patch without this change, I did it only to be consistent with the 
miimon type, but
then upon returning the ifbond miimon variable might have wrong value.
>> Limited testing of this patch was done in VMs.
> 	If this is not actually fixing any bugs (i.e., is a cosmetic
> change only), then I think it's reasonable to expect the changes to be
> fully tested by you to insure there are no regressions introduced.
>
> 	In particular, if a negative number is passed in after your
> patch is applied, is it accepted or rejected, and if it is accepted,
> what is the value?  For example, if the user specifies "miimon=-1" does
> that fail, or is miimon set to 4294967295?
>
> 	-J
The unsigned int changes have been tested and to answer your question,
when you define a module parameter to be of a certain type, that type is
enforced by the way kernel_param_ops are defined for that type. In this
case if you specify a negative value the parameter won't be set and if it is
on the command line (and not through sysfs) the module won't get loaded
as before.
(Information based on tests, kernel/params.c & kernel/module.c)
> --- -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com 
Best regards,
Nikolay Aleksandrov
