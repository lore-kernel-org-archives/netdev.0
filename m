From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 7/8] net: ixgbe: add support for tc_u32
 offload
Date: Wed, 17 Feb 2016 12:42:04 +0100
Message-ID: <20160217114204.GI2213@nanopsycho.orion>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051853.17139.76889.stgit@john-Precision-Tower-5810>
 <56C456C6.60308@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>, amir@vadai.me,
	davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34546 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161300AbcBQLmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 06:42:08 -0500
Received: by mail-wm0-f51.google.com with SMTP id b205so151751652wmb.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 03:42:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56C456C6.60308@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 17, 2016 at 12:17:26PM CET, jhs@mojatatu.com wrote:
>On 16-02-17 12:18 AM, John Fastabend wrote:
>>This adds initial support for offloading the u32 tc classifier. This
>>initial implementation only implements a few base matches and actions
>>to illustrate the use of the infrastructure patches.
>>
>>However it is an interesting subset because it handles the u32 next
>>hdr logic to correctly map tcp packets from ip headers using the ihl
>>and protocol fields. After this is accepted we can extend the match
>>and action fields easily by updating the model header file.
>>
>>Also only the drop action is supported initially.
>>
>>Here is a short test script,
>>
>>  #tc qdisc add dev eth4 ingress
>>  #tc filter add dev eth4 parent ffff: protocol ip \
>>	u32 ht 800: order 1 \
>>	match ip dst 15.0.0.1/32 match ip src 15.0.0.2/32 action drop
>>
>
>Note: i dont see anything that says "hw". Are you delegating ht 0x800
>for h/w only? It is the default ht; so may not be the best choice.

That is not implemented in this patchset. hw/sw/hwsw flag will be done
in a follow up. So far, the user has only possibility to enable/disable
the whole thing by ethtool feature flag.


>
>><-- hardware has dst/src ip match rule installed -->
>>
>>  #tc filter del dev eth4 parent ffff: prio 49152
>
>Would be useful to dump the installed rule so user gets to
>see kernel-assigned prio 49152. The better way
>to do this is use the handle 800::1 as opposed to prio.
>
>>  #tc filter add dev eth4 parent ffff: protocol ip prio 99 \
>>	handle 1: u32 divisor 1
>>  #tc filter add dev eth4 protocol ip parent ffff: prio 99 \
>>	u32 ht 800: order 1 link 1: \
>>	offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 6 ff
>>  #tc filter add dev eth4 parent ffff: protocol ip \
>>	u32 ht 1: order 3 match tcp src 23 ffff action drop
>>
>><-- hardware has tcp src port rule installed -->
>>
>>  #tc qdisc del dev eth4 parent ffff:
>>
>><-- hardware cleaned up -->
>>
>
>All looks cool but I am just worried about the lack of intent that
>something needs to go to hw vs sw. Other worry:
>What happens when things fail to install in hw?

Silently fail. I believe that this should be handled in the same
follow-up I referred to above.


>As it stands right now your assumption is all default rules go to h/w.
>And failure to install is not handled.
>I know Dave wants to push this in so a followup sets of patches to
>address this is fine by me. Otherwise if it is not too much work, please
>address this.
>
>cheers,
>jamal
