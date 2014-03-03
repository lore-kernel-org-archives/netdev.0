From: Andrew Bennieston <andrew.bennieston@citrix.com>
Subject: Re: [PATCH V5 net-next 4/5] xen-netfront: Add support for multiple
 queues
Date: Mon, 3 Mar 2014 12:14:46 +0000
Message-ID: <53147236.60007@citrix.com>
References: <1393252387-17496-1-git-send-email-andrew.bennieston@citrix.com> <1393252387-17496-5-git-send-email-andrew.bennieston@citrix.com> <20140228152250.GP16241@zion.uk.xensource.com> <5310B390.1060604@citrix.com> <20140228161329.GQ16241@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58645 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753982AbaCCMXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2014 07:23:25 -0500
In-Reply-To: <20140228161329.GQ16241@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/02/14 16:13, Wei Liu wrote:
> On Fri, Feb 28, 2014 at 04:04:32PM +0000, Andrew Bennieston wrote:
>> On 28/02/14 15:22, Wei Liu wrote:
>>> On Mon, Feb 24, 2014 at 02:33:06PM +0000, Andrew J. Bennieston wrote:
>>>> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
>>>>
>>>> Build on the refactoring of the previous patch to implement multiple
>>>> queues between xen-netfront and xen-netback.
>>>>
>>>> Check XenStore for multi-queue support, and set up the rings and event
>>>> channels accordingly.
>>>>
>>>> Write ring references and event channels to XenStore in a queue
>>>> hierarchy if appropriate, or flat when using only one queue.
>>>>
>>>> Update the xennet_select_queue() function to choose the queue on which
>>>> to transmit a packet based on the skb hash result.
>>>>
>>>> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
>>>> ---
>>>>   drivers/net/xen-netfront.c |  178 ++++++++++++++++++++++++++++++++++----------
>>>>   1 file changed, 140 insertions(+), 38 deletions(-)
>>>>
>>>> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
>>>> index 4f5a431..470d6ed 100644
>>>> --- a/drivers/net/xen-netfront.c
>>>> +++ b/drivers/net/xen-netfront.c
>>>> @@ -57,6 +57,12 @@
>>>>   #include <xen/interface/memory.h>
>>>>   #include <xen/interface/grant_table.h>
>>>>
>>>> +/* Module parameters */
>>>> +unsigned int xennet_max_queues;
>>>> +module_param(xennet_max_queues, uint, 0644);
>>>> +MODULE_PARM_DESC(xennet_max_queues,
>>>> +		"Maximum number of queues per virtual interface");
>>>> +
>>>
>>> Maybe I'm nit-picking here. But I think exposing xennet_max_queues as
>>> sysfs knob in frontend v.s. xenvif_max_queues in backend doesn't look
>>> very good to me -- userspace tools would need to query different knobs
>>> in frontend and backend. I think it makes sense to use a unified name in
>>> both frontend and backend.
>>>
>>> You can either use xenvif_max_queues as backend does or even just
>>> max_queues for both frontend and backend.
>> They already have to look in a different place, /sys/module/xen_netback
>> vs /sys/module/xen_netfront, so having a different param. name as well
>> isn't really a problem...
>>
>
> Cool. I think both frontend and backend use max_queues will be
> sufficient and more concise, since the path in sysfs is quite
> straightforward. Take netback as example, the existing parameter don't
> have xenvif_ prefix.
>
> Wei.
>
Ok, I've posted a V6 series which uses 'max_queues' as the module param 
for both, but retains the existing variable names within the code.

-Andrew

>> -Andrew
>>
>>>
>>> Wei.
>>>
